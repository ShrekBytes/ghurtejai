# GHURTEJAI

**Product Specification — v1.2 Final**  
**Tour planning + experience sharing app for Bangladesh**

**Stack:** Flutter + Django REST Framework + PostgreSQL + Redis + Celery + Cloudflare R2 + JWT

**Version history:** v1.0 → v1.1 → v1.2 (merged & finalized)

## 1. Terminology (Locked)

These terms are fixed across all code, documentation, and UI copy.

| Concept                          | Term          |
|----------------------------------|---------------|
| A place to visit                 | Destination   |
| Discoverable units (places, foods, activities) | Attraction |
| Items added to a day in a journey| Entry         |
| A complete journey               | Experience    |

**Core data flow:**  
**Destination → Attractions → Entries → Experience**

## 2. Navigation — Bottom Bar

- **Explore**
- **Experiences**
- **Create**
- **Profile**

- Create tab opens the Experience builder directly — no intermediate landing page.
- Bookmarks live inside Profile — no dedicated tab.

## 3. User Roles

| Role     | Capabilities |
|----------|--------------|
| **Guest** | Browse Explore, Destinations, public Experiences. Device-only (local) bookmarks. Cannot interact or create. |
| **User**  | Full interaction: create, share, clone, bookmark, comment, upvote, submit attractions/destinations/transport. |
| **Moderator** | Approve/reject: Destinations, Attractions, Transport, public Experiences. Must provide rejection reason. No Django Admin access. Assigned by Admin. |
| **Admin** | Full approve/reject powers + Django Admin panel access. Can assign Moderator role. |

> Guest bookmarks are stored on-device only (Flutter `shared_preferences` or similar). They are not synced to the server and are lost if the app is uninstalled.

## 4. Core System Rules

### 4.1 Soft Delete (Global)

All user-generated content uses soft delete. Hard delete is never used in v1.

| Field       | Type & Behaviour |
|-------------|------------------|
| `is_deleted` | Boolean — default `False`. Filters applied at queryset level. |
| `deleted_at` | Timestamp — set on deletion, `null` otherwise. |

- Soft-deleted records are hidden from all UI and API responses.
- Retained in the database for moderation review and analytics.
- Django manager override: default queryset always filters `is_deleted=False`.

### 4.2 Rejection Reason

When a Moderator or Admin rejects any content (Destination, Attraction, Transport, or Experience), they must supply a `rejection_reason` string. This is stored on the relevant model and surfaced to the submitting user via notification.

### 4.3 Slug Fields

Destination, Experience, and Tag all carry a `slug` field (unique, auto-generated from name). Slugs are used in URLs and never exposed as raw integer PKs to the client.

### 4.4 Estimated Cost Rule

Estimated cost = sum of all entry costs where cost > 0. If no entries carry a cost, display **"N/A"**. Always labelled in the UI as **"Per person estimate"** to set correct expectations.

### 4.5 JWT Token Lifetimes

| Token          | Lifetime   |
|----------------|------------|
| Access token   | 60 minutes |
| Refresh token  | 7 days     |

Dio interceptor silently catches 401 responses, calls the refresh endpoint, and retries the original request. Only redirects to the login screen if the refresh call itself fails.

## 5. Data Models

### 5.1 Destination

| Field              | Details |
|--------------------|---------|
| `name`             | Indexed. Unique name per region (future enforcement). |
| `slug`             | Unique. Auto-generated from name. |
| `cover_image`      | Stored on Cloudflare R2. |
| `tags`             | Normalized (see Tag model). |
| `description`      | Short description. |
| `stats` (cached)   | `attraction_count`, `food_count`, `activity_count`, `experience_count` — cached in Redis. |
| `status`           | `PENDING` \| `APPROVED` |
| `rejection_reason` | String, nullable. Set when status → rejected. |
| `created_by`       | FK → User |
| `is_deleted` / `deleted_at` | Soft delete fields. |

### 5.2 Attraction

