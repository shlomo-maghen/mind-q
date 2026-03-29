# Milestone 1 — Core Queue

**Status:** Planned
**Platforms:** iOS · Android · Web
**Depends on:** Nothing

---

## Goal

Ship a working Flutter application on iOS, Android, and web where a user can add items to a queue and mark them complete to remove them. No accounts, no cloud, no notifications — local state only.

---

## Goals

- [ ] App opens to Queue View showing the current queue (or empty state)
- [ ] Queue displays items in FIFO order — oldest on top, newest at bottom
- [ ] User can add an item via **Add**: capture sheet opens, user types, taps Add, stays on Queue View
- [ ] User can add an item via **Quick Add**: capture sheet opens, user types, taps Quick Add, app closes immediately
- [ ] Quick Add button has visible subtext: *"add and leave"*
- [ ] Capture sheet auto-focuses the keyboard with no perceptible delay
- [ ] User can mark an item complete (removes it from the queue)
- [ ] Empty state shown when queue has no items: *"Queue is clear. You're focused."*
- [ ] Queue state persists across app restarts (local device storage)
- [ ] App builds and runs on iOS, Android, and web from a single Flutter codebase

---

## Non-Goals

- No user accounts or authentication
- No cloud sync or backend of any kind
- No notifications of any kind
- No settings screen
- No voice input
- No swipe-to-dismiss (tap to complete is sufficient)
- No item detail or edit screen
- No onboarding screens
- No iOS Share Extension, Siri Shortcut, or Android Share Intent
- No web keyboard shortcut or `/quickadd` route
- No integrations

---

## Screens

### Queue View (Home)
- Vertical list of active queue items, oldest on top (FIFO)
- Top task is shown as largest, subsequent tasks are smaller, and grayed out. Scrolling brings tasks into focus: enlarging and changing from grayscale
- Each card: item text + relative time logged ("just now", "5 min ago")
- Two persistent action buttons: **Add** and **Quick Add** *(add and leave)*
- Complete button on each card — removes the item on tap
- Empty state: *"Queue is clear. You're focused."*

### Capture Sheet
- Modal bottom sheet, triggered by either Add or Quick Add
- Single large text input, auto-focused (keyboard opens immediately)
- Confirm button label reflects entry point:
  - "Add" → saves item, closes sheet, user stays on Queue View
  - "Quick Add" → saves item, app closes (returns user to previous app)
- Confirm button disabled when input is empty

---

## Data Model

```
QueueItem {
  id:         String   // UUID, generated locally
  text:       String
  createdAt:  DateTime
}
```

- Stored locally (e.g. `shared_preferences` — JSON-encoded list)
- No server-side schema

---

## Tech

| Layer | Choice |
|---|---|
| UI + Logic | Flutter / Dart |
| State | Riverpod |
| Routing | go_router |
| Local persistence | shared_preferences |

---

## Acceptance Criteria

1. Opening the app shows Queue View with existing items or empty state
2. Items appear in FIFO order (oldest first)
3. Tapping **Add** opens the capture sheet; keyboard is focused immediately
4. Typing text and tapping "Add" saves the item and returns to Queue View
5. Typing text and tapping "Quick Add" saves the item and closes the app
6. Quick Add button has *"add and leave"* subtext visible at all times
7. Tapping the complete button on an item removes it instantly
8. Closing and reopening the app retains all queue items
9. App builds and runs on iOS simulator, Android emulator, and Chrome
