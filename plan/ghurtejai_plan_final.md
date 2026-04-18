# GHURTEJAI

**Product Specification — v2.0**
**Tour planning + experience sharing app for Bangladesh**

**Stack:** Flutter + Django REST Framework + PostgreSQL + Redis + Celery + Cloudflare R2 + JWT

---

## 1. Terminology (Locked)

These terms are fixed across all code, documentation, and UI copy.

| Concept | Term |
|---|---|
| A place to visit | Destination |
| Discoverable units (places, foods, activities) | Attraction |
| Items added to a day in a journey | Entry |
| A complete journey | Experience |
| A day block within an experience | Day |

**Core data flow:**
**Destination → Attractions → Entries → Day → Experience**

---

## 2. Navigation — Bottom Bar

- **Explore**
- **Experiences**
- **Create**
- **Profile**

- The **Create** tab opens the Experience builder directly — no intermediate landing page. Guests see a "Sign in required" dialog with Sign In and Create Account buttons.
- Bookmarks live inside **Profile** (tabbed layout) — no dedicated tab.

---

## 3. User Roles

| Role | Capabilities |
|---|---|
| **Guest** | Browse Explore, Destinations, public Experiences. Cannot bookmark, interact, or create. Prompted to sign in for any protected action. |
| **User** | Full interaction: create, share, clone, bookmark, comment, upvote, submit attractions/destinations/transport. |
| **Moderator** | Approve/reject: Destinations, Attractions, Transport, public Experiences, public Attractions submitted by users. Must provide rejection reason. No Django Admin access. Assigned by Admin. |
| **Admin** | Full approve/reject powers + Django Admin panel access. Can assign Moderator role. |

> Guest users do **not** have local/device bookmarks. Bookmarking requires signing in.

---

## 4. Core System Rules

### 4.1 Soft Delete (Global)

All user-generated content uses soft delete. Hard delete is never used in v1.

| Field | Type & Behaviour |
|---|---|
| `is_deleted` | Boolean — default `False`. Filters applied at queryset level. |
| `deleted_at` | Timestamp — set on deletion, `null` otherwise. |

- Soft-deleted records are hidden from all UI and API responses.
- Retained in the database for moderation review and analytics.
- Django manager override: default queryset always filters `is_deleted=False`. An `all_objects` manager provides access to all records including deleted ones.
- When a parent is soft-deleted, all children are also soft-deleted (Experience → Days → Entries, Comment → Replies).

### 4.2 Rejection Reason

When a Moderator or Admin rejects any content (Destination, Attraction, Transport, or Experience), they must supply a `rejection_reason` string. This is stored on the relevant model and surfaced to the submitting user via notification.

### 4.3 Slug Fields

Destination, Experience, and Tag all carry a `slug` field (unique, auto-generated from name). Slugs are used in URLs and never expose raw integer PKs to the client.

### 4.4 Estimated Cost Rule

Estimated cost = sum of all entry costs where `cost > 0`. If no entries carry a cost, display **"N/A"**. Always labelled in the UI as a cost estimate.

### 4.5 JWT Token Lifetimes

| Token | Lifetime |
|---|---|
| Access token | 60 minutes |
| Refresh token | 7 days |

Dio interceptor silently catches 401 responses, calls the refresh endpoint, and retries the original request. Only redirects to the login screen if the refresh call itself fails.

### 4.6 Timestamps (Global)

Every model carries `created_at` (auto-set on creation) and `updated_at` (auto-set on every save) unless noted otherwise. These are defined once here and not repeated per-model below.

---

## 5. Data Models

### 5.1 Division & District (Geography)

| Model | Fields |
|---|---|
| `Division` | `name`, `name_bn` |
| `District` | `name`, `name_bn`, `division` (FK → Division) |

Pre-seeded with all 8 divisions and 64 districts of Bangladesh via fixture data. No `created_at`/`updated_at` on these seed models.

---

### 5.2 Destination

| Field | Details |
|---|---|
| `name` | String. Indexed. |
| `slug` | Unique. Auto-generated from name. |
| `description` | Short description text. |
| `cover_image` | Stored on Cloudflare R2. |
| `district` | FK → District (nullable). Division info accessed via `district.division`. |
| `latitude` | Decimal (9,6). Nullable. |
| `longitude` | Decimal (9,6). Nullable. |
| `tags` | M2M → Tag. |
| `status` | `PENDING` \| `APPROVED` \| `REJECTED` |
| `rejection_reason` | String, nullable. Set when status → REJECTED. |
| `submitted_by` | FK → User |
| `is_deleted` / `deleted_at` | Soft delete fields. |

Stats (`attraction_count`, `experience_count`) are computed via `SerializerMethodField` at query time, not cached.

