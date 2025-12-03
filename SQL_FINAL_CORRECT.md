# ✅ SOLUSI FINAL - SQL YANG BENAR (Updated)

## **🎯 LANGKAH 1: Jalankan SQL INI (BUCKET: journal-photos)**

Buka **SQL Editor** di Supabase Dashboard dan jalankan:

```sql
-- 1. Hapus semua policy lama
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

-- 2. Buat policy baru yang BENAR (bucket: journal-photos)
CREATE POLICY "Public Access Select"
ON storage.objects FOR SELECT
TO anon
USING ( bucket_id = 'journal-photos' );

CREATE POLICY "Public Access Insert"
ON storage.objects FOR INSERT
TO anon
WITH CHECK ( bucket_id = 'journal-photos' );

CREATE POLICY "Public Access Update"
ON storage.objects FOR UPDATE
TO anon
USING ( bucket_id = 'journal-photos' );

CREATE POLICY "Public Access Delete"
ON storage.objects FOR DELETE
TO anon
USING ( bucket_id = 'journal-photos' );
```

---

## **🎯 LANGKAH 2: Verifikasi**

Cek apakah policies sudah benar:

```sql
SELECT policyname, cmd, roles, qual::text, with_check::text
FROM pg_policies
WHERE tablename = 'objects' 
AND schemaname = 'storage'
AND policyname LIKE '%Public Access%';
```

Harusnya muncul 4 rows dengan `bucket_id = 'journal-photos'`

---

## **🎯 LANGKAH 3: Hot Restart & Test**

1. **Hot restart** Flutter app
2. **Login**
3. **Buat journal dengan foto**
4. **Lihat debug console** - seharusnya:
   ```
   [SUPABASE] 📤 Uploading to bucket: journal-photos
   [SUPABASE] ✅ Upload success!
   ```

---

## **📝 PERUBAHAN KODE:**

Saya sudah update `supabase_helper.dart`:
- ✅ `journal-photos-v2` → `journal-photos` (3 tempat)
- ✅ Upload, getPublicUrl, remove semuanya pakai bucket yang benar

---

## **🎉 SEKARANG SEHARUSNYA BERHASIL!**

Karena:
1. ✅ Kode pakai bucket `journal-photos`
2. ✅ SQL policies untuk bucket `journal-photos`
3. ✅ Bucket sudah Public
4. ✅ Policies untuk SELECT + INSERT + UPDATE (karena upsert: true)

**Silakan jalankan SQL di atas dan test upload foto!** 🚀
