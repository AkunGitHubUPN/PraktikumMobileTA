# 📖 QUICK REFERENCE - SUPABASE MIGRATION

## 🔧 FILE-FILE PENTING:

### 1. Supabase Configuration
```dart
lib/helpers/supabase_helper.dart
```
- Initialize Supabase
- Upload/delete photos
- Get current user

### 2. Authentication Service
```dart
lib/helpers/auth_service.dart
```
- `registerUser(username, password)` → Map?
- `loginUser(username, password)` → Map?
- `getUserById(userId)` → Map?

### 3. Journal Service
```dart
lib/helpers/journal_service.dart
```
- `createJournal(...)` → String? (journal ID)
- `getJournalsForUser()` → List<Map>
- `getJournalById(journalId)` → Map?
- `updateJournal(journalId, judul, cerita)` → bool
- `deleteJournal(journalId)` → bool
- `addPhotoToJournal(journalId, photoUrl)` → bool
- `deletePhoto(photoId)` → bool

### 4. User Session
```dart
lib/helpers/user_session.dart
```
- `currentUserId` → String? (UUID)
- `isLoggedIn` → bool
- `saveSession(userId)` → void
- `clearSession()` → void

---

## 📝 CARA PAKAI SERVICES:

### Register User Baru
```dart
final user = await AuthService.instance.registerUser(username, password);
if (user != null) {
  await UserSession.instance.saveSession(user['id']);
  // Navigate to home
}
```

### Login User
```dart
final user = await AuthService.instance.loginUser(username, password);
if (user != null) {
  await UserSession.instance.saveSession(user['id']);
  // Navigate to home
}
```

### Create Journal
```dart
final journalId = await JournalService.instance.createJournal(
  judul: 'Trip Bali',
  cerita: 'Amazing trip...',
  tanggal: DateTime.now(),
  latitude: -8.4095,
  longitude: 115.1889,
  namaLokasi: 'Bali, Indonesia',
);
```

### Upload Photo
```dart
final photoUrl = await SupabaseHelper.instance.uploadPhoto(
  localFilePath,
  'photo_${DateTime.now().millisecondsSinceEpoch}.jpg',
);

await JournalService.instance.addPhotoToJournal(
  journalId: journalId,
  photoUrl: photoUrl,
);
```

### Get User's Journals
```dart
final journals = await JournalService.instance.getJournalsForUser();
// journals contains all journals with nested photos
```

### Update Journal
```dart
final success = await JournalService.instance.updateJournal(
  journalId: 'xxx',
  judul: 'New Title',
  cerita: 'Updated story',
);
```

### Delete Journal
```dart
final success = await JournalService.instance.deleteJournal(journalId);
// Photos will be auto-deleted (CASCADE)
```

### Logout
```dart
await UserSession.instance.clearSession();
// Navigate to login page
```

---

## 🔑 DATA STRUCTURES:

### User Object
```dart
{
  'id': 'uuid-string',
  'username': 'john_doe',
  'password': 'hashed_password',
  'created_at': '2024-12-04T...'
}
```

### Journal Object (with photos)
```dart
{
  'id': 'uuid-string',
  'user_id': 'uuid-string',
  'judul': 'Trip Title',
  'cerita': 'Story...',
  'tanggal': '2024-12-04T...',
  'latitude': -8.4095,
  'longitude': 115.1889,
  'nama_lokasi': 'Bali, Indonesia',
  'created_at': '...',
  'updated_at': '...',
  'journal_photos': [
    {
      'id': 'uuid-string',
      'journal_id': 'uuid-string',
      'photo_url': 'https://...supabase.co/storage/.../photo.jpg',
      'created_at': '...'
    }
  ]
}
```

---

## 🎨 UI CHANGES NEEDED:

### From Integer ID → UUID String
**BEFORE:**
```dart
int journalId = 123;
```

**AFTER:**
```dart
String journalId = 'uuid-string';
```

### From Local Path → Cloud URL
**BEFORE:**
```dart
String photoPath = '/data/user/0/.../photo.jpg';
Image.file(File(photoPath));
```

**AFTER:**
```dart
String photoUrl = 'https://...supabase.co/.../photo.jpg';
Image.network(photoUrl);
```

---

## 💡 TIPS:

1. **Debug Logs:** Semua services punya print statements
   - `[SUPABASE]` - Supabase operations
   - `[AUTH]` - Authentication
   - `[JOURNAL]` - Journal CRUD

2. **Error Handling:** Semua methods return null/false on error

3. **UUID:** Supabase auto-generate UUID untuk semua `id` fields

4. **Cascade Delete:** 
   - Delete user → auto delete journals
   - Delete journal → auto delete photos

---

**Need help? Check console logs or MIGRATION_PROGRESS.md** 🚀
