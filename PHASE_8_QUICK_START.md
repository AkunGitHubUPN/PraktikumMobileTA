# 🚀 Phase 8: Quick Start Guide

## ⚡ IMMEDIATE NEXT STEPS

### Step 1: Run Database Migration (REQUIRED)

1. **Open Supabase Dashboard**
   - Go to: https://supabase.com/dashboard
   - Select your JejakPena project

2. **Open SQL Editor**
   - Click "SQL Editor" in the left sidebar
   - Click "New query"

3. **Run Migration Script**
   - Copy the entire contents of `PHASE_8_PRIVACY_MIGRATION.sql`
   - OR copy this script:
   ```sql
   ALTER TABLE journals 
   ADD COLUMN IF NOT EXISTS privacy VARCHAR(20) DEFAULT 'public' 
   CHECK (privacy IN ('public', 'private'));
   
   CREATE INDEX IF NOT EXISTS idx_journals_privacy ON journals(privacy);
   CREATE INDEX IF NOT EXISTS idx_journals_user_privacy ON journals(user_id, privacy);
   
   UPDATE journals SET privacy = 'public' WHERE privacy IS NULL;
   ```

4. **Execute**
   - Click "Run" button
   - Wait for success message
   - Check output shows "Migration Complete!"

5. **Verify**
   Run this verification query:
   ```sql
   SELECT privacy, COUNT(*) as count 
   FROM journals 
   GROUP BY privacy;
   ```
   Expected output: All journals should show `privacy: public`

---

### Step 2: Test Privacy Features

#### Create New Journal with Privacy
1. Open app
2. Tap "Tambah Jurnal" (Add Journal)
3. Fill in title and story
4. **Look for privacy dropdown** above photo section
5. Select "Public" or "Private"
6. Save journal
7. **Verify:** Open journal details, check privacy is saved

#### Edit Existing Journal Privacy
1. Open any journal
2. Tap edit icon (pencil)
3. **Look for privacy dropdown** below story field
4. Change privacy setting
5. Tap save
6. **Verify:** Reopen journal, check privacy changed

---

### Step 3: Test Friend Profile

#### Navigate to Friend Profile
1. Go to "Teman" (Friends) tab
2. **Tap on any friend's name** (NEW!)
3. Friend profile page opens
4. See friend's public journals only

#### Test Privacy Filtering
1. Create 2 journals: 1 public, 1 private
2. Ask a friend to view your profile
3. **Verify:** Friend sees only the public journal
4. **Verify:** Private journal is NOT visible

#### Unfriend Feature
1. On friend profile page
2. Tap "person_remove" icon in app bar
3. Confirm removal
4. **Verify:** Return to friends list
5. **Verify:** Friend is removed

---

### Step 4: Access Own Profile (Optional - Add Navigation)

The `ProfilePage` is created but not yet added to navigation.

#### Quick Test (Add Button Temporarily)
Add this to any page to test:
```dart
ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfilePage()),
    );
  },
  child: const Text('My Profile'),
)
```

#### Recommended: Add to Settings Page
In `settings_page.dart`, add a "View Profile" option that navigates to `ProfilePage`.

---

## 📋 TESTING CHECKLIST

### Database ✅
- [ ] SQL script executed successfully
- [ ] `privacy` column exists in `journals` table
- [ ] All existing journals have `privacy = 'public'`
- [ ] Indexes created

### Create Journal 🆕
- [ ] Privacy dropdown visible
- [ ] Can select "Public"
- [ ] Can select "Private"
- [ ] Privacy saves correctly

### Edit Journal ✏️
- [ ] Privacy dropdown visible in edit mode
- [ ] Shows current privacy value
- [ ] Can change from public to private
- [ ] Can change from private to public
- [ ] Changes persist after save

### Friend Profile 👥
- [ ] Can tap friend name to open profile
- [ ] Friend username displays correctly
- [ ] Only public journals shown
- [ ] Private journals NOT shown
- [ ] Can view journal details
- [ ] Can unfriend user
- [ ] Returns to friends list after unfriend

### Own Profile (if added) 👤
- [ ] Username displays correctly
- [ ] Shows all journals (public + private)
- [ ] Lock icon on private journals
- [ ] Globe icon on public journals
- [ ] Journal count correct
- [ ] Friend count correct

