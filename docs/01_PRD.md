# QueueX --- Product Requirements Document v1.0

**Status:** FINAL / BASELINE

## 1. Product summary

QueueX enables customers to order food from participating stalls and
choose a 15-minute pickup slot. Owners manage menus, capacity, peak
periods, and order preparation. QR verification provides controlled
pickup.

## 2. Personas

### Customer

Wants to avoid queues, know when food is ready, and collect it quickly.

### Stall Owner

Wants predictable order volume, controlled pickup flow, visibility into
active orders, and simple operations.

## 3. Customer requirements

### Authentication

-   Splash screen
-   Onboarding
-   Mobile number + OTP
-   One account per mobile number
-   Role-based routing
-   Notification permission
-   Location permission for nearby discovery

If location permission is denied, core ordering must remain usable where
the product can operate without precise location.

### Home

Display:

-   search;
-   nearby stalls;
-   popular stalls;
-   categories;
-   crowd indicators.

Customer crowd states:

-   Available
-   Moderate
-   Peak

Never show actual order counts or internal capacity.

### Stall details

Display:

-   image;
-   name;
-   description;
-   open/closed;
-   crowd state;
-   peak highlights;
-   categories;
-   popular foods.

Closed stalls remain visible but cannot accept new orders.

### Menu

Customer can:

-   browse categories;
-   view item details;
-   add/remove;
-   change quantity.

Item:

-   image;
-   name;
-   description;
-   price;
-   availability.

Out-of-stock items remain visible but cannot be ordered.

### Cart

Show:

-   selected items;
-   quantity;
-   authoritative displayed total.

Proceed to slot selection.

### Slot booking

-   fixed 15-minute slots;
-   only future slots within next 2 hours;
-   full slots disabled;
-   customer sees only state, not booked count;
-   slot capacity enforced by backend transaction.

### Peak mode

Owner can enable temporary peak mode for:

-   15 minutes;
-   30 minutes;
-   1 hour.

During peak mode, online payment is mandatory.

### Payment

Online:

-   Razorpay;
-   trusted verification;
-   confirmation after verified payment;
-   QR generation.

Offline:

-   payment collected at pickup;
-   QR generated for pickup;
-   forbidden during peak mode.

### Order tracking

Customer timeline:

Pending → Accepted → Preparing → Ready → Completed

Rejected, Cancelled, and Expired are terminal outcomes.

### Cancellation

Customer may cancel only while order is Pending.

Cancellation after payment must follow the approved refund/payment
policy defined by implementation; no silent assumption of automatic
refund.

### QR

One unique QR per order. It contains/encodes only the minimum
verification payload, including order identity and a secure random
token. Never expose payment credentials.

QR expires at slot end + 15 minutes and is one-time use.

### Profile

-   personal information;
-   order history;
-   payment history;
-   notifications;
-   settings;
-   help/support.

## 4. Owner requirements

### Authentication

Phone OTP.

### Dashboard

Show:

-   active orders;
-   revenue today;
-   slot utilization;
-   crowd status;
-   peak mode status.

### Order management

Actions:

-   Accept
-   Reject
-   Preparing
-   Ready
-   Complete

Reject requires a reason.

### Order details

Show:

-   customer name;
-   ordered items;
-   pickup slot;
-   payment mode;
-   payment status;
-   QR status.

### Pickup

Online:

-   display PAID;
-   verify QR;
-   complete eligible order.

Offline:

-   display COLLECT PAYMENT;
-   verify QR;
-   collect payment;
-   mark payment paid;
-   complete order.

### Menu management

Owner can:

-   add;
-   edit;
-   delete;
-   update price;
-   change image;
-   mark unavailable.

Historical order items preserve purchase-time name/price.

### Slot management

Owner can:

-   create/configure slots;
-   set capacity;
-   mark peak;
-   enable temporary peak mode.

### Reports

MVP:

-   orders today;
-   revenue today;
-   most ordered items;
-   slot utilization.

## 5. Order lifecycle

### Valid transitions

-   Pending → Accepted
-   Pending → Rejected
-   Pending → Cancelled
-   Accepted → Preparing
-   Preparing → Ready
-   Ready → Completed
-   Ready → Expired

### Transition authority

Customer:

-   Pending → Cancelled

Owner:

-   Pending → Accepted
-   Pending → Rejected
-   Accepted → Preparing
-   Preparing → Ready
-   Ready → Completed

Backend/system:

-   Ready → Expired
-   payment-driven/timeout transitions as explicitly implemented.

## 6. Notifications

Customer notifications:

-   Payment success
-   Payment failure
-   Accepted
-   Preparing
-   Ready
-   Completed
-   Rejected

Notification delivery is best-effort; order state in Firestore remains
authoritative.

## 7. Business invariants

-   One mobile number maps to one account.
-   One owner manages one stall in MVP.
-   A closed stall cannot accept new orders.
-   Offline payment cannot be used during peak mode.
-   A customer cannot cancel after Pending.
-   Rejection requires a reason.
-   Payment failure must not create a confirmed order.
-   Slot capacity cannot be exceeded.
-   QR is one-time use.
-   QR expires after slot end + 15 minutes.
-   Customer cannot view another customer's private data.
-   Owner cannot manage another owner's stall.

## 8. Error expectations

The product must gracefully handle:

-   invalid OTP;
-   network failure;
-   permission denial;
-   empty menu;
-   full slots;
-   unavailable item;
-   payment failure;
-   payment timeout;
-   owner rejecting an order;
-   expired QR;
-   duplicate QR scan;
-   stale screen state;
-   concurrent slot booking.

## 9. Acceptance standard

A requirement is not accepted merely because a screen exists. The full
behavior must work across UI, backend, authorization, data validation,
error handling, and real-time synchronization where applicable.
