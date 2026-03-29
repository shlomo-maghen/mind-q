# Mind-Q — Product Requirements Document

**Version:** 1.0  
**Status:** Approved  
**Platform:** iOS · Android · Web

---

## Overview

**Mind-Q** is a frictionless capture app for interrupting thoughts. When you're deep in Task A and Task B surfaces in your mind, Mind-Q lets you log B in under 5 seconds and return immediately to A — confident you won't lose it.

> *Don't lose your train of thought. Queue it.*

---

## Problem

Context-switching is cognitive debt. You're deep in Task A. A thought hits — Task B needs to happen. You either lose A chasing B, or you lose B trying to hold onto A. Most people try to hold both in working memory. They fail.

> "The average knowledge worker switches tasks every 3 minutes. It takes 23 minutes to fully refocus."
> — Gloria Mark, UC Irvine

---

## Solution

Mind-Q is not a to-do list. It's a short-term buffer — a queue. You log the interrupting thought and go straight back to what you were doing. Later, when you're ready, you review and clear it.

**Four things it does:**

1. **One-tap capture** — Log a thought in under 5 seconds via a floating widget, lock screen shortcut, or voice input. No navigation, no friction.
2. **Stay in context** — Mind-Q doesn't pull you into a task management system. You log it and return to your current task immediately.
3. **Timed reminder** — After a configurable delay (default 1 hour), Mind-Q sends one notification: *"You have N things in your queue."* One notification per session, not one per item.
4. **Clear the queue** — Review, promote to your task manager, or dismiss. The queue stays short by design.

---

## Target Audience

Knowledge workers, developers, writers, students — anyone who works on tasks requiring sustained focus and regularly experiences mid-task interruptions.

---

## Core User Flows

### Add
1. User taps **Add** on Queue View
2. Capture sheet opens
3. User types the thought and taps **Add**
4. Item is saved; user stays on Queue View

### Quick Add
1. User taps **Quick Add** (*add and leave*) on Queue View
2. Capture sheet opens
3. User types the thought and taps **Quick Add**
4. Item is saved; app closes immediately — user returns to whatever they were doing

### Queue Review
1. Reminder notification fires
2. User opens Mind-Q
3. Queue shows all active items in FIFO order (oldest first)
4. For each item: dismiss, snooze (move to back of queue)
5. Queue clears as items are handled

### Settings & Configuration
1. Set notification time

---

## Screens

| Screen | Description | Priority |
|---|---|---|
| **Capture Sheet** | Modal sheet triggered by Add or Quick Add. Large text input, auto-focused. Confirm button matches entry point: "Add" stays in app; "Quick Add" closes the app on save. | P0 |
| **Queue View (Home)** | Vertical list, oldest on top (FIFO). Each card shows text and time logged. Two action buttons: **Add** (stays in app) and **Quick Add** with subtext *"add and leave"* (closes app after saving). Swipe left to dismiss. | P0 |
| **Settings** | Reminder delay, notification toggle, capture trigger method, integrations, theme, data management. | P0 |
| **Item Detail** | Expanded view of a single item. Editable text, notes field, promotion targets, snooze options. | P1 |
| **Onboarding (3 screens)** | Explain the concept, set up quick-capture method, configure first reminder delay. Skippable. | P1 |
| **Empty State** | Clean, encouraging. "Queue is clear. You're focused." No clutter. | P1 |

---

## Fast Capture Access

**Principle:** Quick Add must be reachable in two taps or fewer from wherever the user is, including when the app is not open.

### iOS

| Method | Behavior | Notes |
|---|---|---|
| App icon | Opens Queue View; user taps Quick Add | Default launch |
| Share Extension | Pre-fills capture sheet; closes app on confirm | Invokes Quick Add behavior |
| Siri Shortcut | Opens app to capture sheet in Quick Add mode | `mindq://quickadd` URL scheme; user sets up once in Settings > Siri |
| Back Tap (iOS 14+) | Opens app to capture sheet in Quick Add mode | User configures in Accessibility settings; document in onboarding |

*Post-MVP: Action Button (iPhone 15+ only), home screen widget.*

### Android

| Method | Behavior | Notes |
|---|---|---|
| App icon | Opens Queue View; user taps Quick Add | Default launch |
| Share Intent | Pre-fills capture sheet; closes app on confirm | `Intent.ACTION_SEND`; invokes Quick Add behavior |

*Post-MVP: Quick Settings tile (requires native TileService), home screen widget.*

### Web

| Method | Behavior | Notes |
|---|---|---|
| Quick Add button (FAB) | Always visible on Queue View | Primary entry point; never hidden by scroll |
| Keyboard shortcut `Q` / `Cmd+K` / `Ctrl+K` | Opens capture sheet in Quick Add mode | Global; active on all routes |
| Bookmarkable `/quickadd` route | Opens capture sheet in Quick Add mode | One-click browser bookmark access |

---

## Notification Behavior

- **One notification per session** — not per item
- Scheduled when the first item is added to an empty queue
- Adding more items does not reset or add timers
- Dismissing all items before the timer fires cancels the notification
- Notification reads: *"You have N things in your queue."*
- Notification is **mobile only** — web does not support scheduled local notifications

---

## Cross-Device Sync

- One account syncs across iOS, Android, and web in real time
- A user adds an item on their phone — it appears on their laptop within seconds
- Settings (reminder delay, notifications on/off) are **per-device** and not synced
- App is local-first for performance; sync is handled via Supabase Realtime

---

## Tech Stack

| Layer | Choice |
|---|---|
| UI + Logic | Flutter / Dart (single codebase, all platforms) |
| Backend | Supabase (Postgres + Auth + Realtime) |
| State | Riverpod |
| Routing | go_router |
| Notifications | flutter_local_notifications |

---

## MVP Scope

### In scope
- Add and Quick Add modes (stays in app vs. closes app after saving)
- Platform fast-capture entry points: iOS Share Extension, iOS Siri Shortcut, Android Share Intent, web keyboard shortcut, web `/quickadd` route
- Queue home screen with swipe-to-dismiss
- One configurable reminder per session (not per item)
- Settings: delay, notifications toggle, dark mode
- Cross-device sync via Supabase
- iOS, Android, and Web builds from a single codebase

### Out of scope (post-MVP)
- Home screen / lock screen widgets
- Integrations (Notion, Things 3, Linear, Obsidian)
- Context-aware capture (auto-tag based on open app)
- AI-powered grouping of related queue items
- Recurring pattern detection
- Apple Watch / Wear OS capture
- Team queues (shared thought backlog)
- Offline write queue with sync on reconnect

---

## Success Metrics

- **Capture time** — median time from app open to item saved is under 5 seconds
- **D7 retention** — 40%+ of users return within 7 days of signup
- **Queue clearance rate** — 70%+ of queued items are dismissed or promoted (not abandoned)
- **Notification opt-out rate** — below 30%

---

## Non-Functional Requirements

- Capture sheet must auto-focus the keyboard on open with no perceptible delay
- Realtime sync latency target: under 2 seconds on a normal mobile connection
- App must function on iOS 16+, Android API 26+, and modern evergreen browsers
- No user data is accessible to other users (Row-Level Security enforced at database level)
- Credentials are never committed to source control; passed as build-time environment variables

---

*Mind-Q PRD v1.0*
