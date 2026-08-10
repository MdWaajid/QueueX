# QueueX --- AGENTS.md

## Purpose

You are an engineering collaborator working on QueueX. Treat the
approved project documentation as the source of truth. Implement exactly
the requested scope, preserve the approved architecture, and never
invent business rules when an important requirement is ambiguous.

## Source of truth

Read these documents before implementing affected functionality:

1.  `docs/00_PROJECT_CHARTER.md`
2.  `docs/01_PRD.md`
3.  `docs/02_TRD.md`
4.  `docs/03_APP_FLOW.md`
5.  `docs/04_UI_UX_DESIGN_BRIEF.md`
6.  `docs/05_BACKEND_SCHEMA.md`
7.  `docs/06_IMPLEMENTATION_PLAN.md`
8.  `docs/decisions/ARCHITECTURE_DECISIONS.md`

Priority:

1.  Explicit approved decision
2.  Project Charter
3.  PRD
4.  TRD
5.  Backend Schema
6.  App Flow
7.  UI/UX
8.  Implementation Plan
9.  Existing approved code
10. AI suggestion

## Working rules

-   Work on one clearly defined task at a time.
-   Inspect existing code before editing it.
-   Make the smallest safe change.
-   Do not add unrequested features.
-   Do not silently change database schema, security, payment behavior,
    roles, or state transitions.
-   Ask for clarification before making a major architectural or
    security decision.
-   Never perform destructive production operations without explicit
    approval.
-   Never claim a feature is production-ready without verification.
-   Report changed files, tests, assumptions, risks, and remaining work.

## Technical authority

The client is never trusted for security-sensitive decisions.

Backend-authoritative decisions include:

-   User authorization
-   Role enforcement
-   Stall ownership
-   Slot capacity
-   Slot reservation
-   Order creation
-   Order state transitions
-   Payment verification
-   QR verification
-   QR expiration
-   Peak-mode payment restrictions
-   Time-sensitive business rules

## QueueX roles

Only:

-   Customer
-   Stall Owner

No Super Admin, delivery role, staff role, or multi-stall owner in MVP.

## Order states

Valid states:

`Pending`, `Accepted`, `Preparing`, `Ready`, `Completed`, `Rejected`,
`Cancelled`, `Expired`

Valid transitions:

-   Pending → Accepted
-   Pending → Rejected
-   Pending → Cancelled
-   Accepted → Preparing
-   Preparing → Ready
-   Ready → Completed
-   Ready → Expired

Do not create arbitrary transitions.

## Slot rules

-   Slot duration: 15 minutes.
-   Customers may book only within the next 2 hours.
-   Customers see only Available, Moderate, Peak, Full.
-   Actual order/booked counts are not customer-visible.
-   Capacity must be enforced transactionally/server-side.
-   A reservation must have an explicit lifecycle so abandoned payment
    attempts do not permanently consume capacity.

## Payment rules

-   Online payment uses Razorpay.
-   Offline payment is collected at pickup.
-   Offline payment is forbidden during peak mode.
-   Payment success must be verified by trusted backend logic.
-   Do not trust client-supplied payment amount or payment status.
-   Payment retries/webhooks must be idempotent.

## QR rules

Each order has one unique secure QR token.

A QR is valid only when:

-   token exists;
-   token belongs to the order;
-   order belongs to the owner's stall;
-   QR has not been used;
-   current server time is before slot end + 15 minutes;
-   order is eligible for pickup;
-   payment conditions are satisfied.

Successful verification is one-time only.

## Security

Never expose secrets, service-account credentials, Razorpay secrets,
webhook secrets, OTPs, or private keys in client code, Firestore
documents, logs, or Git.

Firestore and Storage rules must enforce authorization independently of
Flutter UI.

## Real-time behavior

Use Firestore listeners for narrowly scoped real-time data such as:

-   active customer order;
-   owner's active orders;
-   notifications;
-   operational slot state where required.

Avoid unbounded listeners and unnecessary polling.

## Time

Business decisions use trusted server time and the stall's configured
timezone. Device clock changes must not bypass slot, peak, QR, or
opening-hour rules.

## UI

Follow `docs/04_UI_UX_DESIGN_BRIEF.md`. Reuse the approved design
system. Every important screen should handle loading, success, empty,
error, retry, and permission/offline states where applicable.

## Testing

Before declaring a feature complete:

-   run static analysis;
-   run applicable unit/widget/integration tests;
-   test Firebase rules/backend behavior where affected;
-   manually test the feature on a real or representative Android
    device/emulator;
-   test important failure and concurrency cases.

Critical areas requiring strong testing:

-   OTP authentication
-   authorization
-   slot concurrency
-   payment verification
-   order transitions
-   QR verification
-   offline payment
-   notification triggers

## Stop conditions

Stop and ask for approval when:

-   requirements conflict;
-   a critical business rule is missing;
-   a destructive database migration is required;
-   a major architecture change is required;
-   a new external service is required;
-   a new role is required;
-   the requested implementation would violate an approved decision.

## Completion report

For each implementation task, report:

-   Summary
-   Files changed
-   Backend/database changes
-   Tests executed
-   Manual verification
-   Assumptions
-   Known limitations
-   Next task

Do not expand scope silently.
