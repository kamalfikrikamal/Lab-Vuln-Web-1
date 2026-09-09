-- PT Nusantara Logistik - data contoh (realistis, bukan data pribadi asli)
USE nusalog;

-- Password demo untuk semua akun customer di bawah: "Logistik#2025"
-- (didokumentasikan di docs/TESTING.md untuk keperluan verifikasi dashboard.php)
INSERT INTO customers (id, full_name, email, phone, password_hash, company) VALUES
(1,  'Budi Santoso',        'budi.santoso@gmail.com',    '081234560001', '$2y$12$sfeChnm0t/nD.FiTuHR4F.b9paGn9k6BeNiHwwsgb9lizN.zcIu.G', NULL),
(2,  'Siti Nurhaliza',      'siti.nurhaliza@yahoo.com',  '081234560002', '$2y$12$sfeChnm0t/nD.FiTuHR4F.b9paGn9k6BeNiHwwsgb9lizN.zcIu.G', NULL),
(3,  'Agus Prasetyo',       'agus.prasetyo@gmail.com',   '081234560003', '$2y$12$sfeChnm0t/nD.FiTuHR4F.b9paGn9k6BeNiHwwsgb9lizN.zcIu.G', 'Toko Elektronik Maju Jaya'),
(4,  'Dewi Lestari',        'dewi.lestari@outlook.com',  '081234560004', '$2y$12$sfeChnm0t/nD.FiTuHR4F.b9paGn9k6BeNiHwwsgb9lizN.zcIu.G', NULL),
(5,  'Rudi Hartono',        'rudi.hartono@gmail.com',    '081234560005', '$2y$12$sfeChnm0t/nD.FiTuHR4F.b9paGn9k6BeNiHwwsgb9lizN.zcIu.G', 'CV Sumber Rejeki'),
(6,  'Wulan Ramadhani',     'wulan.ramadhani@gmail.com', '081234560006', '$2y$12$sfeChnm0t/nD.FiTuHR4F.b9paGn9k6BeNiHwwsgb9lizN.zcIu.G', NULL),
(7,  'Eko Setiawan',        'eko.setiawan@yahoo.com',    '081234560007', '$2y$12$sfeChnm0t/nD.FiTuHR4F.b9paGn9k6BeNiHwwsgb9lizN.zcIu.G', NULL),
(8,  'Maya Anggraini',      'maya.anggraini@gmail.com',  '081234560008', '$2y$12$sfeChnm0t/nD.FiTuHR4F.b9paGn9k6BeNiHwwsgb9lizN.zcIu.G', 'Butik Anggraini'),
(9,  'Hendra Gunawan',      'hendra.gunawan@gmail.com',  '081234560009', '$2y$12$sfeChnm0t/nD.FiTuHR4F.b9paGn9k6BeNiHwwsgb9lizN.zcIu.G', NULL),
(10, 'Fitriani Rahayu',     'fitriani.rahayu@gmail.com', '081234560010', '$2y$12$sfeChnm0t/nD.FiTuHR4F.b9paGn9k6BeNiHwwsgb9lizN.zcIu.G', NULL),
(11, 'Bagus Wicaksono',     'bagus.wicaksono@gmail.com', '081234560011', '$2y$12$sfeChnm0t/nD.FiTuHR4F.b9paGn9k6BeNiHwwsgb9lizN.zcIu.G', NULL),
(12, 'PT Sinar Abadi Jaya (Procurement)', 'procurement@sinarabadijaya.co.id', '0215501234', '$2y$12$sfeChnm0t/nD.FiTuHR4F.b9paGn9k6BeNiHwwsgb9lizN.zcIu.G', 'PT Sinar Abadi Jaya');

INSERT INTO shipments
  (tracking_id, customer_id, sender_name, sender_address, recipient_name, recipient_address, recipient_city, package_description, weight_kg, status, courier, internal_remarks) VALUES
