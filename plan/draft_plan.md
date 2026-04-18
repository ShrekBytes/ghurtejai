# GHURTEJAI

**Product Specification — v1.3 (Matches Current Implementation)**  
**Tour planning + experience sharing app for Bangladesh**

**Stack:** Flutter + Django REST Framework + PostgreSQL + Redis + Celery + Cloudflare R2 + JWT

**Version history:** v1.0 → v1.1 → v1.2 → v1.3 (updated to match built implementation)

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

- Create tab opens the Experience builder directly — no intermediate landing page. Guests are prompted to sign in via a dialog.
- Bookmarks live inside Profile (tabbed layout) — no dedicated tab.

## 3. User Roles

| Role     | Capabilities |
|----------|--------------|
| **Guest** | Browse Explore, Destinations, public Experiences. Cannot bookmark, interact, or create. Prompted to sign in for any action that requires authentication. |
| **User**  | Full interaction: create, share, clone, bookmark, comment, upvote, submit attractions/destinations/transport. |
| **Moderator** | Approve/reject: Destinations, Attractions, Transport, public Experiences. Must provide rejection reason. No Django Admin access. Assigned by Admin. |
| **Admin** | Full approve/reject powers + Django Admin panel access. Can assign Moderator role. |

> Guest users do **not** have local/device bookmarks. Bookmarking requires signing in. This was simplified from the original plan.

## 4. Core System Rules

### 4.1 Soft Delete (Global)

All user-generated content uses soft delete. Hard delete is never used in v1.

| Field       | Type & Behaviour |
|-------------|------------------|
| `is_deleted` | Boolean — default `False`. Filters applied at queryset level. |
| `deleted_at` | Timestamp — set on deletion, `null` otherwise. |

- Soft-deleted records are hidden from all UI and API responses.
- Retained in the database for moderation review and analytics.
- Django manager override: default queryset always filters `is_deleted=False`. An `all_objects` manager provides access to all records including deleted ones.

### 4.2 Rejection Reason

When a Moderator or Admin rejects any content (Destination, Attraction, Transport, or Experience), they must supply a `rejection_reason` string. This is stored on the relevant model and surfaced to the submitting user via notification.

### 4.3 Slug Fields

Destination, Experience, and Tag all carry a `slug` field (unique, auto-generated from name). Slugs are used in URLs and never exposed as raw integer PKs to the client.

### 4.4 Estimated Cost Rule

Estimated cost = sum of all entry costs where cost > 0. If no entries carry a cost, display **"N/A"**. Always labelled in the UI as a cost estimate.

### 4.5 JWT Token Lifetimes

| Token          | Lifetime   |
|----------------|------------|
| Access token   | 60 minutes |
| Refresh token  | 7 days     |

Dio interceptor silently catches 401 responses, calls the refresh endpoint, and retries the original request. Only redirects to the login screen if the refresh call itself fails.

## 5. Data Models

### 5.1 Division & District (Geography)

| Model      | Fields |
|------------|--------|
| `Division` | `name`, `name_bn` |
| `District` | `name`, `name_bn`, `division` (FK → Division) |

Pre-seeded with all 8 divisions and 64 districts of Bangladesh via fixture data.

### 5.2 Destination

| Field              | Details |
|--------------------|---------|
| `name`             | Indexed. |
| `slug`             | Unique. Auto-generated from name. |
| `description`      | Short description. |
| `cover_image`      | Stored on Cloudflare R2. |
| `district`         | FK → District (nullable). Provides division info via district.division. |
| `latitude`         | Decimal (9,6). Nullable. |
| `longitude`        | Decimal (9,6). Nullable. |
| `tags`             | M2M → Tag. |
| `status`           | `PENDING` \| `APPROVED` \| `REJECTED` |
| `rejection_reason` | String, nullable. Set when status → rejected. |
| `created_by`       | FK → User |
| `is_deleted` / `deleted_at` | Soft delete fields. |

Stats (`attraction_count`, `experience_count`) are computed via `SerializerMethodField` at query time, not cached.

### 5.3 Attraction

