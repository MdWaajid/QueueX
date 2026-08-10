# QueueX --- Project Charter v1.0

**Status:** FINAL / BASELINE\
**Product:** QueueX\
**Phase:** MVP\
**Primary Platform:** Android\
**Future Platform:** iOS

## 1. Product vision

QueueX is a mobile ordering platform for food stalls, canteens, food
courts, and campus dining environments. It reduces physical queues and
crowd congestion by allowing customers to select a short pickup slot,
place an order, receive real-time status updates, and verify pickup
through a one-time QR code.

## 2. MVP objective

The MVP must prove that a customer can:

1.  discover an open or closed stall;
2.  browse its menu;
3.  add items to a cart;
4.  select an available 15-minute slot within the next 2 hours;
5.  pay online or choose offline payment when permitted;
6.  receive an order confirmation and QR;
7.  track order progress in real time;
8.  present the QR at pickup.

The stall owner must be able to:

1.  authenticate;
2.  manage menu items;
3.  manage slots/capacity;
4.  enable peak mode;
5.  process orders;
6.  verify QR pickup;
7.  view basic reports.

## 3. Users

Exactly two MVP roles:

-   Customer
-   Stall Owner

Out of scope:

-   Super Admin
-   Delivery
-   Staff role
-   Multi-stall owner
-   Web dashboard

## 4. Product principles

-   Mobile first
-   Fast
-   Simple one-hand operation
-   Production-oriented
-   Secure by default
-   Real-time where it matters
-   Backend-authoritative for transactions
-   Minimal MVP scope
-   Scalable without premature complexity

## 5. Technology baseline

-   Antigravity IDE
-   Flutter / Dart
-   Firebase Authentication
-   Cloud Firestore
-   Firebase Storage
-   Firebase Cloud Functions
-   Firebase Cloud Messaging
-   Firebase App Check
-   Razorpay India
-   Android first
-   iOS-ready architecture

FlutterFlow is not a required runtime platform for the final
application. If used, it is treated as a prototyping/design aid; the
production source of truth is the Flutter/Dart codebase.

## 6. MVP non-goals

No:

-   delivery;
-   coupons;
-   loyalty;
-   wallet;
-   AI recommendations;
-   reviews;
-   ratings;
-   advanced analytics;
-   super admin;
-   web dashboard.

## 7. Success criteria

The MVP is successful when:

-   customers can complete the end-to-end ordering flow;
-   slot capacity cannot be overbooked under concurrent requests;
-   payment status cannot be forged by the client;
-   QR pickup cannot be reused;
-   owners cannot access another owner's stall data;
-   customers cannot access another customer's private order data;
-   order transitions are enforced;
-   real-time order status works reliably;
-   failures recover safely;
-   the Android application is usable on representative devices.

## 8. Scope freeze

This charter is the baseline for MVP development. New product
capabilities should be treated as post-MVP unless explicitly approved as
a change to the baseline.
