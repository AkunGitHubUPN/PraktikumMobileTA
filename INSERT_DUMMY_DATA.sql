-- ============================================
-- FIXED FULL SCRIPT - JEJAK PENA
-- ============================================

-- 1. CLEANUP (Opsional: Hapus data lama biar bersih)
TRUNCATE TABLE journal_photos, journals, friend_requests, friends, users RESTART IDENTITY CASCADE;

-- ============================================
-- 2. INSERT DUMMY USERS
-- ============================================
INSERT INTO users (id, username, password, created_at) VALUES 
('11111111-1111-1111-1111-111111111111', 'john',  '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', NOW() - INTERVAL '30 days'),
('22222222-2222-2222-2222-222222222222', 'alice', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', NOW() - INTERVAL '25 days'),
('33333333-3333-3333-3333-333333333333', 'bob',   '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', NOW() - INTERVAL '20 days'),
('44444444-4444-4444-4444-444444444444', 'carol', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', NOW() - INTERVAL '15 days'),
('55555555-5555-5555-5555-555555555555', 'david', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', NOW() - INTERVAL '10 days'),
('66666666-6666-6666-6666-666666666666', 'emma',  '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', NOW() - INTERVAL '5 days') 
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- 3. INSERT FRIEND RELATIONSHIPS
-- ============================================
-- Pastikan function 'create_friendship' sudah ada. Jika belum, ganti blok ini.
SELECT create_friendship('11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222');
SELECT create_friendship('11111111-1111-1111-1111-111111111111', '33333333-3333-3333-3333-333333333333');
SELECT create_friendship('22222222-2222-2222-2222-222222222222', '44444444-4444-4444-4444-444444444444');
SELECT create_friendship('33333333-3333-3333-3333-333333333333', '55555555-5555-5555-5555-555555555555');
SELECT create_friendship('44444444-4444-4444-4444-444444444444', '66666666-6666-6666-6666-666666666666');
SELECT create_friendship('55555555-5555-5555-5555-555555555555', '66666666-6666-6666-6666-666666666666');

-- ============================================
-- 4. INSERT FRIEND REQUESTS
-- ============================================
INSERT INTO friend_requests (sender_id, receiver_id, status, created_at) VALUES 
('33333333-3333-3333-3333-333333333333', '22222222-2222-2222-2222-222222222222', 'pending', NOW() - INTERVAL '2 hours'),
('44444444-4444-4444-4444-444444444444', '11111111-1111-1111-1111-111111111111', 'pending', NOW() - INTERVAL '5 hours'),
('66666666-6666-6666-6666-666666666666', '11111111-1111-1111-1111-111111111111', 'pending', NOW() - INTERVAL '1 day'),
('55555555-5555-5555-5555-555555555555', '22222222-2222-2222-2222-222222222222', 'pending', NOW() - INTERVAL '3 days')
ON CONFLICT DO NOTHING;

-- ============================================
-- 5. INSERT DUMMY JOURNALS (ALL UUIDs FIXED)
-- ============================================
-- Saya menambahkan 1 karakter ekstra pada segmen terakhir agar pas 12 digit.

-- JOHN'S JOURNALS
INSERT INTO journals (id, user_id, judul, cerita, tanggal, latitude, longitude, nama_lokasi, created_at) VALUES 
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '11111111-1111-1111-1111-111111111111', 'Liburan ke Bali', 'Cerita Bali...', NOW() - INTERVAL '10 days', -8.718488, 115.176742, 'Pantai Kuta, Bali', NOW() - INTERVAL '10 days'),
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaab', '11111111-1111-1111-1111-111111111111', 'Makan Nasi Padang', 'Cerita Padang...', NOW() - INTERVAL '8 days', -6.200000, 106.816666, 'Jakarta Pusat', NOW() - INTERVAL '8 days'),
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaac', '11111111-1111-1111-1111-111111111111', 'Gunung Bromo', 'Cerita Bromo...', NOW() - INTERVAL '5 days', -7.942494, 112.953011, 'Gunung Bromo', NOW() - INTERVAL '5 days'),
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaad', '11111111-1111-1111-1111-111111111111', 'Kopi Bandung', 'Cerita Kopi...', NOW() - INTERVAL '3 days', -6.914744, 107.609810, 'Dago, Bandung', NOW() - INTERVAL '3 days'),
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaae', '11111111-1111-1111-1111-111111111111', 'Wisata Jogja', 'Cerita Jogja...', NOW() - INTERVAL '1 day', -7.607874, 110.203751, 'Borobudur', NOW() - INTERVAL '1 day');

-- ALICE'S JOURNALS (Fixed IDs: b...ba -> b...bbba)
INSERT INTO journals (id, user_id, judul, cerita, tanggal, latitude, longitude, nama_lokasi, created_at) VALUES 
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbba1', '22222222-2222-2222-2222-222222222222', 'Kuliner Surabaya', 'Cerita Surabaya...', NOW() - INTERVAL '12 days', -7.257472, 112.752090, 'Surabaya', NOW() - INTERVAL '12 days'),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb2', '22222222-2222-2222-2222-222222222222', 'Shopping Mall', 'Cerita Shopping...', NOW() - INTERVAL '7 days', -6.225014, 106.845599, 'Grand Indonesia', NOW() - INTERVAL '7 days'),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb3', '22222222-2222-2222-2222-222222222222', 'Konser Musik', 'Cerita Konser...', NOW() - INTERVAL '4 days', -6.301080, 106.893997, 'GBK Jakarta', NOW() - INTERVAL '4 days'),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb4', '22222222-2222-2222-2222-222222222222', 'Kota Tua', 'Cerita Kota Tua...', NOW() - INTERVAL '2 days', -6.135200, 106.813301, 'Kota Tua', NOW() - INTERVAL '2 days');

