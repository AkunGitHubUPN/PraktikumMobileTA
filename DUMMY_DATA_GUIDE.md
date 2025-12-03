# 📊 Panduan Insert Dummy Data

## Cara Menggunakan

### 1. Buka Supabase Dashboard
1. Login ke [Supabase Dashboard](https://supabase.com/dashboard)
2. Pilih project **"JejakPena"**
3. Klik **SQL Editor** di menu kiri
4. Klik **"New Query"**

### 2. Copy & Run SQL Script
1. Buka file `INSERT_DUMMY_DATA.sql`
2. **Copy SEMUA isi file** (Ctrl+A → Ctrl+C)
3. Paste di SQL Editor
4. Klik **"Run"** atau tekan Ctrl+Enter
5. ✅ Tunggu sampai muncul pesan sukses

### 3. Verifikasi Data
Setelah run, cek di **Table Editor**:
- ✅ Table `users` → Should have 6 users
- ✅ Table `friends` → Should have 12 rows (6 friendships bidirectional)
- ✅ Table `friend_requests` → Should have 4 pending requests
- ✅ Table `journals` → Should have 19 journals
- ✅ Table `journal_photos` → Should have 4 photos

---

## 👥 Data Dummy yang Dibuat

### Users (6 orang)
| Username | Password | Full Name | Deskripsi |
|----------|----------|-----------|-----------|
| `john` | `password123` | John Doe | Power user, punya 5 jurnal |
| `alice` | `password123` | Alice Smith | Active user, 4 jurnal |
| `bob` | `password123` | Bob Johnson | Traveler, 3 jurnal |
| `carol` | `password123` | Carol Williams | Wellness lover, 3 jurnal |
| `david` | `password123` | David Brown | Casual user, 2 jurnal |
| `emma` | `password123` | Emma Davis | New user, 2 jurnal |

**Note:** Semua password sudah di-hash dengan bcrypt!

### Friend Relationships (Bidirectional)
```
john ←→ alice
john ←→ bob
alice ←→ carol
bob ←→ david
carol ←→ emma
david ←→ emma
```

**Total:** 6 friendships = 12 rows di database (bidirectional)

### Pending Friend Requests
```
bob → alice (2 hours ago)
carol → john (5 hours ago)
emma → john (1 day ago)
david → alice (3 days ago)
```

**Total:** 4 pending requests

### Journals per User
```
john  → 5 jurnal (Bali, Nasi Padang, Bromo, Kopi Bandung, Borobudur)
alice → 4 jurnal (Surabaya, Shopping, Konser, Kota Tua)
bob   → 3 jurnal (Raja Ampat, Camping, Malang)
carol → 3 jurnal (Hotel, Spa, Yoga)
david → 2 jurnal (Timezone, Bioskop)
emma  → 2 jurnal (Baking, Jogging)
```

**Total:** 19 jurnal dengan berbagai tema (travel, kuliner, lifestyle)

### Journal Photos
- John's Bali trip (Pantai Kuta)
- John's Bromo adventure
- Alice's shopping haul
- Bob's diving in Raja Ampat

**Total:** 4 photos (menggunakan Unsplash placeholder images)

---

## 🧪 Testing Scenarios

### Test 1: Login dengan User Dummy
```
1. Buka app JejakPena
2. Login:
   Username: john
   Password: password123
3. ✅ Berhasil login
4. ✅ Muncul di Home Page
```

### Test 2: Lihat Jurnal Dummy
```
1. Login as john
2. Go to "Beranda" tab
3. ✅ Should see 5 journals:
   - Wisata Sejarah Yogyakarta (terbaru)
   - Kopi Enak di Bandung
   - Mendaki Gunung Bromo
   - Makan di Warung Nasi Padang
   - Liburan ke Bali (terlama)
```

### Test 3: Lihat Teman yang Ada
```
1. Login as john
2. Go to "Teman" tab → "Friends (2)"
3. ✅ Should see:
   - alice (Alice Smith)
   - bob (Bob Johnson)
```

### Test 4: Lihat Friend Requests
```
1. Login as john
2. Go to "Teman" tab → "Requests (2)"
3. ✅ Should see pending requests from:
   - carol (5 hours ago)
   - emma (1 day ago)
4. Test accept/reject
```

### Test 5: Search User yang Belum Jadi Teman
```
1. Login as john (already friends with: alice, bob)
2. Go to "Teman" tab
3. Search: "carol"
4. ✅ Should see carol (not a friend yet)
5. Search: "alice"
6. ✅ Should see NO RESULTS (already friends)
```

### Test 6: Test dengan User Lain
```
1. Logout
2. Login as alice
3. Go to "Teman" tab → "Friends (2)"
4. ✅ Should see:
   - john
   - carol
5. Go to "Requests (2)"
6. ✅ Should see requests from:
   - bob (2 hours ago)
   - david (3 days ago)
```

---

## 🗑️ Clear Dummy Data (Optional)

Jika ingin **reset dan hapus semua dummy data**:

```sql
-- ⚠️ WARNING: This will delete ALL data!
-- Only run if you want to start fresh

-- Delete in correct order (foreign keys)
DELETE FROM journal_photos;
DELETE FROM journals;
DELETE FROM friend_requests;
DELETE FROM friends;
DELETE FROM users WHERE username IN ('john', 'alice', 'bob', 'carol', 'david', 'emma');

-- Verify deletion
SELECT COUNT(*) FROM users; -- Should be 0 (or only your real users)
```

---

## 📝 Modifikasi Data Dummy

### Tambah User Baru
```sql
INSERT INTO users (id, username, password, full_name, created_at) VALUES
(
  'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx', -- Generate UUID baru
  'username_baru',
  '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', -- password123
  'Nama Lengkap',
  NOW()
);
```

### Tambah Jurnal Baru untuk User
```sql
INSERT INTO journals (id, user_id, judul, cerita, tanggal, latitude, longitude, nama_lokasi, created_at) VALUES
(
  'yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy', -- Generate UUID baru
  '11111111-1111-1111-1111-111111111111', -- john's ID
  'Judul Jurnal Baru',
  'Cerita jurnal yang panjang dan menarik...',
  NOW(),
  -6.200000,
  106.816666,
  'Jakarta',
  NOW()
);
```

### Tambah Friendship Baru
```sql
-- Buat john & carol jadi teman
SELECT create_friendship(
  '11111111-1111-1111-1111-111111111111', -- john
  '44444444-4444-4444-4444-444444444444'  -- carol
);
```

### Tambah Friend Request Baru
```sql
-- emma kirim request ke bob
INSERT INTO friend_requests (sender_id, receiver_id, status, created_at) VALUES
(
  '66666666-6666-6666-6666-666666666666', -- emma
  '33333333-3333-3333-3333-333333333333', -- bob
  'pending',
  NOW()
);
```

---

## 🔍 Query Berguna untuk Monitoring

### Lihat Semua User dan Jumlah Jurnal
```sql
SELECT 
  u.username,
  u.full_name,
  COUNT(j.id) as total_journals,
  u.created_at
FROM users u
LEFT JOIN journals j ON u.id = j.user_id
GROUP BY u.id, u.username, u.full_name, u.created_at
ORDER BY total_journals DESC;
```

### Lihat Semua Friendship
```sql
SELECT 
  u1.username as user1,
  u2.username as user2,
  f.created_at as friend_since
FROM friends f
JOIN users u1 ON f.user_id = u1.id
JOIN users u2 ON f.friend_id = u2.id
WHERE f.user_id < f.friend_id -- Show each friendship only once
ORDER BY f.created_at DESC;
```

### Lihat Pending Requests
```sql
SELECT 
  sender.username as from_user,
  receiver.username as to_user,
  fr.created_at as sent_at,
  NOW() - fr.created_at as time_ago
FROM friend_requests fr
JOIN users sender ON fr.sender_id = sender.id
JOIN users receiver ON fr.receiver_id = receiver.id
WHERE fr.status = 'pending'
ORDER BY fr.created_at DESC;
```

### Lihat User Paling Populer (Most Friends)
```sql
SELECT 
  u.username,
  u.full_name,
  COUNT(f.id) as total_friends
FROM users u
LEFT JOIN friends f ON u.id = f.user_id
GROUP BY u.id, u.username, u.full_name
ORDER BY total_friends DESC;
```

---

## ✅ Success Checklist

Setelah run script, verify:

- [ ] 6 users created (john, alice, bob, carol, david, emma)
- [ ] Semua password = `password123` (hashed)
- [ ] 12 rows in `friends` table (6 friendships x 2 directions)
- [ ] 4 pending requests in `friend_requests`
- [ ] 19 journals total
- [ ] 4 photos in `journal_photos`
- [ ] Can login with any dummy user
- [ ] Can see journals on Home page
- [ ] Can see friends in Friends tab
- [ ] Can see pending requests

---

## 🎯 Kegunaan Data Dummy

### Untuk Testing
- ✅ Test login/logout flow
- ✅ Test journal CRUD operations
- ✅ Test friend system (search, request, accept)
- ✅ Test UI dengan data real
- ✅ Test pull-to-refresh
- ✅ Test empty states vs populated states

### Untuk Demo
- ✅ Show app dengan data yang bagus
- ✅ Demonstrate all features
- ✅ Realistic user scenarios
- ✅ Professional presentation

### Untuk Development
- ✅ Quick testing tanpa manual input
- ✅ Edge case testing (many friends, no friends, etc.)
- ✅ Performance testing dengan banyak data
- ✅ UI testing dengan various content lengths

---

## 🚨 Troubleshooting

### ❌ Error: "duplicate key value violates unique constraint"
**Cause:** Data sudah ada sebelumnya
**Fix:** 
```sql
-- Option 1: Skip existing
-- Script already has ON CONFLICT DO NOTHING

-- Option 2: Delete existing dummy data first
DELETE FROM journal_photos;
DELETE FROM journals;
DELETE FROM friend_requests;
DELETE FROM friends;
DELETE FROM users WHERE username IN ('john', 'alice', 'bob', 'carol', 'david', 'emma');
-- Then run script again
```

### ❌ Error: "function create_friendship does not exist"
**Cause:** Helper function belum dibuat
**Fix:** Run SQL dari `PHASE_7_FRIEND_SYSTEM_SQL.md` terlebih dahulu

### ❌ Password tidak work saat login
**Cause:** bcrypt hash mismatch
**Fix:** Gunakan password: `password123` (lowercase, no spaces)

### ❌ Foto tidak muncul di app
**Cause:** Using Unsplash placeholder URLs
**Fix:** 
- Foto akan muncul jika ada internet
- Atau ganti URL dengan foto asli dari Supabase Storage
- Atau skip insert journal_photos jika tidak perlu

---

## 📚 Reference

- Script file: `INSERT_DUMMY_DATA.sql`
- Phase 7 SQL: `PHASE_7_FRIEND_SYSTEM_SQL.md`
- Testing guide: `TESTING_FRIEND_SYSTEM.md`

---

**Happy Testing!** 🎉

Semua user password: `password123`
