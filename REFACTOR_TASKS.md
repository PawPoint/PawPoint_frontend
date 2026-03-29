# Refactoring Tasks: Royet Branch

This task involves refactoring the Pawpoint frontend to improve modularity, scalability, and code reuse.

## Overall Goal
Clean up the codebase by extracting shared UI components, standardizing error handling, and organizing the project structure by feature.

---

## Task 1: Modularize Shared UI Components & Constants
**Status: [x] Completed**

**Objectives:**
- [ ] Create `lib/core/widgets` and move/create reusable widgets:
    - `AppTextField`: Standardized text input with custom styling.
    - `AppButton`: Standardized button with shadow and loading state.
    - `AppLogo`: Reusable logo widget.
- [ ] Create `lib/core/theme/app_colors.dart` and `lib/core/theme/app_text_styles.dart`.
- [ ] Refactor `LoginPage` and `SignupPage` to use these shared widgets.
- [ ] Ensure consistent use of `GoogleFonts` across all components.

**Verification:**
- Run `flutter analyze` to ensure no errors.
- Visual check: Login and Signup pages should look identical but use shared components.

---

## Task 2: Standardize Error Handling & Validation
**Status: [x] Completed**

**Objectives:**
- [ ] Create `lib/core/utils/error_handler.dart` to handle and format backend/Firebase errors.
- [ ] Create `lib/core/utils/validators.dart` for common validation logic (email, phone, password).
- [ ] Refactor `AuthService` and `AppointmentService` to use the central error handler.
- [ ] Update `LoginPage` and `SignupPage` to use the shared validators.

**Verification:**
- Trigger validation errors and backend errors to ensure they are handled and displayed consistently.

---

## Task 3: Feature-based Organization & Structure Refinement
**Status: [x] Completed**

**Objectives:**
- [ ] Reorganize `lib/presentation` into feature-based subdirectories:
    - `lib/presentation/auth/` (Login, Signup, Verify, etc.)
    - `lib/presentation/pets/` (My Pets, Add Pet, Pet Info, etc.)
    - `lib/presentation/appointments/` (Book Now, Appointments, etc.)
- [ ] Ensure all imports are updated correctly.
- [ ] Run `mcp analyze` (or project-specific analysis tool) to verify project integrity.

**Verification:**
- [x] App builds and runs successfully (all imports verified and fixed).
- [x] Codebase is neatly organized and easier to navigate.
- [x] Integrated ErrorHandler into AppointmentService (Task 2 cleanup).

---

> **Note:** Run `/compress` after completing each task to summarize progress.
