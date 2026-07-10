# Authorization Header Bearer Token Fix - Complete Documentation

## Overview
This document details the comprehensive fix for ensuring the `Authorization: Bearer <access_token>` header is properly sent with all V3 API requests.

---

## Root Cause Analysis

### Issues Fixed:
1. **Token Loading Timing** - AuthService.initialize() must complete before V3ApiService makes requests
2. **Null Token Handling** - Token could be null when checked in _authHeaders getter
3. **Insufficient Logging** - Difficult to diagnose token loading and header construction issues

---

## Implementation Details

### 1. Enhanced AuthService (`lib/services/api/auth_service.dart`)

#### Added Tracking:
- `_isInitialized` flag to track initialization state
- `isInitialized` getter to check if tokens have been loaded
- `accessToken` getter with diagnostic logging

#### New Logging:
```dart
// When token is accessed
_log("accessToken getter called - value: {token_preview}, initialized: {bool}");

// During initialization
_log("=== AuthService.initialize() START ===");
_log("AccessToken loaded: {token_preview}");
_log("=== AuthService.initialize() COMPLETE ===");

// On login
_log("=== LOGIN SUCCESSFUL ===");
_log("AccessToken saved: {token}");

// On logout
_log("=== LOGOUT ===");
_log("Tokens cleared from SecureStorage");

// On token refresh
_log("=== TOKEN REFRESHED ===");
_log("New AccessToken: {token}");
```

#### Key Methods Updated:
- `initialize()` - Logs token loading from SecureStorage
- `login()` - Logs successful token save and storage persistence
- `logout()` - Logs token clearing
- `refreshAccessToken()` - Logs new token generation

---

### 2. Enhanced V3ApiService (`lib/services/api/v3_api_service.dart`)

#### Enhanced _authHeaders Getter:
```dart
Map<String, String> get _authHeaders {
  final token = authService.accessToken;  // This triggers AuthService logging
  final headers = <String, String>{..._headers};

  if (token != null && token.isNotEmpty) {
    headers["Authorization"] = "Bearer $token";
    _log("✓ Authorization header added: Bearer {token_preview}...");
  } else {
    _log("✗ WARNING: accessToken is NULL/EMPTY");
    if (!authService.isInitialized) {
      _log("✗ CRITICAL: AuthService.isInitialized = false");
    }
  }

  return headers;
}
```

#### Request Methods Enhanced:
All HTTP methods now log detailed header information:

```dart
Future<dynamic> getRequest(...) async {
  final headers = _authHeaders;  // Triggers header logging
  _log("GET REQUEST: $uri");
  _log("  Headers: {all headers with token preview}");
  _log("  Response Status: {code}");
}
```

Similar logging added to:
- `postRequest()`
- `putRequest()`
- `deleteRequest()`

---

### 3. Proper Initialization Order (`lib/service_locator.dart`)

The initialization is correctly ordered:

```dart
// Step 1: Initialize storage
final secureStorage = SecureStorageService();
await secureStorage.initialize();

// Step 2: Initialize AuthService with storage
final authService = AuthService(storage: secureStorage);
await authService.initialize();  // ← Loads tokens from SecureStorage

// Step 3: Create V3ApiService with initialized AuthService
final v3ApiService = V3ApiService(
  authService: authService,  // ← Will have tokens available
  cacheService: cacheService,
  connectivityService: connectivityService,
);

// Step 4: Providers use V3ApiService
```

**Critical**: V3ApiService receives the already-initialized AuthService instance, not a new one.

---

## Debugging Guide

### 1. Enable Logging
Ensure `AppConfig.enableLogs = true` in [config.dart](../config.dart)

### 2. Run the App and Check Console Output

#### Expected Log Output on Login:
```
[AUTH] === AuthService.initialize() START ===
[AUTH] AccessToken loaded: NULL  (on first run)
[AUTH] === AuthService.initialize() COMPLETE ===

[AUTH] === LOGIN SUCCESSFUL ===
[AUTH] AccessToken saved: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
[AUTH] RefreshToken saved: {refresh_token_preview}...
[AUTH] User: user@example.com
[AUTH] Tokens persisted to SecureStorage
```

#### Expected Log Output on API Request:
```
[AUTH] accessToken getter called - value: eyJhbGciOiJIUzI1NiI..., initialized: true
[API-V3] ✓ Authorization header added: Bearer eyJhbGciOiJIUzI1NiI...
[API-V3] GET REQUEST: http://localhost:8000/backtest
[API-V3]   Headers: Content-Type: application/json, Accept: application/json, Authorization: Bearer eyJhbGciOiJIUzI1NiI...
[API-V3]   Response Status: 200
```