| Field              | Details |
|--------------------|---------|
| `type`             | `PLACE` \| `FOOD` \| `ACTIVITY` |
| `name`             | Display name. |
| `normalized_name`  | Lowercase, trimmed — set automatically on save for deduplication. |
| `image`            | Stored on R2. |
| `notes`            | Free text. |
| `address`          | String. |
| `price_range`      | String (e.g. ৳100–৳300). |
| `destination`      | FK → Destination |
| `status`           | `PENDING` \| `APPROVED` \| `REJECTED` |
| `rejection_reason` | String, nullable. |
| `created_by`       | FK → User |
| `is_deleted` / `deleted_at` | Soft delete fields. |

### 5.4 Transport

| Field              | Details |
|--------------------|---------|
| `destination`      | FK → Destination |
| `from_location`    | String. |
| `to_location`      | String. |
| `type`             | `BUS` \| `AC_BUS` \| `TRAIN` \| `FLIGHT` \| `OTHER` |
| `operator`         | Operator name. |
| `cost`             | Decimal. |
| `duration`         | Duration field. |
| `departure_time`   | Time field. |
| `start_point`      | String — exact boarding location. |
| `status`           | `PENDING` \| `APPROVED` \| `REJECTED` |
| `rejection_reason` | String, nullable. |
| `is_deleted` / `deleted_at` | Soft delete fields. |

### 5.5 Entry

| Field              | Details |
|--------------------|---------|
| `name`             | Entry label. |
| `time`             | Time of day for this entry. |
| `cost`             | Decimal, optional. Included in estimated cost if > 0. |
| `notes`            | Free text. |
| `attraction`       | FK → Attraction, nullable. Links entry to a known attraction. |
| `day`              | FK → Day (nested inside Experience). |
| `position`         | Integer. Order within the day. |
| `is_deleted` / `deleted_at` | Soft delete fields. |

### 5.6 Experience

| Field              | Details |
|--------------------|---------|
| `title`            | String. |
| `slug`             | Unique. Auto-generated. |
| `description`      | Text. |
| `destination`      | FK → Destination |
| `cover_image`      | Manual upload OR auto-generated 4-image collage (async via Celery → R2). |
| `estimated_cost`   | Auto-computed. Sum of entry costs > 0, else `null` (displayed as N/A). |
| `user_cost`        | Manual override — what the author actually spent. |
| `days`             | Nested: Days → Entries. Each Day has a `position` and optional `date`. |
| `status`           | `DRAFT` \| `PENDING_REVIEW` \| `PUBLISHED` \| `REJECTED` |
| `visibility`       | `PRIVATE` \| `PUBLIC` |
| `rejection_reason` | String, nullable. Set when moderator rejects. |
| `author`           | FK → User |
| `cloned_from`      | FK → Experience, nullable. Stored internally, never shown in UI. |
| `tags`             | M2M → Tag. |
| `is_deleted` / `deleted_at` | Soft delete fields. |

**Experience Status Flow**

| Action                          | Resulting Status |
|---------------------------------|------------------|
| Save for Myself (private)       | `DRAFT` — saved immediately, no approval. |
| Share Experience (public)       | `PENDING_REVIEW` → Moderator/Admin reviews → `PUBLISHED` (or `REJECTED` with reason). |

### 5.7 Tag

| Field     | Details |
|-----------|---------|
| `name`    | Normalized: lowercase, trimmed, deduplicated on save. |
| `slug`    | Unique. Auto-generated. |

Tags are user-created freely. No moderation required. Applied to Destinations and Experiences.

### 5.8 Vote (Experience Upvote)

| Field          | Details |
|----------------|---------|
| `user`         | FK → User |
| `experience`   | FK → Experience |
| `created_at`   | Timestamp. |

One vote per user per experience. Enforced via `unique_together(user, experience)`. Upvote only — no downvotes on experiences.

### 5.9 Comment

| Field     | Details |
|-----------|---------|
| `experience` | FK → Experience |
| `author`  | FK → User |
| `text`    | Comment body. |
| `parent`  | FK → Comment, nullable. 1-level nesting only (replies to comments, not replies to replies). |
| `is_deleted` / `deleted_at` | Soft delete. When a parent is soft-deleted, its replies are also soft-deleted. |

Comment score is computed from the `CommentVote` model (see below).

### 5.10 CommentVote (Reddit-style)

