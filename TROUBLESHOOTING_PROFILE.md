# 🔧 Troubleshooting: Profile Tidak Muncul

## 🐛 Masalah yang Dilaporkan
- Username tidak muncul di profile
- Jumlah jurnal tidak muncul
- Jumlah teman tidak muncul
- Jurnal teman tidak muncul di friend profile
- Tidak bisa melihat jurnal public teman

## 📋 Langkah Debugging

### 1. Cek Console Log
Jalankan aplikasi dan buka **Debug Console** di VS Code. Cari log dengan prefix:
```
[PROFILE]
[FRIEND_PROFILE]
[JOURNAL]
```

### 2. Verifikasi User Session
Pastikan user sudah login:
```dart
// Di debug console, cari log:
[PROFILE] Current userId: <uuid>

// Jika muncul:
[PROFILE] ❌ userId is null
// Berarti user belum login atau session hilang
```

**SOLUSI**: Logout dan login ulang

### 3. Cek Database Supabase

#### A. Verifikasi Tabel `users`
```sql
-- Cek apakah kolom photo_url dan hobby sudah ada
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'users';

-- Harus ada kolom:
-- - id
-- - username
-- - password
-- - photo_url (baru)
-- - hobby (baru)
```

**SOLUSI**: Jika kolom belum ada, jalankan:
```sql
ALTER TABLE users ADD COLUMN IF NOT EXISTS photo_url TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS hobby TEXT;
```

#### B. Cek Data User
```sql
-- Ganti <user_id> dengan UUID user yang login
SELECT id, username, photo_url, hobby 
FROM users 
WHERE id = '<user_id>';

-- Pastikan ada data
```

#### C. Cek Data Journals
```sql
-- Cek jurnal user
SELECT id, judul, user_id, privacy, created_at
FROM journals
WHERE user_id = '<user_id>'
ORDER BY created_at DESC;

-- Pastikan ada data dan kolom privacy ada
```

#### D. Cek Data Friends
```sql
-- Cek daftar teman
SELECT * FROM friends
WHERE user1_id = '<user_id>' OR user2_id = '<user_id>';

-- Pastikan ada data friendship
```

### 4. Verifikasi RLS (Row Level Security)

#### A. Cek Policy untuk `users` table
```sql
-- Lihat existing policies
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies
WHERE tablename = 'users';
```

Pastikan ada policy yang mengizinkan **SELECT** untuk authenticated users:
```sql
-- Contoh policy yang benar
CREATE POLICY "Users can read all user profiles"
ON users FOR SELECT
TO authenticated
USING (true);
```

#### B. Cek Policy untuk `journals` table
```sql
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies
WHERE tablename = 'journals';
```

Pastikan ada policy:
```sql
-- User bisa baca jurnal sendiri
CREATE POLICY "Users can read own journals"
ON journals FOR SELECT
TO authenticated
USING (auth.uid()::text = user_id);

-- User bisa baca jurnal public teman (jika perlu)
-- Atau bisa juga pakai policy yang lebih permisif untuk testing
CREATE POLICY "Users can read public journals"
ON journals FOR SELECT
TO authenticated
USING (privacy = 'public');
```

#### C. Cek Policy untuk `friends` table
```sql
SELECT schemaname, tablename, policyname
FROM pg_policies
WHERE tablename = 'friends';
```

### 5. Test Manual di Supabase

#### Test Query User
```sql
-- Pastikan bisa query users
SELECT id, username FROM users LIMIT 5;
```

#### Test Query Journals dengan Join
```sql
-- Test query yang sama seperti di app
SELECT j.*, 
       json_agg(json_build_object('id', jp.id, 'photo_url', jp.photo_url)) as journal_photos
FROM journals j
LEFT JOIN journal_photos jp ON jp.journal_id = j.id
WHERE j.user_id = '<user_id>'
GROUP BY j.id
ORDER BY j.created_at DESC;
```

