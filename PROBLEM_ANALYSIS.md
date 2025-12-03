# 🔍 ANALISIS MASALAH LENGKAP

## **ERROR YANG TERJADI:**
```
StorageException(message: new row violates row-level security policy, statusCode: 403, error: Unauthorized)
```

---

## **KONTEKS SISTEM:**

### **Tech Stack:**
- **Frontend:** Flutter (Mobile App)
- **Backend:** Supabase (PostgreSQL + Storage)
- **Authentication:** Custom auth (username/password) di tabel `users`, BUKAN Supabase Auth
- **Storage:** Supabase Storage bucket untuk foto journal

### **Arsitektur:**
```
Flutter App (anon key) 
    ↓
Supabase Storage API
    ↓
storage.objects table (RLS ENABLED)
    ↓
Bucket: journal-photos-v2
```

---

## **SITUASI YANG SUDAH DICOBA:**

### ✅ Yang Berhasil:
1. **Manual upload via Dashboard** → ✅ BERHASIL (menggunakan service role key)
2. **Create journal (metadata)** → ✅ BERHASIL (tabel journals bisa insert)
3. **Bucket visibility** → ✅ Sudah set "Public"

### ❌ Yang Gagal:
1. **API upload via Flutter** → ❌ ERROR 403 RLS policy violation
2. **Semua policies sudah dibuat** (SELECT, INSERT, UPDATE, DELETE untuk role `anon`) → ❌ Tetap error

---

## **KONFIGURASI SAAT INI:**

### **Bucket Settings:**
- Name: `journal-photos-v2`
- Visibility: **Public**
- File size limit: Default (atau 50MB)
- Allowed MIME types: Default (atau image/jpeg, image/png)

### **RLS Policies yang Sudah Dibuat:**
```sql
-- Policy 1: Allow anon read
CREATE POLICY "Allow anon read journal-photos"
ON storage.objects FOR SELECT
TO anon
USING (bucket_id = 'journal-photos-v2');

-- Policy 2: Allow anon insert
CREATE POLICY "Allow anon insert journal-photos"
ON storage.objects FOR INSERT
TO anon
WITH CHECK (bucket_id = 'journal-photos-v2');

-- Policy 3: Allow anon update
CREATE POLICY "Allow anon update journal-photos"
ON storage.objects FOR UPDATE
TO anon
USING (bucket_id = 'journal-photos-v2')
WITH CHECK (bucket_id = 'journal-photos-v2');

-- Policy 4: Allow anon delete
CREATE POLICY "Allow anon delete journal-photos"
ON storage.objects FOR DELETE
TO anon
USING (bucket_id = 'journal-photos-v2');
```

### **Flutter Upload Code:**
```dart
final response = await client.storage
    .from('journal-photos-v2')
    .uploadBinary(
        fileName, // Langsung ke root (tidak pakai subfolder)
        bytes,
        fileOptions: FileOptions(
            cacheControl: '3600',
            upsert: true,
            contentType: 'image/jpeg',
        ),
    );
```

### **Supabase Initialization:**
```dart
await Supabase.initialize(
    url: 'https://hejkweydyxdjrhfgpwlm.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...', // Valid anon key
    debug: true,
);
```

---

## **KENDALA PERMISSION:**

### **SQL Error yang Dialami:**
```
ERROR: 42501: must be owner of table objects
```

**Artinya:**
- User tidak punya permission untuk `ALTER TABLE storage.objects`
- Tidak bisa disable RLS secara global
- Hanya bisa buat policies via Dashboard UI

---

## **PERBEDAAN KUNCI:**

| Aspek | Manual Upload (Dashboard) | API Upload (Flutter) |
|-------|---------------------------|---------------------|
| **Auth Method** | Service role key (full access) | Anon key (limited by RLS) |
| **RLS Check** | ❌ Bypassed | ✅ Enforced |
| **Result** | ✅ Berhasil | ❌ Error 403 |

**Kesimpulan:** RLS policies tidak bekerja dengan benar untuk `anon` role!

---

## **HIPOTESIS MASALAH:**