| Field       | Details |
|-------------|---------|
| `user`      | FK → User |
| `comment`   | FK → Comment |
| `value`     | SmallInt: `+1` (upvote) or `-1` (downvote). |
| `created_at`| Timestamp. |

Unique constraint on `(user, comment)`. Comment `score` = sum of upvotes minus downvotes, computed as a property on the Comment model.

### 5.11 Report (Comment Reporting)

| Field       | Details |
|-------------|---------|
| `comment`   | FK → Comment |
| `reporter`  | FK → User |
| `reason`    | String — reported reason or category. |
| `created_at`| Timestamp. |

Unique constraint on `(comment, reporter)` — a user can only report a comment once.

### 5.12 Notification

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

Notifications are created automatically via Django signals.

### 5.13 Bookmark

Two separate tables for cleaner queries:

| Table                    | Fields |
|--------------------------|--------|
| `bookmark_destinations`  | `user` (FK), `destination` (FK), `created_at`. Unique on `(user, destination)`. |
| `bookmark_experiences`   | `user` (FK), `experience` (FK), `created_at`. Unique on `(user, experience)`. |

Bookmarking requires authentication — guests are prompted to sign in.

### 5.14 UserProfile

| Field     | Details |
|-----------|---------|
| `user`    | OneToOne → User |
| `bio`     | Text, blank. |
| `avatar`  | Image, stored on R2. |

Created alongside the user on registration.

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
- Status values include `REJECTED` alongside `PENDING` / `APPROVED` (or `PUBLISHED` for experiences).
- Submitting user is notified of approval or rejection via in-app notification.

## 7. Image Handling

### 7.1 Upload Safety (v1 Layer)

- File type validation — only JPEG, PNG, WebP accepted.
- File size limit — enforced server-side.
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
- Filter by type: **All** | **Destinations** | **Experiences**.

### 8.2 Abstraction Layer

The search backend is wrapped in an abstraction layer (`SearchBackend` base class with `PgSearchBackend` implementation) so it can be swapped to Meilisearch or Typesense in v2 without touching the API contract. Search results are **NOT** cached in v1.

## 9. Pages & Features

### 9.1 Explore Page

- Floating/snapping SliverAppBar with branded "Ghurtejai" logo.
- Search bar ("Where do you want to go?") → opens `showSearch` delegate with recent + popular suggestions.
- Horizontal tag chips: #beach #mountain #nature #adventure #food + user-created tags.
- **Destinations** section — horizontal scroll of destination cards (image with gradient overlay, name, district, stats). "See all →" link to All Destinations.
- **Recent Experiences** section — Twitter-style experience cards (avatar, author, title, description, destination chip, engagement actions). "See all →" link to Experiences feed.
- Pull-to-refresh on the entire page.
- Notification bell in the app bar.

### 9.2 All Destinations Page

- Filter by: division, district, tag (via `django-filter`).
- Sort by: name, created date.
- Destination cards with cover image, name, district, attraction + experience counts.
- Pagination via DRF `StandardResultsPagination`.

### 9.3 Destination Detail Page

- Header: cover image, name, tags, district/division info, coordinates.
- Attractions list (approved only): type, name, notes, address, price range.
- Transport options (approved only): from → to, type, operator, cost, duration, departure time, start point.
- Related experiences from this destination.
- Created by info.

### 9.4 Create Experience Page

- Destination selector (dropdown of approved destinations) + title input.
- Day-by-day builder:
  - Each day has an ordered list of entries.
  - Each entry: name, time, cost, notes.
  - **[+ Add Entry]** and **[+ Add Day]** buttons.
- Visibility toggle: Private / Public.
- Submit → `DRAFT` (private) or `PENDING_REVIEW` (public).
- Guests are blocked before navigation: the MainScaffold shows a "Sign in required" dialog with a button that navigates to the login screen.

### 9.5 Experiences Feed (Twitter-style)

- **Tab bar** with three tabs: **For You** (newest) | **Popular** (most upvoted) | **Budget** (lowest cost first).
- Each experience rendered as a Twitter-style post:
  - Author avatar + username + relative time ("3 hours ago").
  - Bold title + description preview (3 lines).
  - Destination/days/cost info chip.
  - Hashtag tags inline.
  - Action row: comment count, repost, upvote count, bookmark.
