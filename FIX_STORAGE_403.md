# 🚨 FIX ERROR 403: Storage RLS Policy

## Error yang Terjadi:
```
StorageException(message: new row violates row-level security policy, statusCode: 403, error: Unauthorized)
```

---

## ✅ SOLUSI 1: Set Bucket Jadi Public via SQL (PALING MUDAH)

### **Langkah 1: Buka SQL Editor**
1. Buka Supabase Dashboard: https://supabase.com/dashboard/project/hejkweydyxdjrhfgpwlm
2. Klik **SQL Editor** di sidebar kiri
3. Klik **New Query**

### **Langkah 2: Jalankan Query Ini**

**Jika nama bucket Anda adalah `journal-photos`:**
```sql
UPDATE storage.buckets 
SET public = true 
WHERE id = 'journal-photos';
```

**Jika nama bucket baru Anda berbeda (misal `journal-photos-new`):**
```sql
UPDATE storage.buckets 
SET public = true 
WHERE id = 'NAMA_BUCKET_BARU_ANDA';
```

### **Langkah 3: Verifikasi**
Jalankan query ini untuk cek apakah sudah Public:
```sql
SELECT id, name, public 
FROM storage.buckets;
```

Hasilnya harus menunjukkan:
```
id                  | name            | public
--------------------|-----------------|--------
journal-photos      | journal-photos  | true   ✅
```

Jika kolom `public` = `true`, berarti sudah benar!

---

## ✅ SOLUSI 2: Disable RLS untuk Storage Objects

Jika solusi 1 tidak berhasil, jalankan SQL ini:

```sql
-- Matikan RLS untuk storage.objects
ALTER TABLE storage.objects DISABLE ROW LEVEL SECURITY;
```

**⚠️ WARNING:** Ini akan mematikan RLS untuk SEMUA buckets. Hanya untuk development/testing!

---

## ✅ SOLUSI 3: Buat Policy yang Benar

Jika Anda ingin tetap pakai RLS (lebih aman), jalankan SQL ini:

```sql
-- Drop semua policies lama (jika ada)
DROP POLICY IF EXISTS "Public Access" ON storage.objects;
DROP POLICY IF EXISTS "Public Upload" ON storage.objects;
DROP POLICY IF EXISTS "Public Delete" ON storage.objects;
DROP POLICY IF EXISTS "Public Update" ON storage.objects;

-- Buat policies baru untuk bucket journal-photos
CREATE POLICY "Allow public read"
ON storage.objects FOR SELECT
USING (bucket_id = 'journal-photos');

CREATE POLICY "Allow public insert"
ON storage.objects FOR INSERT
WITH CHECK (bucket_id = 'journal-photos');

CREATE POLICY "Allow public update"
ON storage.objects FOR UPDATE
USING (bucket_id = 'journal-photos')
WITH CHECK (bucket_id = 'journal-photos');

CREATE POLICY "Allow public delete"
ON storage.objects FOR DELETE
USING (bucket_id = 'journal-photos');
```

**Catatan:** Ganti `'journal-photos'` dengan nama bucket baru Anda jika berbeda!

---

## 🔍 DEBUGGING: Cek Nama Bucket di Kode

Pastikan nama bucket di kode sama dengan nama bucket di Supabase!

### **File: `lib/helpers/supabase_helper.dart`**
Cari baris ini:
```dart
await client.storage.from('journal-photos').uploadBinary(
```

Pastikan `'journal-photos'` sama persis dengan nama bucket di Supabase Dashboard!

---

## 📋 CHECKLIST:

Setelah menjalankan SQL:

1. ✅ Run SQL: `UPDATE storage.buckets SET public = true WHERE id = 'journal-photos';`
2. ✅ Verify: `SELECT id, name, public FROM storage.buckets;` → public = **true**
3. ✅ Restart Flutter app
4. ✅ Test upload foto
5. ✅ Cek di Supabase Storage → Files → Apakah foto muncul?

---

## 🎯 Jika Masih Error:

### **Cek Console Log:**
Saat upload error, lihat debug console. Cari baris:
```
[SUPABASE] ❌ Upload error details: ...
```

Kirim error message lengkapnya untuk troubleshooting lebih lanjut.

### **Cek Bucket Name:**
1. Buka Storage di Supabase
2. Screenshot daftar buckets
3. Pastikan nama bucket di kode sama persis

### **Test Manual Upload:**
1. Buka Supabase → Storage → Bucket Anda
2. Klik **Upload File** manual
3. Jika manual upload juga error 403 → Bucket belum Public
4. Jika manual upload berhasil → Problem di kode Flutter

---

## 🔧 Perubahan yang Sudah Dilakukan di Kode:

1. ✅ Upload tidak pakai subfolder user lagi (`fileName` langsung, bukan `$userId/$fileName`)
2. ✅ Added detailed logging untuk debugging
3. ✅ Removed unused import `user_session.dart`

Ini menghindari masalah RLS policy yang mungkin memblock akses ke subfolder tertentu.

---

**NEXT STEPS:**
1. Jalankan SQL untuk set bucket jadi public
2. Restart Flutter app
3. Test upload foto
4. Report hasilnya! 🎉