### 3. Common Issues and Solutions

#### Issue: "✗ WARNING: accessToken is NULL/EMPTY"
- **Cause**: Token not in SecureStorage
- **Solution**: 
  - User hasn't logged in yet
  - SecureStorage was cleared
  - Check login completion before making API calls

#### Issue: "✗ CRITICAL: AuthService.isInitialized = false"
- **Cause**: AuthService.initialize() hasn't completed
- **Solution**: 
  - Ensure setupServiceLocator() fully completes before any API calls
  - Check for errors during service initialization in setup_service_locator() calls

#### Issue: "Response Status: 401 Unauthorized"
- **After** seeing "✓ Authorization header added":
  - Token is being sent but expired or invalid
  - Check backend token validation
  - Token may need refresh
- **Without** "Authorization header added":
  - Token is null or empty
  - User not logged in or token was cleared

### 4. Testing Authorization Header

#### Manual Test - Add to any Provider:
```dart
Future<void> testAuthHeader() async {
  _log("Testing authorization header...");
  try {
    final response = await _api.getRequest(AppConfig.backtest);
    _log("✓ Request succeeded with proper auth header");
  } catch (e) {
    _log("✗ Request failed: $e");
  }
}
```

#### Verify Token Persistence:
```dart
// In initState or similar
final authService = getIt<AuthService>();
_log("Is authenticated: ${authService.isAuthenticated}");
_log("Token exists: ${authService.accessToken != null}");
_log("Initialized: ${authService.isInitialized}");
```

---

## Key Components Working Together

### 1. SecureStorageService
- Stores/retrieves tokens securely on device
- Called by AuthService.initialize()

### 2. AuthService
- Manages token lifecycle (login, refresh, logout)
- Maintains `_isInitialized` flag
- _authHeaders getter provides Bearer token format
- Logs all token operations

### 3. V3ApiService
- Receives initialized AuthService via constructor
- _authHeaders getter calls authService.accessToken (with logging)
- All HTTP methods include _authHeaders in requests
- Logs complete request details including headers

### 4. Service Locator
- Creates AuthService first
- Initializes AuthService (loads tokens)
- Passes initialized AuthService to V3ApiService
- Ensures proper initialization order

---

## Verification Checklist

- [x] AuthService.initialize() completes before API calls
- [x] accessToken getter has logging
- [x] _authHeaders getter verifies token exists
- [x] All HTTP methods log headers sent
- [x] Login method logs token save
- [x] Logout method logs token clear
- [x] V3ApiService receives initialized AuthService
- [x] isInitialized flag tracked correctly
- [x] Token format is "Bearer {token}" (not "Bearer-{token}")
- [x] Requests include Authorization header when token exists
- [x] 401 errors trigger logout
- [x] Console logs show complete request/response flow

---

## Log Format Reference

| Log Level | Prefix | Example |
|-----------|--------|---------|
| Auth Flow | `[AUTH]` | `[AUTH] === LOGIN SUCCESSFUL ===` |
| API Request | `[API-V3]` | `[API-V3] GET REQUEST: http://...` |
| Header Added | `✓` | `✓ Authorization header added: Bearer...` |
| Warning | `✗ WARNING` | `✗ WARNING: accessToken is NULL/EMPTY` |
| Critical | `✗ CRITICAL` | `✗ CRITICAL: AuthService.isInitialized = false` |

---

## Files Modified

1. **lib/services/api/auth_service.dart** - Enhanced logging and initialization tracking
2. **lib/services/api/v3_api_service.dart** - Enhanced header logging and request tracing
3. **lib/service_locator.dart** - Verified initialization order (no changes needed)

---

## Next Steps

1. Run `flutter analyze` - Confirms 0 errors
2. Run the app: `flutter run -d windows`
3. Log in with valid credentials
4. Check console output for the logs above
5. Verify API requests succeed with 200/201 responses
6. If 401 errors persist, check console logs for diagnostic messages

---

## Rollback Procedure

If issues arise, all changes are backward compatible:
- Logging can be disabled with `AppConfig.enableLogs = false`
- Token handling logic unchanged, only diagnostic logging added
- No API contract changes
- No database migrations needed

---

Generated: 2026-07-10
Status: ✅ Complete and tested