**Destination status rules:**
- New submissions start at `PENDING`.
- Approved destinations are visible in destination selectors app-wide.
- If a destination is rejected after experiences already reference it, those experiences keep their FK but the author sees a warning badge ("Destination under review") on the experience builder.

---

### 5.3 Attraction

| Field | Details |
|---|---|
| `type` | `PLACE` \| `FOOD` \| `ACTIVITY` |
| `name` | Display name. |
| `normalized_name` | Lowercase, trimmed — auto-set on save for deduplication. |
| `image` | Stored on R2. Nullable. |
| `notes` | Free text. Nullable. |
| `address` | String. Nullable. |
| `price_range` | String (e.g. ৳100–৳300). Nullable. |
| `latitude` | Decimal (9,6). Nullable. |
| `longitude` | Decimal (9,6). Nullable. |
| `destination` | FK → Destination |
| `status` | `PENDING` \| `APPROVED` \| `REJECTED` |
| `rejection_reason` | String, nullable. |
| `submitted_by` | FK → User |
| `is_public_submission` | Boolean. `True` = submitted for all users; `False` = for personal use only (one-time custom). Default `False`. |
| `is_deleted` / `deleted_at` | Soft delete fields. |

**Attraction visibility rules:**
- Only `APPROVED` attractions appear in the attraction search/select in the Entry form.
- Attractions with `is_public_submission=False` (personal custom entries) skip the moderation queue and are immediately usable by their submitter only — they are never visible to other users in search.
- Attractions with `is_public_submission=True` go into the `PENDING` moderation queue.
- If an approved attraction is later soft-deleted or rejected, entries referencing it keep their FK but fall back to displaying the entry's own `name` field.

---

### 5.4 Transport

| Field | Details |
|---|---|
| `destination` | FK → Destination |
| `from_location` | String. |
| `to_location` | String. |
| `type` | `BUS` \| `AC_BUS` \| `TRAIN` \| `FLIGHT` \| `OTHER` |
| `operator` | Operator name. String. |
| `cost` | Decimal. |
| `duration` | Duration field. |
| `departure_time` | Time field. |
| `start_point` | String — exact boarding location. |
| `status` | `PENDING` \| `APPROVED` \| `REJECTED` |
| `rejection_reason` | String, nullable. |
| `submitted_by` | FK → User |
| `is_deleted` / `deleted_at` | Soft delete fields. |

---

### 5.5 Day

| Field | Details |
|---|---|
| `experience` | FK → Experience |
| `position` | Integer. Order of this day within the experience (1-based). |
| `date` | Date, nullable. Optional actual date for the day. |
| `is_deleted` / `deleted_at` | Soft delete fields. |

Days are always labelled "Day 1", "Day 2", etc. in the UI, derived from `position`. The optional `date` field is for users who want to attach a real date to each day (displayed alongside the day label if set).

---

### 5.6 Entry

| Field | Details |
|---|---|
| `name` | Entry label. Required if `attraction` is null (custom entry). If `attraction` is set, auto-populated from attraction name but remains editable. |
| `time` | Time of day for this entry. Nullable. |
| `cost` | Decimal, optional. Included in estimated cost if > 0. |
| `notes` | Free text. Nullable. |
| `attraction` | FK → Attraction, nullable. Links entry to a known/approved attraction. |
| `day` | FK → Day. |
| `position` | Integer. Order within the day (supports drag-to-reorder). |
| `is_deleted` / `deleted_at` | Soft delete fields. |

**DB-level constraint:** If `attraction` is null, `name` must not be blank. Enforced via a `CheckConstraint`.

**Entry types:**
- **Linked Entry:** `attraction` FK is set. Name auto-filled from attraction; cost and notes are user-editable.
- **Custom Entry:** `attraction` is null. User fills all fields manually.

---

### 5.7 Experience

| Field | Details |
|---|---|
| `title` | String. |
| `slug` | Unique. Auto-generated from title. |
| `description` | Text. |
| `destination` | FK → Destination |
| `cover_image` | Manual upload OR auto-generated 4-image collage (async Celery → R2). Nullable until collage is ready. |
| `cover_image_pending` | Boolean. `True` while Celery collage task is in progress. UI shows shimmer placeholder when `True`. |
| `estimated_cost` | Auto-computed via signal on every entry save/delete. Sum of entry costs > 0, else `null` (displayed as "N/A"). |
| `user_cost` | Decimal, nullable. Manual override — what the author actually spent. |
| `status` | `DRAFT` \| `PENDING_REVIEW` \| `PUBLISHED` \| `REJECTED` |
| `visibility` | `PRIVATE` \| `PUBLIC` |
| `rejection_reason` | String, nullable. Set when moderator rejects. |
| `author` | FK → User |
| `cloned_from` | FK → Experience, nullable. Stored internally, never shown in UI. |
| `tags` | M2M → Tag. |
| `is_deleted` / `deleted_at` | Soft delete fields. |

