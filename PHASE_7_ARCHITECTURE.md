# 📊 Phase 7: Friend System Architecture

## System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         JEJAK PENA APP                          │
│                      Friend System (Phase 7)                     │
└─────────────────────────────────────────────────────────────────┘

┌─────────────┐         ┌──────────────┐         ┌──────────────┐
│   Flutter   │         │   Services   │         │   Supabase   │
│     UI      │ ◄─────► │   Layer      │ ◄─────► │   Backend    │
└─────────────┘         └──────────────┘         └──────────────┘
```

---

## Layer Architecture

### 1. UI Layer (Flutter)
```
friends_page.dart
├── SearchBar (User Search)
├── Tab 1: Friends List
│   ├── Friend Card (Avatar, Username, Full Name)
│   └── Remove Friend (Menu)
├── Tab 2: Friend Requests (Received)
│   ├── Request Card (Sender Info)
│   └── Accept/Reject Buttons
└── Tab 3: Sent Requests
    ├── Request Card (Receiver Info)
    └── Cancel Button
```

### 2. Service Layer (Business Logic)
```
friend_service.dart
├── User Search
│   └── searchUsers(query) → List<User>
│
├── Friend Requests
│   ├── sendFriendRequest(userId)
│   ├── getPendingRequests() → List<Request>
│   ├── getSentRequests() → List<Request>
│   ├── acceptFriendRequest(requestId, senderId)
│   ├── rejectFriendRequest(requestId)
│   └── cancelFriendRequest(requestId)
│
└── Friends Management
    ├── getFriends() → List<Friend>
    ├── removeFriend(friendId)
    ├── areFriends(userId1, userId2) → bool
    ├── getFriendCount() → int
    └── getPendingRequestCount() → int
```

### 3. Database Layer (Supabase PostgreSQL)
```
Tables:
├── users (existing)
│   ├── id (UUID)
│   ├── username
│   └── full_name
│
├── friend_requests (new)
│   ├── id (UUID)
│   ├── sender_id (FK → users.id)
│   ├── receiver_id (FK → users.id)
│   ├── status ('pending', 'accepted', 'rejected')
│   └── created_at
│
└── friends (new)
    ├── id (UUID)
    ├── user_id (FK → users.id)
    ├── friend_id (FK → users.id)
    └── created_at

Helper Functions:
├── create_friendship(user1, user2)
└── remove_friendship(user1, user2)
```

---

## Data Flow Diagrams

### 1. Send Friend Request Flow

```
User A                Friend Service           Supabase
  │                         │                      │
  ├─ Search "user_b" ──────►│                      │
  │                         ├─ Query users ───────►│
  │                         │◄─ Return results ────┤
  │◄─ Show results ─────────┤                      │
  │                         │                      │
  ├─ Click "Add" ──────────►│                      │
  │                         ├─ Check if friends ──►│
  │                         │◄─ Not friends ───────┤
  │                         ├─ Check existing req ►│
  │                         │◄─ No request ────────┤
  │                         ├─ Insert request ────►│
  │                         │◄─ Success ───────────┤
  │◄─ Toast: "Sent" ────────┤                      │
  │                         │                      │
```

### 2. Accept Friend Request Flow

```
User B                Friend Service           Supabase
  │                         │                      │
  ├─ Open Requests tab ────►│                      │
  │                         ├─ Get pending ───────►│
  │                         │◄─ Return requests ───┤
  │◄─ Show requests ────────┤                      │
  │                         │                      │
  ├─ Click Accept ─────────►│                      │
  │                         ├─ Update status ─────►│
  │                         │◄─ Success ───────────┤
  │                         ├─ Call RPC function ─►│
  │                         │   create_friendship( │
  │                         │     user_a, user_b)  │
  │                         │◄─ Success ───────────┤
  │◄─ Toast: "Accepted" ────┤                      │
  │                         │                      │
```

### 3. Bidirectional Friendship Creation

```
create_friendship(user_a, user_b)

Step 1: Insert (user_a → user_b)
┌─────────────────────────────┐
│ friends                     │
├─────────────────────────────┤
│ user_id    │ friend_id      │
├────────────┼────────────────┤
│ user_a_id  │ user_b_id      │ ◄── Insert
└─────────────────────────────┘

Step 2: Insert (user_b → user_a)
┌─────────────────────────────┐
│ friends                     │
├─────────────────────────────┤
│ user_id    │ friend_id      │
├────────────┼────────────────┤
│ user_a_id  │ user_b_id      │
│ user_b_id  │ user_a_id      │ ◄── Insert
└─────────────────────────────┘

Result: Both users are friends!
```

---

## State Management

### Friends Page State
```dart
_FriendsPageState {
  // Lists
  List<Friend> _friends = [];
  List<Request> _pendingRequests = [];
  List<Request> _sentRequests = [];
  List<User> _searchResults = [];
  
  // Loading States
  bool _isLoadingFriends = true;
  bool _isLoadingRequests = true;
  bool _isLoadingSent = true;
  bool _isSearching = false;
  
  // Controllers
  TabController _tabController;
  TextEditingController _searchController;
}
```

### Tab Counts (Dynamic)
```
Friends (X)   ← _friends.length
Requests (Y)  ← _pendingRequests.length
Sent (Z)      ← _sentRequests.length
```

---

## Security Model

### Row Level Security (RLS)

```sql
-- friend_requests policies
✓ Public can SELECT (view all requests)
✓ Public can INSERT (send requests)
✓ Public can UPDATE (accept/reject)
✓ Public can DELETE (cancel)

