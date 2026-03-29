# Milestone 2 — Notifications & Settings

**Status:** Planned
**Platforms:** iOS · Android (notifications); Web (settings UI only)
**Depends on:** Milestone 1

---

## Goal

Add a settings screen where users can toggle notifications on or off. When enabled, a single local notification fires after a configurable delay once the first item is added to an empty queue. One notification per session — not one per item.

---

## Goals

- [ ] Settings screen is accessible from Queue View (e.g. gear icon)
- [ ] User can toggle notifications on or off
- [ ] User can set a reminder delay: 15 min / 30 min / 1 hr / 2 hr / 4 hr (default: 1 hr)
- [ ] After last item added, a notification is scheduled for `now + delay`
- [ ] Adding more items to a non-empty queue resets the notification timer.
- [ ] Clearing all items before the timer fires cancels the scheduled notification
- [ ] Notification reads: *"You have N things in your queue."*
- [ ] Toggling notifications off cancels any pending notification immediately
- [ ] Settings persist across app restarts (local, per-device)

---

## Non-Goals

- No per-item notifications
- No push notifications (local only)
- No notification sound or vibration customization
- No notification history
- No snooze action from the notification
- No sync of settings across devices
- No accounts or cloud (deferred to Milestone 3)
- No iOS Share Extension, Siri Shortcut, or Android Share Intent (deferred)

---

## Screens

### Settings Screen
| Setting | Type | Default |
|---|---|---|
| Notifications enabled | Toggle | Off |
| Reminder delay | Selector (15 min / 30 min / 1 hr / 2 hr / 4 hr) | 1 hr |

- Stored locally per device; not synced

---

## Notification Behavior

| Event | Result |
|---|---|
| First item added to empty queue | Schedule one notification at `now + delay` |
| Additional items added (queue non-empty) | Reset timer to `now + delay` |
| All items dismissed before timer fires | Cancel the scheduled notification |
| Timer fires | Show: *"You have N things in your queue."* |
| Notifications toggled off | Cancel any pending notification immediately |
| Delay setting changed | Takes effect on next scheduled notification only |

---

## Data Model Changes

No changes to `QueueItem`. New persisted settings:

```
NotificationSettings {
  enabled:      bool   // default: false
  delayMinutes: int    // default: 60
}
```

---

## Tech

| Layer | Choice |
|---|---|
| Local notifications | flutter_local_notifications |
| Settings persistence | shared_preferences (same store as M1) |
| Platform guard | `kIsWeb` check to suppress notification UI on web |

---

## Acceptance Criteria

1. Settings screen is reachable from Queue View
2. Notifications toggle and delay selector are functional on iOS and Android
3. On web, the notification setting is absent or clearly marked unsupported
4. With notifications on and 15-min delay: adding the first item schedules a notification 15 min out
5. Adding a second item does not create a second notification
6. Dismissing all items before 15 min cancels the notification
7. Notification reads *"You have N things in your queue."* with the correct count
8. Toggling notifications off cancels any pending notification
9. Settings survive app restart