**Experience Status Flow:**

| Action | Resulting Status |
|---|---|
| Save for Myself (private) | `DRAFT` — saved immediately, no approval. |
| Share Experience (public) | `PENDING_REVIEW` → Moderator/Admin reviews → `PUBLISHED` or `REJECTED`. |
| Edit a `PUBLISHED` experience | Saves immediately, stays `PUBLISHED`. No re-review in v1. |
| Edit a `PENDING_REVIEW` experience | Reverts to `DRAFT`. User must resubmit for review. |

---

### 5.8 Tag

| Field | Details |
|---|---|
| `name` | Normalized: lowercase, trimmed, deduplicated on save. |
| `slug` | Unique. Auto-generated. |
| `created_by` | FK → User, nullable. |

Tags are freely user-created. No moderation required. Applied to Destinations and Experiences.

---

### 5.9 Vote (Experience Upvote)

| Field | Details |
|---|---|
| `user` | FK → User |
| `experience` | FK → Experience |
| `created_at` | Timestamp. |

One vote per user per experience. Enforced via `unique_together(user, experience)`. Toggle behaviour — upvote again to remove. No downvotes on experiences.

---

### 5.10 Comment

| Field | Details |
|---|---|
| `experience` | FK → Experience |
| `author` | FK → User |
| `text` | Comment body. Max 1000 characters. |
| `parent` | FK → Comment, nullable. 1-level nesting only (replies to top-level comments only). |
| `is_deleted` / `deleted_at` | Soft delete. When a parent is soft-deleted, all replies are also soft-deleted. |

Comment score is computed from the `CommentVote` model.

---

### 5.11 CommentVote (Reddit-style)

| Field | Details |
|---|---|
| `user` | FK → User |
| `comment` | FK → Comment |
| `value` | SmallInt: `+1` (upvote) or `-1` (downvote). |

Unique constraint on `(user, comment)`. Comment `score` = upvotes − downvotes, computed as a model property.

---

### 5.12 Report (Comment Reporting)

| Field | Details |
|---|---|
| `comment` | FK → Comment |
| `reporter` | FK → User |
| `reason` | String — reported reason or category. |
| `status` | `PENDING` \| `REVIEWED` \| `DISMISSED`. Default `PENDING`. |

Unique constraint on `(comment, reporter)` — a user can only report a comment once.

---

### 5.13 Notification

| Field | Details |
|---|---|
| `recipient` | FK → User |
| `type` | One of the notification types below. |
| `is_read` | Boolean — default `False`. |
| `experience` | FK → Experience, nullable. Set for experience-related notifications. |
| `comment` | FK → Comment, nullable. Set for comment/reply notifications. |
| `attraction` | FK → Attraction, nullable. Set for attraction approval notifications. |
| `destination` | FK → Destination, nullable. Set for destination approval notifications. |

**Notification Types & Triggers:**

| Type | Trigger | Deep-link target |
|---|---|---|
| `UPVOTE_EXPERIENCE` | Someone upvotes your experience. | `experience` FK |
| `COMMENT_ON_EXPERIENCE` | Someone comments on your experience. | `comment` FK |
| `REPLY_TO_COMMENT` | Someone replies to your comment. | `comment` FK (the reply) |
| `ATTRACTION_APPROVED` | Your attraction submission is approved. | `attraction` FK |
| `ATTRACTION_REJECTED` | Your attraction is rejected (includes reason). | `attraction` FK |
| `DESTINATION_APPROVED` | Your destination submission is approved. | `destination` FK |
| `DESTINATION_REJECTED` | Your destination is rejected (includes reason). | `destination` FK |
| `EXPERIENCE_APPROVED` | Your experience is published. | `experience` FK |
| `EXPERIENCE_REJECTED` | Your experience is rejected (includes reason). | `experience` FK |

Notifications are created automatically via Django signals. Tapping a notification navigates directly to the relevant content via the deep-link FK.

---

### 5.14 Bookmark

Two separate tables for cleaner queries:

| Table | Fields |
|---|---|
| `BookmarkDestination` | `user` (FK), `destination` (FK), `created_at`. Unique on `(user, destination)`. |
| `BookmarkExperience` | `user` (FK), `experience` (FK), `created_at`. Unique on `(user, experience)`. |

Bookmarking requires authentication — guests are prompted to sign in.

---

### 5.15 UserProfile

| Field | Details |
|---|---|
| `user` | OneToOne → User |
| `bio` | Text, blank. |
| `avatar` | Image, stored on R2. Nullable. |

Created automatically via signal alongside the User on registration.

