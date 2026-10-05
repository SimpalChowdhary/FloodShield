# FloodShield

FloodShield is a mobile-based flood emergency coordination application being developed to support flood incident reporting, emergency response, and coordination between citizens, authorities, and field teams.

## Technology Stack

- Flutter
- Dart
- Android Studio
- VS Code
- Git and GitHub

## Project Structure

lib/
├── main.dart
├── routes/
│   └── app_routes.dart
└── screens/
    ├── splash/
    ├── auth/
    │   ├── login_screen.dart
    │   └── signup_screen.dart
    ├── home/
    │   └── home_screen.dart
    └── emergency/
        └── report_flood_screen.dart

## Setup

### 1. Requirements

Install the following:

- Flutter SDK
- Dart SDK
- Android Studio
- VS Code
- Git

### 2. Clone the Repository

Clone the FloodShield repository and open the project in VS Code.

### 3. Install Dependencies

Open the terminal in the project folder and run:

flutter pub get

### 4. Check Flutter Setup

Run:

flutter doctor

Fix any required Android or Flutter setup issues before running the application.

### 5. Run the Application

Connect an Android device with USB debugging enabled or start an Android emulator.

Then run:

flutter run

## Current Features

The current mobile application includes:

- Splash screen
- Login screen
- Registration screen
- FloodShield dashboard
- Emergency alert section
- Report Flood screen
- Basic navigation between screens

## Development Branches

Each team member works on a separate Git branch.

Current branches include:

- `main` - shared/main project branch
- `vineesha-app` - Vineesha's mobile application work
- Other team-member branches

Changes should be committed to the appropriate personal branch and merged into `main` through the team's GitHub workflow.

## Future Mobile Features

The following features will be implemented as development continues:

- Role-based home screens
- Automatic GPS location for incident reports
- Photo-based incident reporting
- SQLite local storage
- Offline incident reporting
- Pending Sync status
- My Reports
- Field Team task management
- Backend API integration
- Testing and documentation

## Important

Do not commit passwords, API keys, database credentials, or other private information to GitHub. Use the `.env` file for local configuration when required.