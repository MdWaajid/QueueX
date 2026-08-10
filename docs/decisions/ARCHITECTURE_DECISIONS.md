# QueueX --- Architecture Decisions v1.0

**Status:** FINAL / BASELINE

## ADR-001 --- Flutter/Dart is the production client

Decision:

QueueX production mobile application uses Flutter/Dart.

Antigravity IDE is the primary development environment.

FlutterFlow is optional for prototyping/design assistance and is not the
production architecture authority.

Reason:

-   direct code control;
-   reusable architecture;
-   Firebase integration;
-   future iOS expansion;
-   testability;
-   maintainability.

## ADR-002 --- Firebase is the backend platform

Use Firebase Authentication, Firestore, Storage, Cloud Functions, FCM,
and App Check where applicable.

Reason:

-   fast MVP delivery;
-   real-time Firestore;
-   integrated authentication;
-   serverless backend;
-   scalable foundation.

## ADR-003 --- Two roles only

Customer and Stall Owner.

No additional role in MVP.

## ADR-004 --- Backend-authoritative transactions

Slot reservations, payment verification, QR verification, authorization,
and critical order transitions are backend-authoritative.

Reason:

The mobile client is untrusted and concurrent users can act
simultaneously.

## ADR-005 --- 15-minute slots

All pickup slots use a fixed 15-minute duration in MVP.

## ADR-006 --- Two-hour customer booking horizon

Customers can book only slots within the next 2 hours.

## ADR-007 --- Peak mode requires online payment

When a stall is in active peak mode, offline payment is disabled.

Reason:

Reduce pickup/payment uncertainty during congestion.

## ADR-008 --- QR expires after slot end + 15 minutes

QRs are one-time verification credentials for pickup and expire at the
defined boundary.

## ADR-009 --- Purchase snapshots

OrderItems store item name and price at purchase time.

Reason:

Menu data changes over time; historical orders must remain accurate.

## ADR-010 --- No actual customer-facing queue counts

Customers see only:

-   Available
-   Moderate
-   Peak
-   Full

Internal counts remain backend/owner operational data.

## ADR-011 --- No super admin in MVP

Operational complexity is intentionally excluded from the first release.

## ADR-012 --- No web dashboard in MVP

The MVP is mobile-only.

## ADR-013 --- Specification freeze

These documents form the approved MVP baseline. Changes after
implementation begins should be recorded as explicit decisions rather
than silently editing requirements.

## ADR-014 --- Real-time only where useful

Use real-time listeners for active operational state, not for every
collection.

## ADR-015 --- Environment separation

Development, staging, and production must be separated before production
release.

## ADR-016 --- Security over convenience

No client-side shortcut may override backend authorization or
transaction rules.

## ADR-017 --- Idempotency

Payment callbacks, webhooks, order confirmation, and QR verification
must tolerate retries without duplicating financial or transactional
effects.