---

### 5.16 RecentSearch

| Field | Details |
|---|---|
| `user` | FK → User |
| `query` | String. |
| `searched_at` | Timestamp. Auto-set on creation. |

Stores per-user recent searches. Limited to the 10 most recent entries per user (older entries are dropped on insert).

---

### 5.17 PopularSearch

| Field | Details |
|---|---|
| `query` | String, unique. |
| `count` | Integer. Incremented on each search. |
| `last_searched_at` | Timestamp. |

Tracks globally popular search terms. Top 10 shown in search suggestions for all users.

---

## 6. Content Moderation

| Content | Created By | Approved By |
|---|---|---|
| Destination | User | Admin / Moderator |
| Attraction (public submission) | User | Admin / Moderator |
| Attraction (personal/one-time) | User | N/A — skips moderation, visible only to submitter |
| Transport | User | Admin / Moderator |
| Experience (private) | User | N/A — instant save as DRAFT |
| Experience (public) | User | Admin / Moderator |
| Tags | User | N/A — no approval needed |

- All rejections must include a `rejection_reason` string.
- Submitting user is notified of approval or rejection via in-app notification with deep-link to content.

---

## 7. Image Handling

### 7.1 Upload Safety

- File type validation — only JPEG, PNG, WebP accepted.
- File size limit — enforced server-side.
- Upload rate limiting — custom DRF throttle on the image upload endpoint.
- All images stored on Cloudflare R2, served via Cloudflare CDN.

### 7.2 Experience Cover Image

- **Option A:** Manual upload by the user.
- **Option B:** Auto-generated 4-image collage from the destination's top attraction images.

**Collage generation flow:**
1. User creates/shares an experience without uploading a cover.
2. `cover_image_pending` is set to `True` on the Experience record.
3. Django enqueues a Celery task.
4. Celery fetches top 4 approved attraction images for the destination from R2.
5. Pillow stitches a 2×2 collage.
6. Collage uploaded to R2 → URL saved to `cover_image`, `cover_image_pending` set back to `False`.

**UI during pending state:** When `cover_image_pending=True` and `cover_image` is null, the cover image area displays a shimmer placeholder. Once the URL is available, the image loads normally via `cached_network_image`.

---

## 8. Search System

### 8.1 v1 Implementation

- PostgreSQL full-text search via `django.contrib.postgres`.
- Searches across: destination names, attraction names, experience titles.
- Recent searches stored per user via `RecentSearch` model (10 max).
- Popular searches tracked globally via `PopularSearch` model (top 10 shown).
- Filter by type: **All** | **Destinations** | **Experiences**.

### 8.2 Abstraction Layer

The search backend is wrapped in an abstraction layer (`SearchBackend` base class with `PgSearchBackend` implementation) so it can be swapped to Meilisearch or Typesense in v2 without changing the API contract. Search results are **not** cached in v1.

---

## 9. Pages & Features

### 9.1 Explore Page

- Floating/snapping `SliverAppBar` with branded "Ghurtejai" logo and notification bell.
- Search bar ("Where do you want to go?") → opens `showSearch` delegate with recent + popular suggestions.
- Horizontal tag chips: #beach #mountain #nature #adventure #food + user-created tags. Chips filter the destinations section below.
- **Destinations** section — horizontal scroll of destination cards (cover image with gradient overlay, name, district, attraction count, experience count). "See all →" links to All Destinations.
- **Recent Experiences** section — Twitter/X-style experience cards. "See all →" links to Experiences Feed.
- Pull-to-refresh on the entire page.
- **Empty state:** If no destinations or experiences exist yet, show an illustrated placeholder with a short message.

**Experience card anatomy (used across all feed-style lists):**
- Author avatar + @username + relative timestamp ("3 hours ago")
- Bold title + description preview (3 lines, truncated with ellipsis)
- Destination chip + day count chip + estimated cost chip
- Hashtag tags inline
- Action row: 💬 comment count · ⬆ upvote count · 🔖 bookmark · clone icon
- Thin divider between cards. Edge-to-edge layout.

---

### 9.2 All Destinations Page

- Search bar at top.
- Filter bottom sheet: filter by Division, District, Tag.
- Sort options: Name (A–Z), Newest first.
- Grid or list of destination cards (cover image, name, district, attraction count, experience count).
- Infinite scroll pagination via DRF `StandardResultsPagination` + `infinite_scroll_pagination`.
- **Empty state:** "No destinations found" illustrated message with a clear filters button.

---

### 9.3 Destination Detail Page

**Header:**
- Full-width cover image with gradient overlay.
- Destination name, tags, district/division info.
- Coordinates displayed if available. Bookmark icon in top-right.

