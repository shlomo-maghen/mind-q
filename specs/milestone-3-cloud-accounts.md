# Milestone 3 — Cloud Sync & Accounts

**Status:** Planned
**Platforms:** iOS · Android · Web
**Depends on:** Milestone 1, Milestone 2

---

## Goal

Introduce user accounts so that queue items are persisted in the cloud and synced in real time across all of a user's devices. Local items from earlier milestones are migrated to the cloud on first sign-in.

---

## Goals

- [ ] User can create an account (email + password) and sign in
- [ ] User can sign out; app returns to local-only mode
- [ ] Queue items are stored in Supabase and synced in real time across devices
- [ ] Adding an item on one device appears on all other signed-in devices within ~2 seconds
- [ ] Completing an item on one device removes it on all other signed-in devices within ~2 seconds
- [ ] On first sign-in, locally stored queue items are migrated to the cloud account
- [ ] Row-Level Security (RLS) ensures no user can read or write another user's data
- [ ] Settings remain per-device and are not synced
- [ ] App functions in degraded local mode when offline; syncs on reconnect

---

## Non-Goals

- No OAuth / social login (Google, Apple, GitHub) — email + password only
- No account deletion or data export
- No shared or team queues
- No syncing of notification settings across devices
- No conflict resolution for simultaneous edits (last-write-wins is acceptable)
- No guaranteed offline write queue (best-effort sync only)
- No integrations

---

## Screens

### Sign In Screen
- Email + password fields
- **Sign in** primary button
- **Create account** link → Sign Up screen
- **Continue without account** link → local-only mode

### Sign Up Screen
- Email, password, confirm password fields
- **Create account** button
- On success: signed in, taken to Queue View

### Account Section in Settings
- Shows signed-in email
- **Sign out** button
- When signed out: **Sign in** and **Create account** links

---

## Data Model

### Supabase — `queue_items` table

```sql
create table queue_items (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null references auth.users(id) on delete cascade,
  text         text not null,
  created_at   timestamptz not null default now(),
  completed_at timestamptz  -- null = active; set = completed (soft delete)
);

alter table queue_items enable row level security;

create policy "Users can only access their own items"
  on queue_items for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
```

- Active queue = rows where `completed_at is null`, ordered by `created_at asc` (FIFO)
- Hard deletion deferred to a future milestone

### Local migration on first sign-in
1. Read all items from local storage
2. Insert each into Supabase under the authenticated `user_id`
3. Clear local storage
4. Operate from Supabase going forward

---

## Sync Architecture

- **Local-first:** app renders from an in-memory cache of the user's items
- **Realtime:** Supabase Realtime pushes INSERT / UPDATE events to all connected clients
- **Write path:** writes go to Supabase; Realtime event updates the local cache on all devices
- **Offline:** writes queued locally (best-effort); sync resumes on reconnect

---

## Security Requirements

- RLS enforced at the database level — not just in app code
- Supabase anon key is safe to ship in the client (RLS is the enforcement layer)
- Supabase service role key is never used or exposed in client code
- All data in transit encrypted via TLS

---

## Tech

| Layer | Choice |
|---|---|
| Auth | Supabase Auth (email + password) |
| Database | Supabase Postgres |
| Realtime | Supabase Realtime |
| Flutter client | supabase_flutter |
| State | Riverpod |

Credentials (Supabase URL, anon key) passed as build-time environment variables — never committed to source control.

---

## Acceptance Criteria

1. New user can create an account with email + password
2. After sign-in, queue is loaded from Supabase
3. Item added on Device A appears on Device B within 2 seconds (both online)
4. Item completed on Device A is removed on Device B within 2 seconds
5. Signing out clears in-memory cloud state; app shows empty local queue
6. Local items present before sign-in are migrated on first sign-in and not lost
7. A signed-in user cannot read or modify another user's items (RLS enforced)
8. Adding an item while offline, then reconnecting, results in the item syncing to the cloud
9. Notification settings are not synced — each device retains its own
