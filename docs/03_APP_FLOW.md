# QueueX --- Application Flow v1.0

**Status:** FINAL / BASELINE

## 1. Entry flow

Splash → Session check → If unauthenticated: Onboarding/Login → OTP →
Role resolution → Customer Dashboard OR Owner Dashboard

## 2. Customer flow

### Discovery

Home → Search / Category / Nearby → Stall Details → Menu → Food Details
→ Cart

### Ordering

Cart → Slot Selection → Review → Payment Selection → Payment / Offline
confirmation → Order Confirmation → QR + Order Tracking

### Tracking

Order Details → Pending → Accepted → Preparing → Ready → Pickup →
Completed

Alternate outcomes:

Pending → Cancelled

Pending → Rejected

Ready → Expired

## 3. Customer payment flow

### Online

Cart → Slot selection → Server validation → Temporary slot hold →
Razorpay → Backend verification → Confirm order → Generate QR → Notify
customer

Failure:

Payment failure → Release hold → Show failure/retry → No confirmed order

### Offline

Cart → Slot selection → Validate stall not in peak mode → Create
confirmed order → Generate QR → Show payment due at pickup

## 4. Owner flow

Owner Login → OTP → Owner Dashboard

Dashboard branches:

-   Active Orders
-   Menu Management
-   Slot Management
-   Reports
-   Peak Mode
-   Profile/Settings

## 5. Owner order flow

Active Orders → Order Details

Pending:

Accept → Accepted

Reject → Rejected + mandatory reason

Accepted:

Preparing → Preparing

Preparing:

Ready → Ready

Ready:

QR Verification → If online paid: Complete → If offline unpaid: Collect
payment → mark paid → Complete

## 6. QR flow

Owner scans customer QR → Backend verification → Check token → Check
owner/stall → Check order → Check expiration → Check payment condition →
Check unused status → Mark verified atomically → Allow pickup completion

Failure states:

-   Invalid QR
-   Expired QR
-   Already used
-   Wrong stall
-   Order not ready
-   Payment not satisfied

## 7. Slot flow

Customer opens Slot Selection → Show next 2 hours → Each slot has
customer-visible state → Full disabled → Select slot → Server validates
again before reservation

Owner:

Slot Management → Create/edit capacity → Mark peak → Enable temporary
peak mode

## 8. Peak flow

Owner enables peak mode → Select duration → Server records end time →
During active peak: - online payment required - offline payment
unavailable

When end time passes: → peak mode automatically becomes inactive

## 9. Profile flow

Customer:

Profile → Personal Information → Order History → Payment History →
Notifications → Settings → Help & Support

Owner:

Profile → Stall/Profile information → Settings

## 10. Permission flow

Location permission:

Requested for discovery.

If denied: → explain limitation → allow alternative stall browsing where
supported.

Notification permission:

Requested for operational updates.

If denied: → app remains usable → in-app order status remains
authoritative.

## 11. Global states

Every network-dependent screen should support:

Loading → Success

or:

Loading → Error → Retry

Also:

Empty Offline Permission denied Session expired Unauthorized

## 12. Navigation rules

Customer and Owner navigation are separate.

A customer must never reach owner screens through UI manipulation.

An owner must never reach another owner's operational resources.

Backend authorization remains mandatory even if navigation guards exist.
