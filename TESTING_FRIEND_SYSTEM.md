# 🧪 Testing Friend System - Quick Guide

## Step 1: Run SQL Script in Supabase

1. Open **Supabase Dashboard** → Your Project "JejakPena"
2. Go to **SQL Editor** (left sidebar)
3. Click **"New Query"**
4. Copy the entire SQL from `PHASE_7_FRIEND_SYSTEM_SQL.md`
5. Paste and click **"Run"**
6. ✅ Verify in **Table Editor** you see:
   - `friend_requests` table
   - `friends` table

## Step 2: Run the App

```bash
flutter run
```

## Step 3: Test Friend System

### Test 1: Register Multiple Users
1. **Create User 1:**
   - Username: `john`
   - Password: `john123`
   
2. **Logout** (Settings → Logout)

3. **Create User 2:**
   - Username: `alice`
   - Password: `alice123`

4. **Logout**

5. **Create User 3:**
   - Username: `bob`
   - Password: `bob123`

### Test 2: Send Friend Request
1. **Login as `john`**
2. Tap **"Teman"** tab (bottom navigation)
3. In search bar, type `alice`
4. Click **"Add"** button
5. ✅ Should see: "Friend request sent to alice"
6. Go to **"Sent (1)"** tab
7. ✅ Should see alice in sent requests

### Test 3: Accept Friend Request
1. **Logout → Login as `alice`**
2. Tap **"Teman"** tab
3. Go to **"Requests (1)"** tab
4. ✅ Should see request from `john`
5. Click **✓** (accept)
6. ✅ Should see: "Friend request accepted"
7. Go to **"Friends (1)"** tab
8. ✅ Should see `john` in friends list

### Test 4: Verify Bidirectional Friendship
1. **Logout → Login as `john`**
2. Tap **"Teman"** tab
3. Go to **"Friends (1)"** tab
4. ✅ Should see `alice` in friends list
5. ✅ Friendship is bidirectional!

### Test 5: Search Excludes Friends
1. While logged in as `john`
2. In search bar, type `alice`
3. ✅ Should see: **NO RESULTS** (alice is already a friend)
4. Type `bob`
5. ✅ Should see `bob` (not a friend yet)

### Test 6: Remove Friend
1. While logged in as `john`
2. In **"Friends"** tab, click **⋮** menu on alice
3. Click **"Remove Friend"**
4. Confirm in dialog
5. ✅ Should see: "alice removed from friends"
6. **Logout → Login as `alice`**
7. ✅ Verify alice's friends list is also empty (bidirectional removal)

### Test 7: Reject Friend Request
1. **Login as `bob`**
2. Send friend request to `alice`
3. **Logout → Login as `alice`**
4. Go to **"Requests (1)"** tab
5. Click **✗** (reject)
6. ✅ Should see: "Friend request rejected"
7. ✅ Request disappears from list

### Test 8: Cancel Sent Request
1. **Login as `bob`**
2. Send friend request to `john`
3. Go to **"Sent (1)"** tab
4. Click **"Cancel"**
5. ✅ Should see: "Friend request cancelled"
6. ✅ Request disappears from sent list

## Expected UI Behavior

### Empty States
- **No Friends:** "No friends yet. Search for users to add friends"
- **No Requests:** "No pending requests"
- **No Sent:** "No sent requests"

### Loading States
- Shows `CircularProgressIndicator` while loading
- Pull-to-refresh works on all tabs

### Search Behavior
- Real-time search (searches as you type)
- Shows max results
- Clear button appears when typing
- Excludes:
  - Current user (yourself)
  - Existing friends

### Time Display
- Uses relative time: "2 hours ago", "5 minutes ago", "3 days ago"
- Powered by `timeago` package

## Troubleshooting

### ❌ "Failed to send friend request"
**Cause:** Already sent request OR already friends
**Fix:** Check "Sent" tab or "Friends" tab

### ❌ Tables don't exist
**Cause:** SQL script not run
**Fix:** Run SQL from `PHASE_7_FRIEND_SYSTEM_SQL.md`

### ❌ RLS Policy Error (403)
**Cause:** Policies not created for `anon` role
**Fix:** SQL script includes all necessary policies

### ❌ "User not logged in"
**Cause:** Session expired
**Fix:** Logout and login again

### ❌ Search returns no results
**Cause:** 
1. User doesn't exist
2. User is already a friend
3. Searching for yourself

## Database Verification

Check data in **Supabase Dashboard > Table Editor**:

### `friend_requests` Table
```
| id   | sender_id | receiver_id | status  | created_at |
|------|-----------|-------------|---------|------------|
| uuid | john_id   | alice_id    | pending | 2025-...   |
```

### `friends` Table (After Accepting)
```
| id   | user_id   | friend_id | created_at |
|------|-----------|-----------|------------|
| uuid | john_id   | alice_id  | 2025-...   |
| uuid | alice_id  | john_id   | 2025-...   |  ← Bidirectional
```

## Success Criteria ✅

- [x] Can search for users
- [x] Can send friend requests
- [x] Can receive friend requests
- [x] Can accept friend requests
- [x] Can reject friend requests
- [x] Can cancel sent requests
- [x] Can see friends list
- [x] Can remove friends
- [x] Friendship is bidirectional
- [x] Search excludes friends
- [x] Pull-to-refresh works
- [x] UI is smooth and responsive

---

**🎉 If all tests pass, Phase 7 is complete!**

**Next:** Phase 8 - Journal Sharing (share journals with friends)
