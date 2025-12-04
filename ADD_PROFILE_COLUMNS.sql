-- Menambahkan kolom photo_url dan hobby ke tabel users
-- Jalankan query ini di Supabase SQL Editor

-- Tambah kolom photo_url untuk menyimpan URL foto profile
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS photo_url TEXT;

-- Tambah kolom hobby untuk menyimpan hobi user
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS hobby TEXT;

-- Opsional: Set default value untuk existing users
-- UPDATE users SET hobby = 'Belum diisi' WHERE hobby IS NULL;

-- Verifikasi kolom berhasil ditambahkan
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'users';
