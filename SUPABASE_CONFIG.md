# KONFIGURASI SUPABASE - JEJAK PENA

## 🔑 LANGKAH PENTING: ISI API CREDENTIALS!

Sebelum menjalankan aplikasi, kamu **HARUS** mengisi kredensial Supabase di file:

📄 **File:** `lib/helpers/supabase_helper.dart`

### Cara Mendapatkan Credentials:

1. Buka **Supabase Dashboard**: https://app.supabase.com
2. Pilih project **JejakPena**
3. Klik **Settings** (⚙️ icon) di sidebar kiri
4. Klik **API**
5. Copy 2 nilai ini:

#### 1. Project URL
```
https://xxxxxxxxxxxxx.supabase.co
```

#### 2. Anon/Public Key (panjang)
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6...
```

### Update di Code:

Buka file: `lib/helpers/supabase_helper.dart`

Ganti baris ini:
```dart
static const String supabaseUrl = 'YOUR_SUPABASE_URL_HERE';
static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY_HERE';
```

Dengan:
```dart
static const String supabaseUrl = 'https://xxxxx.supabase.co'; // URL kamu
static const String supabaseAnonKey = 'eyJhbGc...'; // API key kamu
```

---

## 📊 DATABASE TABLES (Sudah Dibuat)

✅ **users** - Tabel untuk menyimpan data user
✅ **journals** - Tabel untuk menyimpan jurnal
✅ **journal_photos** - Tabel untuk menyimpan foto jurnal

---

## 📸 STORAGE BUCKET (Sudah Dibuat)

✅ **journal-photos** - Bucket untuk upload foto (Public)

---

## 🚀 FITUR YANG SUDAH SIAP:

### ✅ Backend Services:
- `SupabaseHelper` - Core Supabase configuration
- `AuthService` - Register, Login, Get User
- `JournalService` - CRUD journals + photos

### 🔄 Migration Status:
- ✅ User authentication (username + password with bcrypt)
- ✅ Journal CRUD operations
- ✅ Photo upload to Supabase Storage
- ✅ User session management (support UUID)

---

## 📝 NEXT STEPS:

1. **ISI CREDENTIALS** di `supabase_helper.dart` (WAJIB!)
2. Update Login Page untuk gunakan `AuthService`
3. Update Register Page untuk gunakan `AuthService`
4. Update Add Journal Page untuk gunakan `JournalService`
5. Update Journal List untuk fetch dari Supabase
6. Testing!

---

## ⚠️ CATATAN PENTING:

- **ID Type Changed:** Dari `int` (SQLite) jadi `String UUID` (Supabase)
- **UserSession:** Sudah support UUID (String)
- **Password:** Tetap pakai bcrypt untuk hashing
- **Photos:** Upload ke Supabase Storage, bukan lokal

---

## 🐛 DEBUGGING:

Kalau ada error, cek:
1. ✅ Credentials sudah diisi?
2. ✅ Tables sudah dibuat di Supabase?
3. ✅ Bucket sudah dibuat dan public?
4. ✅ Internet connection aktif?
5. ✅ `flutter pub get` sudah dijalankan?

---

## 📞 HELP:

Kalau stuck, lihat console log:
- `[SUPABASE]` - Supabase initialization
- `[AUTH]` - Authentication operations
- `[JOURNAL]` - Journal CRUD operations
