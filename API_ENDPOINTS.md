# Maktoob API Endpoints (Real Backend Spec)

> **Base URL:** `https://maktoob.social/api/v1`
> **Auth:** Bearer Sanctum token in `Authorization` header
> **Content-Type:** `application/json` (unless multipart)
> **Timeout:** 30s (requests), 60s (uploads)
> **Pagination:** `?page=1&per_page=20` (max 100)
> **Currency:** ILS (Israeli New Shekel)
> **Timezone:** Asia/Gaza (+02:00)

---

## 1. Auth - Client (Token name: `mobile-app`)

| # | Method | Endpoint | Request Body | Response | Auth | Notes |
|---|--------|----------|-------------|----------|------|-------|
| 1 | POST | `/auth/register` | `{ name*, phone* (unique), password* (min:8), password_confirmation*, email?, company_name? }` | `{ message, client: { id, name, email, phone }, otp_sent: true }` | No | Sends OTP via WhatsApp after registration |
| 2 | POST | `/auth/login` | `{ login* (phone or email), password* }` | `{ message, token: "1\|abc...", client: { id, name, email, phone, avatar, is_verified } }` | No | `login` accepts both email and phone |
| 3 | POST | `/auth/verify-otp` | `{ login*, code* (size:6) }` | `{ message, token, client: { id, name, email, phone, is_verified } }` | No | Marks client as verified, returns token |
| 4 | POST | `/auth/resend-otp` | `{ login*, purpose? (in: registration, forgot_password) }` | `{ message, otp_sent: true }` | No | Resends OTP for registration or forgot password |
| 5 | POST | `/auth/forgot-password` | `{ login* }` | `{ message, otp_sent: true }` | No | Sends OTP to phone for password reset |
| 6 | POST | `/auth/reset-password` | `{ login*, code* (size:6), password* (min:8), password_confirmation* }` | `{ message }` | No | Requires valid OTP from forgot-password |
| 7 | POST | `/auth/logout` | — | `{ message }` | Yes | Invalidates current Sanctum token |
| 8 | GET | `/auth/profile` | — | `{ client: { id, name, email, phone, avatar, company_name, is_verified, locale } }` | Yes | — |
| 9 | PUT | `/auth/profile` | `{ name?, company_name?, address?, city?, country?, locale? (in:ar,en), avatar? (file, max:2048) }` | `{ message, client: {...} }` | Yes | Multipart if uploading avatar |
| 10 | POST | `/auth/change-password` | `{ current_password*, password* (min:8), password_confirmation* }` | `{ message }` | Yes | — |
| 11 | POST | `/auth/fcm-token` | `{ fcm_token* }` | `{ message }` | Yes | Update Firebase push notification token |
| 12 | POST | `/auth/change-user-type` | `{ new_type* (in:client,scanner), reason? (max:1000) }` | `{ success, message }` | Yes | Requires admin approval |
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
| 1 | GET | `/events` | `?search=&status=&page=&per_page=` | `{ success, data: [ EventObject ], meta: { current_page, last_page, per_page, total } }` | Yes | Cache in Hive `events_cache` |
| 2 | POST | `/events` | `{ title_ar*, title_en?, event_type_id*, template_id?, event_date*, event_time?, venue_id?, description_ar?, description_en? }` | `{ success, data: { id, title_ar, status } }` | Yes | Direct create (not wizard) |
| 3 | GET | `/events/{id}` | — | `{ success, data: EventObject }` | Yes | — |
| 4 | PUT | `/events/{id}` | `{ title_ar?, venue_id?, custom_venue_address_ar?, description_ar?, event_date?, status?, max_companions?, allow_companions? }` | `{ success, data: EventObject }` | Yes | Direct edit |
| 5 | DELETE | `/events/{id}` | — | `{ success }` | Yes | — |
| 6 | GET | `/events/{id}/invitations` | — | `{ success, data: [ { id, display_name, guest: { name, email, phone }, status, companions, is_checked_in, open_count } ] }` | Yes | Guest list |
| 7 | GET | `/events/{id}/statistics` | — | `{ success, data: { statistics: { total_invitations, sent, opened, responded, attending, not_attending, maybe } } }` | Yes | — |
| 8 | POST | `/events/{id}/send-invitations` | — | `{ success, message }` | Yes | Triggers bulk sending |
| 9 | POST | `/events/{id}/duplicate` | — | `{ success, data: { id, title_ar } }` | Yes | Duplicates event |

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
| 4 | POST | `/event-wizard/{eventId}/guests/manual` | `{ guests: [ { name*, phone*, email? } ] }` | `{ success, data: { added, guests[] } }` | Yes | — |
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
| 2 | POST | `/event-wizard/{eventId}/services` | `{ service_ids: [1, 3, 5] }` | `{ success }` | Yes |

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
| 1 | GET | `/venues` | `?query=xxx` | `{ success, data: [ VenueObject ] }` | Yes | Cache in Hive `venues_cache` |
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
| 1 | GET | `/events/{eventId}/invitations` | — | `{ success, data: [...] }` | Yes |
| 2 | POST | `/events/{eventId}/invitations` | `{ guest_ids* }` | `{ success, data: {...} }` | Yes |
| 3 | GET | `/invitations/{id}` | — | `{ success, data: {...} }` | Yes |
| 4 | DELETE | `/invitations/{id}` | — | `{ success }` | Yes |
| 5 | POST | `/invitations/{id}/resend` | — | `{ success, message }` | Yes |
| 6 | POST | `/invitations/{id}/check-in` | — | `{ success }` | Yes |

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
| 1 | POST | `/scanner/check-in/scan` | `{ qr_data* }` | `{ success, data: { id, name, phone, status, companions, event_id } }` | Yes (scanner) | Scan & check-in |
| 2 | POST | `/scanner/check-in/{id}/verify` | `{ guest_id? }` | `{ success, data: {...} }` | Yes (scanner) | Manual verify |
| 3 | GET | `/scanner/check-in/history` | `?search=xxx` | `{ success, data: [...] }` | Yes (scanner) | — |
| 4 | GET | `/scanner/attendance/{venueId}` | — | `{ success, data: [...] }` | Yes (scanner) | — |