---

## 🎨 UI PREVIEW

### Privacy Selector in Create Journal
```
┌───────────────────────────────────────┐
│ Judul: [___________________]          │
│                                       │
│ Cerita: [_____________________]       │
│         [_____________________]       │
│                                       │
│ Tanggal: 4 Desember 2025    📅       │
│                                       │
│ ┌─────────────────────────────────┐  │
│ │ 🔒 Privasi Jurnal               │  │
│ │ ▼ Public - Teman dapat melihat │  │
│ │   Private - Hanya saya          │  │
│ └─────────────────────────────────┘  │
│                                       │
│ Foto Jurnal                          │
│ [Camera] [Gallery]                   │
└───────────────────────────────────────┘
```

### Friend Profile Page
```
┌───────────────────────────────────────┐
│  ← JohnDoe                      ❌    │
└───────────────────────────────────────┘
│                                       │
│         👤 JohnDoe                    │
│                                       │
│      Jurnal Publik: 5                 │
│                                       │
├───────────────────────────────────────┤
│ Jurnal Publik          🌐 5 jurnal   │
│                                       │
│ ┌──────────────────────────────────┐ │
│ │ 📷  Trip to Bali           🌐   │ │
│ │     1 Desember 2025              │ │
│ │     Amazing journey...           │ │
│ │     📍 Ubud, Bali                │ │
│ └──────────────────────────────────┘ │
│                                       │
│ ┌──────────────────────────────────┐ │
│ │ 📷  Sunrise Hike          🌐   │ │
│ │     28 November 2025             │ │
│ │     Beautiful morning...         │ │
│ │     📍 Mount Bromo               │ │
│ └──────────────────────────────────┘ │
└───────────────────────────────────────┘
```

---

## 🐛 TROUBLESHOOTING

### Privacy dropdown not showing?
- Check `add_journal_page.dart` has the dropdown code
- Rebuild app: Stop and restart
- Clear cache: `flutter clean && flutter pub get`

### Friend profile shows private journals?
- Check `getUserPublicJournals()` filters by `privacy = 'public'`
- Verify database query in console
- Check journal's privacy value in database

### Database error when creating journal?
- Ensure SQL migration ran successfully
- Check `privacy` column exists
- Verify column has CHECK constraint

### Can't navigate to friend profile?
- Check `friends_page.dart` has `onTap` handler
- Verify import: `import 'friend_profile_page.dart';`
- Rebuild app

---

## 📁 FILES SUMMARY

### Files Created ✨
- `lib/screens/profile_page.dart` - Own profile (all journals)
- `lib/screens/friend_profile_page.dart` - Friend profile (public only)
- `PHASE_8_PRIVACY_MIGRATION.sql` - Database migration
- `PHASE_8_IMPLEMENTATION_COMPLETE.md` - Full documentation
- `PHASE_8_QUICK_START.md` - This guide

### Files Modified 🔧
- `lib/screens/add_journal_page.dart` - Added privacy selector
- `lib/screens/journal_detail_page.dart` - Added privacy selector (edit)
- `lib/screens/friends_page.dart` - Added navigation to friend profile
- `lib/helpers/journal_service.dart` - Added privacy support

---

## ✅ SUCCESS INDICATORS

You'll know Phase 8 is working correctly when:

1. ✅ Creating a journal shows privacy dropdown
2. ✅ Editing a journal shows privacy dropdown with current value
3. ✅ Tapping a friend's name opens their profile
4. ✅ Friend profile shows only public journals
5. ✅ Your private journals DON'T appear on friend's view
6. ✅ Unfriend button removes friend successfully

---

## 🎉 CONGRATULATIONS!

**Phase 8 is now complete!** 🎊

Your JejakPena app now has:
- ✅ Privacy control for journals
- ✅ Friend profile pages
- ✅ Public/private journal filtering
- ✅ Seamless friend-to-profile navigation

**What's Next?**
- Run the database migration (Step 1 above)
- Test all features (Steps 2-4 above)
- Add ProfilePage to navigation (Optional)
- Share with friends and test privacy!

---

**Need Help?** Check `PHASE_8_IMPLEMENTATION_COMPLETE.md` for full details.

**Ready to Test?** Start with Step 1: Database Migration! 🚀
