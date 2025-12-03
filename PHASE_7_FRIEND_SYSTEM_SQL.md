# Phase 7: Friend System - SQL Setup

## Tables to Create in Supabase

Copy and paste this SQL in **Supabase Dashboard > SQL Editor**:

```sql
-- ============================================
-- FRIEND SYSTEM TABLES
-- ============================================

-- 1. Friend Requests Table
CREATE TABLE IF NOT EXISTS friend_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  receiver_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  status TEXT NOT NULL CHECK (status IN ('pending', 'accepted', 'rejected')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- Prevent duplicate requests
  UNIQUE(sender_id, receiver_id)
);

-- 2. Friends Table (bidirectional friendship)
CREATE TABLE IF NOT EXISTS friends (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  friend_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- Prevent duplicate friendships
  UNIQUE(user_id, friend_id),
  
  -- Prevent self-friendship
  CHECK (user_id != friend_id)
);

-- ============================================
-- INDEXES for Performance
-- ============================================

CREATE INDEX IF NOT EXISTS idx_friend_requests_sender ON friend_requests(sender_id);
CREATE INDEX IF NOT EXISTS idx_friend_requests_receiver ON friend_requests(receiver_id);
CREATE INDEX IF NOT EXISTS idx_friend_requests_status ON friend_requests(status);

CREATE INDEX IF NOT EXISTS idx_friends_user_id ON friends(user_id);
CREATE INDEX IF NOT EXISTS idx_friends_friend_id ON friends(friend_id);

-- ============================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================

-- Enable RLS
ALTER TABLE friend_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE friends ENABLE ROW LEVEL SECURITY;

-- Friend Requests Policies (for anon role - custom auth)
CREATE POLICY "Public can view friend requests"
  ON friend_requests FOR SELECT
  TO anon
  USING (true);

CREATE POLICY "Public can create friend requests"
  ON friend_requests FOR INSERT
  TO anon
  WITH CHECK (true);

CREATE POLICY "Public can update friend requests"
  ON friend_requests FOR UPDATE
  TO anon
  USING (true);

CREATE POLICY "Public can delete friend requests"
  ON friend_requests FOR DELETE
  TO anon
  USING (true);

-- Friends Policies (for anon role - custom auth)
CREATE POLICY "Public can view friends"
  ON friends FOR SELECT
  TO anon
  USING (true);

CREATE POLICY "Public can create friends"
  ON friends FOR INSERT
  TO anon
  WITH CHECK (true);

CREATE POLICY "Public can delete friends"
  ON friends FOR DELETE
  TO anon
  USING (true);

-- ============================================
-- HELPER FUNCTIONS
-- ============================================

-- Function to create bidirectional friendship
CREATE OR REPLACE FUNCTION create_friendship(user1 UUID, user2 UUID)
RETURNS VOID AS $$
BEGIN
  -- Insert both directions
  INSERT INTO friends (user_id, friend_id) VALUES (user1, user2)
  ON CONFLICT DO NOTHING;
  
  INSERT INTO friends (user_id, friend_id) VALUES (user2, user1)
  ON CONFLICT DO NOTHING;
END;
$$ LANGUAGE plpgsql;

-- Function to remove bidirectional friendship
CREATE OR REPLACE FUNCTION remove_friendship(user1 UUID, user2 UUID)
RETURNS VOID AS $$
BEGIN
  DELETE FROM friends WHERE user_id = user1 AND friend_id = user2;
  DELETE FROM friends WHERE user_id = user2 AND friend_id = user1;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- AUTO-UPDATE TIMESTAMPS
-- ============================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_friend_requests_updated_at
BEFORE UPDATE ON friend_requests
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();
```

## After Running SQL:

1. Go to **Supabase Dashboard > Table Editor**
2. Verify you see:
   - `friend_requests` table
   - `friends` table
3. Test the policies are working