---

## 13. Payments

| # | Method | Endpoint | Request Body | Response | Auth | Notes |
|---|--------|----------|-------------|----------|------|-------|
| 1 | GET | `/payments` | — | `{ success, data: [...] }` | Yes | — |
| 2 | GET | `/payments/{id}` | — | `{ success, data: {...} }` | Yes | — |
| 3 | POST | `/payments/initiate` | `{ event_id*, amount*, coupon_code? }` | `{ success, data: { payment_id, ... } }` | Yes | Initiate payment |
| 4 | POST | `/coupons/validate` | `{ code*, event_id? }` | `{ success, data: { discount, type } }` | Yes | Validate coupon |

---

## 14. Payment Requests (Bank Transfer)

| # | Method | Endpoint | Request Body | Response | Auth |
|---|--------|----------|-------------|----------|------|
| 1 | POST | `/payment-requests` | Multipart: `file* (invoice image), event_id*` | `{ success, data: { id, status: "pending" } }` | Yes |
| 2 | GET | `/payment-requests` | — | `{ success, data: [...] }` | Yes |
| 3 | GET | `/payment-requests/{id}` | — | `{ success, data: {...} }` | Yes |
| 4 | POST | `/payment-requests/{id}/resubmit` | Multipart: `file*` | `{ success }` | Yes |

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
| 1 | GET | `/notifications` | `{ success, data: [...] }` | Yes |
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
| 4 | GET | `/public/event-types` | `{ success, data: [...] }` | — |
| 5 | GET | `/public/templates` | `{ success, data: [...] }` | — |
| 6 | GET | `/public/packages` | `{ success, data: [...] }` | — |
| 7 | GET | `/public/config` | `{ success, data: {...} }` | App configuration |
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
| 4 | POST | `/admin/clients/{id}/verify` | Yes (admin) | Manual verify |

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
