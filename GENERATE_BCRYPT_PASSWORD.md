# 🔐 Generate Custom Bcrypt Password

Jika ingin mengganti password dummy dengan password sendiri, gunakan salah satu cara berikut:

## Option 1: Online Bcrypt Generator (PALING MUDAH)

1. Buka: https://bcrypt-generator.com/
2. Masukkan password yang diinginkan
3. Pilih **Rounds: 10**
4. Klik **Generate Hash**
5. Copy hash yang dihasilkan
6. Replace di SQL script

**Contoh:**
```
Input: mypassword123
Output: $2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy
```

---

## Option 2: Menggunakan Flutter (Recommended)

Buat file temporary `test_bcrypt.dart`:

```dart
import 'package:flutter_bcrypt/flutter_bcrypt.dart';

void main() async {
  // Ganti dengan password yang diinginkan
  String password = 'password123';
  
  // Generate hash dengan 10 rounds
  String hashed = await FlutterBcrypt.hashPw(
    password: password,
    salt: await FlutterBcrypt.salt(10),
  );
  
  print('Password: $password');
  print('Hashed: $hashed');
  
  // Test verify
  bool isValid = await FlutterBcrypt.verify(
    password: password,
    hash: hashed,
  );
  
  print('Verification: $isValid');
}
```

Run:
```bash
dart run test_bcrypt.dart
```

---

## Option 3: Menggunakan Node.js

Jika punya Node.js installed:

```bash
npm install bcryptjs
```

Buat file `generate_hash.js`:

```javascript
const bcrypt = require('bcryptjs');

// Ganti dengan password yang diinginkan
const password = 'password123';
const saltRounds = 10;

bcrypt.hash(password, saltRounds, function(err, hash) {
  console.log('Password:', password);
  console.log('Hashed:', hash);
  
  // Test verify
  bcrypt.compare(password, hash, function(err, result) {
    console.log('Verification:', result);
  });
});
```

Run:
```bash
node generate_hash.js
```

---

## Option 4: Menggunakan Python

Jika punya Python installed:

```bash
pip install bcrypt
```

Buat file `generate_hash.py`:

```python
import bcrypt

# Ganti dengan password yang diinginkan
password = 'password123'.encode('utf-8')

# Generate hash dengan 10 rounds
salt = bcrypt.gensalt(rounds=10)
hashed = bcrypt.hashpw(password, salt)

print(f'Password: password123')
print(f'Hashed: {hashed.decode()}')

# Test verify
is_valid = bcrypt.checkpw(password, hashed)
print(f'Verification: {is_valid}')
```

Run:
```bash
python generate_hash.py
```

---

## Default Password di Dummy Data

Script `INSERT_DUMMY_DATA.sql` menggunakan:

```
Password: password123
Hash: $2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy
```

**Semua 6 user** menggunakan password yang sama untuk kemudahan testing.

---

## Cara Replace Password di SQL Script

1. Generate hash password baru (gunakan salah satu option di atas)
2. Buka `INSERT_DUMMY_DATA.sql`
3. Find & Replace:
   ```
   Find: $2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy
   Replace: [HASH_BARU_ANDA]
   ```
4. Save file
5. Run SQL script di Supabase

---

## Testing Password

Setelah insert data, test login:

```
Username: john
Password: [password_yang_anda_set]
```

Jika berhasil login → Hash correct! ✅

---

## Tips

### ✅ DO:
- Use bcrypt rounds: 10 (balance security & performance)
- Test hash before inserting to database
- Keep password simple for dummy data (e.g., "password123")
- Document the password somewhere for team testing

### ❌ DON'T:
- Don't use plain text password in database
- Don't use low rounds (< 10)
- Don't use different hashing algorithm
- Don't forget to test login after insert

---

## Verification Query

Untuk cek password hash di database:

```sql
SELECT 
  username, 
  password,
  LENGTH(password) as hash_length
FROM users 
WHERE username = 'john';
```

**Expected:**
- Hash length: 60 characters
- Hash starts with: `$2a$10$` or `$2b$10$`

---

## Password Hash Format

Bcrypt hash format:
```
$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy
│  │  │ │                                                        │
│  │  │ └─ Salt (22 chars)                                       │
│  │  └─ Cost factor (10 = 2^10 iterations)                     │
│  └─ Bcrypt version (2a = bcrypt)                              │
└─ Hash identifier                                               │
                                                                  │
                                                    Hash (31 chars)
```

Total: 60 characters

---

**Need Help?**
- Online tool paling mudah: https://bcrypt-generator.com/
- Always use **10 rounds** for compatibility