| Field              | Details |
|--------------------|---------|
| `type`             | `PLACE` \| `FOOD` \| `ACTIVITY` |
| `name`             | Display name. |
| `normalized_name`  | Lowercase, trimmed — used for deduplication checks. |
| `image`            | Stored on R2. |
| `notes`            | Free text. |
| `address`          | String. |
| `price_range`      | String (e.g. ৳100–৳300). |
| `destination`      | FK → Destination |
| `status`           | `PENDING` \| `APPROVED` |
| `rejection_reason` | String, nullable. |
| `created_by`       | FK → User |
| `is_deleted` / `deleted_at` | Soft delete fields. |

### 5.3 Transport

| Field              | Details |
|--------------------|---------|
| `destination`      | FK → Destination |
| `from_location`    | String, normalized. |
| `to_location`      | String, normalized. |
| `type`             | `BUS` \| `AC_BUS` \| `TRAIN` \| `FLIGHT` \| `OTHER` |
| `operator`         | Operator name. |
| `cost`             | Decimal. |
| `duration`         | Duration field. |
| `departure_time`   | Time field. |
| `start_point`      | String — exact boarding location. |
| `status`           | `PENDING` \| `APPROVED` |
| `rejection_reason` | String, nullable. |
| `is_deleted` / `deleted_at` | Soft delete fields. |

### 5.4 Entry

| Field              | Details |
|--------------------|---------|
| `name`             | Entry label. |
| `time`             | Time of day for this entry. |
| `cost`             | Decimal, optional. Included in estimated cost if > 0. |
| `notes`            | Free text. |
| `custom_fields`    | JSON key-value pairs for user-defined extra info. |
| `attraction`       | FK → Attraction, nullable. Links entry to a known attraction. |
| `day`              | FK → Day (nested inside Experience). |
| `is_deleted` / `deleted_at` | Soft delete fields. |

### 5.5 Experience

| Field              | Details |
|--------------------|---------|
| `title`            | String. |
| `slug`             | Unique. Auto-generated. |
| `destination`      | FK → Destination |
| `cover_image`      | Manual upload OR auto-generated 4-image collage (async via Celery → R2). |
| `estimated_cost`   | Auto-computed. Sum of entry costs > 0, else `null` (displayed as N/A). |
| `user_cost`        | Manual override — what the author actually spent. |
| `days`             | Nested array of Days, each containing Entries. |
| `status`           | `DRAFT` \| `PENDING_REVIEW` \| `PUBLISHED` |
| `visibility`       | `PRIVATE` \| `PUBLIC` |
| `rejection_reason` | String, nullable. Set when moderator rejects. |
| `author`           | FK → User |
| `cloned_from`      | FK → Experience, nullable. Stored internally, never shown in UI. |
| `is_deleted` / `deleted_at` | Soft delete fields. |

**Experience Status Flow**

| Action                          | Resulting Status |
|---------------------------------|------------------|
| Save for Myself (private)       | `DRAFT` — saved immediately, no approval. |
| Share Experience (public)       | `PENDING_REVIEW` → Moderator/Admin reviews → `PUBLISHED` (or rejected with reason). |

### 5.6 Tag

| Field     | Details |
|-----------|---------|
| `name`    | Normalized: lowercase, trimmed, deduplicated on save. |
| `slug`    | Unique. Auto-generated. |

Tags are user-created freely. No moderation required. Applied to Destinations and Experiences.

### 5.7 Comment

| Field     | Details |
|-----------|---------|
| `experience` | FK → Experience |
| `author`  | FK → User |
| `text`    | Comment body. |
| `parent`  | FK → Comment, nullable. 1-level nesting only (replies to comments, not replies to replies). |
| `upvotes` | Integer counter. |
| `downvotes` | Integer counter. |
| `is_deleted` / `deleted_at` | Soft delete. When a parent is soft-deleted, its replies are also soft-deleted. |

### 5.8 Report (Comment Reporting)

A dedicated Report model tracks user reports on comments. This gives moderators full context and supports multiple users reporting the same comment.

| Field       | Details |
|-------------|---------|
| `comment`   | FK → Comment |
| `reporter`  | FK → User |
| `reason`    | String — reported reason or category. |
| `created_at`| Timestamp. |

Unique constraint on `(comment, reporter)` — a user can only report a comment once.

### 5.9 Notification

