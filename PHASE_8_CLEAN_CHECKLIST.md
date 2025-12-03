# ✅ Phase 8: Friend Profile & Privacy - Clean Implementation

## 🎯 **KONSEP YANG BENAR:**

**TIDAK PERLU FEED!** User langsung lihat profile teman.

### User Journey:
```
1. Tab "Teman" → List teman
2. Tap "alice" → Friend Profile Page
3. Lihat:
   - Username: alice
   - Stats: 3 jurnal public
   - List: Hanya jurnal PUBLIC alice
4. Tap jurnal → Lihat detail
5. Button "Unfriend" kalau mau
```

---

## 📋 **YANG PERLU DIKERJAKAN:**

### ⚠️ **STEP 1: Run SQL Script** (2 menit)

Buka Supabase Dashboard → SQL Editor, copy & paste:

```sql
-- Add privacy column (public/private only)
ALTER TABLE journals 
ADD COLUMN IF NOT EXISTS privacy VARCHAR(20) DEFAULT 'public' 
CHECK (privacy IN ('public', 'private'));

-- Create index
CREATE INDEX IF NOT EXISTS idx_journals_privacy ON journals(privacy);

-- Set existing journals to public
UPDATE journals 
SET privacy = 'public' 
WHERE privacy IS NULL;

-- Success message
DO $$ 
BEGIN 
  RAISE NOTICE '✅ Privacy column added successfully!'; 
END $$;
```

---

### 📝 **STEP 2: Add Privacy Selector** (20 menit)

#### A. Update `create_journal_page.dart`:

```dart
// 1. Add state variable (di class)
String _selectedPrivacy = 'public';

// 2. Add dropdown widget (sebelum button save)
DropdownButtonFormField<String>(
  value: _selectedPrivacy,
  decoration: const InputDecoration(
    labelText: 'Privacy',
    prefixIcon: Icon(Icons.lock_outline),
    border: OutlineInputBorder(),
  ),
  items: const [
    DropdownMenuItem(
      value: 'public',
      child: Row(
        children: [
          Icon(Icons.public, color: Colors.green, size: 20),
          SizedBox(width: 8),
          Text('Public - Teman dapat melihat'),
        ],
      ),
    ),
    DropdownMenuItem(
      value: 'private',
      child: Row(
        children: [
          Icon(Icons.lock, color: Colors.red, size: 20),
          SizedBox(width: 8),
          Text('Private - Hanya saya'),
        ],
      ),
    ),
  ],
  onChanged: (value) {
    setState(() => _selectedPrivacy = value!);
  },
),

// 3. Update createJournal call (tambahkan privacy parameter)
final journalId = await _journalService.createJournal(
  judul: _judulController.text,
  cerita: _ceritaController.text,
  tanggal: _selectedDate,
  latitude: _latitude,
  longitude: _longitude,
  namaLokasi: _namaLokasiController.text,
  privacy: _selectedPrivacy, // ADD THIS
);
```

#### B. Update `journal_detail_page.dart`:

```dart
// 1. Add state variable
String _selectedPrivacy = 'public';

// 2. Load privacy dari database (in _loadJournal)
setState(() {
  _selectedPrivacy = _journal?['privacy'] ?? 'public';
});

// 3. Add dropdown (di edit mode)
if (_isEditMode) {
  // ...existing edit fields...
  
  DropdownButtonFormField<String>(
    value: _selectedPrivacy,
    decoration: const InputDecoration(
      labelText: 'Privacy',
      prefixIcon: Icon(Icons.lock_outline),
    ),
    items: const [
      DropdownMenuItem(
        value: 'public',
        child: Row(
          children: [
            Icon(Icons.public, color: Colors.green, size: 20),
            SizedBox(width: 8),
            Text('Public'),
          ],
        ),
      ),
      DropdownMenuItem(
        value: 'private',
        child: Row(
          children: [
            Icon(Icons.lock, color: Colors.red, size: 20),
            SizedBox(width: 8),
            Text('Private'),
          ],
        ),
      ),
    ],
    onChanged: (value) {
      setState(() => _selectedPrivacy = value!);
    },
  ),
}

// 4. Update save method
await _journalService.updateJournal(
  journalId: widget.journalId,
  judul: _judulController.text,
  cerita: _ceritaController.text,
  privacy: _selectedPrivacy, // ADD THIS
);
```

