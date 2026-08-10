# QueueX --- Implementation Plan v1.0

**Status:** FINAL / BASELINE

## Phase 0 --- Environment

Deliver:

-   Flutter project;
-   Android configuration;
-   Git repository;
-   development Firebase environment;
-   environment configuration;
-   base architecture;
-   linting/formatting;
-   test setup.

Exit criteria:

-   app launches;
-   Firebase connects;
-   dev configuration is isolated.

## Phase 1 --- Design system

Build:

-   theme;
-   typography;
-   spacing;
-   buttons;
-   fields;
-   cards;
-   chips;
-   dialogs;
-   loading/error/empty components.

Exit criteria:

-   reusable components exist;
-   UI follows the approved design brief.

## Phase 2 --- Authentication

Implement:

-   splash;
-   onboarding;
-   phone number;
-   OTP;
-   session restoration;
-   role resolution;
-   logout.

Test:

-   invalid OTP;
-   retry;
-   expired session;
-   customer routing;
-   owner routing.

## Phase 3 --- Authorization foundation

Implement:

-   role-aware navigation;
-   Firestore rules;
-   Storage rules;
-   owner/stall authorization;
-   protected backend functions.

Exit criteria:

-   customer cannot access owner resources;
-   owner cannot access another owner's stall.

## Phase 4 --- Customer discovery

Implement:

-   home;
-   search;
-   categories;
-   nearby stalls;
-   popular stalls;
-   stall details;
-   open/closed state;
-   crowd indicators.

## Phase 5 --- Menu and cart

Implement:

-   category browsing;
-   item details;
-   availability;
-   cart;
-   quantity;
-   totals.

Test:

-   unavailable items;
-   quantity changes;
-   empty cart;
-   price changes after cart load.

## Phase 6 --- Slots

Implement:

-   15-minute slots;
-   next-2-hour window;
-   customer-visible availability states;
-   owner capacity configuration;
-   peak marking.

Critical:

-   transactional concurrency protection.

Test:

-   last slot capacity;
-   simultaneous booking;
-   full slot;
-   stale client;
-   expired slot.

## Phase 7 --- Order creation

Implement backend-authoritative order creation.

Validate:

-   customer;
-   stall;
-   menu availability;
-   purchase-time prices;
-   quantities;
-   slot;
-   payment mode;
-   peak restrictions.

## Phase 8 --- Online payment

Implement:

-   Razorpay test integration;
-   backend payment order;
-   client payment UI;
-   trusted verification;
-   webhook/idempotency;
-   failure handling;
-   hold release.

Do not move to production credentials yet.

## Phase 9 --- Offline payment

Implement:

-   offline order;
-   payment due state;
-   QR;
-   owner collection;
-   payment confirmation;
-   completion.

Verify offline payment is blocked during peak.

## Phase 10 --- Order tracking

Implement:

-   real-time order listener;
-   timeline;
-   state changes;
-   customer cancellation;
-   rejection reason.

## Phase 11 --- Owner operations

Implement:

-   dashboard;
-   active orders;
-   accept;
-   reject;
-   preparing;
-   ready;
-   complete.

Test simultaneous actions and stale screens.

## Phase 12 --- QR pickup

Implement:

-   secure token generation;
-   QR display;
-   owner scanner;
-   backend verification;
-   expiration;
-   one-time atomic use;
-   online/offline payment conditions.

## Phase 13 --- Notifications

Implement:

-   FCM;
-   token refresh;
-   notification records;
-   order event triggers;
-   payment event triggers.

## Phase 14 --- Menu management

Implement:

-   add;
-   edit;
-   delete;
-   price;
-   image;
-   availability.

Verify historical order snapshots remain unchanged.

## Phase 15 --- Slot and peak management

Implement:

-   slot management;
-   peak marking;
-   temporary peak mode;
-   automatic peak expiration;
-   online-only payment during peak.

## Phase 16 --- Reports

Implement only:

-   orders today;
-   revenue today;
-   most ordered items;
-   slot utilization.

Avoid advanced analytics.

## Phase 17 --- Hardening

Review:

-   Firestore rules;
-   Storage rules;
-   Functions;
-   payment verification;
-   QR verification;
-   App Check;
-   secrets;
-   logs;
-   indexes;
-   performance.

## Phase 18 --- Testing

Run:

-   unit tests;
-   widget tests;
-   integration tests;
-   security rule tests;
-   backend tests;
-   concurrency tests;
-   payment failure tests;
-   QR replay tests;
-   offline/network interruption tests.

## Phase 19 --- UAT

Test complete journeys.

Customer:

Login → Browse → Cart → Slot → Pay → Track → QR → Pickup

Owner:

Login → Configure → Receive → Accept → Prepare → Ready → Verify →
Complete

## Phase 20 --- Release preparation

Only after UAT:

-   production Firebase;
-   production Razorpay;
-   production FCM;
-   monitoring;
-   privacy/legal documents;
-   release signing;
-   Play Store preparation.

## Task execution rule

Each phase is broken into small tasks. Do not ask the AI to implement
multiple unrelated phases in one prompt.

Every task ends with verification before the next task begins.
