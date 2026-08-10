# QueueX --- Backend Schema v1.0

**Status:** FINAL / BASELINE

## 1. Collections

Primary collections:

-   Users
-   Stalls
-   FoodCategories
-   MenuItems
-   Slots
-   Orders
-   OrderItems
-   Payments
-   QRVerifications
-   Notifications

A temporary slot reservation/hold can be implemented as a subcollection
or dedicated collection if required by the chosen transactional design.
Its lifecycle must not expose internal counts to customers.

## 2. Users

Fields:

-   userId
-   name
-   phoneNumber
-   role
-   profileImage
-   isActive
-   fcmToken(s)
-   createdAt
-   updatedAt
-   lastLoginAt

Rules:

-   user ID is tied to Firebase Auth UID;
-   role is server-controlled;
-   customer cannot change role;
-   owner identity is verified by backend authorization.

## 3. Stalls

Fields:

-   stallId
-   ownerId
-   stallName
-   description
-   stallImage
-   phoneNumber
-   locationName
-   latitude
-   longitude
-   status
-   openingTime
-   closingTime
-   timezone
-   isPeakModeEnabled
-   peakModeEndTime
-   createdAt
-   updatedAt

## 4. FoodCategories

Fields:

-   categoryId
-   stallId
-   name
-   imageUrl
-   sortOrder
-   isActive
-   createdAt
-   updatedAt

## 5. MenuItems

Fields:

-   itemId
-   stallId
-   categoryId
-   itemName
-   description
-   price
-   imageUrl
-   preparationTimeMinutes
-   isAvailable
-   createdAt
-   updatedAt

## 6. Slots

Fields:

-   slotId
-   stallId
-   startTime
-   endTime
-   capacity
-   bookedCount
-   status
-   isPeak
-   createdAt
-   updatedAt

`bookedCount` is internal operational data and is not customer-visible.

Slot state should be derived/validated from authoritative backend state.

## 7. Orders

Fields:

-   orderId
-   orderNumber
-   customerId
-   stallId
-   slotId
-   paymentId
-   status
-   paymentMode
-   totalAmount
-   qrVerificationId
-   rejectionReason
-   acceptedAt
-   preparingAt
-   readyAt
-   completedAt
-   cancelledAt
-   rejectedAt
-   expiredAt
-   createdAt
-   updatedAt

## 8. OrderItems

Fields:

-   orderItemId
-   orderId
-   itemId
-   itemName
-   priceAtPurchase
-   quantity
-   subtotal
-   createdAt

This is a purchase snapshot. Historical orders must not depend on the
current menu price/name.

## 9. Payments

Fields:

-   paymentId
-   orderId
-   customerId
-   amount
-   paymentMode
-   paymentStatus
-   gatewayName
-   gatewayTransactionId
-   gatewayOrderId
-   refundStatus
-   refundTransactionId
-   createdAt
-   updatedAt
-   verifiedAt

Never store gateway secrets.

## 10. QRVerifications

Fields:

-   verificationId
-   orderId
-   qrTokenHash or secure token representation
-   status
-   generatedAt
-   expiresAt
-   verifiedAt
-   verifiedByOwnerId

Status:

-   unused
-   verified
-   expired

Use secure random tokens and atomic verification.

## 11. Notifications

Fields:

-   notificationId
-   userId
-   type
-   title
-   message
-   isRead
-   createdAt

## 12. Relationships

User → owns → Stall

Stall → contains → FoodCategories

Stall → contains → MenuItems

Stall → owns → Slots

Customer → creates → Orders

Order → contains → OrderItems

Order → references → Payment

Order → references → QRVerification

User → receives → Notifications

## 13. Security requirements

Customer:

-   can read own orders;
-   can read own notifications;
-   can update allowed profile fields;
-   cannot write payment status;
-   cannot write order status;
-   cannot change role;
-   cannot alter slot capacity.

Owner:

-   can read/manage own stall;
-   can manage own menu;
-   can manage own slots;
-   can process orders belonging to own stall;
-   cannot access another owner's stall data.

Sensitive operations should be performed through trusted backend
functions.

## 14. Firestore query/index planning

Expected query patterns include:

-   stalls by status/location;
-   menu items by stall/category;
-   slots by stall/time range;
-   customer orders by customer/createdAt;
-   owner orders by stall/status/createdAt;
-   notifications by user/createdAt.

Create only the indexes required by actual queries.

## 15. Data retention

Do not automatically delete transactional history simply to simplify UI.

Retention, deletion, and privacy policy should be defined before
production launch.

## 16. Consistency rules

Backend must ensure:

-   slot capacity cannot be exceeded;
-   payment status matches verified gateway state;
-   order state follows allowed transitions;
-   QR cannot be verified twice;
-   expired QR cannot be accepted;
-   offline payment is not permitted during peak;
-   owner authorization matches stall ownership.
