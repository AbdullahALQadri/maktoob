# Maktoob API Endpoints (Real Backend Spec)

> **Base URL:** `https://maktoob.social/api/v1`
> **Auth:** Bearer Sanctum token in `Authorization` header
> **Content-Type:** `application/json` (unless multipart)
> **Timeout:** 30s (requests), 60s (uploads)
> **Pagination:** `?page=1&per_page=20`. Defaults and caps differ per endpoint, and so do the shapes (raw Laravel paginator with top-level `last_page`; `ApiResponse` `{data[], meta{last_page}}`; Resource collection `{data, links, meta{last_page}}`; `{<items>[], pagination{last_page}}`). The app reads them all through `Pagination` (`lib/core/api/paginated_fetch.dart`): `lastPageOf()` / `fetchAll()` walk pages until `last_page`, an empty page, or a page cap.
> **Currency:** ILS (Shekel, Palestine - Gaza). USD / EUR are quotes on top (see Currencies).
> **Timezone:** Asia/Gaza (+02:00)

---

## 1. Auth - Client (Token name: `mobile-app`)

| # | Method | Endpoint | Request Body | Response | Auth | Notes |
|---|--------|----------|-------------|----------|------|-------|
| 1 | POST | `/auth/register` | `{ name* (the PERSON's full name as on their ID: letters only, ≥ 2 words; for an institution the representative, with the organization in organization_name_ar), phone* (unique), password* (min:8), password_confirmation*, terms_accepted* (true), email?, company_name? }` | `{ message, client: { id, name, email, phone }, otp_sent: true }` | No | Sends OTP via WhatsApp after registration. `terms_accepted` = the "I agree to the Terms and Conditions" box; recorded with version, time, IP and channel. |
| 2 | POST | `/auth/login` | `{ login* (phone or email), password* }` | `{ message, token: "1\|abc...", client: { id, name, email, phone, avatar, is_verified } }` | No | `login` accepts both email and phone |
| 3 | POST | `/auth/verify-otp` | `{ login*, code* (size:6) }` | `{ message, token, client: { id, name, email, phone, is_verified } }` | No | Marks client as verified, returns token |
| 4 | POST | `/auth/resend-otp` | `{ login*, purpose? (in: registration, forgot_password) }` | `{ message, otp_sent: true }` | No | Resends OTP for registration or forgot password |
| 5 | POST | `/auth/forgot-password` | `{ login* }` | `{ message, otp_sent: true }` | No | Sends OTP to phone for password reset |
| 6 | POST | `/auth/reset-password` | `{ login*, code* (size:6), password* (min:8), password_confirmation* }` | `{ message }` | No | Requires valid OTP from forgot-password |
| 7 | POST | `/auth/logout` | — | `{ message }` | Yes | Invalidates current Sanctum token |
| 8 | GET | `/auth/profile` | — | `{ client: { id, name, email, phone, avatar, avatar_url, initials, company_name, address, city, country, locale, is_active, is_verified, verified_at, created_at, account_type, institution_status, institution, institution_memberships, must_change_password, identity: { status, verified_at, required, … } (see "Identity verification (KYC)"), legal: { acceptance_required, terms_version, privacy_version, pending: [{type, version, title, change_summary, url}] } } }` | Yes | `legal.acceptance_required` → the app shows the blocking accept screen (after any forced password change). Whitelisted shape (`Client::accountPayload()`), same `client` as login / register / verify-otp. `avatar` is a storage path; **display `avatar_url`** (absolute). |
| 9 | PUT / POST | `/auth/profile` | `{ name? (min:2), email? (nullable, unique), company_name?, address?, city?, country?, locale? (in:ar,en), avatar? (jpg/png/webp, ≤2 MB, ≥96×96), remove_avatar? (bool) }` | `{ message, client: {...} }` | Yes | Use **POST** for multipart (PHP ignores multipart on PUT). Phone is not editable. |
| 9a | POST | `/auth/profile/avatar` | multipart `{ avatar* }` | `{ message, client: {...} }` | Yes | Replaces and deletes the old file. |
| 9b | DELETE | `/auth/profile/avatar` | — | `{ message, client: {...} }` | Yes | Removes the photo; `avatar_url` becomes null. |
| 10 | POST | `/auth/change-password` | `{ current_password*, password* (min:8), password_confirmation* }` | `{ message }` | Yes | — |
| 10a | POST | `/auth/legal/accept` | `{ terms_accepted* (true), channel? (app\|web) }` | `{ success, message, data: { client } }` | Yes | Accepts every Terms / Privacy version in force (after staff publish a material change). |
| 11 | POST | `/auth/fcm-token` | `{ fcm_token }` (present; empty/null clears it) | `{ message }` | Yes | Update Firebase push token. The app sends `''` on logout to stop pushes |
| 13 | DELETE | `/auth/account` | — | `{ success, message }` | Yes | Soft deletes account, revokes all tokens |

---

## 2. Auth - Guest (Token name: `guest-app`)

| # | Method | Endpoint | Request Body | Response | Auth | Notes |
|---|--------|----------|-------------|----------|------|-------|
| 1 | POST | `/guest/auth/send-otp` | `{ phone* }` | `{ success, message }`; 422 for a non-Palestinian mobile (codes go by SMS); 429 when the number had its daily codes | No | — |
| 2 | POST | `/guest/auth/verify-otp` | `{ phone*, otp* (size:6) }` | `{ success, token, data: { id, name, phone, email, gender, locale } }` | No | Returns guest token |
| 3 | POST | `/guest/auth/logout` | — | `{ success }` | Yes | — |
| 4 | GET | `/guest/profile` | — | `{ data: { id, name, phone, email, gender, locale } }` | Yes | — |
| 5 | PUT | `/guest/profile` | `{ name?, email?, gender? (in:male,female) }` | `{ data: { id, name, phone, email, gender, locale } }` | Yes | — |
| 6 | POST | `/guest/fcm-token` | `{ fcm_token* }` | `{ message }` | Yes | — |

---

## 3. Auth - Scanner (Token name: `scanner-app`)

| # | Method | Endpoint | Request Body | Response | Auth | Notes |
|---|--------|----------|-------------|----------|------|-------|
| 1 | POST | `/scanner/auth/login` | `{ email*, password* }` | `{ success, token, data: { id, name, email, phone, avatar, active_assignments_count } }` | No | — |
| 2 | POST | `/scanner/auth/logout` | — | `{ success }` | Yes | — |
| 3 | GET | `/scanner/auth/profile` | — | `{ data: { id, name, email, phone } }` | Yes | — |
| 4 | POST | `/scanner/auth/fcm-token` | `{ fcm_token* }` | `{ message }` | Yes | — |

---

## 4. Auth - Admin (Token name: `admin-app`)

| # | Method | Endpoint | Request Body | Response | Auth | Notes |
|---|--------|----------|-------------|----------|------|-------|
| 1 | POST | `/admin/auth/login` | `{ email*, password* }` | `{ success, token, data: { id, name, email, roles[], permissions[], is_super_admin } }` | No | — |
| 2 | POST | `/admin/auth/logout` | — | `{ success }` | Yes | — |
| 3 | GET | `/admin/auth/profile` | — | `{ data: { id, name, email, roles[], permissions[] } }` | Yes | — |

---

## 5. Client Dashboard

| # | Method | Endpoint | Response | Auth | Notes |
|---|--------|----------|----------|------|-------|
| 1 | GET | `/client/home` | `{ success, data: { totals{events, active_events, invitations, responses, response_rate}, next_event: EventCard\|null, events: EventCard[≤6], free_trial_available, now } }` | Yes | **Used by the app's home.** Same numbers, nearest occasion and order as the web dashboard (`App\Services\Client\ClientHome`) |
| 1b | GET | `/client/events?status=&q=&page=&per_page=` | `{ success, data: EventCard[], meta{current_page,last_page,per_page,total,from,to}, counts{all, draft, pending_payment, active, completed, cancelled} }` | Yes | **The app's My events tab.** Same list as the portal (`App\Services\Client\ClientEventList`): view scope, newest first, `status` one of the enum (anything else ignored), `q` searches the title (wildcards are literal), `per_page` 1-50 (default 12). `counts` ignore the filters |
| 2 | GET | `/client/dashboard/stats` | `{ success, data: [ { title, title_ar, value, icon, color, subtitle, subtitle_ar } ] }` | Yes | Legacy (older app builds). "Active" there means date not passed |
| 3 | GET | `/client/dashboard/recent-events` | `{ success, data: [ { id, name, name_ar, date, status, guest_count, venue, venue_ar, type, type_ar } ] }` | Yes | Legacy (older app builds) |

- **Scope:** own events plus the institution events the member may *view* (door staff see none, as on the portal).
- **EventCard** (`App\Support\ClientEventCard`): `{id, title, status, event_type{id,name_ar,name_en}|null, event_date (Gaza ISO with offset), image_url, invitations_count, opened_count, responded_count, countdown_days (0 today, <0 passed, null when cancelled), next_action{key, step}, step_number (1-6 while draft / pending_payment, else null), steps_total, my_role}`.
- **`next_action.key`:** `complete_details | add_guests | choose_design | pay | track_payment | send_invitations | view_results` (`ClientEventProgress::nextAction`). The app words it itself.
- **`now`:** Gaza time with its UTC offset; the app turns the hourly banner mood with it (`BannerMood`, pinned to the backend by a test).
- **Offline:** no local copy; the offline cache (`DioConsumer`) serves the last answer and adds `_offline.age_seconds`.

