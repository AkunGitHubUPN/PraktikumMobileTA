# 🔧 PANDUAN FIX STORAGE RLS ERROR 403

## Error yang Terjadi:
```
StorageException(message: new row violates row-level security policy, statusCode: 403, error: Unauthorized)
```

## ✅ SOLUSI LANGKAH DEMI LANGKAH

### **STEP 1: Pastikan Bucket adalah PUBLIC**

1. Buka Supabase Dashboard:
   ```
   https://supabase.com/dashboard/project/hejkweydyxdjrhfgpwlm/storage/buckets
   ```

2. Di halaman Storage Buckets:
   - Cari bucket bernama **`journal-photos`**
   - Klik **icon gear (⚙️)** atau **titik tiga (⋮)** di sebelah kanan bucket
   - Pilih **"Edit bucket"** atau **"Bucket settings"**

3. Di form Edit Bucket:
   - Cari checkbox **"Public bucket"**
   - **CENTANG/ENABLE** checkbox tersebut
   - Klik **"Save"** atau **"Update bucket"**

4. Verifikasi:
   - Setelah disimpan, di kolom "Visibility" seharusnya tertulis **"Public"** (bukan "Private")

---

### **STEP 2: Tambah Storage Policies (via UI)**

1. Masih di halaman Storage, klik bucket **`journal-photos`**

2. Klik tab **"Policies"** (biasanya di samping tab "Objects")

3. Klik tombol **"New Policy"** atau **"Create policy"**

4. Pilih template **"Allow public access"** ATAU pilih **"Custom policy"**

5. Buat 4 policies berikut (satu per satu):

#### **Policy A: SELECT (View/Read)**
```
Policy name: Public Select Access
Allowed operation: SELECT
Target roles: public
USING expression: bucket_id = 'journal-photos'
```
Klik **Save policy**

#### **Policy B: INSERT (Upload)**
```
Policy name: Public Insert Access
Allowed operation: INSERT
Target roles: public
WITH CHECK expression: bucket_id = 'journal-photos'
```
Klik **Save policy**

#### **Policy C: UPDATE**
```
Policy name: Public Update Access
Allowed operation: UPDATE
Target roles: public
USING expression: bucket_id = 'journal-photos'
WITH CHECK expression: bucket_id = 'journal-photos'
```
Klik **Save policy**

#### **Policy D: DELETE**
```
Policy name: Public Delete Access
Allowed operation: DELETE
Target roles: public
USING expression: bucket_id = 'journal-photos'
```
Klik **Save policy**

---

### **STEP 3: Verifikasi Policies**

Di tab **Policies**, Anda seharusnya melihat 4 policies:
- ✅ Public Select Access (SELECT, public)
- ✅ Public Insert Access (INSERT, public)
- ✅ Public Update Access (UPDATE, public)
- ✅ Public Delete Access (DELETE, public)

---

### **STEP 4: Test Upload**

1. Restart aplikasi Flutter Anda
2. Login dengan akun yang sudah ada
3. Coba buat journal baru dengan foto
4. Upload seharusnya berhasil! 🎉

---

## ⚠️ JIKA MASIH ERROR:

### **Alternatif 1: Gunakan Supabase Storage tanpa Folder**

Edit `lib/helpers/supabase_helper.dart`, ubah path upload:

```dart
// SEBELUM (dengan folder user):
final String fullPath = '$userId/$fileName';

// SESUDAH (langsung di root bucket):
final String fullPath = fileName;
```

### **Alternatif 2: Check Bucket Name**

Pastikan nama bucket di kode sama persis dengan di dashboard:
- Kode: `'journal-photos'`
- Dashboard: `journal-photos` (bukan `journal_photos` atau `journalphotos`)

### **Alternatif 3: Recreate Bucket**

1. Backup semua foto yang sudah ada (jika ada)
2. Delete bucket `journal-photos`
3. Buat bucket baru dengan nama `journal-photos`
4. **CENTANG "Public bucket" saat membuat**
5. Jangan tambah policies apapun (public bucket tidak perlu RLS)

---

## 🎯 PENJELASAN

**Kenapa Error 403?**
- Supabase Storage punya Row Level Security (RLS) default yang block semua akses
- Karena kita pakai custom auth (bukan Supabase Auth), Supabase tidak recognize user kita
- Solusi: Set bucket jadi Public ATAU buat policies yang allow public access

**Apakah Aman?**
- Public bucket = semua orang bisa lihat foto (OK untuk app journal)
- Siapa pun bisa upload jika punya API key (API key sudah di kode, jadi cukup aman)
- Untuk production, bisa pakai Supabase Edge Functions untuk validasi server-side

---

## 📝 CHECKLIST

- [ ] Bucket `journal-photos` sudah set jadi **Public**
- [ ] Visibility di dashboard menunjukkan **"Public"**
- [ ] Ada 4 policies (SELECT, INSERT, UPDATE, DELETE) untuk role **public**
- [ ] Restart Flutter app setelah perubahan
- [ ] Test upload foto dan berhasil ✅

---

Jika masih ada error setelah semua langkah di atas, screenshot:
1. Halaman Storage Buckets (tunjukkan visibility)
2. Halaman Policies untuk bucket journal-photos
3. Error message dari Flutter debug console

Saya akan bantu troubleshoot lebih lanjut! 🔍