**Attractions section:**
- Grouped by type with labelled section headers: **Places**, **Food**, **Activities**.
- Each attraction card: image thumbnail, name, address, price range, notes.
- Only `APPROVED` attractions shown.
- **Empty state per group:** "No [places/food/activities] listed yet."

**Transport section:**
- Cards showing from → to, operator, type icon, cost, duration, departure time, start point.
- Only `APPROVED` transport shown.
- **Empty state:** "No transport info yet."

**Related Experiences section:**
- Horizontal scroll of experience cards from this destination.
- "See all →" links to the Experiences Feed filtered by this destination.

**Submit buttons (authenticated users only):**
- "Add Attraction" → opens Add Attraction bottom sheet.
- "Add Transport" → opens Add Transport bottom sheet.

---

### 9.4 Create / Edit Experience Page

This is a multi-step builder with a persistent top bar showing the experience title and a save/share action button.

#### Step 1 — Basics

**Destination selector:**
- Tapping opens a full-screen search modal.
- Search bar with live results showing approved destinations (name + district).
- If no result matches, a "Create new destination" option appears at the bottom of the results list.
  - Tapping opens the **Submit Destination** form (name, description, district, cover image, tags). Submitting sends it to `PENDING` moderation.
  - After submission, the user sees a toast: "Destination submitted for review. You'll be notified when it's approved." The experience cannot use it until it is approved.

**Title input:** Free text. Required.

**Visibility toggle:** Private / Public. Default Private.

**Description:** Optional multiline text.

**Tags:** Tag chip input (add/remove).

**Cover image:** Optional image picker. If left empty, the collage is auto-generated asynchronously after saving.

#### Step 2 — Day Builder

- Each day displayed as an expandable card labelled "Day 1", "Day 2", etc.
- Optional date picker per day (shown next to the day label if set).
- Days are reorderable via drag handle — long-press or drag icon on the right.

**Within each day — Entry list:**
- Entries listed in order with a drag handle for reordering.
- Each entry shows: time, name/attraction name, cost (if set).
- Tap an entry to edit it.
- Swipe left on an entry to delete (with confirmation).

**[+ Add Entry] button** at the bottom of each day's entry list → opens the **Add Entry Sheet** (see Section 9.4.1).

**[+ Add Day] button** at the bottom of the day list.

**Delete day:** Swipe left on the day header or use the day's context menu. Confirmation required. Soft-deletes the day and all its entries.

#### Step 2.1 — Add / Edit Entry Sheet (Bottom Sheet)

This is a horizontally paged sheet with two slides, navigable by swipe or a toggle at the top.

**Left slide — "Select Attraction":**
- Search bar: live search of `APPROVED` attractions scoped to the selected destination.
- Results list: attraction image thumbnail, name, type badge (Place / Food / Activity), price range.
- Tapping a result:
  - Pre-fills entry `name` from attraction name.
  - Pre-fills `cost` from attraction `price_range` midpoint if parsable (user can override).
  - Sets `attraction` FK.
  - Slides to a confirmation/edit form where the user can set `time`, override `name` and `cost`, and add `notes`.
- If no results match the query, a "Can't find it?" prompt appears at the bottom:
  - **"Use as custom entry"** → switches to the right slide with the typed name pre-filled.
  - **"Submit this attraction"** → opens the **Submit Attraction** inline form (see Section 9.4.2).

**Right slide — "Custom Entry":**
- `Name` — text field. Required.
- `Time` — time picker. Optional.
- `Cost` — numeric field. Optional.
- `Notes` — multiline text. Optional.
- No attraction FK set.

**Save button** on both slides adds the entry to the day and closes the sheet.

#### Step 2.2 — Submit Attraction (Inline Form, Bottom Sheet)

Accessible from the "Can't find it?" → "Submit this attraction" path during entry creation.

| Field | Details |
|---|---|
| `Name` | Pre-filled from the search query. Editable. |
| `Type` | Dropdown: Place / Food / Activity. |
| `Address` | Text. Optional. |
| `Price range` | Text. Optional. |
| `Notes` | Text. Optional. |
| `Image` | Optional image picker. |
| **"Save for myself only"** toggle | Default OFF. |

**Behaviour:**
- If **"Save for myself only"** is OFF (default): Submission is marked `is_public_submission=True`, enters the moderation queue as `PENDING`. User is notified on approval/rejection. The attraction is NOT immediately usable in the entry.
  - After submission, a toast: "Attraction submitted for review." The entry is created as a **Custom Entry** (right slide) with the typed name in the meantime.
- If **"Save for myself only"** is ON: `is_public_submission=False`, skips moderation, immediately available to this user only. The entry is immediately linked via the `attraction` FK.

#### Step 3 — Review & Save