---

## 6. Events

| # | Method | Endpoint | Request Body / Query | Response | Auth | Notes |
|---|--------|----------|---------------------|----------|------|-------|
| 1 | GET | `/events` | `?search=&status=&page=&per_page=` (default 15, max 100) | Raw Laravel paginator: `{ data: [ EventObject ], current_page, last_page, per_page, total, ... }` | Yes | The app walks every page (`per_page=50`, at most 20 pages) via `Pagination.fetchAll` |
| 2 | POST | `/events` | `{ title_ar*, title_en?, event_type_id*, template_id?, event_date*, event_time?, venue_id?, description_ar?, description_en? }` | `{ success, data: { id, title_ar, status } }` | Yes | Direct create (not wizard) |
| 3 | GET | `/events/{id}` | — | `{ event: { ...event columns, image_url, allowed_channels, my_role, details } }` | Yes | `details` = everything the host entered, the same fields the portal and the admin show (`App\Support\EventDetails::forApi`): `starts_at` / `ends_at` / `invitations_sent_at` / `created_at` (Gaza ISO with offset; read the wall clock), `venue { name, address, map_url, lat, lng }`, `description`, `occasion_answers [ { key, label_ar, label_en, value, on_invitation } ]` (every answer, even to a question removed later), `replies { require_response, response_deadline, allow_companions, max_companions (0 = not allowed, null = no limit), ask_reason }`, `messages [ { key: invitation\|acceptance\|refusal\|ask_reason_prompt\|ask_reason_question\|thank_you, ar, en } ]` (only the texts the host wrote), `delivery_method`, `billing { package { name_ar, name_en }, custom_package, invitation_limit, invitations_used, remaining, invoice_number, total, paid, currency: ILS }` |
| 4 | PUT | `/events/{id}` | `{ title_ar?, venue_id?, custom_venue_address_ar?, description_ar?, event_date?, status?, max_companions?, allow_companions? }` | `{ success, data: EventObject }` | Yes | Direct edit |
| 5 | DELETE | `/events/{id}` | — | `{ message }`; 422 `{ code: cancel_instead }` once an active event's invitations were sent | Yes (owner) | Cancel instead: `PUT /events/{id} { status: cancelled }` |
| 6 | GET | `/events/{id}/invitations` | `?status=&reply=&q=&page=&per_page=` (default 15, max 1000) | Resource collection: `{ data: [ { id, display_name, guest: { name, email, phone }, status, companions, is_checked_in, open_count } ], links, meta: { current_page, last_page, ... }, counts: { all, attending, not_attending, maybe, none, failed } }` | Yes | Guest list; the app walks every page (`per_page=200`, at most 50 pages) and filters offline itself. `reply` = attending, not_attending, maybe, none (no answer), failed (did not arrive); `q` matches the name or the number's digits (a local 059… finds +970 59…). `counts` ignore the filters |
| 6a | GET | `/events/{id}/activity` | — | `{ success, data: [ { invitation_id, type: opened\|replied, reply, name, companions, at (Gaza ISO) } ] }` (latest 8) | Yes (view) | Event page feed, same as the portal (`App\Services\Client\EventFollowUp`) |
| 6b | GET | `/events/{id}/progress` | — | `{ success, data: { in_setup, next_action{key, step}, steps: [ { key, done, current } ×6 ], invitations_count } }` | Yes (view) | The draft page's checklist (`ClientEventProgress`) |
| 6c | POST | `/events/{id}/invitations/resend-failed` | — | `{ success, data: { failed, sent } }`; 422 `{ message, code: nothing_failed \| resend_blocked }` | Yes (manage) | `throttle:invite-resend`; skips guests past the resend cap / cooldown |
| 6d | PUT | `/events/{id}/invitations/{invitation}/guest` | `{ name, phone }` | `{ success, data: invitation }`; 422 when already sent or the number is invalid | Yes (manage) | Fix a guest before sending (`UnsentGuestEditor`, shared with the portal) |
| 7 | GET | `/events/{id}/statistics` | — | `{ statistics: { checked_in, checked_in_companions, attendees, total_invitations, sent, failed, opened, responded, attending, not_attending, maybe, ... } }` | Yes | `attendees` = checked-in guests + their companions (door count). The app merges `checked_in*` / `attendees` into event details. |
| 8 | POST | `/events/{id}/send-invitations` | `{ delivery_method* (whatsapp\|sms\|email\|app, from `allowed_channels`), invitation_ids? }` | `{ message, dispatched, skipped, invitations_sent_at }`; 409 nothing new to send; 422 not active / channel not in package / nothing pending | Yes | Sends every `pending` invitation. Callable again later: it sends only guests added since |
| 8b | POST | `/events/{id}/guests/add` | `{ guests: [ { name*, phone* } ] }` | 201 `{ created, sent, duplicates, invalid_phones[], over_limit_count, remaining_invitations }`; 422 not active / over package limit | Yes | Add guests to a live event. Sent right away if the invitations already went out |

**EventObject:** `{ id, title_ar, title_en, event_type: { id, name_ar, name_en }, event_date, event_time, venue_data: { name_ar }, custom_venue_address_ar, description_ar, max_invitations, status, rsvp_deadline, response_deadline, package: { name_ar }, template: { name_ar }, max_companions, allow_companions }`

**Where (the place):** the app asks once — one line in `custom_venue_name_ar` («قاعة الأندلس – الرمال، غزة») plus an optional Gaza pin (`custom_venue_lat/lng`). It sends `custom_venue_address_ar: ""` with the line to clear an older separate address, and shows `custom_venue_name_ar` + `custom_venue_address_ar` through `VenueText.line()` (the address only when it adds to the name; same rule as `Event::venueLine()`). Renaming the place in Arabic clears its stale English copy unless `custom_venue_name_en` is sent too. Approving an edit request that changes `venue` also clears the old address and pin.

---

## 7. Event Edit Requests

| # | Method | Endpoint | Request Body | Response | Auth | Notes |
|---|--------|----------|-------------|----------|------|-------|
| 1 | GET | `/events/{id}/edit-requests` | — | `{ success, data: [ { id, event_id, changes: {}, status, admin_notes, created_at } ] }` | Yes | — |
| 2 | POST | `/events/{id}/edit-requests` | `{ name?, venue?, venue_address?, description?, event_date?, max_companions?, allow_companions?, rsvp_deadline? }` | `{ success, data: { id, status: "pending" }, message }` | Yes | Requires admin approval. One pending request per event: a second one is refused with 422 `errors.changes`. On approval of a new `venue` / `event_date`, staff choose whether to notify the guests (WhatsApp template `maktoob_event_changed_*`) and the door staff; the event's own door shifts move with a new date. |

---

## 8. Event Wizard (7-Step Creation Flow)

### Step 1: Event Type & Template

| # | Method | Endpoint | Request Body | Response | Auth |
|---|--------|----------|-------------|----------|------|
| 1 | GET | `/event-wizard/event-types` | — | `{ success, data: [ { id, name_ar, name_en, icon, is_custom } ] }` | Yes |
| 2 | GET | `/event-wizard/event-types/{id}/templates` | — | `{ success, data: [ { id, name_ar, name_en, preview_url, gradient_colors[] } ] }` | Yes |
| 3 | POST | `/event-wizard/event-types/custom` | `{ name_ar*, name_en? }` | `{ success, data: { id, name_ar, is_custom } }` | Yes |
| 4 | POST | `/event-wizard/initialize` | `{ event_type_id*, custom_event_type_name?, template_id* }` | `{ success, data: { event_id } }` | Yes |
| 5 | POST | `/event-wizard/{eventId}/custom-template` | Multipart: `file* (image), description?` | `{ success, data: { template_id } }` | Yes |

### Step 2: Event Details

| # | Method | Endpoint | Request Body | Response | Auth |
|---|--------|----------|-------------|----------|------|
| 1 | GET | `/event-wizard/{eventId}/form-fields` | — | `{ success, data: { fields: [ { key, label_ar, label_en, type, required } ], venues: [...] } }` | Yes |
| 2 | PUT | `/event-wizard/{eventId}/details` | `{ title_ar*, title_en?, description_ar?, description_en?, event_date*, event_time*, venue_id?, custom_venue_name_ar?, custom_venue_address_ar?, custom_venue_city_ar?, custom_venue_lat?, custom_venue_lng?, partner_count?, event_type_form_values? }` | `{ success }` | Yes |

### Step 3: Invitation Preview

| # | Method | Endpoint | Response | Auth |
|---|--------|----------|----------|------|
| 1 | GET | `/event-wizard/{eventId}/preview` | `{ success, data: { preview_url, template_data } }` | Yes |

### Step 4: Guest Management

