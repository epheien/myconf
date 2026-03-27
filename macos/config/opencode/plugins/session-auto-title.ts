import type { Plugin } from "@opencode-ai/plugin"
import type { Event, EventMessagePartUpdated } from "@opencode-ai/sdk"
import fs from "fs/promises"

const logFile = "opencode-session-title.log"

function log(...args: any[]) {
  const message = args
    .map((arg) => {
      if (typeof arg === "object") {
        return JSON.stringify(arg, null, 2)
      }
      return String(arg)
    })
    .join(" ")
  const timestamp = new Date().toISOString()
  fs.appendFile(logFile, `[${timestamp}] ${message}\n`).catch(() => { })
}

const parentTitlePrefix = "New session - "
const childTitlePrefix = "Child session - "
const defaultTitlePattern = new RegExp(
  `^(${parentTitlePrefix}|${childTitlePrefix})\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}\\.\\d{3}Z$`,
)

function isDefaultTitle(title: string): boolean {
  return defaultTitlePattern.test(title)
}

function extractTitle(text: string): string {
  const lines = text.split("\n").filter((line) => line.trim().length > 0)
  if (lines.length === 0) {
    return "New Session"
  }

  let title = lines[0]!.trim()

  //title = title.replace(/^(请|帮我|可以|能否|我需要|我想|我要|帮我?，?)/, "")
  //title = title.replace(/^[#@＃＠]\s*/, "")
  //title = title.replace(/^(help|please|can you|could you|i need|i want|help me,?\s*)/i, "")

  const maxLength = 50
  if (title.length > maxLength) {
    title = title.slice(0, maxLength - 3) + "..."
  }

  return title || "New Session"
}

export const OpenCodeSessionTitle: Plugin = async (ctx) => {
  return {
    event: async ({ event }: { event: Event }) => {
      //log("event:", event.type)

      if (event.type !== "message.part.updated") {
        return
      }

      const partEvent = event as EventMessagePartUpdated
      const part = partEvent.properties.part

      if (part.type !== "text") {
        return
      }

      if ("synthetic" in part && part.synthetic) {
        return
      }

      const sessionID = part.sessionID
      const session = await ctx.client.session.get({
        path: {
          id: sessionID,
        },
      })

      const currentTitle = session.data?.title || ""
      if (!isDefaultTitle(currentTitle)) {
        return
      }

      const title = extractTitle(part.text)
      await ctx.client.session.update({
        path: {
          id: sessionID,
        },
        body: {
          title,
        },
      })
    },
  }
}

export default OpenCodeSessionTitle