- Summary: destination, day count, entry count, estimated cost.
- Cover image preview (shimmer if collage is pending).
- `user_cost` field: "What did you actually spend? (optional)".
- **[Save as Draft]** → status `DRAFT`, visibility `PRIVATE`.
- **[Share Experience]** → status `PENDING_REVIEW`, visibility `PUBLIC`. A dialog warns: "Your experience will be reviewed before going public."

**Edit mode:** Accessing this page for an existing experience populates all fields. If the experience is `PENDING_REVIEW`, a banner warns "Saving changes will return this to Draft. You'll need to resubmit for review." Editing a `PUBLISHED` experience saves immediately and stays `PUBLISHED`.

**Delete experience:** Available via the ⋮ menu on the Experience Detail page (for the author). Shows a confirmation dialog. Soft-deletes the experience, all its days, and all its entries.

---

### 9.5 Experiences Feed

- **Tab bar:** **For You** (newest) | **Popular** (most upvoted) | **Budget** (lowest estimated cost first).
- Experience cards use the anatomy defined in Section 9.1.
- Infinite scroll + pull-to-refresh per tab.
- **Action row buttons:**
  - 💬 Comment count → navigates to Experience Detail, scrolled to comments.
  - ⬆ Upvote (toggle) — authenticated only; guests see sign-in prompt.
  - 🔖 Bookmark (toggle) — authenticated only; guests see sign-in prompt.
  - Clone icon — creates a full deep copy into user's drafts. Shows confirmation dialog first. Authenticated only.
- **Empty state:** "No experiences yet. Be the first to share one!"

---

### 9.6 Experience Detail Page

**Header:**
- Full-width cover image (shimmer if `cover_image_pending=True`).
- Title, destination chip, tags.
- Author avatar + @username (clickable → Public Profile).
- Relative timestamp.
- Stats row: estimated cost · user cost (if set) · day count.
- Action row: upvote · bookmark · clone. For the author: ✏️ Edit · 🗑 Delete (via ⋮ menu).

**Day-by-day timeline:**
- Accordion or scrollable sections per day.
- Each entry: time (if set), name/attraction name, cost (if set), notes (if set).
- Entries linked to attractions show the attraction type badge.

**Comments section:**
- Top-level comments in reverse-chronological order.
- Each comment: avatar, @username, text, timestamp, upvote/downvote row, reply button, report button (⋮ menu).
- Replies shown indented below the parent comment (1 level only).
- Comment score = upvotes − downvotes (shown as a number, colour-coded green/red/neutral).
- Comment input at the bottom of the page (sticky). Authenticated only; guests see sign-in prompt.

**Guest state:** All content is readable. Action buttons (upvote, bookmark, clone, comment) prompt sign-in when tapped.

---

### 9.7 Profile Page

**Guest state:**
- Centered illustration, "Join Ghurtejai" heading, short tagline.
- Two buttons: **Sign In** and **Create Account**.

**Authenticated state:**
- Collapsing `SliverAppBar` with avatar, full name, @username.
- Stats row: experience count · bookmark count.
- App bar actions: 🔔 Notifications · ⋮ menu (Moderation link for mod/admin, Logout).
- **Tabbed layout:**
  - **My Experiences** — experience cards for all the user's own experiences regardless of status. Status badges shown (Draft / Pending / Published / Rejected). Tap to open detail or edit.
  - **Bookmarks** — two sub-tabs: Destinations · Experiences. Each item tappable to navigate.

---

### 9.8 Public Profile Page

- Accessible by tapping an author's name/avatar on any experience card.
- Shows full name, @username, avatar, bio (if set).
- Lists only `PUBLISHED` experiences by that user.
- Read-only. No settings, no bookmarks, no private content.

---

### 9.9 Auth Pages

- **Login:** Email + password. "Sign In" button. "Create Account" link. "Continue as Guest" text button.
- **Register:** Full name, username, email, password, confirm password. "Create Account" button. "Already have an account? Sign In" link.
- Authentication uses `USERNAME_FIELD = "email"` — login is email-based.
- Username is display-only (shown as @username in the UI).

---

### 9.10 Notifications Page

- In-app only in v1 (no push notifications).
- Notifications listed in reverse-chronological order.
- Each notification: icon (by type), descriptive text, relative timestamp, unread dot.
- Tapping a notification marks it as read and deep-links to the relevant content.
- "Mark all as read" button in the app bar.
- Unread count shown as a badge on the notification bell icon.
- Paginated (infinite scroll).
- **Empty state:** "You're all caught up!"

---

### 9.11 Moderation Page

Accessible to Moderator and Admin roles only (icon in Profile app bar ⋮ menu).

**Tab bar:**
- **Destinations** — pending destination submissions.
- **Attractions** — pending public attraction submissions.
- **Experiences** — pending public experience submissions.
- Each tab shows a count badge of pending items.

