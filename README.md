# TaskHub

A flutter project for students to organize tasks, timetables, and group activities.

## About the Project

TaskHub helps students manage their academic and personal life by providing:
  - Task and deadline tracking
  - Timetable management
  - Group collaboration through chats
  - Notes and reminders in one place

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

---

## Progress Reports:

### Report 2 (Sep 6, 2025)

**What I built:**
  - Completed the Sign Up screen with the following:
      - Username, email, password and confirm password fields
      - Password visibility toggle for both password fields
      - Validation checks for empty fields, minimum length, and matching passwords
      - Email format validation using 'RegEx'
  - Improved the login screen:
      - Converted to 'Form' with validators
      - Centralized layout with scroll support
  - Added navigation:
      - Login to HomeScreen on success
      - Login to SignUp and SignUp to Login using 'Navigator.pushReplacement'
    
**What I learned:**
  - Difference between 'TextField' and 'TextFormField'
  - How to use 'GlobalKey<FormState>' for validation across multiple fields
  - How to show quick feedback using 'ScaffoldMessenger.of(context).showSnackBar'
  - Using 'SigleChildScrollView' and 'ConstrainedBox' to keep forms centered and usable on all screen sizes

**Planned features:**
  - "Check your inbox" screen for email verification after Sign Up
  - Adding "Forgot Password" flow
  - starting to design the main menu layout



### Report 1 (Aug 30, 2025)

**What I built:**
  - Created a login screen with email and password input fields
  - Added password visibility toggle
  - Implemented a login button that validates empty fields

**What I learned:**
  - Basics of 'setState' to update UI dynamically
  - Basics of 'TextEditingController'
  - How to style buttons with 'Padding'

**Planned features:**
  - Adding other ways to log in
  - Sign up and verification of email screens
  - Main menu