(100001, 1,  'Budi Santoso',    'Jl. Kenanga No. 12, Jakarta Selatan',    'Ratna Dewi',      'Jl. Diponegoro No. 45, Bandung',        'Bandung',   'Dokumen kontrak',            0.50, 'terkirim', 'NusaLog Express', NULL),
(100002, 1,  'Budi Santoso',    'Jl. Kenanga No. 12, Jakarta Selatan',    'Andi Saputra',    'Jl. Ahmad Yani No. 88, Surabaya',       'Surabaya',  'Paket pakaian',              1.20, 'transit',  'NusaLog Express', NULL),
(100003, 2,  'Siti Nurhaliza',  'Jl. Melati No. 7, Depok',                'Rina Wati',       'Jl. Sudirman No. 21, Medan',            'Medan',     'Buku dan alat tulis',        2.00, 'dikirim',  'NusaLog Express', NULL),
(100004, 3,  'Toko Elektronik Maju Jaya', 'Jl. Pasar Baru No. 5, Jakarta Pusat', 'Joko Prabowo', 'Jl. Gatot Subroto No. 10, Semarang', 'Semarang', 'Charger dan kabel HDMI',    0.80, 'terkirim', 'NusaLog Express', NULL),
(100005, 3,  'Toko Elektronik Maju Jaya', 'Jl. Pasar Baru No. 5, Jakarta Pusat', 'Lina Marlina',  'Jl. Veteran No. 33, Makassar',      'Makassar',  'Speaker bluetooth',         1.50, 'diproses', 'NusaLog Express', NULL),
(100006, 4,  'Dewi Lestari',    'Jl. Anggrek No. 3, Tangerang',           'Yusuf Ibrahim',   'Jl. Pahlawan No. 9, Surabaya',          'Surabaya',  'Boneka mainan anak',         0.60, 'terkirim', 'NusaLog Express', NULL),
(100007, 5,  'CV Sumber Rejeki','Jl. Industri Raya No. 21, Bekasi',       'Warung Makmur',   'Jl. Merdeka No. 14, Bandung',           'Bandung',   'Bahan baku kemasan (20 dus)', 45.00, 'dikirim', 'NusaLog Express', NULL),
(100008, 5,  'CV Sumber Rejeki','Jl. Industri Raya No. 21, Bekasi',       'Toko Sembako Jaya','Jl. Kartini No. 2, Yogyakarta',        'Yogyakarta','Bahan baku kemasan (10 dus)', 22.50, 'transit', 'NusaLog Express', NULL),
(100009, 6,  'Wulan Ramadhani', 'Jl. Cempaka No. 18, Bogor',              'Fajar Nugroho',   'Jl. Sisingamangaraja No. 6, Medan',     'Medan',     'Sepatu olahraga',            0.90, 'terkirim', 'NusaLog Express', NULL),
(100010, 7,  'Eko Setiawan',    'Jl. Flamboyan No. 9, Bandung',           'Nita Puspita',    'Jl. Malioboro No. 88, Yogyakarta',      'Yogyakarta','Kerajinan tangan',           0.70, 'dikirim',  'NusaLog Express', NULL),
(100011, 8,  'Butik Anggraini', 'Jl. Cihampelas No. 55, Bandung',         'Sari Indah',      'Jl. Ahmad Yani No. 120, Palembang',     'Palembang', 'Baju batik (5 pcs)',         1.10, 'terkirim', 'NusaLog Express', NULL),
(100012, 8,  'Butik Anggraini', 'Jl. Cihampelas No. 55, Bandung',         'Dian Permata',    'Jl. Gajah Mada No. 30, Denpasar',       'Denpasar',  'Baju batik (3 pcs)',         0.70, 'diproses', 'NusaLog Express', NULL),
(100013, 12, 'PT Sinar Abadi Jaya', 'Kawasan Industri Pulogadung Blok C No. 8, Jakarta Timur', 'Gudang Regional Surabaya', 'Jl. Rungkut Industri No. 15, Surabaya', 'Surabaya', 'Komponen elektronik (palet, 300kg)', 300.00, 'diproses', 'NusaLog Express', 'Pengiriman korporat prioritas. Koordinasi SLA & dokumen pabean ditangani langsung lewat sistem internal staf, bukan lewat customer service reguler - jangan proses manual tanpa konfirmasi tim internal.'),
(100014, 9,  'Hendra Gunawan',  'Jl. Beringin No. 14, Semarang',          'Wahyu Aditya',    'Jl. Kaliurang No. 40, Yogyakarta',      'Yogyakarta','Suku cadang motor',          3.20, 'transit',  'NusaLog Express', NULL),
(100015, 9,  'Hendra Gunawan',  'Jl. Beringin No. 14, Semarang',          'Rizky Ramadhan',  'Jl. Diponegoro No. 77, Solo',           'Solo',      'Aki motor',                  4.50, 'terkirim', 'NusaLog Express', NULL),
(100016, 10, 'Fitriani Rahayu', 'Jl. Mawar No. 22, Malang',               'Putri Ayu',       'Jl. Panglima Sudirman No. 5, Surabaya', 'Surabaya',  'Kosmetik (paket kecil)',     0.40, 'terkirim', 'NusaLog Express', NULL),
(100017, 11, 'Bagus Wicaksono', 'Jl. Ir. H. Juanda No. 60, Bandung',      'Taufik Hidayat',  'Jl. Slamet Riyadi No. 99, Solo',        'Solo',      'Laptop bekas (refurbished)', 2.30, 'dikirim',  'NusaLog Express', NULL),
(100018, 2,  'Siti Nurhaliza',  'Jl. Melati No. 7, Depok',                'Dedi Kurniawan',  'Jl. Yos Sudarso No. 18, Balikpapan',    'Balikpapan','Peralatan dapur',            1.80, 'diproses', 'NusaLog Express', NULL),
(100019, 4,  'Dewi Lestari',    'Jl. Anggrek No. 3, Tangerang',           'Sri Wahyuni',     'Jl. Hayam Wuruk No. 25, Denpasar',      'Denpasar',  'Aksesoris fashion',          0.30, 'terkirim', 'NusaLog Express', NULL),
(100020, 6,  'Wulan Ramadhani', 'Jl. Cempaka No. 18, Bogor',              'Bambang Irawan',  'Jl. Basuki Rahmat No. 41, Malang',      'Malang',    'Peralatan olahraga',         2.60, 'gagal',    'NusaLog Express', NULL),
(100021, 7,  'Eko Setiawan',    'Jl. Flamboyan No. 9, Bandung',           'Ayu Kartika',     'Jl. Pemuda No. 3, Semarang',            'Semarang',  'Piring dan gelas keramik',   3.00, 'transit',  'NusaLog Express', NULL),
(100022, 10, 'Fitriani Rahayu', 'Jl. Mawar No. 22, Malang',               'Ilham Maulana',   'Jl. Veteran No. 60, Makassar',          'Makassar',  'Sparepart komputer',         1.00, 'dikirim',  'NusaLog Express', NULL),
(100023, 3,  'Toko Elektronik Maju Jaya', 'Jl. Pasar Baru No. 5, Jakarta Pusat', 'Rizal Fadillah', 'Jl. Ahmad Yani No. 200, Pekanbaru', 'Pekanbaru', 'Router wifi (10 unit)',    5.00, 'terkirim', 'NusaLog Express', NULL),
(100024, 11, 'Bagus Wicaksono', 'Jl. Ir. H. Juanda No. 60, Bandung',      'Nurul Hidayah',   'Jl. Cendrawasih No. 8, Manado',         'Manado',    'Buku pelajaran (1 dus)',     6.50, 'terkirim', 'NusaLog Express', NULL);

-- Akun staff internal (targetnya dibobol via SQLi filter-bypass, bukan tebak password)
INSERT INTO staff (username, password_hash, full_name, role) VALUES
('admin',   '$2y$12$hE.rBVVvrySHT5LCLvfe/O0xWIRSgNXYDKuYOht.gt5BdpvS44cm2', 'Administrator Sistem', 'admin'),
('opsdesk', '$2y$12$sWkUHv3yXm78CklCiVZtneSXpJ4qjOXmPb7nFJYPe/PviYBROg046', 'Tim Operasional',      'staff');