---

### 👤 **STEP 3: Create Profile Pages** (Saya buatkan)

Akan saya buatkan 2 files:
1. ✅ `lib/screens/profile_page.dart` - Own profile
2. ✅ `lib/screens/friend_profile_page.dart` - Friend profile

---

### 🔗 **STEP 4: Add Navigation** (5 menit)

Update `friends_page.dart`:

```dart
// In _buildFriendsList, update ListTile
ListTile(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FriendProfilePage(
          userId: friend['id'],
          username: friend['username'],
        ),
      ),
    );
  },
  // ...existing code...
)
```

---

## 🧪 **TESTING CHECKLIST:**

### Database
- [ ] Run SQL script
- [ ] Verify: `SELECT * FROM information_schema.columns WHERE table_name = 'journals' AND column_name = 'privacy'`
- [ ] Should return 1 row

### Privacy Selector
- [ ] Create journal with "Public" → Save successful
- [ ] Create journal with "Private" → Save successful
- [ ] Edit journal: Public → Private → Save successful
- [ ] Verify in Supabase: privacy column updated

### Friend Profile
- [ ] Login as john
- [ ] Go to "Teman" tab
- [ ] Tap alice → Opens alice's profile
- [ ] See only alice's PUBLIC journals
- [ ] Private journals NOT visible
- [ ] Can tap journal to see details
- [ ] "Unfriend" button works

### Own Profile
- [ ] Login as john
- [ ] Go to profile (if implemented)
- [ ] See ALL journals (public + private)
- [ ] Stats show correct count

---

## 📊 **PRIVACY LOGIC:**

### Public Journal:
- ✅ Visible to friends
- ✅ Appears in friend's profile page
- ✅ Can be viewed by friends

### Private Journal:
- ❌ NOT visible to friends
- ❌ Does NOT appear in friend's profile page
- ✅ Only visible to owner (in Beranda)

---

## 🎯 **PRIORITY ORDER:**

1. **FIRST:** Run SQL (wajib!) ⚠️
2. **SECOND:** Privacy selector in create_journal_page
3. **THIRD:** Privacy in edit mode (journal_detail_page)
4. **FOURTH:** Profile pages (saya buatkan)
5. **LAST:** Testing

**Estimated Time:** 1-2 hours total

---

## 📁 **CURRENT FILES:**

### ✅ Ready to Use:
- `PHASE_8_REVISED_SQL.md` - SQL script
- `PHASE_8_REVISED_PLAN.md` - Complete plan
- `PHASE_8_FINAL_SUMMARY.md` - Summary & guide
- `PHASE_8_CLEANUP_SUMMARY.md` - Cleanup log

### ✅ Code Files:
- `lib/helpers/journal_service.dart` - Backend ready
- `lib/screens/home_page.dart` - 4 tabs (clean)

### ⏳ To Create:
- `lib/screens/profile_page.dart`
- `lib/screens/friend_profile_page.dart`

---

## 🚀 **NEXT ACTION:**

Mau saya buatkan Profile Pages sekarang?

Atau kamu mau coba add privacy selector dulu, baru kita lanjut profile pages?

**Pilih:**
- Option A: Saya buatkan semua (profile pages + privacy selector)
- Option B: Kamu add privacy selector dulu, saya bantu debug
- Option C: Saya buatkan profile pages dulu, privacy selector nanti

Mana yang mau? 😊

---

**Status:** ✅ Cleanup complete, ready for implementation  
**Next:** Run SQL → Add privacy → Create profiles