#### Test Query Public Journals
```sql
-- Test untuk friend profile
SELECT j.*, 
       json_agg(json_build_object('id', jp.id, 'photo_url', jp.photo_url)) as journal_photos
FROM journals j
LEFT JOIN journal_photos jp ON jp.journal_id = j.id
WHERE j.user_id = '<friend_user_id>' AND j.privacy = 'public'
GROUP BY j.id
ORDER BY j.created_at DESC;
```

### 6. Kemungkinan Penyebab Masalah

#### A. RLS Terlalu Ketat
**Gejala**: Query sukses di SQL Editor tapi gagal di app

**Solusi Sementara** (untuk testing):
```sql
-- Disable RLS sementara untuk testing
ALTER TABLE users DISABLE ROW LEVEL SECURITY;
ALTER TABLE journals DISABLE ROW LEVEL SECURITY;
ALTER TABLE friends DISABLE ROW LEVEL SECURITY;

-- JANGAN LUPA ENABLE KEMBALI SETELAH TESTING!
```

**Solusi Permanent**: Perbaiki RLS policies

#### B. User ID Format Tidak Match
**Gejala**: userId di log berbeda format dengan di database

**Cek**:
```dart
// Di app, print userId
print('User ID type: ${UserSession.instance.currentUserId.runtimeType}');
print('User ID value: ${UserSession.instance.currentUserId}');
```

```sql
-- Di Supabase, cek format user_id
SELECT id, pg_typeof(id), user_id, pg_typeof(user_id)
FROM journals
LIMIT 1;
```

#### C. Kolom Privacy Tidak Ada
**Gejala**: Error saat query journals

**Solusi**:
```sql
-- Tambahkan kolom privacy jika belum ada
ALTER TABLE journals ADD COLUMN IF NOT EXISTS privacy TEXT DEFAULT 'public';

-- Update existing data
UPDATE journals SET privacy = 'public' WHERE privacy IS NULL;
```

### 7. Quick Fix - Reset RLS

Jika semua gagal, reset semua RLS policies:

```sql
-- 1. Drop semua policies
DROP POLICY IF EXISTS "Users can read all user profiles" ON users;
DROP POLICY IF EXISTS "Users can read own journals" ON journals;
DROP POLICY IF EXISTS "Users can read public journals" ON journals;

-- 2. Buat ulang dengan policy sederhana
CREATE POLICY "Enable read for authenticated users"
ON users FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Enable read for authenticated users"
ON journals FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Enable read for authenticated users"
ON friends FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Enable read for authenticated users"
ON journal_photos FOR SELECT
TO authenticated
USING (true);
```

### 8. Cara Testing Cepat

1. **Restart App** (hot restart tidak cukup)
   ```bash
   flutter run
   ```

2. **Logout & Login Ulang**

3. **Buka Profile Page** dan perhatikan console log

4. **Cek Error Messages** di console:
   - Jika ada error "permission denied" → RLS issue
   - Jika ada error "column does not exist" → Migration belum dijalankan
   - Jika ada error "null" → Data tidak ada atau query gagal

### 9. Debugging Checklist

- [ ] SQL migration sudah dijalankan (photo_url, hobby, privacy columns)
- [ ] User sudah login (userId tidak null)
- [ ] RLS policies sudah benar
- [ ] Data ada di database (users, journals, friends)
- [ ] Console log tidak ada error
- [ ] Restart aplikasi setelah perubahan

### 10. Kode Debug Tambahan

Tambahkan di `profile_page.dart` untuk testing:

```dart
@override
void initState() {
  super.initState();
  _debugSession();
  _loadProfileData();
}

void _debugSession() {
  final userId = UserSession.instance.currentUserId;
  print('=== DEBUG SESSION ===');
  print('User ID: $userId');
  print('User ID Type: ${userId.runtimeType}');
  print('Is Null: ${userId == null}');
  print('====================');
}
```

---

## 📞 Jika Masih Bermasalah

1. Share console log lengkap
2. Share hasil query SQL test
3. Share screenshot error (jika ada)

---

## ✅ Solusi yang Sudah Ditambahkan

- ✅ Debug logging di ProfilePage
- ✅ Debug logging di FriendProfilePage
- ✅ Stack trace untuk error
- ✅ Detailed print statements
