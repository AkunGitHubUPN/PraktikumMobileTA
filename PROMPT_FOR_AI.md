# 🤖 PROMPT UNTUK AI LAIN (Supabase Expert)

## **KONTEKS:**
Saya mengembangkan Flutter mobile app dengan Supabase backend. App menggunakan **custom authentication** (username/password di tabel `users`), BUKAN Supabase Auth bawaan. Saya mengalami masalah upload foto ke Supabase Storage.

---

## **MASALAH:**
Upload foto dari Flutter ke Supabase Storage selalu gagal dengan error:
```
StorageException(message: new row violates row-level security policy, statusCode: 403, error: Unauthorized)
```

---

## **SETUP SAAT INI:**

### **1. Bucket Configuration:**
- Bucket name: `journal-photos-v2`
- **Visibility: Public** (sudah dicentang di Dashboard)
- Created via Dashboard UI dengan opsi "Public bucket" enabled

### **2. RLS Policies (Sudah Dibuat via Dashboard UI):**
```
Policy Name: Allow anon read journal-photos
Operation: SELECT
Target Role: anon
Policy Definition: bucket_id = 'journal-photos-v2'

Policy Name: Allow anon insert journal-photos
Operation: INSERT
Target Role: anon
Policy Definition: bucket_id = 'journal-photos-v2'

Policy Name: Allow anon update journal-photos
Operation: UPDATE
Target Role: anon
Policy Definition: bucket_id = 'journal-photos-v2'

Policy Name: Allow anon delete journal-photos
Operation: DELETE
Target Role: anon
Policy Definition: bucket_id = 'journal-photos-v2'
```

### **3. Flutter Code:**
```dart
// Initialization
await Supabase.initialize(
  url: 'https://xxxxx.supabase.co',
  anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...', // Valid anon key
  debug: true,
);

// Upload
final client = Supabase.instance.client;
final bytes = Uint8List.fromList(await File(filePath).readAsBytes());

final response = await client.storage
    .from('journal-photos-v2')
    .uploadBinary(
        'photo_123456.jpg', // Direct to root, no subfolder
        bytes,
        fileOptions: FileOptions(
            cacheControl: '3600',
            upsert: true,
            contentType: 'image/jpeg',
        ),
    );
```

### **4. Authentication:**
- **TIDAK** menggunakan Supabase Auth (`client.auth.signInWithPassword`)
- Menggunakan custom auth: username/password disimpan di tabel `users` dengan bcrypt
- User login, dapat UUID, disimpan di `SharedPreferences`
- Tidak ada JWT token dari Supabase Auth

---

## **YANG SUDAH BERHASIL:**
1. ✅ Manual upload via Supabase Dashboard → **BERHASIL**
2. ✅ Create/read/update data di tabel `journals` → **BERHASIL**
3. ✅ Bucket visibility sudah "Public"

## **YANG GAGAL:**
1. ❌ Upload via Flutter API → **ERROR 403 RLS policy violation**

---

## **YANG SUDAH DICOBA:**

1. ✅ Set bucket jadi Public via Dashboard
2. ✅ Buat 4 RLS policies (SELECT, INSERT, UPDATE, DELETE) untuk role `anon`
3. ✅ Recreate bucket baru dengan nama `journal-photos-v2`
4. ✅ Upload langsung ke root bucket (tidak pakai subfolder)
5. ✅ Eksplisit set `contentType: 'image/jpeg'`
6. ❌ Tidak bisa jalankan `ALTER TABLE storage.objects` (error: must be owner of table)
7. ❌ Tidak bisa disable RLS via SQL

---

## **PERTANYAAN:**

### **1. Apakah bucket "Public" otomatis allow write access tanpa RLS policies?**
Atau "Public" hanya untuk read access? Apakah masih perlu policies untuk INSERT?

### **2. Apakah custom auth (non-Supabase Auth) menyebabkan masalah ini?**
Karena saya tidak menggunakan `client.auth.signInWithPassword`, apakah Supabase Storage tidak recognize `anon` role dengan benar?

### **3. Apa perbedaan antara:**
- **Public bucket** (centang di Dashboard)
- **RLS disabled** untuk bucket
- **Policies untuk role `anon`**

### **4. Apakah ada konfigurasi tambahan yang diperlukan untuk:**
- Membuat bucket benar-benar public untuk write access (upload)?
- Menggunakan Storage tanpa Supabase Auth?

### **5. Solusi alternatif apa yang bisa saya coba:**
- Apakah perlu pakai Supabase Auth + custom auth bersamaan?
- Apakah perlu buat Edge Function untuk upload?
- Apakah ada SQL command lain selain `ALTER TABLE` untuk disable RLS?

---

## **ENVIRONMENT:**
- Flutter: 3.x
- Supabase Flutter: `^2.5.0`
- Supabase instance: Free tier
- Platform: Android (emulator)

---

## **GOAL:**
Saya ingin Flutter app bisa upload foto ke Supabase Storage menggunakan anon key, dengan custom authentication (tanpa Supabase Auth), dan bucket yang sudah public.

**Bagaimana cara konfigurasi yang benar untuk use case ini?**