**Types & Triggers**

| Type                     | Trigger |
|--------------------------|---------|
| `UPVOTE_EXPERIENCE`      | Someone upvotes your experience. |
| `COMMENT_ON_EXPERIENCE`  | Someone comments on your experience. |
| `REPLY_TO_COMMENT`       | Someone replies to your comment. |
| `ATTRACTION_APPROVED`    | Your attraction submission is approved. |
| `EXPERIENCE_APPROVED`    | Your experience is approved and published. |
| `EXPERIENCE_REJECTED`    | Your experience is rejected (includes `rejection_reason`). |

| Field          | Details |
|----------------|---------|
| `recipient`    | FK → User |
| `type`         | One of the types above. |
| `is_read`      | Boolean — default `False`. |
| `created_at`   | Timestamp. |

### 5.10 Bookmark

Two separate tables for cleaner queries and no polymorphic overhead:

| Table                    | Fields |
|--------------------------|--------|
| `bookmark_destinations`  | `user` (FK), `destination` (FK), `created_at`. Unique on `(user, destination)`. |
| `bookmark_experiences`   | `user` (FK), `experience` (FK), `created_at`. Unique on `(user, experience)`. |

Guest bookmarks: stored on-device only. When a guest signs up, the app prompts to migrate local bookmarks to the account on first login.

## 6. Content Moderation

| Content                  | Created By | Approved By          |
|--------------------------|------------|----------------------|
| Destination              | User       | Admin / Moderator    |
| Attraction               | User       | Admin / Moderator    |
| Transport                | User       | Admin / Moderator    |
| Experience (private)     | User       | N/A — instant save   |
| Experience (public)      | User       | Admin / Moderator    |
| Tags                     | User       | N/A — no approval needed |
| Images (R2)              | User       | N/A in v1            |

- All rejections must include a `rejection_reason` string.
- Rejected content status: `REJECTED` (added alongside existing statuses).
- Submitting user is notified of approval or rejection via in-app notification.
- Future v2: trusted users → auto-approval pathway.

## 7. Image Handling

### 7.1 Upload Safety (v1 Layer)

- File type validation — only JPEG, PNG, WebP accepted.
- File size limit — enforced server-side (recommended: 5 MB max).
- Upload rate limiting — custom DRF throttle on the image upload endpoint.
- All images stored on Cloudflare R2, served via Cloudflare CDN.

### 7.2 Experience Cover Image

- **Option A:** Manual upload by the user.
- **Option B:** Auto-generated 4-image collage from the destination's top attractions.

**Collage generation flow:**
1. User creates/shares an experience without uploading a cover.
2. Django enqueues a Celery task.
3. Celery fetches top 4 attraction images from R2.
4. Pillow stitches a 2×2 collage.
5. Collage uploaded to R2 → URL saved back to the Experience record.

## 8. Search System

### 8.1 v1 Implementation

- PostgreSQL full-text search via `django.contrib.postgres`.
- Searches across: destination names, attraction names, experience titles.
- Recent searches stored per user. Popular searches tracked globally.
- Filter by type: **All** \| **Destinations** \| **Experiences**.
- No AI search in v1.

### 8.2 Abstraction Layer

The search backend is wrapped in an abstraction layer so it can be swapped to Meilisearch or Typesense in v2 without touching the API contract. Search results are **NOT** cached in v1 — only trending and popular data are cached.

## 9. Pages & Features

### 9.1 Explore Page

- Hero carousel — popular/featured destinations.
- Search bar — searches destination names, attraction names, experience titles.
- Below bar: recent searches (per user) + global popular searches.
- Filter results by type: **All** \| **Destinations** \| **Experiences**.
- Category tag filter (horizontal scroll): #Beach #Mountain #Nature #Adventure #Food + user-created tags.
- All Destinations section (grid) with **"See all →"** link.
- Trending Experiences section (horizontal scroll, ranked by upvotes).

### 9.2 All Destinations Page

- Search bar (destination filter pre-selected).
- Filter chips: tags, division/district, days range, budget range.
- Sort: asc/desc by budget, experience count, days.
- Destination card: image collage, name, division/district, price range, experience count.
- Pagination or dynamic (infinite) loading.

