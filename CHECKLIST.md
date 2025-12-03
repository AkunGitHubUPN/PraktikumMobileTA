# ✅ CHECKLIST SEBELUM LANJUT

## 🔴 WAJIB SEKARANG:

### 1. Isi Supabase Credentials
- [ ] Buka `lib/helpers/supabase_helper.dart`
- [ ] Ganti `YOUR_SUPABASE_URL_HERE` dengan URL projectmu
- [ ] Ganti `YOUR_SUPABASE_ANON_KEY_HERE` dengan API key mu
- [ ] Save file

### 2. Install Dependencies
Jalankan di terminal:
```powershell
flutter pub get
```

### 3. Verifikasi Supabase Dashboard
- [ ] Tables sudah dibuat (users, journals, journal_photos)
- [ ] Bucket sudah dibuat (journal-photos)
- [ ] Bucket sudah public

---

## 🟡 OPSIONAL (RECOMMENDED):

### 4. Test Basic Setup
Jalankan app untuk test login/register:
```powershell
flutter run
```

Cek di console:
- ✅ Harus ada log: `[SUPABASE] ✅ Initialized successfully!`
- ✅ Test register user baru
- ✅ Test login dengan user yang baru dibuat

---

## 🟢 SIAP LANJUT KE PHASE 4:

Kalau sudah:
- ✅ Credentials diisi
- ✅ `flutter pub get` berhasil
- ✅ Login/Register works

Maka kita lanjut update:
1. **Add Journal Page** - create journal + upload foto
2. **Home Tab Page** - fetch & display journals
3. **Journal Detail Page** - edit/delete journal

---

## 🐛 KALAU ADA ERROR:

### Error: "Failed to initialize Supabase"
- Cek internet connection
- Cek credentials sudah benar
- Cek URL tidak ada typo

### Error: "No tables found"
- Buka Supabase Dashboard > SQL Editor
- Jalankan lagi script create tables

### Error: "Storage bucket not found"
- Buka Supabase Dashboard > Storage
- Buat bucket "journal-photos" (centang Public)

---

**Status saat ini: Step 8/15 selesai (53% done!)** 🎉

**Mau lanjut ke Phase 4 atau test dulu?** 🚀