-- BOB'S JOURNALS (Fixed IDs: c...ca -> c...cca1)
INSERT INTO journals (id, user_id, judul, cerita, tanggal, latitude, longitude, nama_lokasi, created_at) VALUES 
('cccccccc-cccc-cccc-cccc-cccccccccca1', '33333333-3333-3333-3333-333333333333', 'Diving Raja Ampat', 'Cerita Raja Ampat...', NOW() - INTERVAL '15 days', -0.239860, 130.518700, 'Raja Ampat', NOW() - INTERVAL '15 days'),
('cccccccc-cccc-cccc-cccc-cccccccccca2', '33333333-3333-3333-3333-333333333333', 'Camping Ranca Upas', 'Cerita Camping...', NOW() - INTERVAL '9 days', -7.145160, 107.382080, 'Ranca Upas', NOW() - INTERVAL '9 days'),
('cccccccc-cccc-cccc-cccc-cccccccccca3', '33333333-3333-3333-3333-333333333333', 'Kuliner Malang', 'Cerita Malang...', NOW() - INTERVAL '6 days', -7.966620, 112.632632, 'Malang', NOW() - INTERVAL '6 days');

-- CAROL'S JOURNALS (Fixed IDs: d...da -> d...dda1)
INSERT INTO journals (id, user_id, judul, cerita, tanggal, latitude, longitude, nama_lokasi, created_at) VALUES 
('dddddddd-dddd-dddd-dddd-dddddddddda1', '44444444-4444-4444-4444-444444444444', 'Staycation', 'Cerita Hotel...', NOW() - INTERVAL '11 days', -6.195830, 106.823108, 'Hotel Indonesia', NOW() - INTERVAL '11 days'),
('dddddddd-dddd-dddd-dddd-dddddddddda2', '44444444-4444-4444-4444-444444444444', 'Spa Day', 'Cerita Spa...', NOW() - INTERVAL '8 days', -6.229728, 106.774324, 'Senayan City', NOW() - INTERVAL '8 days'),
('dddddddd-dddd-dddd-dddd-dddddddddda3', '44444444-4444-4444-4444-444444444444', 'Yoga Ubud', 'Cerita Yoga...', NOW() - INTERVAL '5 days', -8.507620, 115.263680, 'Ubud', NOW() - INTERVAL '5 days');

-- DAVID'S JOURNALS (Fixed IDs: e...ea -> e...eea1)
INSERT INTO journals (id, user_id, judul, cerita, tanggal, latitude, longitude, nama_lokasi, created_at) VALUES 
('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeea1', '55555555-5555-5555-5555-555555555555', 'Main Timezone', 'Cerita Game...', NOW() - INTERVAL '14 days', -6.175110, 106.865039, 'Pacific Place', NOW() - INTERVAL '14 days'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeea2', '55555555-5555-5555-5555-555555555555', 'Nonton Bioskop', 'Cerita Film...', NOW() - INTERVAL '7 days', -6.301080, 106.651680, 'GI XXI', NOW() - INTERVAL '7 days');

-- EMMA'S JOURNALS (Fixed IDs: f...fa -> f...ffa1)
INSERT INTO journals (id, user_id, judul, cerita, tanggal, latitude, longitude, nama_lokasi, created_at) VALUES 
('ffffffff-ffff-ffff-ffff-ffffffffffa1', '66666666-6666-6666-6666-666666666666', 'Belajar Masak', 'Cerita Masak...', NOW() - INTERVAL '6 days', -6.243278, 106.783890, 'Cooking Studio', NOW() - INTERVAL '6 days'),
('ffffffff-ffff-ffff-ffff-ffffffffffa2', '66666666-6666-6666-6666-666666666666', 'Olahraga', 'Cerita Jogging...', NOW() - INTERVAL '3 days', -6.187140, 106.823680, 'Taman Menteng', NOW() - INTERVAL '3 days');

-- ============================================
-- 6. INSERT DUMMY JOURNAL PHOTOS (LINKED CORRECTLY)
-- ============================================
-- IDs sudah diperbaiki menjadi format UUID valid (f00...)
-- Journal IDs disesuaikan dengan Journal Insert di atas

INSERT INTO journal_photos (id, journal_id, photo_url, created_at) VALUES 
-- Photo untuk John
('f0000000-0000-0000-0000-000000000001', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'https://images.unsplash.com/photo-1537996194471-e657df975ab4', NOW() - INTERVAL '10 days'), 
('f0000000-0000-0000-0000-000000000002', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaac', 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4', NOW() - INTERVAL '5 days'),

-- Photo untuk Alice (Journal ID: b...bbbbb2)
('f0000000-0000-0000-0000-000000000003', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb2', 'https://images.unsplash.com/photo-1441986300917-64674bd600d8', NOW() - INTERVAL '7 days'),

-- Photo untuk Bob (Journal ID: c...ccca1 yang tadinya error)
('f0000000-0000-0000-0000-000000000004', 'cccccccc-cccc-cccc-cccc-cccccccccca1', 'https://images.unsplash.com/photo-1559827260-dc66d52bef19', NOW() - INTERVAL '15 days');

-- ============================================
-- FINISH
-- ============================================
DO $$ 
BEGIN 
  RAISE NOTICE '✅ ALL DATA INSERTED SUCCESSFULLY WITH VALID UUIDs!'; 
END $$;