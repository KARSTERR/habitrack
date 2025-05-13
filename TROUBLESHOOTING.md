# HabiTrack Troubleshooting Guide

## Common Issues and Solutions

### Type Mismatch Between Backend and Frontend

#### Problem: "type int is not a subtype of type string"

This error occurs because the backend (Go) and frontend (Flutter/Dart) handle ID types differently:

- The Go backend uses `int64` for user IDs (defined in `models/user.go`)
- The Flutter frontend expects user IDs as `String` (defined in `lib/models/user.dart`)

#### Solution

We've implemented robust type handling in two places:

1. **User.fromJson** in `lib/models/user.dart`:

   ```dart
   factory User.fromJson(Map<String, dynamic> json) {
     // Handle different ID types coming from backend (could be int64 or string)
     String userId;
     var rawId = json['id'];
     if (rawId is int) {
       userId = rawId.toString();
     } else if (rawId is String) {
       userId = rawId;
     } else {
       throw FormatException('Unexpected ID format: ${rawId.runtimeType}');
     }

     return User(
       id: userId,
       username: json['username'],
       email: json['email'],
       createdAt: DateTime.parse(json['created_at']),
     );
   }
   ```

2. **login method** in `lib/services/auth_service.dart`:

   ```dart
   // Handle user_id which could be int or string from backend
   String userId;
   var rawId = data['user_id'];
   if (rawId is int) {
     userId = rawId.toString();
   } else if (rawId is String) {
     userId = rawId;
   } else {
     // Fallback in case of unexpected type
     userId = rawId.toString();
   }

   return User(
     id: userId,
     username: data['username'],
     email: data['email'],
     createdAt: DateTime.now(),
   );
   ```

### Options for Future Development

For a more permanent solution, you could consider:

1. **Change the backend**: Modify the Go backend to return IDs as strings
2. **Change the frontend**: Update the Dart models to use integers instead of strings
3. **Consistent serialization**: Ensure consistent JSON serialization across the application

The current solution preserves compatibility with both approaches and ensures the app will work even if the backend changes how IDs are returned.

## Other Common Issues

For other common issues and solutions, please refer to the [BUILD.md](./BUILD.md) file.