| # | Method | Endpoint | Request Body | Response | Auth | Notes |
|---|--------|----------|-------------|----------|------|-------|
| 1 | GET | `/event-wizard/{eventId}/guests` | — | `{ success, data: [ { id, name, phone, email, status, source } ] }` | Yes | — |
| 2 | POST | `/event-wizard/{eventId}/guests/import-contacts` | `{ contacts: [ { name*, phone*, email? } ] }` | `{ success, data: { imported, duplicates, guests[] } }` | Yes | Bulk from phone |
| 3 | POST | `/event-wizard/{eventId}/guests/import-excel` | Multipart: `file* (.xlsx)` | `{ success, data: { imported, errors[], guests[] } }` | Yes | Columns: Name, Phone |
| 4 | POST | `/event-wizard/{eventId}/guests/manual` | `{ guests: [ { name*, phone* } ], replace? }` | `{ success, data: { added, guests[] } }` | Yes | `replace: true` (sent by the app) = this is the full list: draft guests not in it are deleted; `guests` may then be empty |
| 5 | GET | `/event-wizard/{eventId}/guests/contacts-selected` | — | `{ success, data: [] }` | Yes | Previously selected |
| 6 | DELETE | `/event-wizard/{eventId}/guests/{guestId}` | — | `{ success }` | Yes | — |
| 7 | POST | `/event-wizard/{eventId}/guests/bulk-remove` | `{ guest_ids: ["uuid-1", ...] }` | `{ success, data: { removed } }` | Yes | — |
| 8 | POST | `/event-wizard/{eventId}/guests/clear` | `{ source? (in: manual, contacts, excel) }` | `{ success, data: { removed } }` | Yes | Clear by source |
| 9 | POST | `/event-wizard/{eventId}/guests/remove-duplicates` | — | `{ success, data: { removed, remaining } }` | Yes | Server-side dedup |
| 10 | GET | `/event-wizard/excel-format` | — | `{ success, data: { columns[], sample_url } }` | Yes | Excel format info |

### Step 4.5: Invitation Configuration

| # | Method | Endpoint | Request Body | Response | Auth |
|---|--------|----------|-------------|----------|------|
| 1 | PUT | `/event-wizard/{eventId}/invitation-config` | `{ default_delivery_method (whatsapp\|sms\|link), message_ar?, message_en?, refusal_message_ar?, refusal_message_en?, allow_companions?, max_companions?, require_response?, response_deadline?, ask_reason_enabled? }` | `{ success }` | Yes |

### Step 5: Extra Services

| # | Method | Endpoint | Request Body | Response | Auth |
|---|--------|----------|-------------|----------|------|
| 1 | GET | `/event-wizard/{eventId}/services` | — | `{ success, data: { services: [ { id, name_ar, name_en, description_ar, description_en, includes_ar, includes_en, category, base_price (ILS, the "from" price when there are levels), icon, image, audience, lead_time_days, active_options: [ { id, name_ar, name_en, price (ILS), includes_ar, includes_en } ] } ], grouped_services, categories } }`. `active_options` are the service's levels (empty = one price); every price is for the whole event. Only services offered for this event: its occasion (admin-picked occasions, none = all) and the client's account kind (`audience`: all / individual / institution). `includes_*` is one item per line. A service with `lead_time_days` cannot be added closer than that to the event | Yes |
| 2 | POST | `/event-wizard/{eventId}/services` | `{ service_ids: [1, 3, 5], service_options?: { "<service id>": <level id> } }` (a service with levels and no pick, or a level of another service, gets its cheapest level) | `{ success, message, data: { services_total, selected_services, requested_service_ids } }`. Before payment it replaces the invoice's services. On an **active (paid)** event it never re-bills: each newly ticked service becomes an add-on request (`requested_service_ids`); see §14.1. `422` while a payment request is under review, or on a completed/cancelled event | Yes |

### Step 6: Package Selection

| # | Method | Endpoint | Request Body | Response | Auth |
|---|--------|----------|-------------|----------|------|
| 1 | GET | `/event-wizard/{eventId}/packages` | — | `{ success, data: [ { id, name_ar, name_en, price (ILS), max_guests, features[], is_popular } ] }` | Yes |
| 2 | POST | `/event-wizard/{eventId}/package` | `{ package_id*, is_custom_package?, custom_guest_count?, custom_service_ids?, custom_channels?, custom_features? }` | `{ success }` | Yes |

### Step 7: Invoice & Submit

| # | Method | Endpoint | Request Body | Response | Auth |
|---|--------|----------|-------------|----------|------|
| 1 | GET | `/event-wizard/{eventId}/invoice` | — | `{ success, data: { invoice_number, base_price, services_total, template_fee, discount, total_price, line_items: [ { description, amount } ], created_at, event_name, package_name, guest_count } }` | Yes |
| 2 | POST | `/event-wizard/{eventId}/save` | `{ is_draft* }` | `{ success, message }` | Yes |
| 3 | GET | `/event-wizard/{eventId}/state` | — | `{ success, data: { current_step, completed_steps[], event, design_allowance } }` (see *Design limits* below) | Yes |
| 4 | POST | `/event-wizard/{eventId}/activate` | — | `{ success, message }` | Yes |

---

## 9. Venues

| # | Method | Endpoint | Request Body / Query | Response | Auth | Notes |
|---|--------|----------|---------------------|----------|------|-------|
| 1 | GET | `/venues` | `?search=&page=&per_page=` (default 15, max 100) | Raw Laravel paginator: `{ data: [ VenueObject ], current_page, last_page, ... }` | Yes | The host's own venues. The app (list and search) walks every page (`per_page=100`, at most 20 pages) via `Pagination.fetchAll` |
| 2 | GET | `/venues/{id}` | — | `{ success, data: VenueObject }` | Yes | — |
| 3 | POST | `/venues` | `{ name_ar*, name_en?, address_ar*, address_en?, city_ar?, city_en?, capacity?, price_per_hour?, latitude?, longitude?, amenities[]? }` | `{ success, data: VenueObject }` | Yes | — |
| 4 | PUT | `/venues/{id}` | Same as POST (all optional) | `{ success, data: VenueObject }` | Yes | — |
| 5 | DELETE | `/venues/{id}` | — | `{ success }` | Yes | — |
| 6 | GET | `/venues-system` | — | `{ success, data: [...] }` | Yes | System-wide (not client-specific) |

**VenueObject:** `{ id, name_ar, name_en, address_ar, address_en, city_ar, city_en, capacity, price_per_hour, rating, image_url, amenities[], latitude, longitude, is_active }`

---

## 10. Client Guests (Contact List)

| # | Method | Endpoint | Request Body / Query | Response | Auth |
|---|--------|----------|---------------------|----------|------|
| 1 | GET | `/guests` | `?search=&page=&per_page=` | `{ success, data: [...] }` | Yes |
| 2 | POST | `/guests` | `{ name*, phone*, email? }` | `{ success, data: {...} }` | Yes |
| 3 | GET | `/guests/{id}` | — | `{ success, data: {...} }` | Yes |
| 4 | PUT | `/guests/{id}` | `{ name?, phone?, email? }` | `{ success, data: {...} }` | Yes |
| 5 | DELETE | `/guests/{id}` | — | `{ success }` | Yes |
| 6 | POST | `/guests/import` | Multipart: `file* (.xlsx)` | `{ success, data: { imported } }` | Yes |

---

## 11. Client Invitations

| # | Method | Endpoint | Request Body | Response | Auth |
|---|--------|----------|-------------|----------|------|
| 1 | GET | `/events/{eventId}/invitations` | `?status=&page=&per_page=` (default 15, max 1000) | Resource collection: `{ data: [...], links, meta: { current_page, last_page, ... } }`. The app walks every page (`per_page=200`, at most 50 pages) | Yes |
| 2 | POST | `/events/{eventId}/invitations` | `{ guest_ids* }` | `{ success, data: {...} }` | Yes |
| 3 | GET | `/invitations/{id}` | — | `{ success, data: {...} }` | Yes |
| 4 | DELETE | `/invitations/{id}` | — | `{ success }` | Yes |
| 5 | POST | `/invitations/{id}/resend` | — | `{ success, message }`; 422 `{ message, code: resend_blocked }` (answered / arrived guest, per-guest cap, cooldown); 429 `{ message, code: throttled }` | Yes |
| 6 | POST | `/invitations/{id}/check-in` | `{ actual_companions? (0..max_companions), notes? }` | `{ message, returning, declined_rsvp, warning, invitation }`; 422 `{ message, code: event_not_active\|qr_not_yet_valid\|qr_expired\|too_many_companions, max_companions? }` | Yes |
| 7 | POST | `/events/{event}/check-in/scan` | `{ qr_code* }` | `{ success, data: { invitation: { ...scan payload, scan flags: `can_check_in` (bool), `blocker` (`event_not_active`|`qr_not_yet_valid`|`qr_expired`|null), `valid_on` ("dd/mm/yyyy" or "dd/mm/yyyy - dd/mm/yyyy" | null)\|`blocker` (`event_not_active`|`qr_not_yet_valid`|`qr_expired`|null), `valid_on` ("dd/mm/yyyy" or "dd/mm/yyyy - dd/mm/yyyy" | null), `blocker_message`, `event_status`, `max_companions` (int\|`blocker` (`event_not_active`|`qr_not_yet_valid`|`qr_expired`|null), `valid_on` ("dd/mm/yyyy" or "dd/mm/yyyy - dd/mm/yyyy" | null), `declined_rsvp` (bool), `warning`, plus `already_checked_in`, `last_check_in{checked_in_at}` } } }`; 404 invalid QR | Yes |

