import { readFileSync } from "node:fs";
import { join } from "node:path";

export const name = "session-autotitle";
export const inject = ["sessionTitle"];

const CLAIM = /tasks:claim\s+([A-Za-z0-9_-]+)/;
const VENTURE = /--venture\s+([A-Za-z0-9_-]+)/;
const MAX_TITLE = 72;
const DEFAULT_MARKER = "docs/session-prompt.md";

function firstUserText(session) {
  try {
    for (const event of session.snapshotEvents()) {
      if (event?.type !== "user/message" || event.data?.source?.kind !== "user") continue;
      const text = (event.data.content ?? [])
        .filter((block) => block?.type === "text")
        .map((block) => block.text)
        .join("\n");
      if (text.trim().length > 0) return text;
    }
  } catch {
    return undefined;
  }
  return undefined;
}

function boardTitle(repoRoot, venture, id) {
  try {
    const file = join(repoRoot, "apps", venture, "docs", "tasks", "index.json");
    const board = JSON.parse(readFileSync(file, "utf8"));
    return board.tasks?.find((task) => task.id === id)?.title;
  } catch {
    return undefined;
  }
}

function renameFromClaim(ctx, exec, config) {
  if (exec?.name !== "bash") return;
  const command = exec.arguments?.command;
  if (typeof command !== "string") return;
  const claim = command.match(CLAIM);
  const venture = command.match(VENTURE)?.[1];
  if (!claim || !venture) return;
  const session = exec.agent?.session;
  if (!session) return;
  const prompt = firstUserText(session);
  const marker = config.promptMarker ?? DEFAULT_MARKER;
  if (!prompt?.includes(marker)) return;
  const taskTitle = boardTitle(config.repoRoot, venture, claim[1]);
  if (!taskTitle) return;
  const next = `${venture}/${claim[1]} — ${taskTitle}`.slice(0, MAX_TITLE);
  const current = ctx.sessionTitle.get(session);
  if (current?.title === next) return;
  if (current?.title?.startsWith(`${venture}/`)) return;
  ctx.sessionTitle.rename(session, next);
}

export function apply(ctx, config = {}) {
  if (typeof config.repoRoot !== "string") return;
  ctx.on("tools/post-execute", async (exec, result, next) => {
    const decision = await next();
    try {
      if (!result?.isError) renameFromClaim(ctx, exec, config);
    } catch (error) {
      try { ctx.logger?.warn?.(`session-autotitle: ${String(error)}`); } catch {}
    }
    return decision;
  });
}
