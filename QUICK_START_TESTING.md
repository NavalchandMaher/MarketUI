# PHASE 4 AUTHORIZATION FIX - QUICK START GUIDE

## What Was Fixed
The 401 Unauthorized errors were caused by **two old duplicate files** that created new uninitialized AuthService instances instead of using the dependency-injected shared instance.

**Old Problem:**
```
V3ApiService.dart ← final AuthService _auth = AuthService(); ← NEW instance!
```

**Fixed:**
```
V3ApiService.dart ← export 'api/v3_api_service.dart'; ← Correct instance!
```

## Files Changed
1. ✅ `lib/services/v3_api_service.dart` → Converted to export redirect
2. ✅ `lib/services/auth_service.dart` → Converted to export redirect  
3. ✅ `lib/services/storage/secure_storage_service.dart` → Enhanced with:
   - Platform detection (Web vs Native)
   - Comprehensive logging
   - SharedPreferences fallback for Web

## How to Test

### STEP 1: Clean Build
```bash
flutter clean
flutter pub get
flutter analyze
```
**Expected:** 0 errors

### STEP 2: Enable Logging
Edit `lib/config.dart` and change:
```dart
static const bool enableLogs = false;  // ← FALSE (OLD)
```
To:
```dart
static const bool enableLogs = true;   // ← TRUE (NEW)
```

### STEP 3: Run App
```bash
flutter run
```

### STEP 4: Watch Console (Initialization)
Look for:
```
[STORAGE] Initialized with FlutterSecureStorage (native platform)
OR
[STORAGE] Initialized with SharedPreferences (Web platform)

[AUTH] === AuthService.initialize() START ===
[STORAGE] Reading AccessToken from...
[STORAGE] ✓ AccessToken loaded: eyJhbGc... OR ✗ NULL (first time)
[AUTH] === AuthService.initialize() COMPLETE ===
```

### STEP 5: Login
1. Tap Login screen
2. Enter test credentials
3. Watch console for:
```
[AUTH] === LOGIN SUCCESSFUL ===
[AUTH] AccessToken saved: eyJhbGc...
[STORAGE] Saving AccessToken: eyJhbGc...
[STORAGE] ✓ Successfully saved AccessToken
[AUTH] Tokens persisted to SecureStorage
```

### STEP 6: Navigate to Dashboard
1. After login, tap Dashboard menu item
2. Watch console for:
```
[API-V3] GET REQUEST: https://api.example.com/v3/dashboard
[API-V3] ✓ Authorization header added: Bearer eyJhbGc...
[API-V3] Response Status: 200
```
3. **VERIFY:** Should see 200, NOT 401

### STEP 7: Test Persistence (Optional)
1. Close app completely
2. Reopen app
3. Watch console for:
```
[STORAGE] ✓ AccessToken loaded: eyJhbGc...
```
4. Navigate to Dashboard WITHOUT logging in
5. Should work (tokens loaded from storage)

## Success Indicators
✅ No 401 errors in API responses
✅ Console shows "[API-V3] ✓ Authorization header added"
✅ Console shows "[STORAGE] ✓ Successfully saved"
✅ Console shows "[STORAGE] ✓ AccessToken loaded" on restart

## If Something's Wrong

### Issue: "AccessToken loaded: NULL"
→ This is normal on first run. Login with credentials to fix it.

### Issue: "WARNING: accessToken is NULL"
→ Tokens not loaded. Check:
1. Did you perform login?
2. Are you seeing "[STORAGE] ✓ Successfully saved" after login?
3. Did you close the app completely (not just minimize)?

### Issue: Still Getting 401 Errors
→ Check:
1. Are you seeing "[STORAGE] ✓ AccessToken loaded" on startup?
2. Are you seeing "[API-V3] ✓ Authorization header added" in console?
3. Is your token still valid (30-minute TTL)?
4. Re-login to get a fresh token

### Issue: Flutter Web Not Working
→ Check browser console for errors:
1. Open DevTools (F12)
2. Go to Console tab
3. Check for localStorage errors
4. Try disabling private browsing mode

## Quick Verification

### Before Making Changes
```bash
flutter analyze
```
Expected: 0 errors (or existing errors, not new ones)

### After Making Changes
```bash
flutter pub get
flutter analyze
```
Expected: Same or fewer errors, not more

## Revert If Needed
All changes are in 3 files:
- `lib/services/v3_api_service.dart`
- `lib/services/auth_service.dart`
- `lib/services/storage/secure_storage_service.dart`

Each file can be individually reverted from git if needed.

## Turn Off Logging When Done
After testing, disable logging to reduce console noise:
```dart
static const bool enableLogs = false;  // ← Set back to false
```

## What's Next
- [ ] Follow steps above
- [ ] Verify 200 OK responses (not 401)
- [ ] Test on all platforms (Android, iOS, Web if available)
- [ ] Run full test suite
- [ ] Disable logging
- [ ] Deploy to staging/production

---
Need more details? See:
- **AUTH_TROUBLESHOOTING_GUIDE.md** - Detailed troubleshooting
- **PHASE4_SUMMARY.md** - Technical details
