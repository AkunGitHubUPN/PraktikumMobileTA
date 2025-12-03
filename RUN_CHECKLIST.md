# ✅ FINAL CHECKLIST - BEFORE RUNNING

## 🎯 **LANGKAH TERAKHIR SEBELUM RUN:**

### **1. Install Dependencies**
Jalankan di terminal VSCode:
```powershell
flutter pub get
```

**Expected output:**
```
Running "flutter pub get" in MobileTA...
Resolving dependencies...
+ supabase_flutter 2.5.0
...
Got dependencies!
```

---

### **2. Verify Supabase Credentials**

Buka file: `lib/helpers/supabase_helper.dart`

Check line 12-13:
```dart
static const String supabaseUrl = 'https://hejkweydyxdjrhfgpwlm.supabase.co';
static const String supabaseAnonKey = 'eyJhbGc...';
```

✅ **Sudah terisi!**

---

### **3. Verify Database Tables**

Login ke Supabase Dashboard: https://app.supabase.com

Check:
- [ ] Table `users` exists
- [ ] Table `journals` exists  
- [ ] Table `journal_photos` exists
- [ ] Storage bucket `journal-photos` exists (Public)

Kalau belum ada, jalankan script di `SUPABASE_CONFIG.md`

---

### **4. Run App**

```powershell
flutter run
```

**Expected console output:**
```
Launching lib\main.dart on Android...
Running Gradle task 'assembleDebug'...
✓ Built build\app\outputs\flutter-apk\app-debug.apk.
Installing build\app\outputs\flutter-apk\app.apk...
Syncing files to device...

[SUPABASE] ✅ Initialized successfully!
[SESSION] Tidak ada sesi aktif.
```

✅ Kalau muncul `[SUPABASE] ✅ Initialized successfully!` → Setup BERHASIL!

---

## 🧪 **QUICK TEST PLAN:**

### **Scenario 1: Happy Path (5 menit)**

1. **Register** → Input username/password → Klik Daftar
   - ✅ Sukses → kembali ke Login
   
2. **Login** → Input credentials → Klik Login
   - ✅ Sukses → masuk ke Home Page
   
3. **Create Journal** → Klik + → Isi form → Save
   - ✅ Jurnal muncul di list
   
4. **View Detail** → Klik jurnal → Lihat detail
   - ✅ Detail tampil lengkap
   
5. **Logout** → Settings → Logout
   - ✅ Kembali ke Login

### **Scenario 2: Photo Upload (3 menit)**

1. Create journal dengan foto
2. Check di Supabase Dashboard > Storage > journal-photos
   - ✅ Foto muncul di folder `{user_id}/photo_xxx.jpg`

---

## 🐛 **COMMON ERRORS & FIXES:**

### **Error 1: "Package supabase_flutter not found"**
```
flutter pub get
flutter clean
flutter pub get
```

### **Error 2: "Failed to connect to Supabase"**
- Check internet
- Check credentials di `supabase_helper.dart`
- Check Supabase project status di dashboard

### **Error 3: "relation 'users' does not exist"**
- Tables belum dibuat
- Go to Supabase Dashboard > SQL Editor
- Run CREATE TABLE scripts

### **Error 4: "Storage bucket not found"**
- Go to Supabase Dashboard > Storage
- Create bucket `journal-photos` (centang Public)

### **Error 5: App crash saat create journal**
- Check console logs
- Kemungkinan foto upload gagal
- Check storage policies

---

## 📊 **SUCCESS INDICATORS:**

Console logs yang HARUS muncul:

```
✅ [SUPABASE] ✅ Initialized successfully!
✅ [SESSION] User ID xxxxx ditemukan. Auto-login berhasil.
✅ [AUTH] ✅ Login successful: xxxxx
✅ [JOURNAL] ✅ Created: xxxxx
✅ [JOURNAL] ✅ Photo added to journal: xxxxx
```

---

## 🎉 **JIKA SEMUA SUKSES:**

Congratulations! Migration ke Supabase BERHASIL! 🎊

App sekarang:
- ✅ Cloud-based (data tersimpan di Supabase)
- ✅ Photo storage di cloud
- ✅ Multi-device ready (login dari device manapun)
- ✅ Scalable (bisa handle banyak users)
- ✅ Siap untuk fitur sosial (Phase 5)

---

## 📞 **NEED HELP?**

Kalau ada error:
1. Screenshot error message
2. Copy console logs
3. Check `FINAL_SUMMARY.md` untuk troubleshooting
4. Check `SUPABASE_GUIDE.md` untuk API reference

---

**Status:** ✅ READY TO RUN
**Date:** December 4, 2025
**Version:** 2.0.0 (Cloud Edition)

## 🚀 **GO GO GO!**

```powershell
flutter run
```
