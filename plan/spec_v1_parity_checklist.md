# Ghurtejai v1 spec parity checklist

Cross-reference: [ghurtejai_plan_final.md](ghurtejai_plan_final.md) sections 1–14. §15 items are **out of scope**.

Legend: OK = implemented | PARTIAL | GAP

## §1–2 Terminology & navigation

| Item | Status | Notes |
|------|--------|--------|
| Terms: Destination, Attraction, Entry, Day, Experience | OK | Used in backend + Flutter |
| Bottom tabs: Explore, Experiences, Create, Profile | OK | `main_shell.dart` / router |
| Create: no landing; guests → sign-in dialog | OK | `create_tab_screen.dart`, `guest_gate.dart` |
| Bookmarks in Profile only | OK | Profile tabs |

## §3–4 Roles & system rules

| Item | Status | Notes |
|------|--------|--------|
| Guest read-only + prompts | OK | `guest_gate`, API `AllowAny` reads |
| Soft delete + `all_objects` | OK | `core/models.py`, cascade rules |
| Slugs for Destination, Experience, Tag | OK | Models |
| JWT 60m / 7d | OK | `settings/base.py` SIMPLE_JWT |
| Rejection reason on reject | OK | Moderation serializers/views |

## §5 Data models

| Item | Status | Notes |
|------|--------|--------|
| Division/District fixtures | PARTIAL | Verify seed data completeness (8/64) |
| Experience statuses & flow | OK | Serializers `update` PENDING→DRAFT |
| Vote, Comment, CommentVote, Report | OK | `interactions` |
| Bookmarks split tables | OK | |
| Notifications types | OK | `notifications` app |
| RecentSearch (10 max) | OK | `search/signals.py` |
| PopularSearch | OK | |

## §6–7 Moderation & images

| Item | Status | Notes |
|------|--------|--------|
| Moderation queue (dest, attr, transport, exp) | OK | Backend + Flutter 4 tabs |
| Image upload + throttle | OK | `ImageUploadView` |
| Cover collage Celery | OK | `experiences/tasks.py` |

## §8 Search

| Item | Status | Notes |
|------|--------|--------|
| SearchBackend + PgSearchBackend | OK | `search/backends.py` |
| Recent + popular suggestions | OK | |
| Filter type all/destinations/experiences/attractions | OK | API `type` param |

## §9 Pages (Flutter)

| Item | Status | Notes |
|------|--------|--------|
| Explore: search, tags, destinations, recent exp | OK | `explore_screen.dart` |
| Experience card anatomy | OK | `feed_cards.dart` |
| Experiences feed tabs For You / Popular / Budget | OK | `experiences_screen.dart` |
| Create multi-step builder | OK | `create_experience_screen.dart` (+ split widgets) |
| Profile: guest vs auth, bookmarks sub-tabs | OK | `profile_screen.dart` |
| Notifications | OK | |
| Auth login/register | OK | Error messages via `api_error.dart` |

## §10 Empty & error states

| Item | Status | Notes |
|------|--------|--------|
| Shimmer on load | PARTIAL | Explore shimmer; some lists use spinner |
| Network error + retry | OK | Explore; extend as needed |

## §11–14 Tech, Redis, throttles, business rules

| Item | Status | Notes |
|------|--------|--------|
| Stack (Django, DRF, Postgres, Redis, Celery, JWT) | OK | |
| DRF throttles | OK | `core/throttles.py` |
| Clone, estimated cost, tag rules | OK | See serializers + signals |

## Backend one-offs addressed in parity pass

| Item | Status | Notes |
|------|--------|--------|
| Transport detail GET public read (approved) | OK | `TransportDetailView` GET AllowAny |

---

## QA notes (implementation pass)

- **Auth:** Register/login errors use `formatApiError` ([`frontend/lib/core/network/api_error.dart`](frontend/lib/core/network/api_error.dart)).
- **Backend:** Transport detail GET allows anonymous read of approved rows; authenticated users also see own pending ([`backend/apps/destinations/views.py`](backend/apps/destinations/views.py) `TransportDetailView`).
- **Create flow:** `EntryDraft` / `DayDraft` live in [`create_experience_drafts.dart`](frontend/lib/features/create/presentation/create_experience_drafts.dart); builder UI remains in [`create_experience_screen.dart`](frontend/lib/features/create/presentation/create_experience_screen.dart) with `formatApiError` on save/upload failures.
- **Analyzer:** `dart analyze` clean on touched Flutter paths (only deprecation infos on older Radio APIs in builder).

---

_Last updated: parity implementation pass._
