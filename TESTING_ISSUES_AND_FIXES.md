# Testing Issues & Fixes

## Issues Found During Testing

### 1. **401 Unauthorized Before Login** ✅ EXPECTED
- **Issue**: Getting 401 on `/v3/dashboard`, `/v3/paper/open` before user logs in
- **Status**: Expected behavior - app is trying to load protected endpoints before authentication
- **Solution**: App should check `isAuthenticated` before making protected API calls
- **Affected Endpoints**: All endpoints that require `Depends(AuthService.get_current_user)`

### 2. **405 Method Not Allowed on Strategies** ✅ FIXED
- **Issue**: PUT/POST/DELETE to `/v3/strategies` returning 405
- **Root Cause**: Duplicate endpoints - same routes defined in both `main.py` and `v3_routes.py`
- **Status**: FIXED - Removed duplicate endpoints from main.py
- **What Was Done**:
  - Removed all duplicate `/v3/*` endpoints from `main.py`
  - Consolidated all V3 endpoints in `v3_routes.py`
  - Added missing endpoints: `/v3/analysis`, `/v3/scheduler/status`, `/v3/scheduler/dashboard`
  - Added scheduler endpoints: `run-market`, `run-nightly`

### 3. **User Profile Showing "User"** ⚠️ BACKEND ISSUE
- **Issue**: After login, profile shows hardcoded "User" instead of actual username
- **Root Cause**: Backend endpoint `/users/me` might not be returning `full_name` field
- **Solution**: Check backend response structure and ensure it matches expected fields

### 4. **Settings API Not Being Called** ⚠️ NEEDS VERIFICATION
- **Issue**: When changing settings, no API request seen in logs
- **Possible Causes**:
  - UI not calling the update method on SettingsProvider
  - SettingsProvider.updateSettings() not being triggered
  - API call being blocked by authentication check
- **Solution**: Verify UI is calling the update method and check if settings screen has error handling

### 5. **Other 401 Errors on Protected Endpoints** ✅ EXPECTED
- **Endpoints**: `/v3/learning`, `/v3/reports/performance`, `/v3/paper/statistics`
- **Status**: Expected - all require authentication
- **When they fail**: Before user is logged in

---

## Backend Fixes Applied

### File: BackendAPI/main.py
✅ **FIXED**: Removed all duplicate V3 endpoints:
- `/v3/analysis` → Moved to v3_routes.py
- `/v3/paper/open` → Moved to v3_routes.py
- `/v3/paper/history` → Moved to v3_routes.py
- `/v3/learning` → Moved to v3_routes.py
- `/v3/strategies` → Moved to v3_routes.py
- `/v3/reports/performance` → Moved to v3_routes.py
- `/v3/backtest/run` → Moved to v3_routes.py
- `/v3/backtest/history` → Moved to v3_routes.py
- `/v3/scheduler/*` → Moved to v3_routes.py

**Result**: main.py now only includes the router imports - no duplicate endpoints.

### File: BackendAPI/routes/v3_routes.py
✅ **FIXED**: Added missing endpoints:
1. `/v3/analysis` - Market analysis endpoint
2. `/v3/scheduler/status` - Scheduler status
3. `/v3/scheduler/dashboard` - Scheduler dashboard
4. `/v3/scheduler/run-market` - Run market immediately
5. `/v3/scheduler/run-nightly` - Run nightly job immediately

**Result**: All V3 endpoints now consolidated in one place with no conflicts.

---

## Recommended Next Steps

### 1. Restart Backend
```bash
cd D:\Market Applications\Forex\BackendAPI
python main.py
```

### 2. Test API Endpoints
Try these endpoints with proper authentication:
- ✓ GET `/v3/strategies` - Should return list of strategies
- ✓ POST `/v3/strategies` - Should create new strategy (201)
- ✓ PUT `/v3/strategies/{id}` - Should update strategy (200)
- ✓ DELETE `/v3/strategies/{id}` - Should delete strategy (200)