### 9.3 Destination Page

- Header: cover image (collage of top attractions), name, tags.
- Quick stats: Attractions count, Food count, Activities count, Experiences count.
- Top Attractions — 2×2 grid cards (image, name, notes, address).
- Top Foods — horizontal scroll (dish name, shop, price, address, note).
- Top Activities — grid (image, name, note, address).
- Getting There — search from→to, filter by transport type, sort, result cards (operator, times, cost, start point).
- Cost & Duration estimate panel.
- Top Experiences from this destination (cards).
- CTAs: **[Create Experience]** **[Bookmark Destination]**

### 9.4 Create Experience Page

- Destination selector + title input.
- Cover image: manual upload OR trigger async collage generation (Celery).
- Day-by-day builder:
  - Each day has a date + ordered list of entries.
  - **[+ Add Entry]** → modal with attraction search (filter by Place / Food / Activity) OR **[+ Add Custom Entry]** (name, time, cost, notes, custom fields).
  - **[+ Add Day]** button at the bottom.
- Cost section: estimated cost (auto, labelled **"Per person estimate"**) + manual **"Your Cost"** field.
- Visibility toggle: Private / Public.
- Actions: **[Save for Myself]** → `DRAFT` (private, instant) \| **[Share Experience]** → `PENDING_REVIEW` (requires moderation).

### 9.5 Experiences Feed

- Cards show: cover image, title, destination, stats (entries, attractions, days, cost), tags, upvote count, comment count.
- Per-card actions: Upvote, Bookmark, Clone.
- Clone from feed: creates a full independent copy in the user's drafts immediately (no attribution shown).
- Filters: tags, destination, days range, budget range.
- Sort: **Popular** (default, by upvotes) \| **New** \| **Cost** \| **Duration**.

### 9.6 Experience Page

- Header: cover image, title, destination tag, author name (clickable → public profile).
- Stats: attractions, entries, estimated cost, days.
- Day-by-day timeline (times and costs per entry).
- Attractions highlight section.
- Actions: **[Clone]** **[Bookmark]** **[Upvote]** **[Comment]**
- Clone: full deep copy into user's drafts. No attribution shown. Fully editable.
- Comments: Reddit-style, 1-level nesting, upvote/downvote per comment, report button.

### 9.7 Profile Page

- Header: avatar, name, username.
- My Experiences grid — public experiences visible to others, private only to self.
- Bookmarks section — saved destinations + experiences, **"See all"** link.
- Settings: Language (EN/BN), Notifications on/off, Logout.
- Edit Profile deferred to v2.

### 9.8 Public Profile Page

- Accessible by tapping author name on any experience.
- Shows only the user's **PUBLISHED** experiences.
- Read-only. No settings, no bookmarks.

### 9.9 Auth Pages

- Login: email or username + password. Forgot password link.
- Register: name, username, email, password, confirm password.
- Continue as Guest option on both screens.

### 9.10 Notifications Page

- In-app only in v1 (no push notifications).
- Events: upvote on your experience, comment on your experience, reply to your comment, attraction approved, experience approved, experience rejected (with reason).
- Mark as read. Unread count badge on the Profile tab icon.

## 10. Tech Stack

### 10.1 Backend

| Component          | Technology |
|--------------------|----------|
| Framework          | Django 5.x + Django REST Framework |
| Database           | PostgreSQL |
| Caching + Rate limiting | Redis via django-redis |
| Task queue         | Celery + Redis broker |
| Auth               | JWT via djangorestframework-simplejwt |
| Image storage      | Cloudflare R2 via django-storages[s3] + boto3 |
| Image processing   | Pillow (collage generation inside Celery task) |
| Search             | django.contrib.postgres full-text search (abstracted for future swap) |
| CORS               | django-cors-headers |
| Filtering          | django-filter |
| Admin panel        | Django Admin (built-in) |
| API docs           | drf-spectacular (OpenAPI / Swagger) |
| Environment        | python-decouple |
| Throttling         | DRF built-in throttle classes, state stored in Redis |

### 10.2 Backend pip packages