- Thin dividers between posts. Edge-to-edge layout.
- Pull-to-refresh per tab.

### 9.6 Experience Detail Page

- Header: cover image, title, destination tag, author name (clickable → public profile).
- Day-by-day timeline with times and costs per entry.
- Stats: estimated cost, user cost, day count.
- Actions: **[Clone]** **[Bookmark]** **[Upvote]**
- Clone: full deep copy into user's drafts. `cloned_from` FK stored internally. No attribution shown. Fully editable.
- Comments section: 1-level nesting, Reddit-style upvote/downvote per comment, report button.

### 9.7 Profile Page

- **Guest state:** Centered prompt with "Join Ghurtejai" heading, description, and two buttons: "Sign In" and "Create Account" — both navigate correctly to auth screens.
- **Authenticated state:**
  - Collapsing header with avatar, full name, @username.
  - Stats row: experience count, bookmark count.
  - **Tabbed layout:** "My Experiences" | "Bookmarks".
  - My Experiences: Twitter-style cards of user's own experiences (all statuses).
  - Bookmarks: saved destinations + saved experiences, each with navigation.
  - App bar actions: notifications, moderation (for mod/admin roles), logout via popup menu.

### 9.8 Public Profile Page

- Accessible by tapping author name on any experience.
- Shows only the user's **PUBLISHED** experiences.
- Read-only. No settings, no bookmarks.

### 9.9 Auth Pages

- **Login:** Email + password. "Sign In" button, "Create Account" link, "Continue as Guest" text button.
- **Register:** Full name, username, email, password, confirm password. "Create Account" button, "Already have an account? Sign In" link.
- Authentication uses `USERNAME_FIELD = "email"` — login is email-based.

### 9.10 Notifications Page

- In-app only in v1 (no push notifications).
- Events: upvote on your experience, comment on your experience, reply to your comment, attraction approved, experience approved, experience rejected (with reason).
- Mark as read. Unread count available via API.
- Accessed from the notification bell icon in the app bar.

### 9.11 Moderation Page

- Accessible to Moderator and Admin roles only (icon in profile app bar).
- Lists pending content: destinations, attractions, experiences awaiting approval.
- Approve or reject with mandatory rejection reason.

## 10. Tech Stack

### 10.1 Backend

| Component          | Technology |
|--------------------|----------|
| Framework          | Django 5.x + Django REST Framework |
| Database           | PostgreSQL 16 |
| Caching + Rate limiting | Redis 7 via django-redis |
| Task queue         | Celery + Redis broker |
| Auth               | JWT via djangorestframework-simplejwt |
| Image storage      | Cloudflare R2 via django-storages[s3] + boto3 |
| Image processing   | Pillow (collage generation inside Celery task) |
| Search             | django.contrib.postgres full-text search (abstracted via SearchBackend) |
| CORS               | django-cors-headers |
| Filtering          | django-filter |
| Admin panel        | Django Admin (built-in) |
| API docs           | drf-spectacular (OpenAPI / Swagger) |
| Environment        | python-decouple |
| Throttling         | DRF built-in throttle classes (custom: LoginRateThrottle, RegisterRateThrottle, UploadRateThrottle), state stored in Redis |
| WSGI server        | Gunicorn (production) / Django dev server (development) |
| DB driver          | psycopg 3 (`psycopg[binary]`) |

### 10.2 Backend pip packages

```text
django  djangorestframework  djangorestframework-simplejwt  django-storages[s3]  boto3  django-redis  celery  django-cors-headers  django-filter  drf-spectacular  Pillow  psycopg[binary]  python-decouple  gunicorn
```

### 10.3 Frontend (Flutter)

| Component          | Technology |
|--------------------|----------|
| State management   | Riverpod (`flutter_riverpod`, `riverpod_annotation`) |
| HTTP client        | Dio |
| Auth token refresh | Dio interceptor — silently retries on 401, redirects to login only if refresh fails. Web uses `BrowserHttpClientAdapter` for CORS. |
| Auth storage       | `flutter_secure_storage` (JWT access + refresh token persistence) |
| Image handling     | `cached_network_image`, `image_picker` |
| Routing            | go_router |
| UI                 | Material 3 (Material Design 3 with `ColorScheme.fromSeed`) |
| Time formatting    | `timeago` |
| Internationalization | `intl` |
| Loading states     | `shimmer` |
| Pagination         | `infinite_scroll_pagination` |
| SVG support        | `flutter_svg` |
| Code generation    | `freezed`, `json_serializable`, `build_runner`, `riverpod_generator` |

