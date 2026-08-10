# QueueX --- Technical Requirements Document v1.0

**Status:** FINAL / BASELINE

## 1. Architecture

Use a Flutter mobile client with Firebase backend services.

Logical layers:

-   Presentation
-   Application/use-case logic
-   Data/repository layer
-   Firebase/backend integration
-   Trusted Cloud Functions for sensitive operations

Keep feature boundaries clear so future iOS support is practical.

## 2. Client

-   Flutter
-   Dart
-   Material-based design system customized to QueueX
-   Responsive layouts
-   Reusable components
-   Strong typing
-   Explicit loading/error/empty states

State management may use a maintained, well-supported approach selected
during implementation, but the choice must be documented and should not
create unnecessary global state.

## 3. Firebase

Use:

-   Firebase Authentication for phone OTP;
-   Firestore for transactional application data;
-   Storage for images;
-   Cloud Functions for trusted operations;
-   FCM for push notifications;
-   App Check where supported.

## 4. Trusted backend operations

Sensitive operations should be callable through trusted backend code or
equivalent server-authoritative mechanisms:

-   create/confirm order;
-   reserve/release slot capacity;
-   verify payment;
-   process Razorpay webhooks;
-   transition order state;
-   verify QR;
-   complete offline payment;
-   expire eligible orders/QRs;
-   enforce peak payment rules;
-   send operational notifications.

## 5. Slot reservation design

Never implement capacity as an unprotected read-modify-write.

Recommended lifecycle:

`Available → Held → Confirmed → Released/Expired`

A short-lived reservation/hold may be created while payment is in
progress. Its duration must be finite and server-authoritative.

For offline payment, the slot can become confirmed after successful
server-side order creation.

For online payment:

1.  validate cart and slot;
2.  create a short-lived hold transactionally;
3.  initiate payment;
4.  verify payment;
5.  confirm order and slot;
6.  release hold if payment fails/expires.

The exact hold duration is a configurable technical parameter and must
not be hard-coded into UI.

## 6. Order creation

The backend must calculate/validate:

-   stall;
-   customer;
-   menu item availability;
-   purchase-time prices;
-   quantities;
-   slot;
-   payment mode;
-   peak restrictions;
-   total.

The client-provided total is not authoritative.

## 7. Payment architecture

Razorpay secrets remain server-side.

The payment lifecycle must support:

-   initiation;
-   success;
-   failure;
-   timeout;
-   duplicate callback;
-   webhook retry;
-   idempotent verification;
-   refund state where applicable.

A payment callback received by the client is not, by itself, proof of
successful payment.

## 8. Order state enforcement

Backend validates every transition against the state machine.

Concurrent actions must not produce invalid states.

Example:

If two owners attempt to act on the same Pending order, only the first
valid transition succeeds.

## 9. QR architecture

Generate a cryptographically strong random token on the trusted backend.

Store a secure representation according to the selected implementation.
Avoid exposing unnecessary internal identifiers.

Verification must be atomic enough to prevent two simultaneous scans
from both succeeding.

QR validity:

`current server time <= slot.endTime + 15 minutes`

and:

`verification status = unused`

before successful verification.

## 10. Time

Business time uses server/trusted backend time and the stall's
configured timezone.

Never trust device clock for:

-   slot eligibility;
-   QR expiration;
-   peak mode expiration;
-   order expiration;
-   opening hours.

## 11. Real-time

Firestore listeners should be scoped.

Customer:

-   own active order;
-   relevant notifications.

Owner:

-   own stall active orders;
-   relevant slot/operational data.

Use queries, limits, pagination, and indexes appropriately.

## 12. Security model

Firebase Auth identifies users.

Firestore/Storage rules enforce access.

Role claims or server-controlled role fields must not be user-editable.

The backend must verify authorization for owner operations.

## 13. Suggested authorization matrix

  Resource                Customer                    Owner
  ----------------------- --------------------------- ----------------------
  Own profile             Read/write allowed fields   Own profile
  Stall discovery         Read published data         Own stall management
  Menu                    Read                        Own stall CRUD
  Slots                   Read available state        Own stall management
  Own orders              Read                        Own stall orders
  Other customer orders   No                          No
  Payment status          Own order                   Own stall order
  QR verification         No owner verification       Own stall
  Reports                 No                          Own stall

## 14. Storage

Recommended paths:

`stalls/{stallId}/...`

`menuItems/{itemId}/...`

Access must be ownership-aware.

## 15. Notifications

Backend events trigger notifications. Store notification records for
in-app history.

FCM token refresh must be handled.

## 16. Reliability

Sensitive commands should be idempotent where retries are possible.

Examples:

-   payment verification;
-   webhook processing;
-   order confirmation;
-   QR verification;
-   notification creation.

## 17. Observability

Development/staging should record useful operational events without
logging secrets or sensitive credentials.

Production monitoring should be introduced before release.

## 18. Environment separation

At minimum:

-   development;
-   staging;
-   production.

Use separate Firebase environments/projects or an equivalent controlled
separation.

## 19. Performance requirements

Avoid:

-   unbounded listeners;
-   loading entire collections;
-   oversized images;
-   repeated identical reads;
-   polling for data that can use listeners.

Use:

-   pagination;
-   query limits;
-   image compression;
-   caching where appropriate;
-   targeted listeners.

## 20. Testing

Required coverage for critical logic:

-   Firestore security rules;
-   slot concurrency;
-   order transitions;
-   payment verification;
-   QR one-time verification;
-   authorization;
-   offline payment;
-   notification triggers.

## 21. Release security

Before production:

-   enable appropriate App Check;
-   verify security rules;
-   remove test credentials;
-   configure production payment keys securely;
-   verify webhook endpoint security;
-   verify least-privilege access;
-   verify logging does not expose secrets.
