# ⚠️ SOLUSI ALTERNATIF: DISABLE RLS SEMENTARA

## Jika semua cara gagal, gunakan ini HANYA untuk testing:

### 1. Dapatkan Service Role Key

1. Buka Supabase Dashboard → Settings → API
2. Copy **service_role key** (JANGAN yang anon/public key!)
3. **JANGAN share key ini ke siapa pun!**

### 2. Buat SQL Function untuk Disable RLS

Karena kita tidak bisa ALTER TABLE storage.objects, kita bisa coba workaround dengan mengubah bucket menjadi public via SQL:

```sql
-- Run di SQL Editor
-- Ini akan set bucket jadi public tanpa perlu ALTER TABLE

UPDATE storage.buckets 
SET public = true,
    file_size_limit = 52428800,  -- 50MB
    allowed_mime_types = ARRAY['image/jpeg', 'image/png', 'image/jpg', 'image/gif']
WHERE id = 'journal-photos';
```

### 3. Cek Hasil

```sql
SELECT id, name, public, file_size_limit, allowed_mime_types 
FROM storage.buckets 
WHERE id = 'journal-photos';
```

Pastikan kolom `public` = `true`

---

## 🎯 CARA PALING PASTI:

Karena error 403 RLS policy dan kita tidak bisa ubah via SQL, satu-satunya cara yang PASTI work adalah:

### RECREATE BUCKET DARI AWAL

1. **Backup semua data** (jika ada foto di bucket lama)

2. **Delete bucket lama:**
   - Storage → Klik titik tiga di bucket journal-photos → Delete

3. **Buat bucket baru:**
   - Klik **"New bucket"**
   - Name: `journal-photos-v2`
   - **CENTANG "Public bucket"** ✅
   - **CENTANG "File size limit"** → Set 50MB
   - **Set allowed MIME types** → `image/jpeg, image/png`
   - Klik **"Create bucket"**

4. **Update kode Flutter:**
   - Ganti semua `'journal-photos'` jadi `'journal-photos-v2'` di supabase_helper.dart

5. **Test upload lagi** - Seharusnya berhasil karena bucket baru sudah public dari awal!

---

**MANA YANG HARUS DICOBA?**

Urutan prioritas:
1. ✅ **PERTAMA:** Coba buat policies via Dashboard UI (Storage → Policies)
2. ✅ **KEDUA:** Coba SQL `UPDATE storage.buckets SET public = true`
3. ✅ **TERAKHIR:** Recreate bucket baru dengan nama `journal-photos-v2` yang sudah public dari awal

Kasih tau saya mana yang berhasil! 🔍