---

## 12. Scanner

### Assignments

| # | Method | Endpoint | Response | Auth |
|---|--------|----------|----------|------|
| 1 | GET | `/scanner/assignments` | `{ success, data: { assignments: [ { id, venue, event, start_date, end_date, status, is_active } ] } }` | Yes (scanner) |
| 2 | GET | `/scanner/assignments/active` | `{ success, data: { assignments[], count } }` | Yes (scanner) |
| 3 | GET | `/scanner/assignments/{id}` | `{ success, data: { id, venue, event, start_date, end_date, status, is_active } }` | Yes (scanner) |

### Venues & Events

| # | Method | Endpoint | Response | Auth |
|---|--------|----------|----------|------|
| 1 | GET | `/scanner/venues` | `{ success, data: [...] }` | Yes (scanner) |
| 2 | GET | `/scanner/venues/{id}` | `{ success, data: {...} }` | Yes (scanner) |
| 3 | GET | `/scanner/venues/{id}/events` | `{ success, data: [...] }` | Yes (scanner) |

### Check-in

| # | Method | Endpoint | Request Body / Query | Response | Auth | Notes |
|---|--------|----------|---------------------|----------|------|-------|
| 1 | POST | `/scanner/check-in/scan` | `{ qr_code*, venue_id* }` | `{ success, data: { invitation: { id, guest_name, response_status, expected_companions, ..., scan flags: `can_check_in` (bool), `blocker` (`event_not_active`|`qr_not_yet_valid`|`qr_expired`|null), `valid_on` ("dd/mm/yyyy" or "dd/mm/yyyy - dd/mm/yyyy" | null)\|`blocker` (`event_not_active`|`qr_not_yet_valid`|`qr_expired`|null), `valid_on` ("dd/mm/yyyy" or "dd/mm/yyyy - dd/mm/yyyy" | null), `blocker_message`, `event_status`, `max_companions` (int\|`blocker` (`event_not_active`|`qr_not_yet_valid`|`qr_expired`|null), `valid_on` ("dd/mm/yyyy" or "dd/mm/yyyy - dd/mm/yyyy" | null), `declined_rsvp` (bool), `warning`, plus `already_checked_in`, `last_check_in{checked_in_at}` } } }` | Yes (scanner) | Scan only. If `can_check_in` is false the app shows `blocker_message` and offers no confirm; `declined_rsvp` shows `warning` but still allows. |
| 2 | POST | `/scanner/check-in/{id}/verify` | `{ invitation_id*, venue_id*, actual_companions? (0..max_companions), notes? }` | `{ success, message, returning, warning, declined_rsvp, data: { attendance_log: { id, invitation_id, checked_in_at, actual_companions, guest_name } } }`; 422 `{ message, code: event_not_active\|qr_not_yet_valid\|qr_expired\|too_many_companions, max_companions? }` | Yes (scanner) | Confirms check-in. `returning: true` = the guest came in earlier today: let back in, `attendance_log` is that first entry, nothing new is recorded. |
| 4 | GET | `/scanner/attendance/{venueId}` | — | `{ success, data: [...] }` | Yes (scanner) | — |

### Offline door (the app's scanner uses these; works with no internet)

The phone downloads a **door pack** (every invitation of the event, the door rules, the gates) before the event, admits guests from it with no connection, and uploads what it recorded later. The same API sits under three roots, by who holds the phone (all `ApiResponse` envelopes, `{success, message, data}`; own limiter `throttle:door` per token, 300/min; responses gzipped when asked):

| Root | Who | Auth |
|---|---|---|
| `/events/{event}/door/*` | the host, or an institution member (`scan` for pack/sync, `manage` for gates/codes/devices) | client token |
| `/scanner/events/{event}/door/*` | a scanner account assigned to the event's venue | scanner token |
| `/door/*` | a staff phone paired with a door code (no account) | its own door token |

| # | Method | Path (under the root) | Request | Response `data` | Notes |
|---|--------|------|---------|----------|-------|
| 1 | GET | `pack` | query `device_uuid, device_name, platform, gate_id, pending` (registers the phone) | `{ format: 1, event{id,title,status,event_date,end_date,valid_from,valid_until (ISO UTC),valid_on,timezone,allow_companions,companion_limit,venue_name}, gates[{id,name,audience: all\|men\|women,is_active}], keys{salt,sign} (base64url), server_time, cursor, roster_version, invitations[{id, hashes[], name, name_en, gender, phone_tail, companions, max_companions, rsvp, check_in\|null}] }` | No QR codes in the pack: `hashes` = first 16 bytes hex of HMAC-SHA256(salt, lower(code)) for `qr_code` and `short_url`. |
| 2 | GET | `changes?since={cursor}&limit=` | same query as pack | `{ cursor, has_more, check_ins[{id,uuid,invitation_id,checked_in_at,companions,gate_id,device_name,source,flag}], event_status, roster_version, server_time }` | Other doors' check-ins. A different `roster_version` = download the pack again. |
| 3 | POST | `check-ins` | `{ device{uuid,name,platform,gate_id,pending}, sent_at (device clock), items[≤500]{ uuid*, invitation_id*, companions, scanned_at, source: online\|offline\|lan\|manual, gate_id, device_uuid, device_name, notes } }` | `{ results[{ uuid, status: recorded\|replayed\|returned\|refused, code?, message?, flag?, max_companions?, check_in? }], device_id, server_time }` | Idempotent by item `uuid`. `online` = live claim (door rules decide; refused = not admitted). Others already happened: kept at `scanned_at` (clock skew corrected), a broken rule → `flag`. An invitation that already came in → `returned` (the guest stepped out and came back; `check_in` is the first entry, nothing is kept). |
| 4 | POST | `lookup` | `{ qr }` | one pack invitation entry; 404 unknown | A guest added after the download. |
| 5 | GET | `summary` | — | `{ totals{invitations,checked_in,companions,people,flagged}, by_source{}, gates[{...gate, guests, companions}], no_gate{guests,companions}, devices[...], can_manage }` | `/door/summary` hides `devices`. |
| 6 | GET/POST/PUT/DELETE | `gates`, `gates/{id}` | `{ name*, audience? }` | gate | client root, `manage` |
| 7 | GET/POST/DELETE | `codes`, `codes/{id}` | `{ label?, gate_id?, max_devices? (1..50) }` | POST: `{ code: "XXXXX-XXXXX" (shown once), door_code{id,label,hint,gate_id,max_devices,used_count,expires_at,revoked,usable}, share_text }` | client root, `manage`. Codes are stored hashed. |
| 8 | GET/DELETE | `devices`, `devices/{id}` | — | `[{id,kind: paired\|client\|scanner\|lan,name,gate_id,last_seen_at,last_sync_at,pending,revoked,check_ins}]` | DELETE revokes a paired phone (401 `device_revoked` after). |

Paired phones: `POST /door/pair {code*, device_uuid*, device_name*, platform?}` (public, `throttle:door-pair`) → `{ token, device, event, gates, access_until }`; 422 `{code: invalid_code\|code_expired\|code_full\|event_not_active\|device_revoked}`. Then `GET /door/session`, `PUT /door/gate {gate_id}`, `POST /door/logout`.

New QR images encode `/i/{short_url}?k={event}.{invitation}.{max|n}.{sig}`: `sig` = base64url of the first 12 bytes of HMAC-SHA256(sign key, `v1|event|invitation|max|lower(short_url)`). An offline door accepts a genuine invitation that is not in its pack yet (warning `unlisted`). Older QRs (plain link, bare code, JSON) still scan through the pack.

**Venue hub (no server).** One door phone serves the others over the venue Wi-Fi / its hotspot: `POST http://{ip}:8787/v1/{hello|pack|claim|push|changes}`, every body AES-256-GCM sealed with the secret in the hub's join QR (`maktoob-door:1:{base64url json{h: hosts[], e: event, t, n, k}}`). Phones joined to it learn within a second or two who another door let in, so a guest coming back shows as a return there too.
- `claim`: answers `admitted`, `returned` (`check_in` = the first entry) or `refused` (`code`). the joined phone waits 4 s at most. The hub gives the server 1.5 s of that (when it answered in the last two minutes), then decides itself; a claim the server got late is replayed by its `uuid`, never counted twice. Claims for different guests run side by side, the same guest one at a time. No answer in time = the joined phone decides alone and uploads later.
- On Android the hub runs as a foreground service (`connectedDevice`, a "venue hub on" notification), so it keeps serving with the screen off or another app open. On iOS it serves only while the app is open: the hub screen keeps the screen awake.

