# Maktoob API Endpoints (Real Backend Spec)

> **Base URL:** `https://maktoob.social/api/v1`
> **Auth:** Bearer Sanctum token in `Authorization` header
> **Content-Type:** `application/json` (unless multipart)
> **Timeout:** 30s (requests), 60s (uploads)
> **Pagination:** `?page=1&per_page=20`. Defaults and caps differ per endpoint, and so do the shapes (raw Laravel paginator with top-level `last_page`; `ApiResponse` `{data[], meta{last_page}}`; Resource collection `{data, links, meta{last_page}}`; `{<items>[], pagination{last_page}}`). The app reads them all through `Pagination` (`lib/core/api/paginated_fetch.dart`): `lastPageOf()` / `fetchAll()` walk pages until `last_page`, an empty page, or a page cap.
> **Currency:** ILS (Israeli New Shekel)
> **Timezone:** Asia/Gaza (+02:00)

---

## 1. Auth - Client (Token name: `mobile-app`)

| # | Method | Endpoint | Request Body | Response | Auth | Notes |
|---|--------|----------|-------------|----------|------|-------|
| 1 | POST | `/auth/register` | `{ name*, phone* (unique), password* (min:8), password_confirmation*, terms_accepted* (true), email?, company_name? }` | `{ message, client: { id, name, email, phone }, otp_sent: true }` | No | Sends OTP via WhatsApp after registration. `terms_accepted` = the "I agree to the Terms and Conditions" box; recorded with version, time, IP and channel. |
| 2 | POST | `/auth/login` | `{ login* (phone or email), password* }` | `{ message, token: "1\|abc...", client: { id, name, email, phone, avatar, is_verified } }` | No | `login` accepts both email and phone |
| 3 | POST | `/auth/verify-otp` | `{ login*, code* (size:6) }` | `{ message, token, client: { id, name, email, phone, is_verified } }` | No | Marks client as verified, returns token |
| 4 | POST | `/auth/resend-otp` | `{ login*, purpose? (in: registration, forgot_password) }` | `{ message, otp_sent: true }` | No | Resends OTP for registration or forgot password |
| 5 | POST | `/auth/forgot-password` | `{ login* }` | `{ message, otp_sent: true }` | No | Sends OTP to phone for password reset |
| 6 | POST | `/auth/reset-password` | `{ login*, code* (size:6), password* (min:8), password_confirmation* }` | `{ message }` | No | Requires valid OTP from forgot-password |
| 7 | POST | `/auth/logout` | — | `{ message }` | Yes | Invalidates current Sanctum token |
| 8 | GET | `/auth/profile` | — | `{ client: { id, name, email, phone, avatar, avatar_url, initials, company_name, address, city, country, locale, is_active, is_verified, verified_at, created_at, account_type, institution_status, institution, institution_memberships, must_change_password, legal: { acceptance_required, terms_version, privacy_version, pending: [{type, version, title, change_summary, url}] } } }` | Yes | `legal.acceptance_required` → the app shows the blocking accept screen (after any forced password change). Whitelisted shape (`Client::accountPayload()`), same `client` as login / register / verify-otp. `avatar` is a storage path; **display `avatar_url`** (absolute). |
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
| 1 | POST | `/guest/auth/send-otp` | `{ phone* }` | `{ success, message }` | No | — |
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
| 1 | GET | `/client/dashboard/stats` | `{ success, data: [ { title, title_ar, value, icon, color, subtitle, subtitle_ar } ] }` | Yes | Cache: `CACHED_STATS` |
| 2 | GET | `/client/dashboard/recent-events` | `{ success, data: [ { id, name, name_ar, date, status, guest_count, venue, venue_ar, type, type_ar } ] }` | Yes | Cache: `CACHED_RECENT_EVENTS` |

> **Caching:** Cache-first fallback. Try remote, cache result. On failure, serve cached data.

---

## 6. Events