### 10.4 Infrastructure

| Component          | Technology |
|--------------------|----------|
| Image storage + CDN| Cloudflare R2 + Cloudflare CDN |
| Containerization   | Docker + Docker Compose |
| Web server (prod)  | Nginx (reverse proxy) |
| App server (prod)  | Gunicorn |

### 10.5 Docker Compose Services

**Development (`docker-compose.dev.yml`):**

| Service  | Role |
|----------|------|
| `db`     | PostgreSQL 16 Alpine |
| `redis`  | Redis 7 Alpine |
| `web`    | Django dev server (runserver) |
| `celery` | Celery worker (same Django image) |

**Production (planned):**

| Service  | Role |
|----------|------|
| `db`     | PostgreSQL |
| `redis`  | Redis |
| `web`    | Django + Gunicorn |
| `celery` | Celery worker |
| `nginx`  | Reverse proxy |

## 11. Redis Usage (Scoped for v1)

| Purpose                     | Details |
|-----------------------------|---------|
| Rate limiting state         | Login, register, image upload endpoints via DRF throttle classes. |
| Celery broker               | Task queue for async collage generation. |
| Django cache backend        | General cache framework configured with Redis. |

> Destination stats and trending data are computed at query time via serializer methods and database annotations, not cached in Redis in v1. Add caching after measuring real query latency in production.

## 12. API Throttling

| Throttle class         | Applied to |
|------------------------|------------|
| `AnonRateThrottle`     | All unauthenticated (guest) requests. |
| `UserRateThrottle`     | All authenticated user requests. |
| `LoginRateThrottle`    | Login endpoint (stricter limit). |
| `RegisterRateThrottle` | Register endpoint (stricter limit). |
| `UploadRateThrottle`   | Image upload endpoint (stricter limit). |

## 13. Business Logic Rules

| Rule                        | Behaviour |
|-----------------------------|-----------|
| Estimated cost              | Sum of entry costs > 0. If none → display **"N/A"**. |
| Experience clone            | Full deep copy into user's drafts. `cloned_from` FK stored internally. No attribution shown in UI. Fully independent and editable. |
| Public experience visibility| Only **PUBLISHED** experiences appear on the feed and public profiles. |
| Soft delete — experience    | `is_deleted=True`. All child days and entries also soft-deleted. Removed from all queries. |
| Soft delete — comment with replies | `is_deleted=True` on parent comment. All replies also soft-deleted. |
| JWT expiry                  | Access: 60 min. Refresh: 7 days. Dio interceptor silently refreshes on 401. Redirects to login only if refresh fails. |
| Rejection                   | Rejection reason is mandatory. Stored on model. User notified via notification. |
| Guest access                | Guests can browse all public content but cannot bookmark, comment, upvote, or create. Prompted to sign in for all protected actions. |
| Tag normalization           | Tags are lowercased, trimmed, and deduplicated on save. Slugs auto-generated. |
| Comment voting              | Reddit-style via separate `CommentVote` model. +1 or -1 per user per comment. Score = upvotes − downvotes. |
| Comment report uniqueness   | A user can only submit one Report per comment. Enforced via `unique_together` constraint. |
| Upvote on experience        | One upvote per user per experience via `Vote` model. Toggle behavior (upvote/remove). |

## 14. Deferred to v2

- Google Sign-In / OAuth.
- AI Search — natural language query → auto-set filters → results.
- Image moderation AI — automated content safety scanning.
- Follow / follower system.
- Push notifications (in-app only for v1).
- Export experience as PDF / shareable trip plan.
- Edit Profile page.
- Forgot password / password reset flow.
- Offline mode / local drafts.
- Reputation / trusted user system (auto-approval pathway).
- Meilisearch or Typesense swap for full-text search.
- Language switching (EN/BN).
- Notification preferences (on/off).
- Redis caching for destination stats and trending data.

---

**GHURTEJAI — Product Spec v1.3 — Matches Current Implementation**
