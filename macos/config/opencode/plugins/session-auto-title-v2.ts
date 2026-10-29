import type { Plugin } from "@opencode/plugin"

// V2 uses the same default titles as V1:
//   New session - 2026-01-01T00:00:00.000Z
//   Child session - 2026-01-01T00:00:00.000Z
const defaultTitlePattern =
  /^(New session|Child session) - \d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z$/

function isDefaultTitle(title: string | undefined): boolean {
  return !title || defaultTitlePattern.test(title)
}

function extractTitle(text: string): string {
  const lines = text.split("\n").filter((line) => line.trim().length > 0)
  if (lines.length === 0) {
    return "New Session"
  }

  let title = lines[0]!.trim()

  const maxLength = 50
  if (title.length > maxLength) {
    title = title.slice(0, maxLength - 3) + "..."
  }

  return title || "New Session"
}

function majorVersion(version: string): number {
  const match = version.match(/\d+/)
  return match ? Number.parseInt(match[0], 10) : 0
}

const plugin = {
  id: "session-auto-title-v2",
  setup(ctx: Plugin.Context) {
    // V2 only: OpenCode 1.x calls server() instead of setup().
    if (majorVersion(ctx.app.version) < 2) {
      return
    }

    const controller = new AbortController()

    // The V1 plugin listened to message.part.updated and used the first text
    // part of the session. In V2 the equivalent event is the user prompt
    // entering the session inbox.
    void (async () => {
      for await (const event of ctx.event.subscribe({
        types: ["session.inbox.enqueued"],
        signal: controller.signal,
      })) {
        try {
          const item = event.data.item
          if (item.type !== "user") {
            continue
          }

          const sessionID = event.data.sessionID
          const session = await ctx.session.get({ sessionID })
          if (!isDefaultTitle(session.title)) {
            continue
          }

          await ctx.session.update({
            sessionID,
            title: extractTitle(item.payload.text),
          })
        } catch (error) {
          console.error("[session-auto-title-v2] failed to update session title", error)
        }
      }
    })().catch((error) => {
      if (!controller.signal.aborted) {
        console.error("[session-auto-title-v2] event subscription failed", error)
      }
    })

    return () => controller.abort()
  },
  // OpenCode 1.x calls server() on the default object. The V2 implementation
  // must stay inactive there, so return an empty hooks object.
  async server() {
    return {}
  },
}

export default plugin
