# Handoff Prompt — Family OKR Tracker

Use this prompt when starting a new Claude Code session on your MacBook to continue work on this project.

---

## How to Use

1. On your MacBook, install Claude Code CLI:
   ```bash
   npm install -g @anthropic-ai/claude-code
   ```

2. Clone this repo and check out the branch:
   ```bash
   git clone <your-repo-url>
   cd Hello-World
   git checkout claude/family-okr-tracking-app-CfzxQ
   ```

3. Start Claude Code from the repo root:
   ```bash
   claude
   ```

4. Paste the prompt below as your first message.

---

## Paste This as the First Message

```
I'm continuing work on a Family OKR Tracker project. Please start by reading
the full design spec at FamilyOKR/docs/DESIGN.md — it contains all the
architecture, data model, UX/UI, and implementation decisions we finalized
in a previous session.

Context summary:
- Native app: SwiftUI for iOS + macOS
- Sync: iCloud (CloudKit) as single source of truth
- Yearly OKR cycle (not quarterly)
- Family members update progress via a Lark group chat bot
- Lark bot + LLM agent hosted on a VPS (Node.js/TypeScript)
- VPS writes to CloudKit via Server-to-Server API
- LLM uses a Claude-compatible API (e.g., Claude Haiku) for natural language parsing
- App UI follows Apple HIG — Fitness/Reminders/Stocks style
- Avatars are initials in colored circles (no emoji)
- Scope: no Apple Watch, no app push notifications in v1
- Widgets: small + medium home screen widgets

Important: The existing code in FamilyOKR/FamilyOKR/ is an EARLIER draft from
before we finalized the design. It uses quarterly periods and local-only
SwiftData. It needs to be refactored to match DESIGN.md:
- Change OKRPeriod from quarters to years
- Add CloudKit sync to SwiftData container
- Replace emoji avatars with initials+colored-circle components
- Add Activity Feed screen
- Add Lark User ID field to FamilyMember
- Add ActivityLog model
- Remove sample-data loader (we're not shipping sample data)
- Add onboarding flow
- Restructure project: move app code into /app subdirectory, prepare /server
  subdirectory for the Node.js VPS code later

Phase 1 goal: Refactor the SwiftUI app per DESIGN.md and get it compiling
and running in the iOS Simulator and macOS. You have full access to Xcode
on this Mac — please build it and verify it runs, iterate on the UI using
simulator screenshots, and don't report completion until you've seen it
actually working.

Phase 2 (later): Build the Node.js VPS with Lark bot + LLM agent.

Please read DESIGN.md first, then propose a concrete plan for Phase 1
refactoring before making changes. Confirm with me before executing.
```

---

## What the Next Session Will Have Access To on Your Mac

- **Xcode** — full iOS/macOS toolchain
- **xcodebuild** — command-line build
- **xcrun simctl** — iOS Simulator control (boot, install, screenshot)
- **Swift Package Manager** — dependency management
- **Node.js + npm** — for VPS work later

The Claude session can:
- Compile the app with `xcodebuild`
- Boot a simulator and install the app
- Take screenshots with `xcrun simctl io booted screenshot out.png`
- Read those screenshots to see the real UI
- Iterate visually until the design is right

---

## Files the Next Session Should Read First

1. `FamilyOKR/docs/DESIGN.md` — full design spec (architecture, data model, UX/UI)
2. `FamilyOKR/FamilyOKR/` — current code (earlier draft, needs refactor)
3. `README.md` — repo overview

---

## Key Decisions Already Made (Do Not Re-Litigate)

- **Platform:** SwiftUI, iOS 17+ and macOS 14+
- **Storage:** SwiftData with CloudKit sync
- **Cycle:** Yearly OKRs (not quarterly or monthly)
- **Integration:** Lark bot via VPS (Node.js/TypeScript)
- **LLM:** Claude-compatible API, low-cost model (Haiku)
- **Sync strategy:** iCloud is source of truth, VPS writes via CloudKit S2S API
- **OKR management:** App-only (bot cannot create/edit objectives)
- **Bot interaction:** Family group chat, natural language, English
- **UI style:** Apple HIG, no custom chrome, initials-in-circles avatars
- **Scope v1:** No Apple Watch, no app push notifications
- **Widgets:** Small + medium home screen widgets included

---

## Open Questions for You to Decide Later

- Bundle ID and Apple Developer Team ID (needs to be set in Xcode)
- CloudKit container name (suggest: `iCloud.com.yourteam.familyokr`)
- VPS hosting provider for Phase 2
- Lark app credentials (already exist per your setup)