| # | Method | Endpoint | Request Body / Query | Response | Auth | Notes |
|---|--------|----------|---------------------|----------|------|-------|
| 1 | GET | `/events` | `?search=&status=&page=&per_page=` (default 15, max 100) | Raw Laravel paginator: `{ data: [ EventObject ], current_page, last_page, per_page, total, ... }` | Yes | The app walks every page (`per_page=50`, at most 20 pages) via `Pagination.fetchAll` |
| 2 | POST | `/events` | `{ title_ar*, title_en?, event_type_id*, template_id?, event_date*, event_time?, venue_id?, description_ar?, description_en? }` | `{ success, data: { id, title_ar, status } }` | Yes | Direct create (not wizard) |
| 3 | GET | `/events/{id}` | — | `{ success, data: EventObject }` | Yes | — |
| 4 | PUT | `/events/{id}` | `{ title_ar?, venue_id?, custom_venue_address_ar?, description_ar?, event_date?, status?, max_companions?, allow_companions? }` | `{ success, data: EventObject }` | Yes | Direct edit |
| 5 | DELETE | `/events/{id}` | — | `{ message }`; 422 `{ code: cancel_instead }` once an active event's invitations were sent | Yes (owner) | Cancel instead: `PUT /events/{id} { status: cancelled }` |
| 6 | GET | `/events/{id}/invitations` | `?status=&page=&per_page=` (default 15, max 1000) | Resource collection: `{ data: [ { id, display_name, guest: { name, email, phone }, status, companions, is_checked_in, open_count } ], links, meta: { current_page, last_page, ... } }` | Yes | Guest list; the app walks every page (`per_page=200`, at most 50 pages) |
| 7 | GET | `/events/{id}/statistics` | — | `{ statistics: { checked_in, checked_in_companions, attendees, total_invitations, sent, failed, opened, responded, attending, not_attending, maybe, ... } }` | Yes | `attendees` = checked-in guests + their companions (door count). The app merges `checked_in*` / `attendees` into event details. |
| 8 | POST | `/events/{id}/send-invitations` | `{ delivery_method* (whatsapp\|sms\|email\|app, from `allowed_channels`), invitation_ids? }` | `{ message, dispatched, skipped, invitations_sent_at }`; 409 nothing new to send; 422 not active / channel not in package / nothing pending | Yes | Sends every `pending` invitation. Callable again later: it sends only guests added since |
| 8b | POST | `/events/{id}/guests/add` | `{ guests: [ { name*, phone* } ] }` | 201 `{ created, sent, duplicates, invalid_phones[], over_limit_count, remaining_invitations }`; 422 not active / over package limit | Yes | Add guests to a live event. Sent right away if the invitations already went out |

**EventObject:** `{ id, title_ar, title_en, event_type: { id, name_ar, name_en }, event_date, event_time, venue_data: { name_ar }, custom_venue_address_ar, description_ar, max_invitations, status, rsvp_deadline, response_deadline, package: { name_ar }, template: { name_ar }, max_companions, allow_companions }`

---

## 7. Event Edit Requests

| # | Method | Endpoint | Request Body | Response | Auth | Notes |
|---|--------|----------|-------------|----------|------|-------|
| 1 | GET | `/events/{id}/edit-requests` | — | `{ success, data: [ { id, event_id, changes: {}, status, admin_notes, created_at } ] }` | Yes | — |
| 2 | POST | `/events/{id}/edit-requests` | `{ name?, venue?, venue_address?, description?, event_date?, max_companions?, allow_companions?, rsvp_deadline? }` | `{ success, data: { id, status: "pending" }, message }` | Yes | Requires admin approval |

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
| 1 | GET | `/event-wizard/{eventId}/services` | — | `{ success, data: [ { id, name_ar, name_en, description_ar, description_en, price (ILS), icon_url, event_type_id } ] }` | Yes |
| 2 | POST | `/event-wizard/{eventId}/services` | `{ service_ids: [1, 3, 5] }` | `{ success, message, data: { services_total, selected_services, requested_service_ids } }`. Before payment it replaces the invoice's services. On an **active (paid)** event it never re-bills: each newly ticked service becomes an add-on request (`requested_service_ids`); see §14.1. `422` while a payment request is under review, or on a completed/cancelled event | Yes |

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
| 3 | GET | `/event-wizard/{eventId}/state` | — | `{ success, data: { current_step, completed_steps[], event } }` | Yes |
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
| 5 | POST | `/invitations/{id}/resend` | — | `{ success, message }` | Yes |
| 6 | POST | `/invitations/{id}/check-in` | `{ actual_companions? (0..max_companions), notes? }` | `{ message, declined_rsvp, warning, invitation }`; 422 `{ message, code: event_not_active|qr_not_yet_valid|qr_expired|too_many_companions\|code: event_not_active|qr_not_yet_valid|qr_expired|too_many_companions, max_companions? }`; 409 `{ message, code: already_checked_in }` | Yes |
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
| 2 | POST | `/scanner/check-in/{id}/verify` | `{ invitation_id*, venue_id*, actual_companions? (0..max_companions), notes? }` | `{ success, message, warning, declined_rsvp, data: { attendance_log: { id, invitation_id, checked_in_at, actual_companions, guest_name } } }`; 422 `{ message, code: event_not_active|qr_not_yet_valid|qr_expired|too_many_companions\|code: event_not_active|qr_not_yet_valid|qr_expired|too_many_companions, max_companions? }`; 409 `{ message, code: already_checked_in }` | Yes (scanner) | Confirms check-in. 409 shows "already checked in" with the scan time. |
| 4 | GET | `/scanner/attendance/{venueId}` | — | `{ success, data: [...] }` | Yes (scanner) | — |

> **Door rules (CheckInService, all check-in paths):** status must be `active` or `completed` (draft / pending_payment / cancelled → `event_not_active`), and the QR is valid **by date in Asia/Gaza** from 00:00 of `event_date`'s day to 23:59:59 of `end_date`'s day (or `event_date`'s day). Before → `qr_not_yet_valid` ("الدعوة صالحة يوم {date}"), after → `qr_expired` ("انتهت صلاحية الدعوة"). The app's self-service (kiosk) mode uses the same two endpoints: scan, then check in immediately with `actual_companions` = RSVP companions capped at `max_companions`.

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
| 2 | POST | `/events/{id}/add-ons` | `{ extra_service_id*, quantity? (1–100), notes? }` | `201` + same `data`. `422` if the event is not active, the service is already on it, or not offered for its type | Yes (manage) |
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
