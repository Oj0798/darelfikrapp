# Dar El Fikr Subscription Gating Audit

This report audits interaction and gating behavior across:
- `category_books_screen.dart`
- `search_screen.dart`
- `reader_screen.dart`
- `subscription_screen.dart`

## Interaction map

1. Category/Search flows open `VolumesScreen` from `category_books_screen.dart`.
2. `VolumesScreen` opens `ReaderScreen` and forwards `requiredTags`.
3. `ReaderScreen` enforces free preview (`freePages`) and tier-based lock after preview.
4. `SubscriptionScreen` currently returns a selected tier, but does not persist `df_is_subscribed=true`.

## Key issues

### 1) Access check allows non-subscribed users into restricted works (work/volume level)
- Current check in category/volume is `if (_isSubscribed && !_hasAccess(...))`, meaning *unsubscribed* users bypass this check and can open any work/volume until Reader lock.
- If product requirement is “block access beyond preview,” this is acceptable at reader level, but inconsistent with an expected “restricted work” gate in listing flows.

### 2) Search flow misses pre-reader access check entirely
- `search_screen.dart` routes straight to `VolumesScreen` without checking if selected work is outside current tier.
- This creates inconsistent UX vs category flow where checks exist.

### 3) Subscription activation mismatch (`df_is_subscribed` not set in SubscriptionScreen)
- `SubscriptionScreen` writes only tier and pops.
- Screens that depend on `df_is_subscribed` may still treat user as unsubscribed until Reader-specific save logic runs.

### 4) Debounced search race condition
- `_onChanged` issues async `repo.searchWorks(q)` calls without request ordering or stale response protection.
- Slow old response can overwrite newer query results.

### 5) Search loading indicator can stay stuck when query cleared
- In empty query branch, `_results` is cleared but `_loading` is not reset to false.

### 6) Reader lock page logic can show previous free page only
- When locked, content is forced to `widget.freePages` instead of current attempted page.
- This is defensible for preview UX, but inconsistent with “you tried to move past preview”.

### 7) Shared gating logic duplicated in three places
- `_grantedTagsForTier` and `_hasAccess` are duplicated in Category, Volumes, and Reader, increasing drift risk.

## Suggested fixes (high level)

1. Normalize gating function in shared utility (single source of truth).
2. In list/search/volume taps, if subscribed + no entitlement -> show upgrade; optionally allow preview entry for unsubscribed consistently.
3. On successful subscription selection, persist both tier and `df_is_subscribed=true`.
4. Add stale-response token in search debounce path.
5. Ensure `_loading=false` when query clears.
