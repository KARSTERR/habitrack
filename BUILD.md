# HabiTrack Build Instructions

This document provides detailed instructions for setting up and running both the backend (Go) and frontend (Flutter) components of the HabiTrack application.

## Prerequisites

### Backend (Go)

- [Go](https://golang.org/dl/) 1.18 or higher
- [Docker](https://www.docker.com/products/docker-desktop/) and Docker Compose
- [Migrate CLI](https://github.com/golang-migrate/migrate/tree/master/cmd/migrate) (Optional for manual migrations)

### Frontend (Flutter)

- [Flutter](https://flutter.dev/docs/get-started/install) 3.7.2 or higher
- [Android Studio](https://developer.android.com/studio) (for Android development)
- [Xcode](https://developer.apple.com/xcode/) (for iOS development, Mac only)
- [VS Code](https://code.visualstudio.com/) (recommended editor)

## Backend Setup

### Using Docker (Recommended)

1. Navigate to the backend directory:

   ```powershell
   cd .\backend\
   ```

2. Start the backend services using Docker Compose:

   ```powershell
   docker-compose up -d
   ```

   This will start both the PostgreSQL database and the Go API server.

3. Verify the services are running:
   ```powershell
   docker-compose ps
   ```

### Manual Setup (Without Docker)

1. Set up a PostgreSQL database and update the connection details in `backend/.env`. A sample file `.env.example` is provided as a template.

2. Navigate to the backend directory:

   ```powershell
   cd .\backend\
   ```

3. Install dependencies:

   ```powershell
   go mod download
   ```

4. Run database migrations:

   ```powershell
   cd .\cmd\migrate\
   go run main.go
   ```

5. Start the server:
   ```powershell
   cd ..
   go run main.go
   ```

## Frontend Setup

1. Ensure Flutter is installed and properly set up:

   ```powershell
   flutter doctor
   ```

2. Navigate to the project root:

   ```powershell
   cd c:\Users\KARSTERR\Projects\habitrack
   ```

3. Install Flutter dependencies:

   ```powershell
   flutter pub get
   ```

4. Run the application on your preferred platform:

   - For Android emulator:

     ```powershell
     flutter run
     ```

     The command will automatically detect and use any running emulator.

   - For iOS simulator (Mac only):

     ```powershell
     flutter run
     ```

   - For web:

     ```powershell
     flutter run -d chrome
     ```

## Configuration

### Backend Configuration

The backend configuration is stored in `backend/.env`. You can modify this file to change settings such as:

- Database connection details
- Server port
- JWT secret
- Other environment-specific variables

### Frontend Configuration

The frontend configuration is in `lib/utils/config.dart`. You may need to update the API URL to match your backend settings:

```dart
class Config {
  // Special IP for Android emulator to access host machine's localhost
  static const String host = "10.0.2.2"; // Use "localhost" for web/desktop
  static const int port = 8080;

  // Base URLs
  static String get apiUrl => "http://$host:$port/api/v1";
}
```

> **Note for Android Emulator**: Android emulators need to use `10.0.2.2` instead of `localhost` to access services running on your development machine.

## Troubleshooting

### Flutter Local Notifications Issue

If you encounter a build error related to `flutter_local_notifications` package, specifically an ambiguous method reference:

```
error: reference to bigLargeIcon is ambiguous
bigPictureStyle.bigLargeIcon(null);
```

The fix is to modify the source code of the plugin to explicitly cast the null value:

1. Find the file at:

   ```
   C:\Users\<USERNAME>\AppData\Local\Pub\Cache\hosted\pub.dev\flutter_local_notifications-<version>\android\src\main\java\com\dexterous\flutterlocalnotifications\FlutterLocalNotificationsPlugin.java
   ```

2. Look for the line with `bigPictureStyle.bigLargeIcon(null);`

3. Replace it with:

   ```java
   bigPictureStyle.bigLargeIcon((android.graphics.Bitmap)null);
   ```

4. Clean the build:
   ```powershell
   flutter clean
   flutter pub get
   ```

### Backend Connection Issues

If you encounter issues connecting to the backend from your Flutter app:

1. Verify that the Docker containers are running properly:

   ```powershell
   cd c:\Users\KARSTERR\Projects\habitrack
   docker-compose ps
   ```

2. Check the logs of the backend container for any errors:

   ```powershell
   docker-compose logs backend
   ```

3. Make sure your `config.dart` file is configured correctly:

   - For Android emulator: Use `10.0.2.2` as the host to connect to your development machine's localhost
   - For iOS simulator: Use `localhost` as the host
   - For physical devices: Use your machine's IP address on the local network

4. If using an Android emulator or physical device, ensure your host machine's firewall allows connections to port 8080.

5. If all else fails, try restarting the backend services:
   ```powershell
   docker-compose down
   docker-compose up -d
   ```

### Registration Issues

If you're experiencing problems with user registration:

1. **"User with this email already exists" error**:

   - The application now features real-time email availability checking
   - When entering an email, the UI will display a check mark (✓) if the email is available
   - If you see an error icon, the email is already registered

2. **Check the email availability functionality**:

   - The app checks email availability as you type (with debouncing)
   - The backend route for this check is `/api/v1/auth/check-email`
   - You can manually test this endpoint:

     ```powershell
     # Test with a new email
     curl "http://localhost:8080/api/v1/auth/check-email?email=new@example.com"

     # Test with an existing email
     curl "http://localhost:8080/api/v1/auth/check-email?email=existing@example.com"
     ```

3. **If registration fails with no visible error**:

   - Check the application logs for more details
   - Ensure the database migrations have been applied properly
   - Verify that the `devMode` flag in `lib/services/auth_service.dart` is set to `false`

4. **Type mismatch errors** (like "type int is not a subtype of type string"):
   - See the [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) document for detailed solutions
   - These typically occur due to data type differences between the Go backend and Flutter frontend

### Assets Issue

If you encounter errors about missing assets:

1. Ensure the assets directories exist:

   ```powershell
   New-Item -Path ".\assets\images" -ItemType Directory -Force
   New-Item -Path ".\assets\icons" -ItemType Directory -Force
   ```

2. Verify the `pubspec.yaml` has the correct assets configuration:
   ```yaml
   flutter:
     uses-material-design: true
     assets:
       - assets/images/
       - assets/icons/
   ```

## Development Workflow

1. Start the backend (if not using Docker):

   ```powershell
   cd .\backend\
   go run main.go
   ```

2. In a separate terminal, run the Flutter app:

   ```powershell
   flutter run
   ```

3. Make changes to your code and use hot reload (press `r` in the terminal) or hot restart (press `R`) to see your changes.

## Building for Production

### Backend

Build the Go binary:

```powershell
cd .\backend\
go build -o habitrack.exe
```

### Frontend

Build the Flutter app for your target platform:

- For Android:

  ```powershell
  flutter build apk --release
  ```

- For iOS (Mac only):

  ```powershell
  flutter build ios --release
  ```

- For web:

  ```powershell
  flutter build web --release
  ```

- For Windows:
  ```powershell
  flutter build windows --release
  ```

The built artifacts will be available in the `build` directory.
