# QueueX --- UI/UX Design Brief v1.0

**Status:** FINAL / BASELINE

## 1. Design direction

QueueX should feel like a modern consumer startup product:

-   clean;
-   minimal;
-   friendly;
-   fast;
-   confident;
-   practical.

The application should prioritize one-hand mobile usage.

## 2. Visual system

### Colors

Primary: Warm Orange

Background: White / light neutral

Success: Green

Warning: Yellow

Peak/Danger: Red

Neutral text: dark charcoal

Secondary text: muted gray

Do not overuse accent colors.

### Color semantics

Green = available/success

Yellow = moderate/warning

Red = peak/danger/full

Orange = primary QueueX action/brand

Do not use red simply as decoration.

## 3. Typography

Use a clean, highly readable sans-serif.

Hierarchy:

-   large page title;
-   section heading;
-   card title;
-   body;
-   supporting metadata;
-   small status label.

Maintain accessible contrast and readable tap targets.

## 4. Spacing

Use a consistent spacing scale. Prefer fewer, reusable spacing values
instead of arbitrary per-screen values.

## 5. Components

Create reusable components for:

-   primary button;
-   secondary button;
-   text field;
-   OTP field;
-   stall card;
-   menu item card;
-   slot card;
-   status chip;
-   order timeline;
-   payment summary;
-   QR card;
-   empty state;
-   error state;
-   loading state;
-   confirmation dialog;
-   bottom sheet.

## 6. Customer navigation

Recommended primary navigation:

-   Home
-   Orders
-   Notifications
-   Profile

Cart can use a persistent contextual action/badge.

## 7. Owner navigation

Recommended primary navigation:

-   Dashboard
-   Orders
-   Menu
-   Slots
-   Profile

Reports can be accessible from Dashboard or a secondary section.

## 8. Home screen

Priority:

1.  greeting/context;
2.  search;
3.  nearby stalls;
4.  categories;
5.  popular stalls/items;
6.  crowd state.

Avoid clutter.

## 9. Stall card

Show:

-   stall image;
-   name;
-   short descriptor;
-   open/closed;
-   crowd state.

Do not show exact queue/order numbers.

## 10. Stall detail

Show prominent:

-   stall identity;
-   status;
-   crowd state;
-   menu categories;
-   popular items.

The customer should reach food selection quickly.

## 11. Menu item card

Show:

-   image;
-   item name;
-   short description;
-   price;
-   availability;
-   add action.

Out-of-stock items remain visible and clearly disabled.

## 12. Slot selection

Slots must be easy to scan.

Each slot shows:

-   time range;
-   state;
-   peak indicator if relevant.

Customer states:

Available Moderate Peak Full

Do not display capacity or booked count.

## 13. Checkout

Checkout should clearly separate:

-   items;
-   subtotal/total;
-   pickup slot;
-   payment mode;
-   final action.

Prevent accidental duplicate submission with a processing state.

## 14. Order tracking

Use a simple horizontal/vertical timeline depending on screen width.

Primary statuses:

Pending Accepted Preparing Ready Completed

Show alternate terminal states clearly:

Rejected Cancelled Expired

## 15. QR screen

QR should be visually dominant.

Also show:

-   order number;
-   stall;
-   pickup slot;
-   payment status;
-   expiry information.

Never expose secrets.

## 16. Owner dashboard

Prioritize operational information:

-   orders requiring action;
-   active orders;
-   today's revenue;
-   slot utilization;
-   peak mode.

Avoid unnecessary charts in MVP.

## 17. Owner order screen

Orders should be grouped by operational state.

Pending orders need obvious Accept/Reject actions.

Reject requires a reason dialog.

Ready orders need an obvious pickup verification action.

## 18. Feedback

Use:

-   inline validation;
-   snackbars/toasts for lightweight results;
-   dialogs for destructive/important confirmation;
-   loading indicators for asynchronous operations.

## 19. Accessibility

-   readable text;
-   sufficient contrast;
-   adequate touch targets;
-   do not rely on color alone;
-   meaningful labels for icons;
-   accessible QR status information.

## 20. Responsive behavior

Design for small Android phones first, then scale to larger screens.

Avoid fixed pixel layouts that break on different dimensions.

## 21. Motion

Use subtle motion only when it improves comprehension.

Avoid:

-   heavy entrance animations;
-   excessive bouncing;
-   long transitions;
-   decorative animation that delays task completion.

## 22. UX principles

Every important action should answer:

-   What is happening?
-   What can I do?
-   Did it succeed?
-   If it failed, how do I recover?

## 23. UI acceptance

A screen is not complete until:

-   loading state exists;
-   empty state exists where applicable;
-   error/retry state exists;
-   disabled state exists where applicable;
-   success feedback exists;
-   navigation works;
-   backend state is reflected correctly.