```text
django  djangorestframework  djangorestframework-simplejwt  django-storages[s3]  boto3  django-redis  celery  django-cors-headers  django-filter  drf-spectacular  Pillow  psycopg2-binary  python-decouple
```

### 10.3 Frontend (Flutter)

| Component          | Technology |
|--------------------|----------|
| State management   | Riverpod (`flutter_riverpod`) |
| HTTP client        | dio |
| Auth token refresh | Dio interceptor — silently retries on 401, redirects to login only if refresh fails. |
| Auth storage       | `flutter_secure_storage` (JWT access + refresh token persistence) |
| Image handling     | `cached_network_image`, `image_picker` |
| Routing            | go_router |
| UI                 | Material 3 |
| Forms              | flutter_form_builder |
| Guest bookmarks    | `shared_preferences` (device-only, not synced) |

### 10.4 Infrastructure

| Component          | Technology |
|--------------------|----------|
| Image storage + CDN| Cloudflare R2 + Cloudflare CDN |
| Containerization   | Docker + Docker Compose |
| Web server         | Nginx (reverse proxy) |
| App server         | Gunicorn |
| Hosting            | VPS (DigitalOcean / Linode / Hetzner) or PaaS |

### 10.5 Docker Compose Services

| Service | Role |
|---------|------|
| `db`    | PostgreSQL |
| `redis` | Redis |
| `web`   | Django + Gunicorn |
| `celery`| Celery worker (separate container, same Django image) |
| `nginx` | Reverse proxy |

## 11. Redis Usage (Scoped for v1)

| Purpose                     | Details |
|-----------------------------|---------|
| Cache: trending experiences | Ranked by upvotes. Invalidated on new upvote. |
| Cache: popular destinations | Ranked by experience count + stats. Invalidated on new content. |
| Cache: destination stats    | `attraction_count`, etc. per destination. |
| Rate limiting state         | Login, register, image upload endpoints via DRF throttle classes. |
| Celery broker               | Task queue for async collage generation. |

> Search results are **NOT** cached in v1. Add caching here only after measuring real query latency in production.

## 12. API Throttling

| Throttle class      | Applied to |
|---------------------|------------|
| `AnonRateThrottle`  | All unauthenticated (guest) requests. |
| `UserRateThrottle`  | All authenticated user requests. |
| Custom throttle     | Login endpoint, Register endpoint, Image upload endpoint (stricter limits). |

## 13. Business Logic Rules

| Rule                        | Behaviour |
|-----------------------------|-----------|
| Estimated cost              | Sum of entry costs > 0. If none → display **"N/A"**. Labelled **"Per person estimate"** in UI. |
| Experience clone            | Full deep copy into user's drafts. `cloned_from` FK stored internally. No attribution shown in UI. Fully independent and editable. |
| Public experience visibility| Only **PUBLISHED** experiences appear on the feed and public profiles. |
| Soft delete — experience    | `is_deleted=True`. All child days and entries also soft-deleted. Removed from all queries. |
| Soft delete — comment with replies | `is_deleted=True` on parent comment. All replies also soft-deleted. |
| JWT expiry                  | Access: 60 min. Refresh: 7 days. Dio interceptor silently refreshes on 401. Redirects to login only if refresh fails. |
| Rejection                   | Rejection reason is mandatory. Stored on model. User notified via `EXPERIENCE_REJECTED` notification. |
| Guest bookmarks             | Device-only (`shared_preferences`). Not synced to server. App prompts migration on first login after sign-up. |
| Tag normalization           | Tags are lowercased, trimmed, and deduplicated on save. Slugs auto-generated. |
| Comment report uniqueness   | A user can only submit one Report per comment. Enforced via `unique_together` constraint. |

## 14. Deferred to v2

- AI Search — natural language query → auto-set filters → results.
- Image moderation AI — automated content safety scanning.
- Follow / follower system.
- Push notifications (in-app only for v1).
- Export experience as PDF / shareable itinerary.
- Edit Profile.
- Offline mode / local drafts.
- Reputation / trusted user system (auto-approval pathway).
- Meilisearch or Typesense swap for full-text search.

---

**GHURTEJAI — Product Spec v1.2 Final — Production-ready**