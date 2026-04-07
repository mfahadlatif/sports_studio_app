# Approval Workflow Implementation Walkthrough

This document outlines the changes made to implement a consistent approval workflow for Complexes and Grounds.

## 1. Backend Changes (PHP/Laravel)

### 1.1 Email Notifications
- Created `StatusUpdateAlert` mailable to notify owners when their complex or ground status is updated to 'active'.
- Added `email_owner_on_approval` logic in `AdminController`.

### 1.2 Administrative Routes
- Added `PUT /admin/complexes/{id}/status` for explicit approval actions.
- Refactored `updateGroundStatus` to include the same notification logic.

### 1.3 Visibility Logic
- Re-verified `GroundController@index` and `show` to ensure they only show 'active' entities with 'active' parent complexes for public users.

## 2. Mobile App Changes (Flutter)

### 2.1 Admin Panel Improvements
- **Actions:** Replaced the previous broken/missing logic in `AdminComplexManagementPage` with proper "Approve" (tick) and "Deactivate" (pause) buttons.
- **Logic:** Integrated the new `PUT /admin/complexes/{id}/status` API call.

### 2.2 Owner Submission Flow
- **Complex Creation:** Added a mandatory confirmation dialog upon successful submission informing the owner that admin approval is pending.
- **Ground Creation:** Added a similar pending-approval dialog for new grounds.
- **Restrictions:** In `ComplexDetailPage`, the "Add Ground" button is now restricted. If the complex is not yet approved, the owner sees: *"You can add grounds only after your complex is approved."*

## 3. Next Steps for Testing
1. **Admin Approval:** Log in as admin and use the new tick button to approve a complex.
2. **Notification Check:** Verify that the owner receives an email (using MailTrap or local logs).
3. **Owner Path:** Create a new complex as an owner, see the dialog, and observe that the "Add Ground" button is disabled until approved.
4. **User Visibility:** Verify that a ground only appears in the public marketplace after BOTH it and its parent complex are set to 'active'.