### **Kemungkinan 1: Policy Conflict**
- Ada policy lama yang konflik (sudah di-drop tapi masih cached)
- Policies tidak ter-apply dengan benar ke bucket `journal-photos-v2`

### **Kemungkinan 2: Bucket Configuration Issue**
- Bucket "Public" tidak sama dengan "RLS disabled"
- Public bucket masih enforce RLS untuk write operations
- Butuh konfigurasi tambahan selain centang "Public bucket"

### **Kemungkinan 3: Custom Auth Problem**
- Supabase tidak mengenali user karena pakai custom auth (bukan Supabase Auth)
- `anon` role tidak punya permission default untuk insert ke storage.objects
- Butuh policy khusus untuk **unauthenticated** access

### **Kemungkinan 4: Storage API Version/Bug**
- Bug di Supabase Storage API untuk public buckets
- Versi `supabase_flutter` tidak kompatibel dengan RLS setup

---

## **PERTANYAAN KUNCI:**

1. **Apakah bucket "Public" otomatis bypass RLS untuk write operations?**
   - Atau hanya untuk read operations?

2. **Apakah policies untuk role `anon` cukup untuk unauthenticated API access?**
   - Atau butuh role `public` atau `authenticated`?

3. **Apakah ada cara disable RLS untuk bucket tertentu tanpa `ALTER TABLE`?**
   - Via SQL function? Via API? Via Dashboard setting?

4. **Apakah custom auth (non-Supabase Auth) mempengaruhi Storage permissions?**
   - Bagaimana Supabase Storage validate access tanpa JWT dari Supabase Auth?

---

## **SOLUSI YANG BELUM DICOBA:**

### **Opsi A: Menggunakan Authenticated Upload**
- Buat temporary Supabase Auth user saat register custom user
- Gunakan JWT token dari Supabase Auth untuk upload
- Kombinasi custom auth + Supabase Auth

### **Opsi B: Server-side Upload (Edge Function)**
- Buat Edge Function dengan service role key
- Flutter call Edge Function → Edge Function upload ke Storage
- Bypass RLS karena pakai service role

### **Opsi C: Direct SQL Manipulation**
```sql
-- Disable RLS untuk bucket spesifik (butuh superuser permission)
UPDATE storage.buckets 
SET public = true, 
    avif_autodetection = false,
    file_size_limit = 52428800,
    allowed_mime_types = NULL
WHERE id = 'journal-photos-v2';

-- Atau coba buat policy dengan owner/service_role
CREATE POLICY "Allow all for service role"
ON storage.objects FOR ALL
TO service_role
USING (bucket_id = 'journal-photos-v2');
```

### **Opsi D: Ganti ke Cloudinary/AWS S3**
- Jika Supabase Storage terlalu ribet, pakai provider lain
- Upload langsung dari Flutter ke Cloudinary
- Simpan URL di Supabase database

---

## **INFO TAMBAHAN YANG DIBUTUHKAN:**

1. Output dari query:
```sql
SELECT * FROM pg_policies 
WHERE tablename = 'objects' 
AND schemaname = 'storage';
```

2. Output dari query:
```sql
SELECT id, name, public, owner, file_size_limit, allowed_mime_types
FROM storage.buckets 
WHERE id = 'journal-photos-v2';
```

3. Full error stack trace dari Flutter debug console

4. Versi package:
   - `supabase_flutter: ^2.5.0`
   - Versi Supabase instance (bisa cek di Settings)

---

## **KESIMPULAN:**

**Root Cause:** RLS policies untuk `anon` role tidak ter-apply dengan benar untuk INSERT operations pada `storage.objects`, meskipun bucket sudah Public dan policies sudah dibuat.

**Missing Piece:** Ada konfigurasi atau permission tambahan yang diperlukan untuk membuat `anon` role bisa upload via API, yang berbeda dengan setting "Public bucket" di UI.

**Next Action:** Perlu bantuan dari Supabase expert atau dokumentasi resmi tentang:
- Cara benar konfigurasi public bucket untuk write access dengan custom auth
- Perbedaan antara "Public bucket" dan "Disable RLS"
- Alternatif workaround selain policies manual
