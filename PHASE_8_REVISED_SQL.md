# Phase 8: Friend Profile & Privacy - SQL Setup (REVISED)

## 🎯 **Simple Privacy System**

Hanya 2 level:
- **public** - Teman bisa lihat
- **private** - Hanya user sendiri

---

## ✅ **COMPLETE SQL SCRIPT**

Copy & paste ke Supabase SQL Editor:

```sql
-- ============================================
-- PHASE 8: FRIEND PROFILE & PRIVACY - SIMPLE
-- ============================================

-- 1. Add privacy column (public/private only)
ALTER TABLE journals 
ADD COLUMN IF NOT EXISTS privacy VARCHAR(20) DEFAULT 'public' 
CHECK (privacy IN ('public', 'private'));

-- 2. Create index for faster filtering
CREATE INDEX IF NOT EXISTS idx_journals_privacy ON journals(privacy);
CREATE INDEX IF NOT EXISTS idx_journals_user_privacy ON journals(user_id, privacy);

-- 3. Set all existing journals to 'public' (default)
UPDATE journals 
SET privacy = 'public' 
WHERE privacy IS NULL;

-- ============================================
-- SUCCESS MESSAGE
-- ============================================
DO $$ 
BEGIN 
  RAISE NOTICE '✅ Phase 8: Privacy column added successfully!'; 
  RAISE NOTICE '📝 Privacy: public (default) or private';
  RAISE NOTICE '🔍 Indexes created for performance';
  RAISE NOTICE '🎉 Ready to use!';
END $$;
```

---

## 🧪 **VERIFICATION**

### Check if privacy column exists:
```sql
SELECT column_name, data_type, column_default
FROM information_schema.columns 
WHERE table_name = 'journals' AND column_name = 'privacy';
```

**Expected:**
```
column_name | data_type           | column_default
------------|---------------------|----------------
privacy     | character varying   | 'public'::character varying
```

### Check privacy distribution:
```sql
SELECT privacy, COUNT(*) as count
FROM journals
GROUP BY privacy;
```

**Expected:**
```
privacy  | count
---------|-------
public   | 19    (all journals if dummy data inserted)
```

### Test query for friend's public journals:
```sql
-- Get alice's PUBLIC journals
SELECT judul, cerita, privacy, created_at
FROM journals
WHERE user_id = '22222222-2222-2222-2222-222222222222'  -- alice's ID
AND privacy = 'public'
ORDER BY created_at DESC;
```

---

## 🎯 **USAGE IN FLUTTER**

### Get Public Journals of a User (for Friend Profile):
```dart
// In journal_service.dart
Future<List<Map<String, dynamic>>> getUserPublicJournals(String userId) async {
  final response = await _supabase
      .from('journals')
      .select('*, journal_photos(id, photo_url)')
      .eq('user_id', userId)
      .eq('privacy', 'public')
      .order('created_at', ascending: false);
  
  return List<Map<String, dynamic>>.from(response);
}
```

### Get All Journals of Current User (for Own Profile):
```dart
// In journal_service.dart
Future<List<Map<String, dynamic>>> getMyJournals() async {
  final userId = UserSession.instance.currentUserId;
  
  final response = await _supabase
      .from('journals')
      .select('*, journal_photos(id, photo_url)')
      .eq('user_id', userId)
      .order('created_at', ascending: false);
  
  return List<Map<String, dynamic>>.from(response);
}
```

---

## 📊 **TESTING PRIVACY**

### Set some journals to private:
```sql
-- Make alice's first 2 journals private
UPDATE journals 
SET privacy = 'private' 
WHERE user_id = '22222222-2222-2222-2222-222222222222'  -- alice
AND judul IN ('Shopping Mall', 'Kuliner Surabaya');

-- Verify
SELECT username, judul, privacy 
FROM journals j
JOIN users u ON j.user_id = u.id
WHERE u.username = 'alice'
ORDER BY j.created_at DESC;
```

**Expected:**
```
username | judul              | privacy
---------|--------------------|---------
alice    | Shopping Mall      | private
alice    | Kuliner Surabaya   | private
alice    | Konser Musik       | public
alice    | Kota Tua           | public
```

Now if you query alice's PUBLIC journals:
```sql
SELECT judul, privacy 
FROM journals
WHERE user_id = '22222222-2222-2222-2222-222222222222'
AND privacy = 'public';
```

**Expected:** Only 2 journals (Konser Musik, Kota Tua)

---

## ✅ **THAT'S IT!**

**Simple, right?** 

No complex feed functions needed. Just:
1. Add `privacy` column
2. Query with `WHERE privacy = 'public'` when viewing friend's profile
3. Query without privacy filter when viewing own profile

---

**Next Steps:**
1. Run this SQL script
2. Add privacy dropdown to create_journal_page
3. Add privacy dropdown to journal_detail_page (edit mode)
4. Create profile pages

**Status:** Ready to run! 🚀