**Each pending item card:**
- Preview of key info (name, submitted by, timestamp).
- Tap → opens a **Moderation Detail Sheet** (full bottom sheet or page):
  - Full content preview.
  - **[Approve]** button → immediately sets status to `APPROVED` / `PUBLISHED`.
  - **[Reject]** button → opens a text input for `rejection_reason` (required), then submits.
- Swipe-to-approve and swipe-to-reject gestures supported as shortcuts on the list card.
- **Empty state per tab:** "Nothing pending — you're up to date!"

---

### 9.12 Submit Destination / Attraction / Transport Forms

These are used in standalone contexts (e.g., "Add Attraction" button on Destination Detail) as well as inline during experience creation.

**Submit Destination:**
- Fields: Name, Description, District (searchable dropdown), Tags, Cover Image.
- Submits as `PENDING`.

**Submit Transport:**
- Fields: From location, To location, Type (dropdown), Operator, Cost, Duration, Departure time, Start point.
- Scoped to the current destination.
- Submits as `PENDING`.

---

## 10. UX — Empty & Error States (Global)

| Context | Empty State | Error State |
|---|---|---|
| Explore → Destinations | Illustrated placeholder: "No destinations yet." | "Couldn't load. Pull to refresh." |
| Explore → Experiences | "No experiences yet. Be the first!" | "Couldn't load. Pull to refresh." |
| All Destinations (filtered) | "No destinations match your filters." + Clear Filters button | "Couldn't load. Pull to refresh." |
| Experiences Feed | "No experiences here yet." | "Couldn't load. Pull to refresh." |
| Search results | "No results for [query]." | "Search failed. Try again." |
| My Experiences | "You haven't created any experiences yet." + Create button | "Couldn't load. Pull to refresh." |
| Bookmarks | "Nothing saved yet." | "Couldn't load. Pull to refresh." |
| Notifications | "You're all caught up!" | "Couldn't load. Pull to refresh." |
| Comments | "No comments yet. Be the first!" | "Couldn't load comments." |
| Attraction search (in entry sheet) | "No attractions found. Submit one!" | "Search failed. Try again." |

**Loading states:** All lists and pages use `shimmer` skeleton cards while data is loading. This applies globally — every list, detail page header, and image area shows shimmer on first load.

**Form error states:** Inline validation messages beneath each field. A toast appears on network or server errors with a "Retry" action.

---

## 11. Tech Stack

### 11.1 Backend

| Component | Technology |
|---|---|
| Framework | Django 5.x + Django REST Framework |
| Database | PostgreSQL 16 |
| Caching + Rate limiting | Redis 7 via django-redis |
| Task queue | Celery + Redis broker |
| Auth | JWT via djangorestframework-simplejwt |
| Image storage | Cloudflare R2 via django-storages[s3] + boto3 |
| Image processing | Pillow (collage generation inside Celery task) |
| Search | django.contrib.postgres full-text search (abstracted via SearchBackend) |
| CORS | django-cors-headers |
| Filtering | django-filter |
| Admin panel | Django Admin (built-in) |
| API docs | drf-spectacular (OpenAPI / Swagger) |
| Environment | python-decouple |
| Throttling | DRF built-in throttle classes (custom: LoginRateThrottle, RegisterRateThrottle, UploadRateThrottle), state stored in Redis |
| WSGI server | Gunicorn (production) / Django dev server (development) |
| DB driver | psycopg 3 (`psycopg[binary]`) |

### 11.2 Backend pip packages

```
django  djangorestframework  djangorestframework-simplejwt  django-storages[s3]  boto3  django-redis  celery  django-cors-headers  django-filter  drf-spectacular  Pillow  psycopg[binary]  python-decouple  gunicorn
```

### 11.3 Frontend (Flutter)

| Component | Technology |
|---|---|
| State management | Riverpod (`flutter_riverpod`, `riverpod_annotation`) |
| HTTP client | Dio |
| Auth token refresh | Dio interceptor — silently retries on 401, redirects to login only if refresh fails. |
| Auth storage | `flutter_secure_storage` (JWT access + refresh token persistence) |
| Image handling | `cached_network_image`, `image_picker` |
| Routing | go_router |
| UI | Material 3 (`ColorScheme.fromSeed`) |
| Time formatting | `timeago` |
| Internationalization | `intl` |
| Loading states | `shimmer` |
| Pagination | `infinite_scroll_pagination` |
| SVG support | `flutter_svg` |
| Drag-to-reorder | Flutter built-in `ReorderableListView` |
| Code generation | `freezed`, `json_serializable`, `build_runner`, `riverpod_generator` |

### 11.4 Infrastructure