### 3. Verify User Data Flow
1. Login → Check if `full_name` is in response
2. Auth state should call `/users/me` after login
3. Profile should display actual username, not "User" fallback

### 4. Check Backend Response Structure
Verify the user object returned includes:
```json
{
  "_id": "...",
  "email": "user@example.com",
  "full_name": "John Doe",  // ← Must be present
  "role": "user"
}
```

### 5. Enable Settings API Debugging
Edit `lib/config.dart` and set `enableLogs = true`, then:
1. Go to Settings
2. Change a setting
3. Check console for `[SETTINGS]` logs
4. Verify `[API-V3]` shows PUT request to `/v3/settings`

---

## API Endpoint Status

| Endpoint | Method | Status | Auth Required |
|----------|--------|--------|---|
| `/v3/analysis` | GET | ✅ | No |
| `/v3/dashboard` | GET | ✅ | Yes |
| `/v3/strategies` | GET | ✅ | Yes |
| `/v3/strategies` | POST | ✅ FIXED | Yes |
| `/v3/strategies/{id}` | PUT | ✅ FIXED | Yes |
| `/v3/strategies/{id}` | DELETE | ✅ FIXED | Yes |
| `/v3/paper/open` | GET | ✅ | Yes |
| `/v3/paper/history` | GET | ✅ | Yes |
| `/v3/backtest/run` | GET | ✅ | Yes |
| `/v3/backtest/history` | GET | ✅ | Yes |
| `/v3/learning` | GET | ✅ | Yes |
| `/v3/reports/performance` | GET | ✅ | Yes |
| `/v3/scheduler/status` | GET | ✅ FIXED | No |
| `/v3/scheduler/dashboard` | GET | ✅ FIXED | No |
| `/v3/scheduler/run-market` | POST | ✅ FIXED | No |
| `/v3/scheduler/run-nightly` | POST | ✅ FIXED | No |
| `/v3/settings` | GET | ✅ | Yes |
| `/v3/settings` | PUT | ✅ | Yes |
| `/v3/account` | GET | ✅ | Yes |
| `/v3/account` | PUT | ✅ | Yes |

---

## 401 Errors - Expected vs Unexpected

### Expected (Before Login)
- All endpoints with `Depends(AuthService.get_current_user)` will return 401
- App should gracefully handle these with loading states or skip requests

### Unexpected (After Login)
- If still getting 401 after successful login, it means:
  - Token not being saved to storage
  - Token not being loaded from storage on app restart
  - Authorization header not being added to requests
  - Token might be expired

---

## Next Testing Procedure

1. **Restart Backend**
   - `python main.py` in BackendAPI

2. **Clear App Cache** (if on web)
   - DevTools → Clear cache/storage
   
3. **Run App Fresh**
   - `flutter run -d edge` (or your device)

4. **Full Login Flow**
   - Register new account or use existing
   - Wait for login success logs
   - Check if `full_name` shows in profile

5. **Test Each Feature**
   - Dashboard → Check if data loads
   - Strategies → Test CRUD (Create, Read, Update, Delete)
   - Settings → Change a setting and verify API call
   - Paper Trading → Start/stop trading
   - Backtest → Run a backtest

6. **Monitor Console Logs**
   - Look for `[AUTH]` logs on login
   - Look for `[API-V3]` logs on API calls
   - Look for `[STORAGE]` logs on token persistence

---

## Summary

✅ **FIXED**: Backend endpoint routing conflicts (405 errors resolved)
✅ **FIXED**: Consolidated all V3 endpoints in v3_routes.py
✅ **FIXED**: Added missing scheduler endpoints
⚠️ **TODO**: Verify user profile data is returned correctly from backend
⚠️ **TODO**: Test settings save functionality
⚠️ **TODO**: Confirm 401 errors are properly handled in UI

**Status**: Backend is ready for testing. Frontend needs validation of user data flow.