> **Door rules (CheckInService, all check-in paths):** status must be `active` or `completed` (draft / pending_payment / cancelled → `event_not_active`), and the QR is valid **by date in Asia/Gaza** from 00:00 of `event_date`'s day to 23:59:59 of `end_date`'s day (or `event_date`'s day). Before → `qr_not_yet_valid` ("الدعوة صالحة يوم {date}"), after → `qr_expired` ("انتهت صلاحية الدعوة"). **The first entry is the attendance; a later scan that day is a return** (`returning` / `returned`): let back in, nothing recorded, companions not asked again; after the day it is `qr_expired` like any scan. The app's self-service (kiosk) mode uses the same two endpoints: scan, then check in immediately with `actual_companions` = RSVP companions capped at `max_companions`; a return is a "welcome back" with no check-in call.

---

## 13. Payments

| # | Method | Endpoint | Request Body | Response | Auth | Notes |
|---|--------|----------|-------------|----------|------|-------|
| 1 | GET | `/payments` | — | `{ success, data: [...] }` | Yes | — |
| 2 | GET | `/payments/{id}` | — | `{ success, data: {...} }` | Yes | — |
| 3 | POST | `/payments/initiate` | `{ event_id*, amount*, coupon_code? }` | `{ success, data: { payment_id, ... } }` | Yes | Initiate payment |
| 4 | POST | `/coupons/validate` | `{ code*, event_id? }` | `{ success, data: { discount, type } }` | Yes | Validate coupon |
| 5 | GET | `/payments/bank-details` | — | `{ success, message, data: { bank, wallet, wallets, instructions, contact, is_configured } }` | Yes | Maktoob manual-payment details (read-only). See below. |

**`GET /payments/bank-details`** — global Maktoob payment details, edited on Dashboard → Settings → Payment. Every value is `null` when not configured; nothing is ever a placeholder.

```json
{
  "success": true,
  "message": "...",
  "data": {
    "bank": { "name_ar": "…", "name_en": "…", "account_holder": "…|null", "account_number": "…|null", "iban": "…|null", "swift_code": "…|null" },
    "wallet": { "provider_name": "…|null", "account_number": "…" },
    "wallets": [ { "provider_name": "…", "account_number": "…" } ],
    "instructions": { "ar": "…|null", "en": "…|null" },
    "contact": { "invoice_whatsapp": "…|null", "support_whatsapp": "…|null" },
    "is_configured": true
  }
}
```

- `bank` is `null` unless an account number **or** IBAN is set; `wallet` is `null` unless a wallet number is set.
- `wallets` lists **every** configured wallet (e.g. Jawwal Pay, PalPay); `wallet` is just the first one, kept for old app builds. Older backends omit `wallets` — the app then falls back to `wallet`.
- The app chats about a payment on `contact.invoice_whatsapp`, falling back to `support_whatsapp`; the button is hidden when neither is set.
- `is_configured` is `true` when there is a usable bank, wallet, or payment instructions.
- Do not use `/payments/initiate` for this — it is a POST that creates a payment. (A GET there returns 404, captured by `/payments/{id}`.)

---

## 14. Payment Requests (cash / bank transfer / wallet)

| # | Method | Endpoint | Request Body | Response | Auth |
|---|--------|----------|-------------|----------|------|
| 1 | POST | `/payment-requests` | Multipart: `event_id*`, `payment_method` (`bank_transfer`\|`wallet`\|`cash`, default `bank_transfer`), `wallet_provider` (required when `wallet`; the picked `provider_name`), `invoice_images[]` (1–5 images, required unless `cash`), `client_notes` | `201 { message, payment_request }`; `422` if a pending request already exists for the event | Yes |
| 2 | GET | `/payment-requests` | — | `{ success, data: [...] }` | Yes |
| 3 | GET | `/payment-requests/{id}` | — | `{ success, data: {...} }` | Yes |
| 4 | POST | `/payment-requests/{id}/resubmit` | Multipart: `file*` | `{ success }` | Yes |
| 5 | GET | `/payment-requests/upgrade-quote?event_id=&target_package_id=` *or* `&custom_invitations=` | — | `{ success, data: { current_limit, target_limit, current_subtotal, new_subtotal, difference, tax_rate, tax_amount, total } }`; `422` if the event is not `active` or the target is not bigger | Yes |
| 6 | POST | `/payment-requests/upgrade` | Multipart: `event_id*`, `target_package_id` **or** `custom_invitations`, `payment_method`, `wallet_provider`, `invoice_images[]` (unless cash), `client_notes` | `201 { success, data: { payment_request (kind=upgrade), quote } }`. On admin approval the event's invitation limit rises; status stays `active` | Yes |

### 14.1 Extra services on a paid event ("add-ons")

A service added after the event is paid is its own small order. Status (`event_extra_service.status`, forward only): `requested` → team checks availability → `awaiting_payment` (or `declined`) → host pays **only the services' price** (institution discount applied, no tax; never the package again) → `confirmed` → `completed`. The host may withdraw (`withdrawn`) before a payment is sent. Requested / awaiting / declined / withdrawn rows are not part of the event's bill (`amountDue`, upgrade quotes). FCM `type`: `service.approved`, `service.declined` (re-fetch over HTTP).

| # | Method | Endpoint | Request Body | Response | Auth |
|---|--------|----------|-------------|----------|------|
| 1 | GET | `/events/{id}/add-ons` | — | `{ success, data: { can_request, invoice_open, services: [ { extra_service_id, name_ar, name_en, image, icon, quantity, unit_price, total_price, status, notes, decision_note, payment_request_id, can_withdraw } ], payment_due: { items[], subtotal, discount_percent, discount_amount, total }, pending_payment_request: { id, request_number, kind, amount } \| null, available_services: [ExtraService] } }` | Yes (manage) |
| 2 | POST | `/events/{id}/add-ons` | `{ extra_service_id*, extra_service_option_id?, notes? }` (`quantity` is accepted from old builds and ignored: a service covers the whole event, always 1) | `201` + same `data`. `422` if the event is not active, the service is already on it, not offered for this event, or too close to the event for its `lead_time_days` | Yes (manage) |
| 3 | DELETE | `/events/{id}/add-ons/{serviceId}` | — | same `data`; `422` once paid or while its payment is under review | Yes (manage) |
| 4 | POST | `/events/{id}/add-ons/pay` | Multipart, like §14 #1: `payment_method`, `wallet_provider`, `invoice_images[]` (unless cash), `client_notes` | `201 { success, data: { payment_request (kind=services), ...same data } }`. Amount = `payment_due.total`, computed server-side. `422` if nothing is approved or a request is already pending | Yes (owner) |

`POST /events/{id}/extra-services` (and `/bulk`) on an active event also create add-on requests; `DELETE` withdraws one.

Cards don't work in Gaza: the host pays cash in person, by IBAN transfer, or by a local wallet, and an admin approves the request in the dashboard, which activates the event. Cash requests carry no images.

---

## 15. Scanner Requests

| # | Method | Endpoint | Request Body | Response | Auth |
|---|--------|----------|-------------|----------|------|
| 1 | GET | `/scanner-requests` | — | `{ success, data: [...] }` | Yes |
| 2 | POST | `/scanner-requests` | `{ event_id*, venue_id*, date*, ... }` | `{ success, data: {...} }` | Yes |
| 3 | GET | `/scanner-requests/{id}` | — | `{ success, data: {...} }` | Yes |

---

## 16. Notifications

| # | Method | Endpoint | Response | Auth |
|---|--------|----------|----------|------|
| 1 | GET | `/notifications` | `?unread=&page=&per_page=` (default 20, max 100) → `ApiResponse` paginated: `{ success, data: [...], meta: { current_page, last_page, per_page, total, unread_count } }`. Each item: `{ id, type, title, body, data, sender: { name, avatar_url }, is_read, read_at, created_at }`; `sender` is always the platform ("مكتوب" / "Maktoob" + the logo), never a staff member, and the app draws the bundled logo. The app loads `per_page=50` and fetches the next page when the list is scrolled near its end; the bell badge uses `meta.unread_count` (the server's total) | Yes |
| 2 | POST | `/notifications/{id}/read` | `{ success }` | Yes |
| 3 | POST | `/notifications/read-all` | `{ success }` | Yes |
| 4 | GET | `/notifications/unread-count` | `{ success, data: { count } }` | Yes |

---

## 17. Guest Browse

| # | Method | Endpoint | Response | Auth |
|---|--------|----------|----------|------|
| 1 | GET | `/guest/venues` | `{ success, data: [...] }` | Yes (guest) |
| 2 | GET | `/guest/venues/{id}` | `{ success, data: {...} }` | Yes (guest) |
| 3 | GET | `/guest/events` | `{ success, data: [...] }` | Yes (guest) |
| 4 | GET | `/guest/events/{id}` | `{ success, data: {...} }` | Yes (guest) |
| 5 | POST | `/guest/scan-qr` | `{ qr_data* }` | `{ success, data: {...} }` | Yes (guest) |

---

## 18. Public (No Auth)

| # | Method | Endpoint | Response | Notes |
|---|--------|----------|----------|-------|
| 1 | GET | `/public/events` | `{ success, data: [...] }` | — |
| 2 | GET | `/public/events/{id}` | `{ success, data: {...} }` | — |
| 3 | GET | `/public/venues` | `{ success, data: [...] }` | — |
| 4 | GET | `/public/event-types` | `{ event_types: [{id,name_ar,name_en,slug,icon,color,group_id}], groups: [{id,slug,name_ar,name_en,icon,color,event_types:[...]}] }` (raw, no envelope) | Throttled 60/min. `groups` lists active groups with platform (non-custom) types only; empty groups omitted. Used by the guest Explore home. |
| 5 | GET | `/public/templates?event_type_id=` | `{ success, message, data: { templates: [{id,title,image_url,thumbnail_url,event_type_id}], total, event_type_id, is_fallback } }` | Throttled 60/min. Ready-made starter designs (max 20); never client event/invitation images. Falls back to the `other` type's starters (`is_fallback: true`). `event_type_id` must be an integer (422). |
| 6 | GET | `/public/packages` | `{ success, data: [...] }` | — |
| 7 | GET | `/public/config` | `{ success, data: {...} }` | App configuration |
| 7a | GET | `/public/legal/{terms\|privacy}?lang=ar\|en` | `{ success, data: { type, version, title, body, html, change_summary, requires_acceptance, effective_at, published_at, url } }` | Throttled 60/min. The version in force; 404 if none is published. Arabic is the binding text. |
| 8 | GET | `/public/invitation/{qrCode}` | `{ success, data: {...} }` | View invitation by QR |
| 9 | POST | `/public/invitation/{qrCode}/respond` | `{ response*, companions?, reason? }` | RSVP via QR link |

---

## 19. Admin Panel

### Dashboard

| # | Method | Endpoint | Auth |
|---|--------|----------|------|
| 1 | GET | `/admin/dashboard/statistics` | Yes (admin) |
| 2 | GET | `/admin/dashboard/recent-activity` | Yes (admin) |

### Clients

| # | Method | Endpoint | Auth | Notes |
|---|--------|----------|------|-------|
| 1 | GET | `/admin/clients` | Yes (admin) | `?search=&status=` |
| 2 | GET | `/admin/clients/{id}` | Yes (admin) | — |
| 3 | POST | `/admin/clients/{id}/toggle-status` | Yes (admin) | Activate/deactivate |
| 4 | POST | `/admin/clients/{id}/verify` | removed | Staff never mark a client verified |

### Events

| # | Method | Endpoint | Auth |
|---|--------|----------|------|
| 1 | GET | `/admin/events` | Yes (admin) |
| 2 | GET | `/admin/events/{id}` | Yes (admin) |
| 3 | GET | `/admin/events/{id}/statistics` | Yes (admin) |

### Venues

| # | Method | Endpoint | Auth |
|---|--------|----------|------|
| 1 | GET/POST | `/admin/venues` | Yes (admin) |
| 2 | GET/PUT/DELETE | `/admin/venues/{id}` | Yes (admin) |
| 3 | POST | `/admin/venues/{id}/toggle-status` | Yes (admin) |

### Users

| # | Method | Endpoint | Auth |
|---|--------|----------|------|
| 1 | GET/POST | `/admin/users` | Yes (admin) |
| 2 | GET/PUT/DELETE | `/admin/users/{id}` | Yes (admin) |
| 3 | POST | `/admin/users/{id}/toggle-status` | Yes (admin) |
| 4 | GET | `/admin/users/roles` | Yes (admin) |

### Payments & Payment Requests

| # | Method | Endpoint | Auth |
|---|--------|----------|------|
| 1 | GET | `/admin/payments` | Yes (admin) |
| 2 | GET | `/admin/payments/{id}` | Yes (admin) |
| 3 | PUT | `/admin/payments/{id}/status` | Yes (admin) |
| 4 | GET | `/admin/payments/report` | Yes (admin) |
| 5 | GET | `/admin/payment-requests` | Yes (admin) |
| 6 | GET | `/admin/payment-requests/{id}` | Yes (admin) |
| 7 | POST | `/admin/payment-requests/{id}/approve` | Yes (admin) |
| 8 | POST | `/admin/payment-requests/{id}/reject` | Yes (admin) |

### Event Types, Templates, Packages, Services

| # | Method | Endpoint | Auth |
|---|--------|----------|------|
| 1 | GET/POST | `/admin/event-types` | Yes (admin) |
| 2 | GET/PUT/DELETE | `/admin/event-types/{id}` | Yes (admin) |
| 3 | GET/POST | `/admin/templates` | Yes (admin) |
| 4 | GET/PUT/DELETE | `/admin/templates/{id}` | Yes (admin) |
| 5 | GET/POST | `/admin/packages` | Yes (admin) |
| 6 | GET/PUT/DELETE | `/admin/packages/{id}` | Yes (admin) |
| 7 | GET/POST | `/admin/services` | Yes (admin) |
| 8 | GET/PUT/DELETE | `/admin/services/{id}` | Yes (admin) |

### Scanners & Edit Requests

| # | Method | Endpoint | Auth |
|---|--------|----------|------|
| 1 | GET/POST | `/admin/scanners` | Yes (admin) |
| 2 | GET/PUT/DELETE | `/admin/scanners/{id}` | Yes (admin) |
| 3 | GET | `/admin/scanners/{id}/assignments` | Yes (admin) |
| 4 | GET | `/admin/edit-requests` | Yes (admin) |
| 5 | GET | `/admin/edit-requests/{id}` | Yes (admin) |
| 6 | POST | `/admin/edit-requests/{id}/approve` | Yes (admin) |
| 7 | POST | `/admin/edit-requests/{id}/reject` | Yes (admin) |

### Coupons & Notifications

| # | Method | Endpoint | Auth |
|---|--------|----------|------|
| 1 | GET/POST | `/admin/coupons` | Yes (admin) |
| 2 | GET/PUT/DELETE | `/admin/coupons/{id}` | Yes (admin) |
| 3 | GET | `/admin/notifications` | Yes (admin) |
| 4 | POST | `/admin/notifications/send` | Yes (admin) |

---

## Error Response Format

```json
{
  "success": false,
  "message": "Human-readable error message",
  "errors": {
    "field_name": ["Validation error 1", "Validation error 2"]
  }
}
```

| Code | Meaning | App Handling |
|------|---------|-------------|
| 200 | Success | Parse response |
| 201 | Created | Parse response |
| 400 | Bad Request | Show validation errors |
| 401 | Unauthorized | Clear token, redirect to login |
| 403 | Forbidden | Show permission error |
| 404 | Not Found | Show not found message |
| 422 | Validation Error | Show field-level errors |
| 429 | Rate Limited | Retry with backoff |
| 500 | Server Error | Show generic error, log details |

---

## Caching & Offline Strategy

| Data | Cache Method | Key / Box | Offline Behavior |
|------|-------------|-----------|------------------|
| Home Stats | SharedPreferences | `CACHED_STATS` | Serve cached |
| Recent Events | SharedPreferences | `CACHED_RECENT_EVENTS` | Serve cached |
| Events List | Hive | `events_cache` | Serve cached |
| Venues List | Hive | `venues_cache` | Serve cached + local search |
| Auth Token | FlutterSecureStorage | Encrypted | — |
| App Preferences | SharedPreferences | `loggedIn`, `locale`, `themeMode` | Always available |
| General Cache | Hive | `app_cache` | Serve cached |
| Any GET (except live data: generation status, door, auth, scanner) | Hive | `http_cache` (`OfflineCacheInterceptor`) | Last good answer, header `x-maktoob-cache: 1` |
| Door packs, door check-ins, door sessions | SQLite | `maktoob_offline.db` (`OfflineDatabase`) | The door works fully offline; uploads when online (foreground + WorkManager / BGTaskScheduler) |
| Writes made offline (resend / remove invitation) | SQLite | `pending_actions` (`PendingActionsQueue`) | Sent in order when online, each with its own `Idempotency-Key`; Settings → "Waiting to send" |
| Door tokens (paired phone, scanner account) | FlutterSecureStorage | `door_token_{session}` | Survive logout / 401 so queued check-ins still upload |

Every non-GET request carries an `Idempotency-Key` header (`IdempotencyInterceptor`); the backend `IdempotentRequests` middleware replays the first answer for a repeat (`Idempotent-Replayed: true`), 422 `idempotency_key_reused` for the same key with another body, 409 `idempotency_in_progress` while the first still runs. Reads and keyed writes are retried on timeouts / dropped connections / 502-504 (`RetryInterceptor`).

---

## Implementation Status

| Feature | Status | Notes |
|---------|--------|-------|
| Auth (Client) | Mock | Real data source exists, DI uses mock |
| Auth (Guest/Scanner/Admin) | Defined | Endpoints ready, mock in app |
| Home/Dashboard | Mock | Needs real endpoint wiring |
| Events | Partial | Real API calls with mock fallback |
| Event Wizard | Most Complete | `EventWizardApiService` integrated |
| Venues | Mock | All mock data |
| Scanner | Mock | In-memory mock |
| Payments | Mock | Simulated upload |
| Notifications | Defined | Endpoints added, no UI yet |
| Guest Browse | Defined | Endpoints only |
| Admin | Defined | Endpoints only |
| Public | Defined | Endpoints only |

---

## Endpoint Count Summary

| Category | Count |
|----------|-------|
| Auth (all types) | 26 |
| Dashboard | 2 |
| Events + Edit Requests | 11 |
| Event Wizard | 24 |
| Venues | 6 |
| Guests (contact list) | 6 |
| Invitations | 6 |
| Scanner | 10 |
| Payments + Requests | 8 |
| Scanner Requests | 3 |
| Notifications | 4 |
| Guest Browse | 5 |
| Public | 9 |
| Admin | 40+ |
| **Total** | **~160** |

---

## Flutter Endpoint Constants

All endpoints defined in: `lib/core/api/end_points.dart`
Base URL: `Endpoints.baseUrl` (`https://maktoob.social/api/v1`)
Wizard API service: `lib/core/api/event_wizard_api_service.dart`

---

## Institutions

Companies & associations. Backend is the source of truth (`maktoob-backend/app/Http/Controllers/Api/V1/InstitutionController.php`). New endpoints use the `{success, message, data}` envelope.

### Account type in the client payload
`POST /auth/register`, `POST /auth/login`, `POST /auth/verify-otp` and `GET /auth/profile` now return, inside `client`:
```json
{ "account_type": "individual|institution",
  "institution_status": null | "pending" | "approved" | "rejected",
  "institution": null | { "id", "status", "name_ar", "name_en", "sector", "contact_person", "contact_phone",
                          "registration_number", "logo_url", "rejection_reason", "reviewed_at",
                          "discount_percent", "invitation_credits" } }
```
`GET /auth/profile` also returns `client.institution_memberships: [{membership_id, institution_id, institution_name, institution_status, owner_client_id, role}]`.
Show the AdminApprovalWaitingScreen when `account_type == institution && institution_status != approved` (rejected → show `rejection_reason` + "edit & resubmit").

### Register as institution
`POST /auth/register` (multipart if sending a logo) — existing fields plus optional:
`user_type: user|institution`, `organization_name_ar`, `organization_name_en`, `sector` (company|association|ngo|education|government|health|other), `contact_person`, `contact_phone`, `registration_number`, `logo` (jpg/png/webp ≤ 2 MB). `user_type=institution` creates a **pending** institution.

### Endpoints (auth:sanctum + client)
| Method | Path | Who | Notes |
|---|---|---|---|
| GET | `/institution` | any client | `data`: payload above + `memberships` + `pending_invites:[{id, role, institution_id, institution_name, invited_at}]` |
| POST | `/institution/profile` | any client | Fields: `organization_name_ar`, `organization_name_en`, `sector`, `registration_number`, `tax_number`, `website` (scheme added if missing), `official_email`, `contact_person`, `contact_phone`, `governorate`, `address` (old builds: `location`), `description`, `declaration` (accepted), `logo` (multipart, ≥128×128). New/rejected → `pending`. **Approved/suspended:** names, sector, registration/tax numbers, website and logo go to `institution.pending_changes` until staff approve; contact fields apply at once |
| POST | `/institution/documents` | owner | multipart `{type: registration_certificate|tax_certificate|authorization_letter|other, file: pdf/jpg/png/webp ≤ 8 MB}` → 201 + institution payload. Stored privately (max 15) |
| GET | `/institution/documents/{id}` | owner | Streams the owner's own file |
| DELETE | `/institution/documents/{id}` | owner | Only before approval (422 after) |
| GET | `/institution/members` | owner | `data.members:[{id, phone, role, name, status: invited|active, invited_at, accepted_at}]`, `data.roles` |
| POST | `/institution/members` | owner | `{phone, role: manager|door_staff|viewer}` → 201 |
| PUT | `/institution/members/{id}` | owner | `{role}` |
| DELETE | `/institution/members/{id}` | owner | remove |
| POST | `/institution/invites/{id}/accept` | invited phone | 403 if the logged-in phone differs |
| DELETE | `/institution/invites/{id}` | invited/member | decline or leave |
| GET | `/institution/credits` | owner | `{balance, discount_percent, transactions:[{id,type: topup|usage|adjustment, amount, balance_after, event_id, note, created_at}]}` |

### Rules the app must handle
- Pending/rejected institution: `POST /events/{id}/invitations` → **403** `{message, code: "institution_not_approved"}`; activation (`/event-wizard/{id}/activate`, free save) → 422 with blocker `institution_not_approved`.
- Team roles on the owner's events: **manager** = everything the owner does except delete event/payments/team; **door_staff** = `events/{id}/check-in/scan`, `events/{id}/guests/check-in-list`, `invitations/{id}/check-in` only; **viewer** = `GET events/{id}`, `/statistics`, `/invitations` (read-only). `GET /events` now also lists events the member can view/scan. Others → 403/404.
- `GET /event-wizard/{id}/packages`: each package gains `discount_percent`, `final_price`, `is_private`; only system + this owner's private packages are listed. `invoice_total` already includes the discount (backend authoritative).
- `GET /event-wizard/{id}/packages` (2026-10-19): each package also has `price_per_invitation` (₪, null for free/unlimited) and `volume_saving_percent` (int, saving vs the dearest per-invitation package in the list; 0 = none). Maktoob charges **no tax**: `tax_rate` / `tax_amount` stay in invoice payloads but are always 0.
- Prepaid credits: if the approved institution's balance ≥ the package's invitation count, activation succeeds **without payment** and the balance is deducted (one ledger `usage` row per event).
- FCM push types: `institution.approved`, `institution.rejected` (re-fetch `GET /institution`).
- `GET /events` rows and `GET /events/{id}` carry `my_role` (`owner|manager|door_staff|viewer`). The app hides edit for viewer/door_staff, delete and payment for everyone but the owner, and opens the scanner directly for door_staff.
- `POST /event-wizard/initialize` (and the web portal create form) accept optional `institution_id`: allowed only for the owner or an accepted **manager** of that **approved** institution (else 403). The event is created with `client_id` = institution owner (billing, credits, discount, logo apply) and `created_by_client_id` = the caller. The app asks "لمن هذه المناسبة؟" once when the user has such a choice.
- `POST /event-wizard/{id}/save` response `data.credits_cover: bool` — true when the approved institution's prepaid credits cover the package; the app then calls `/activate` directly (credits are deducted) instead of opening payment.


## 2026-10-12 — amount due, payment methods, upgrades, list fields

- **Amount is always server-computed** (`Event::amountDue()`: package or custom-package price + extra services − institution discount + configured tax). `amount` posted to `POST /payment-requests` / resubmit is accepted but **ignored**. `GET /event-wizard/{id}/invoice` totals use the same calculator (new additive field `discount_amount`).
- **Payment methods**: `bank_transfer`, `wallet` and `cash` are always accepted, even when the bank/wallet details are not configured (the team sends them on WhatsApp). `wallet_provider` is free text; the web portal offers `Jawwal Pay` / `PalPay` (+ configured names).
- **Payment request `kind`**: `initial` (default) or `upgrade` (+ `target_package_id`, `target_invitations`). See endpoints 5–6 above.
- **New form-field type `list`** (`field_type: "list"`): the value is an **array of strings** (several people: pilgrims, speakers, honorees, hosts). Send `event_type_form_values: { pilgrim_name: ["أحمد", "سارة"] }`. A plain string is still accepted and split on `،` / `,` / ` و `. Seeded fields now of type `list`: `host_names` (label "أصحاب الدعوة"), `pilgrim_name`, `speaker_names`, `honoree_names`. Titles/highlights join them in Arabic ("أحمد وسارة", "أحمد، سارة ومحمد"). The app should render chips (input + "أضف"); until then a single text field still works.
- `GET /event-wizard/ai-form-fields/{typeId}` for the caller's **own custom type** now creates 2–5 suggested fields on first call (fallback: one `details` textarea "تفاصيل المناسبة").
- Events have `sms_reminder_enabled` (SMS = reminder one day before; WhatsApp = the invitation).

### Institution verification (2026-10-19)
`institution` (in `/auth/profile`, `/institution`, and the profile/document responses) also carries:
`tax_number, website, official_email, governorate, address, description, is_verified, suspension_reason, submitted_at, declaration_accepted_at, verification{name, sector, logo, registration_document, declaration}, documents[{id, type, original_name, mime, size, uploaded_at}], pending_changes{fields{column: value}, logo_url, submitted_at} | null`.

- Status adds **`suspended`** (`pending | approved | rejected | suspended`). Suspended = no activation, no discount, no logo on invitations.
- Staff approve only when: name + sector + declaration + a `registration_certificate` (or the reviewer confirms an offline check) + the owner's number is verified.
- FCM types: `institution.approved|rejected|suspended|reinstated|changes_approved|changes_rejected` → re-fetch `/auth/profile`.
- `POST /auth/change-user-type` was removed (it never did anything). Becoming an institution = `POST /institution/profile`.

### Individuals vs institutions (2026-10-21)
- `GET /event-wizard/{id}/packages` and `POST /event-wizard/{id}/package` only offer the client's **price list**: `packages.audience` is `all | individual | institution`. Institutions never see the free package. A package outside the list returns 404 on select.
- `GET /public/packages?audience=institution` returns the institution list (default: individuals).
- `client` payloads add `conversion_request: null | { status, rejection_reason, submitted_at }`. This is set when an **individual** asked to become an institution: `account_type` stays `individual` (events keep working) until staff approve it, then it becomes `institution`. `GET /institution` returns that request's profile and documents under `institution`. Documents can be uploaded during review (`POST /institution/documents`).
- `POST /auth/register` with `user_type=institution` also accepts `otp_channel: email|phone` (email requires `email`; the code then arrives by email) and `registration_document` (pdf/jpg/png/webp ≤ 8 MB, multipart). Foreign numbers are accepted with their country code (`+46…`).

### Multi-currency (2026-10-22)
The shekel is still the only **ledger** currency: every `amount`, `total` and invoice stays ILS. USD / EUR are a *quote* on top, offered only when staff switched the currency on **and** entered its rate (Settings → Currencies). All changes are additive; older apps keep working in ₪.

- `GET /public/currencies` → `{currencies: [{code, symbol, name, is_base}]}` (ILS first, then the offered ones).
- `GET /public/packages` also returns `currencies` and, per package, `prices_by_currency: {ILS: {amount, formatted, source}, USD: {…}}` (`source` = `base | fixed | converted | free`). `GET /event-wizard/{id}/packages` adds the same `prices_by_currency` to each package.
- `GET /payments/bank-details?currency=USD` returns that currency's own bank account when one is configured (`bank_currency: "USD"`); otherwise the main account with `bank_currency: null` (the bank converts the transfer).
- `GET /payment-requests/currency-quote?event_id=&currency=USD` → `{currency, amount, formatted, rate, ils_total}`. 422 when the currency is not offered. The quote is exact for a package's own total (its fixed price in that currency); with services or a discount it is the shekel total converted and rounded up.
- `POST /payment-requests`, `POST /payment-requests/{id}/resubmit`, `POST /payment-requests/upgrade` accept an optional **`original_currency`** (`USD`/`EUR`/…). The server records `original_currency`, `original_amount` and `exchange_rate` from its own quote (so `original_amount × exchange_rate = amount`); the client chooses a currency, **never an amount**. `ILS` or omitted records nothing foreign. The other funding fields (`bank_route`, `payer_*`, `funding_reference`) are accepted too.
- `clients.currency` stores a client's preferred display currency (portal/landing session for now).
- App work still to do: a currency picker on the payment screen that calls `currency-quote`, sends `original_currency`, and re-fetches `bank-details?currency=`.

### Design limits and billed-message limits (2026-10-24)
Every generated image (a design background or an editor sticker) is a paid call, so the server meters them per event. Designs are **free to the client**; there is nothing to buy.

- **Allowance:** each event has `designs_per_event` designs (default 3, plus any the team granted) and `stickers_per_event` stickers (default 5). A new event gets its own.
- **Unpaid pool:** images on events that were never paid (not `active`/`completed`) also share one pool per phone number over 30 days (default 12). Paying for an event takes its images out of the pool, so a client who pays is never held back by it.
- **One at a time:** a client has one design (and one sticker) in flight at a time.
- **`design_allowance`** = `{ designs_limit, designs_used, designs_left, stickers_limit, stickers_used, stickers_left, pool_reached }`. `designs_left` already includes the pool, so it is the number to show and to disable the button on. It is returned by:
  - `GET /event-wizard/{id}/state` (in `data`);
  - `POST /event-wizard/{id}/generate-prompt`, `confirm-generate`, `refine-generate` (in `data`);
  - `GET /event-wizard/{id}/generation-status/{imageId}` (in `data`, refreshed on every poll);
  - `POST /events/{id}/concepts/generate`, `POST …/concepts/runs/{run}/regenerate` and `GET …/concepts/runs/{run}` (top level).
- **Refunds:** an image that fails or times out gives its design back (the next poll shows it). A concept run keeps only the backgrounds that were actually painted.
- **Concepts:** a client gets at most **3** concepts per request (`requested_count` above 3 is clamped), and never more than `designs_left`. The run's `requested_count` is what was granted.
- **Refusals** carry `{ success: false, message, code, design_allowance }`. Show `message` as is: it is localized and never says "AI".
  - 422 `event_limit` · `sticker_limit` · `unpaid_pool` · `blocked` (the team paused designs for this account);
  - 429 `busy` (previous design still painting) · `client_daily` · `throttled` (more than 4 requests a minute / 30 an hour);
  - 503 `paused` (the team paused designs for everyone, or the daily / monthly spending cap was reached).
- `generate-prompt` already answers 422 when `designs_left` is 0, so a used-up event cannot keep composing prompts.
- **Resends:** at most 3 per guest (`invitation_max_resends`), 15 minutes apart (`invitation_resend_cooldown_minutes`), and never to a guest who answered or arrived.
- **Codes:** a number gets at most 5 codes a day (`otp_daily_per_number`), and the platform has a daily ceiling (`otp_daily_global_cap`). Both come back as the usual cooldown reply with their own `message`. SMS codes go to local mobiles (`+970` / `+972 5x`) only; other numbers get WhatsApp.

## Identity verification (KYC) and institution KYB (2026-10-26)

`is_verified` still means only "the mobile number was confirmed by code". Identity is a separate state: the client sends a photo of an official document with their legal name typed **in parts, exactly as printed** (never split from one string), and the Maktoob team reviews it. Once verified, the legal name is fixed (changing it needs a new document) and invoices / receipts print it; the account `name` stays the display name.

### Endpoints (auth:sanctum + client, `{success, message, data}`)

| Method | Endpoint | Body | Response |
|---|---|---|---|
| GET | `/auth/identity?locale=ar\|en` | — | `data: { identity, submissions: [submission] (latest 5), options: { document_types: [{key, label}], countries: [{code, name}] (PS first, names in `locale`), four_part_id_countries: ["PS"], check_digit_id_countries: ["PS","IL"], minimum_age: 18, max_file_kb: 8192 } }` |
| POST | `/auth/identity` (multipart) | `document_type*` (national_id\|passport\|residence_permit), `document_country*` (ISO 3166 alpha-2), `document_number*`, `document_expires_on?` (Y-m-d, after today), `first_name_ar`, `father_name_ar`, `grandfather_name_ar`, `family_name_ar`, `given_names_latin`, `family_name_latin`, `birth_date*` (Y-m-d, age ≥ 18), `front*` (jpg/png/webp/pdf ≤ 8 MB), `back?`, `declaration*` = 1 | 201 `data: { identity, submission }` · 422 per field · 429 throttled (10/hour; 5 submissions/day) |

- **Rules (mirrored in the app by `IdentityRules`):** Arabic fields Arabic letters only, Latin fields Latin letters only; a Palestinian (`PS`) national ID needs all four Arabic parts; a passport needs `given_names_latin` + `family_name_latin`; otherwise at least first + family name in one script. `PS` / `IL` national ID numbers are 9 digits with the check digit (weights 1,2,1,2…, digit sums, total % 10 == 0, padded left to 9); other numbers `[A-Z0-9]{4,20}`. Arabic-Indic digits are accepted and normalized.
- A new submission **replaces** a pending one. The app compresses the photos (≈2200 px, JPEG quality 85, well under 2 MB) and needs a connection: ID photos are never queued offline.
- `submission` = `{ id, status (pending|approved|rejected|cancelled|superseded), method, document_type, document_country, document_last4, document_expires_on, legal_name, birth_date, has_back, submitted_at, reviewed_at, rejection_reason }`. The full number and the files are never returned.
- `legal_name` = `{ ar: { first, father, grandfather, family, full }, latin: { given, family, full } }`.

### `client.identity` (login / register / verify-otp / GET + PUT `/auth/profile`)

`{ status: none|pending|verified|rejected, verified_at, required, required_reason, legal_name | null, document: { type, country, last4, expires_on } | null, pending: { id, document_type, submitted_at } | null, rejection_reason }`

- `required: true` = the team asked this client to verify; their events cannot be activated until then (activation blocker `identity_required`, shown with the server `message` as is).
- Older backends send no `identity`; the app treats that as "not shown".
- FCM types `identity.approved`, `identity.rejected`, `identity.required` (data: `type`, `client_id`) → re-fetch `/auth/profile` (never trust the push body).

### Register: `name` is the person

`name` is always the person's own full name (letters only, at least two words; 422 otherwise). An institution sign-up sends the representative's name in `name` and the organization in `organization_name_ar` (the app no longer puts the organization's name in `name`; the server tolerates that older shape only when `organization_name_ar == name`). `contact_person` defaults to the representative's name.

### Institution KYB fields

- The institution payload (`client.institution`, `GET /institution` → `data.institution`) adds `trade_name_ar, trade_name_en, display_name, legal_form, registration_authority, registration_country (ISO2), registration_date (Y-m-d), representative_role (owner|director|authorized), country (ISO2)`. `name_ar` / `name_en` are the **official** names (as on the certificate; invoices print them); the trade names are optional brand names shown on invitations.
- `POST /institution/profile` accepts the same keys: `legal_form` ∈ `sole_proprietorship, general_partnership, limited_partnership, private_limited_company, public_limited_company, non_profit_company, association, foreign_ngo, cooperative, government, other`; `registration_date` not in the future. On an approved / suspended institution these are reviewed (held in `pending_changes`) like the other identity fields.
- `verification` checklist keys: `name, sector, logo, legal_details, registration_document, representative_identity, authorization, declaration`. `legal_details` = legal form + registration number + registration country; `representative_identity` = the owner's own identity is verified (the app links it to the identity screen); `authorization` = `representative_role` set, plus an `authorization_letter` document when the role is `authorized`. All but `logo` are required for approval.
