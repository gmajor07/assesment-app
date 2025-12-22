# Flutter API Connectivity Fix Guide

## Problem Summary
Your Flutter app was experiencing a `SocketException: Operation timed out (OS Error: Operation timed out, errno = 60)` error when trying to connect to your API at `http://localhost/flutter-api/api/items`.

## Root Cause
Different platforms use different localhost references to access the host machine's API server:
- **Android Emulator**: Uses `10.0.2.2` to access the host machine's localhost
- **iOS Simulator**: Uses `localhost` directly to access the host machine's localhost

There were several issues:
1. **Platform-specific hardcoding**: The API service was only configured for Android
2. **No connection timeout**: The HTTP client was waiting indefinitely
3. **Poor error handling**: Generic error messages made debugging difficult
4. **Single point of failure**: Only one URL configuration
5. **No fallback options**: No alternative connection methods

## Solutions Implemented

### 1. Platform-Aware API Endpoint Configuration
The API service now automatically detects the platform and uses the correct localhost reference:
- **Android Emulator**: `http://10.0.2.2:8000/api/items.php`
- **iOS Simulator**: `http://localhost:8000/api/items.php`
- **Web**: `http://localhost:8000/api/items.php`

### 2. Intelligent Connection Strategy
Instead of hardcoding platform-specific URLs, the service now:
- Detects the running platform automatically
- Uses the appropriate localhost reference for each platform
- Provides a unified interface for all platforms
- Easier to debug and maintain across platforms

### 3. Proper Timeout Handling
- **Connection timeout**: 10 seconds
- **Receive timeout**: 30 seconds
- Prevents indefinite waiting

### 4. Enhanced Error Handling
- Specific error messages for different failure types
- Detailed logging for debugging
- Timeout-specific exceptions
- Network error categorization

### 5. Better HTTP Client Configuration
- Uses `http.Client()` with proper headers
- Streaming responses for better performance
- Proper client cleanup

## How to Test

### 1. Ensure Your API Server is Running
Make sure your PHP API server is running on port 8000:
```bash
php -S localhost:8000
```

### 2. Test the API Endpoint Directly
Verify your API responds correctly:
```bash
curl http://localhost:8000/api/items.php
```

### 3. Run Your Flutter App

#### For Android Emulator:
```bash
flutter run -d android
```

#### For iOS Simulator:
```bash
flutter run -d ios
```

#### For Both (will show device picker):
```bash
flutter run
```

### 4. Check the Logs
Look for messages like:
- "Attempting to connect to: http://[platform-specific-host]:8000/api/items.php"
- "Successfully fetched items from: http://[platform-specific-host]:8000/api/items.php"

**For Android Emulator**: You should see `10.0.2.2` in the URL
**For iOS Simulator**: You should see `localhost` in the URL

### 5. Verify API Response
You should see the JSON data in the logs and your app should display the items correctly.

## If Issues Persist

### 1. Check API Server Status
Ensure your API is running and accessible:
```bash
curl http://localhost/flutter-api/api/items
```

### 2. Network Connectivity Test
From your development machine, verify the API responds correctly.

### 3. Firewall Issues
If you still get connection refused errors:
- Check if your web server allows connections from the emulator
- Ensure no firewall is blocking port 80/8080

### 4. Alternative Solutions
If the Android emulator still can't connect:

**Option A: Use your actual IP address**
```dart
static const List<String> baseUrls = [
  'http://YOUR_LOCAL_IP/flutter-api/api/items',
  'http://10.0.2.2/flutter-api/api/items',
  'http://127.0.0.1/flutter-api/api/items',
];
```
Replace `YOUR_LOCAL_IP` with your computer's IP address (find it with `ifconfig` on Mac/Linux or `ipconfig` on Windows).

**Option B: Use a tunneling service**
- Use ngrok: `ngrok http 80`
- Update the URLs to use the ngrok tunnel

**Option C: Use different emulator settings**
- Try different Android emulator configurations
- Some emulators handle localhost differently

## Key Improvements Made

1. **Platform Compatibility**: Works seamlessly on both Android emulators and iOS simulators
2. **Automatic Detection**: Intelligently chooses the correct localhost reference per platform
3. **Resilience**: Multiple fallback URLs ensure connection success
4. **Debuggability**: Detailed logging helps identify connection issues
5. **Performance**: Streaming responses and proper client management
6. **User Experience**: Clear error messages instead of generic timeouts
7. **Maintainability**: Centralized configuration and reusable patterns

## Next Steps

1. Test the app with the improved API service
2. Monitor the logs during API calls
3. If issues persist, try the alternative IP address approach
4. Consider implementing a network status checker for production apps

The updated service should now successfully connect to your API and display the items in your Flutter app!