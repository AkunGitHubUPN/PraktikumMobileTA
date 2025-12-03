# 🎯 Phase 8: Friend Profile & Privacy - REVISED PLAN

## ✅ **YANG BENAR-BENAR DIBUTUHKAN:**

### **1. Privacy System (Simple)**
- **Public** - Teman bisa lihat
- **Private** - Hanya user sendiri yang bisa lihat

**Bukan 3 level!** Hanya 2 level saja (public/private).

---

### **2. Profile Page** 👤
**File:** `lib/screens/profile_page.dart`

**Features:**
- Tampilkan info user:
  - Username
  - Bio (opsional)
  - Total jurnal
  - Total teman
  - Member since
- **World Map**: Tampilkan semua jurnal user di peta
- **List Jurnal**: Grid/List view semua jurnal
- **Edit Profile** button

---

### **3. Friend Profile Page** 👥
**File:** `lib/screens/friend_profile_page.dart`

**Features:**
- Tampilkan info teman:
  - Username
  - Bio
  - Total jurnal (yang public)
  - Teman sejak kapan
- **World Map**: Tampilkan semua jurnal PUBLIC teman di peta
- **List Jurnal**: Hanya jurnal PUBLIC
- **Unfriend** button

**Access:**
- Dari Friends Page → Tap teman → Lihat profile

---

### **4. Privacy Selector di Add/Edit Journal** 🔒

#### **Add Journal Page**
**File:** `lib/screens/create_journal_page.dart`

**Add:**
```dart
// Privacy dropdown
DropdownButtonFormField<String>(
  value: _privacy, // default: 'public'
  decoration: InputDecoration(
    labelText: 'Privacy',
    prefixIcon: Icon(Icons.lock_outline),
  ),
  items: [
    DropdownMenuItem(
      value: 'public',
      child: Row(children: [
        Icon(Icons.public, color: Colors.green),
        SizedBox(width: 8),
        Text('Public - Teman dapat melihat'),
      ]),
    ),
    DropdownMenuItem(
      value: 'private',
      child: Row(children: [
        Icon(Icons.lock, color: Colors.red),
        SizedBox(width: 8),
        Text('Private - Hanya saya'),
      ]),
    ),
  ],
  onChanged: (value) {
    setState(() => _privacy = value!);
  },
)
```

#### **Edit Journal Page**
**File:** `lib/screens/journal_detail_page.dart`

**Add:**
- Privacy dropdown di edit mode
- Update privacy saat save

---

## 🗂️ **DATABASE CHANGES:**

### **1. ALTER TABLE journals**
```sql
-- Add privacy column (only public/private)
ALTER TABLE journals 
ADD COLUMN IF NOT EXISTS privacy VARCHAR(20) DEFAULT 'public' 
CHECK (privacy IN ('public', 'private'));

-- Create index
CREATE INDEX IF NOT EXISTS idx_journals_privacy ON journals(privacy);
```

### **2. No need for feed functions!**
Karena kita lihat langsung dari profile teman, tidak perlu function `get_feed_journals()`.

Cukup query biasa:
```sql
-- Get public journals from a specific user
SELECT * FROM journals 
WHERE user_id = '<friend_id>' 
AND privacy = 'public'
ORDER BY created_at DESC;
```

---

## 📋 **FILES TO CREATE/UPDATE:**

### **Create:**
1. ✅ `lib/screens/profile_page.dart` - Own profile
2. ✅ `lib/screens/friend_profile_page.dart` - Friend profile
3. ✅ `PHASE_8_REVISED_SQL.md` - Simple SQL script

### **Update:**
1. ✅ `lib/screens/create_journal_page.dart` - Add privacy dropdown
2. ✅ `lib/screens/journal_detail_page.dart` - Add privacy in edit mode
3. ✅ `lib/helpers/journal_service.dart` - Update methods
4. ✅ `lib/screens/friends_page.dart` - Add tap to view profile

### **Delete:**
1. ❌ `lib/screens/feed_page.dart` - Tidak perlu
2. ❌ `PHASE_8_JOURNAL_SHARING_SQL.md` - Ganti dengan yang baru

---

## 🚀 **FLOW:**

### **User Journey 1: Lihat Profile Teman**
```
1. User buka "Teman" tab
2. User tap pada salah satu teman (misal: alice)
3. Buka FriendProfilePage(userId: alice_id)
4. Tampilkan:
   - Username, bio, stats
   - Map dengan pin jurnal PUBLIC alice
   - List jurnal PUBLIC alice
5. User bisa tap jurnal untuk lihat detail
6. User bisa "Unfriend" alice
```

### **User Journey 2: Buat Jurnal dengan Privacy**
```
1. User buka "Beranda" tab
2. User tap tombol "+"
3. Buka CreateJournalPage
4. User isi judul, cerita, lokasi
5. User pilih privacy: Public / Private
6. User save
7. Jurnal tersimpan dengan privacy setting
```

### **User Journey 3: Edit Privacy Jurnal**
```
1. User buka jurnal detail
2. User tap "Edit"
3. User ubah privacy: Public → Private
4. User save
5. Sekarang teman tidak bisa lihat jurnal ini
```

---

## ✅ **CHECKLIST:**

### Database
- [ ] Run SQL: ALTER TABLE journals ADD privacy
- [ ] Verify privacy column exists
- [ ] Update existing journals to 'public'

### Profile Page
- [ ] Create profile_page.dart
- [ ] Show user stats (total journals, total friends)
- [ ] Show map with all journals
- [ ] Show list of all journals (own)
- [ ] Edit profile button (optional)

### Friend Profile Page
- [ ] Create friend_profile_page.dart
- [ ] Show friend stats
- [ ] Show map with PUBLIC journals only
- [ ] Show list of PUBLIC journals only
- [ ] Unfriend button
- [ ] Access from friends_page (tap friend)

### Privacy Selector
- [ ] Add dropdown in create_journal_page
- [ ] Default to 'public'
- [ ] Save privacy when create
- [ ] Add dropdown in journal_detail_page (edit mode)
- [ ] Update privacy when save edit

### Testing
- [ ] Create journal as public → Friend can see
- [ ] Create journal as private → Friend cannot see
- [ ] Edit journal public → private → Friend cannot see
- [ ] View friend profile → See only public journals
- [ ] View own profile → See all journals

---

## 🎯 **PRIORITY:**

1. **FIRST:** SQL script (add privacy column)
2. **SECOND:** Privacy selector in add/edit journal
3. **THIRD:** Profile pages (own + friend)
4. **LAST:** Integration & testing

---

**Status:** Plan Ready! Let's implement! 🚀