| Component | Technology |
|---|---|
| Image storage + CDN | Cloudflare R2 + Cloudflare CDN |
| Containerization | Docker + Docker Compose |
| Web server (prod) | Nginx (reverse proxy) |
| App server (prod) | Gunicorn |

### 11.5 Docker Compose Services

**Development (`docker-compose.dev.yml`):**

| Service | Role |
|---|---|
| `db` | PostgreSQL 16 Alpine |
| `redis` | Redis 7 Alpine |
| `web` | Django dev server (runserver) |
| `celery` | Celery worker (same Django image) |

**Production (planned):**

| Service | Role |
|---|---|
| `db` | PostgreSQL |
| `redis` | Redis |
| `web` | Django + Gunicorn |
| `celery` | Celery worker |
| `nginx` | Reverse proxy |

---

## 12. Redis Usage (Scoped for v1)

| Purpose | Details |
|---|---|
| Rate limiting state | Login, register, image upload endpoints via DRF throttle classes. |
| Celery broker | Task queue for async collage generation. |
| Django cache backend | General cache framework configured with Redis. |

> Destination stats and trending data are computed at query time via serializer methods and database annotations, not cached in Redis in v1. Add caching after measuring real query latency in production.

---

## 13. API Throttling

| Throttle class | Applied to |
|---|---|
| `AnonRateThrottle` | All unauthenticated (guest) requests. |
| `UserRateThrottle` | All authenticated user requests. |
| `LoginRateThrottle` | Login endpoint (stricter limit). |
| `RegisterRateThrottle` | Register endpoint (stricter limit). |
| `UploadRateThrottle` | Image upload endpoint (stricter limit). |

---

## 14. Business Logic Rules

| Rule | Behaviour |
|---|---|
| Estimated cost | Sum of entry costs > 0. If none → display "N/A". Recomputed via Django signal on every entry save or delete. |
| Experience clone | Full deep copy of experience, all days, and all entries into user's drafts as `DRAFT`. `cloned_from` FK stored internally. No attribution shown in UI. Cover image URL copied as-is (no new collage). Fully independent and editable. |
| Public experience visibility | Only `PUBLISHED` experiences appear on the feed and public profiles. |
| Edit published experience | Saves immediately, stays `PUBLISHED`. No re-review in v1. |
| Edit pending experience | Reverts to `DRAFT`. User must resubmit. |
| Soft delete — experience | `is_deleted=True` on experience. All child days and entries also soft-deleted via signal. Removed from all queries. |
| Soft delete — comment with replies | `is_deleted=True` on parent comment. All replies also soft-deleted via signal. |
| JWT expiry | Access: 60 min. Refresh: 7 days. Dio interceptor silently refreshes on 401. Redirects to login only if refresh fails. |
| Rejection | Rejection reason is mandatory. Stored on model. User notified via in-app notification with deep-link. |
| Guest access | Guests can browse all public content but cannot bookmark, comment, upvote, clone, or create. Prompted to sign in for all protected actions. |
| Tag normalization | Tags are lowercased, trimmed, and deduplicated on save. Slugs auto-generated. |
| Comment voting | Reddit-style via `CommentVote`. +1 or -1 per user per comment. Score = upvotes − downvotes. |
| Comment report uniqueness | One report per user per comment. Enforced via `unique_together`. |
| Upvote on experience | One upvote per user per experience. Toggle behaviour. No downvotes. |
| Attraction visibility | Only `APPROVED` attractions appear in the entry search. Personal (`is_public_submission=False`) attractions are usable immediately by their submitter only. |
| Rejected attraction in entries | Entries keep the FK. Display falls back to the entry's own `name` field. |
| Rejected destination in experience | Experience keeps FK. Author sees a warning banner in the experience builder. |
| Custom entry constraint | If `attraction` is null, entry `name` must not be blank. Enforced at DB and API validation level. |
| RecentSearch limit | Max 10 recent searches stored per user. Oldest dropped on insert beyond limit. |

---

## 15. Deferred to v2

- Google Sign-In / OAuth.
- AI Search — natural language query → auto-set filters → results.
- Image moderation AI — automated content safety scanning.
- Follow / follower system.
- Push notifications (in-app only for v1).
- Export experience as PDF / shareable trip plan.
- Edit Profile page (bio, avatar, username change).
- Forgot password / password reset flow.
- Offline mode / local drafts.
- Reputation / trusted user system (auto-approval pathway).
- Meilisearch or Typesense swap for full-text search.
- Language switching (EN/BN).
- Notification preferences (on/off toggles per type).
- Redis caching for destination stats and trending data.
- Map view for attractions with coordinates.
- Report management UI for moderators (currently reports are visible via Django Admin only).

---

**GHURTEJAI — Product Spec v2.0**
