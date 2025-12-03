# ✅ SOLUSI FINAL - JAWABAN DARI AI EXPERT

## **ROOT CAUSE:**
1. **Public bucket ≠ write access** - Public hanya untuk READ
2. **`upsert: true` butuh SELECT + INSERT + UPDATE permission sekaligus** ← INI KUNCI!
3. **Policy via UI mungkin tidak presisi untuk role `anon`**

---

## **🎯 LANGKAH 1: Jalankan SQL (WAJIB!)**

Buka **SQL Editor** di Supabase Dashboard dan jalankan script berikut:

```sql
-- 1. Hapus semua policy lama agar tidak konflik
DROP POLICY IF EXISTS "Allow anon read journal-photos" ON storage.objects;
DROP POLICY IF EXISTS "Allow anon insert journal-photos" ON storage.objects;
DROP POLICY IF EXISTS "Allow anon update journal-photos" ON storage.objects;
DROP POLICY IF EXISTS "Allow anon delete journal-photos" ON storage.objects;
DROP POLICY IF EXISTS "Allow anon read journal-photos-v2" ON storage.objects;
DROP POLICY IF EXISTS "Allow anon insert journal-photos-v2" ON storage.objects;
DROP POLICY IF EXISTS "Allow anon update journal-photos-v2" ON storage.objects;
DROP POLICY IF EXISTS "Allow anon delete journal-photos-v2" ON storage.objects;
DROP POLICY IF EXISTS "Public Access Select" ON storage.objects;
DROP POLICY IF EXISTS "Public Access Insert" ON storage.objects;
DROP POLICY IF EXISTS "Public Access Update" ON storage.objects;
DROP POLICY IF EXISTS "Public Access Delete" ON storage.objects;

-- 2. Policy SELECT (Wajib untuk Upsert & Read)
CREATE POLICY "Public Access Select"
ON storage.objects FOR SELECT
TO anon
USING ( bucket_id = 'journal-photos-v2' );

-- 3. Policy INSERT (Untuk Upload)
CREATE POLICY "Public Access Insert"
ON storage.objects FOR INSERT
TO anon
WITH CHECK ( bucket_id = 'journal-photos-v2' );

-- 4. Policy UPDATE (Wajib karena upsert: true)
CREATE POLICY "Public Access Update"
ON storage.objects FOR UPDATE
TO anon
USING ( bucket_id = 'journal-photos-v2' );

-- 5. Policy DELETE (Optional, tapi mungkin butuh)
CREATE POLICY "Public Access Delete"
ON storage.objects FOR DELETE
TO anon
USING ( bucket_id = 'journal-photos-v2' );
```

**✅ Setelah jalankan SQL di atas, lanjut ke langkah 2**

---

## **🎯 LANGKAH 2: Hot Restart Flutter App**

1. Stop aplikasi Flutter
2. Run ulang: `flutter run`

---

## **🎯 LANGKAH 3: Test Upload**

1. Login ke app
2. Buat journal dengan **1 foto**
3. Lihat debug console

**Expected Result:**
```
[SUPABASE] 📤 Uploading to bucket: journal-photos-v2
[SUPABASE] 📦 File size: xxxxx bytes
[SUPABASE] 📡 Upload response: {...}
[SUPABASE] ✅ Upload success!
[SUPABASE] 🔗 Public URL: https://...
[ADD_JOURNAL] ✅ Photo uploaded: https://...
[ADD_JOURNAL] ✅ Photo linked to journal
```

---

## **🔍 Jika Masih Error, Cek:**

### **Error Berbeda:**
Jika error message berubah (bukan lagi "violates row-level security policy"), beritahu detail errornya.

### **Masih 403:**
1. Verifikasi policies sudah dibuat:
```sql
SELECT policyname, cmd, roles, qual, with_check
FROM pg_policies
WHERE tablename = 'objects' AND schemaname = 'storage'
AND policyname LIKE '%Public Access%';
```

Harusnya muncul 4 policies: Select, Insert, Update, Delete

2. Verifikasi bucket name benar:
```sql
SELECT id, name, public FROM storage.buckets WHERE id = 'journal-photos-v2';
```

Harusnya `public = true`

---

## **⚠️ CATATAN KEAMANAN:**

Policy ini membuka akses INSERT/UPDATE ke role `anon` (publik). **Siapapun yang tahu URL Supabase Anda bisa upload file.**

**Risiko:** Spam attack - orang bisa membanjiri storage dengan file sampah.

**Mitigasi (Untuk Production):**

### **Opsi 1: Batasi ukuran file**
Di bucket settings, set `File size limit` ke 5MB atau 10MB.

### **Opsi 2: Tambah folder restriction**
```sql
-- Contoh: Hanya izinkan upload jika nama file sesuai pola
CREATE POLICY "Public Access Insert"
ON storage.objects FOR INSERT
TO anon
WITH CHECK (
  bucket_id = 'journal-photos-v2'
  AND name ~ '^photo_[0-9]+_[0-9]+\.jpg$' -- Regex pattern
);
```

### **Opsi 3: Gunakan Edge Function (Recommended)**
Buat Supabase Edge Function yang:
1. Terima request upload dari Flutter
2. Validasi user (cek custom auth)
3. Upload dengan `service_role` key
4. Return URL ke Flutter

**Tapi untuk development/testing sekarang, policy di atas sudah cukup!**

---

## **📋 CHECKLIST:**

- [ ] Jalankan SQL DROP + CREATE policies
- [ ] Verifikasi policies ada (query SELECT)
- [ ] Hot restart Flutter app
- [ ] Test upload 1 foto
- [ ] ✅ **BERHASIL!** (foto muncul di Supabase Storage)

---

## **🎉 JIKA BERHASIL:**

Selamat! Upload foto sudah bekerja. Untuk production nanti:
1. Tambah file size limit di bucket settings
2. Pertimbangkan pakai Edge Function untuk keamanan lebih baik
3. Atau switch ke Supabase Auth (lebih secure)

---

**Silakan jalankan SQL di Langkah 1 dan test!** 🚀