-- friends policies
✓ Public can SELECT (view friends)
✓ Public can INSERT (add friendship)
✓ Public can DELETE (remove friendship)
```

**Note:** Using `anon` role because of custom auth (not Supabase Auth)

### Data Integrity Constraints

```sql
friend_requests:
  ✓ UNIQUE(sender_id, receiver_id) - No duplicate requests
  ✓ CHECK(status IN ('pending', 'accepted', 'rejected'))

friends:
  ✓ UNIQUE(user_id, friend_id) - No duplicate friendships
  ✓ CHECK(user_id != friend_id) - No self-friendship
```

---

## Performance Optimizations

### Database Indexes

```sql
-- friend_requests
CREATE INDEX idx_friend_requests_sender ON friend_requests(sender_id);
CREATE INDEX idx_friend_requests_receiver ON friend_requests(receiver_id);
CREATE INDEX idx_friend_requests_status ON friend_requests(status);

-- friends
CREATE INDEX idx_friends_user_id ON friends(user_id);
CREATE INDEX idx_friends_friend_id ON friends(friend_id);
```

**Benefits:**
- Fast user lookup (O(log n))
- Fast status filtering
- Efficient JOIN queries

### Query Optimizations

```dart
// ✓ GOOD: Uses indexes
.select('*').eq('user_id', currentUserId)

// ✗ BAD: Table scan
.select('*').ilike('username', '%query%')  // Still acceptable for search
```

---

## User Scenarios

### Scenario 1: Finding and Adding a Friend
```
1. John opens "Teman" tab
2. Types "alice" in search bar
3. Sees alice's profile
4. Clicks "Add"
5. Request sent to alice
6. Alice sees notification badge
7. Alice opens "Requests (1)" tab
8. Clicks ✓ to accept
9. Both are now friends
```

### Scenario 2: Managing Friends
```
1. John opens "Friends (5)" tab
2. Sees list of 5 friends
3. Wants to remove alice
4. Clicks ⋮ menu on alice
5. Clicks "Remove Friend"
6. Confirms in dialog
7. alice is removed
8. alice's friend list also updated (bidirectional)
```

### Scenario 3: Canceling a Mistake
```
1. Bob sends request to wrong person
2. Goes to "Sent (1)" tab
3. Clicks "Cancel"
4. Request is removed
5. Can send to correct person now
```

---

## Error Handling

### Network Errors
```dart
try {
  await friendService.sendFriendRequest(userId);
  // Success toast
} catch (e) {
  // Error toast: "Failed to send friend request"
  print('Error: $e');
}
```

### Business Logic Errors
```dart
// Already friends
if (existingFriend != null) {
  throw Exception('Already friends');
}

// Duplicate request
if (existingRequest != null) {
  throw Exception('Friend request already sent');
}
```

### UI Fallbacks
```dart
// Empty state
if (_friends.isEmpty) {
  return EmptyStateWidget();
}

// Loading state
if (_isLoading) {
  return CircularProgressIndicator();
}
```

---

## Testing Strategy

### Unit Tests (Service Layer)
```dart
test('Send friend request creates request in DB')
test('Accept request creates bidirectional friendship')
test('Remove friend deletes both friendship records')
test('Search excludes existing friends')
```

### Integration Tests (UI + Service)
```dart
test('User can send and accept friend request')
test('Friendship is bidirectional')
test('Pull to refresh updates friend list')
```

### Manual Tests (User Experience)
- Search functionality
- Request flow (send/accept/reject)
- UI responsiveness
- Error messages
- Loading states

---

## Metrics & Analytics (Future)

### Track These Events
```dart
Analytics.logEvent('friend_request_sent', {
  'sender_id': currentUserId,
  'receiver_id': receiverId,
});

Analytics.logEvent('friend_request_accepted', {
  'user_id': currentUserId,
  'friend_id': senderId,
});
```

### Measure These KPIs
- Average friends per user
- Friend request acceptance rate
- Time to accept request
- Daily active users with friends
- Search usage frequency

---

## Future Enhancements (Post-Phase 7)

### Phase 8: Journal Sharing
- Share journals with friends
- View friends' shared journals
- Privacy controls

### Phase 9: Real-time Location
- Share live location with friends
- See friends nearby
- Real-time updates

### Phase 10: Stories
- Instagram-like stories
- Share with friends only
- 24-hour auto-delete

### Other Ideas
- Friend suggestions (mutual friends)
- Block user feature
- Friend request notifications (push)
- Friend activity feed
- Group friends (family, close friends, etc.)

---

## Summary

```
┌──────────────────────────────────────────────────────────┐
│  Phase 7: Friend System ✅ COMPLETE                      │
├──────────────────────────────────────────────────────────┤
│  • Database: 2 tables + 2 helper functions               │
│  • Service: 12 methods for friend management             │
│  • UI: 3-tab interface with search                       │
│  • Features: 15+ friend-related features                 │
│  • Security: RLS policies + data integrity               │
│  • Performance: 5 indexes for fast queries               │
└──────────────────────────────────────────────────────────┘

Next: Phase 8 - Journal Sharing 🚀
```
