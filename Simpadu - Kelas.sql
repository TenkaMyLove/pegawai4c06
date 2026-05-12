-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: May 10, 2026 at 12:14 PM
-- Server version: 8.4.3
-- PHP Version: 8.3.26

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `simpadu`
--

-- --------------------------------------------------------

--
-- Table structure for table `absensi_mahasiswa`
--

CREATE TABLE `absensi_mahasiswa` (
  `ID_ABSENSI` bigint UNSIGNED NOT NULL,
  `NIM` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `KELAS_ID` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `KODE_PERTEMUAN` int NOT NULL,
  `TANGGAL` date NOT NULL,
  `STATUS` enum('H','S','I','A') COLLATE utf8mb4_unicode_ci NOT NULL,
  `METODE` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `absensi_mahasiswa`
--

INSERT INTO `absensi_mahasiswa` (`ID_ABSENSI`, `NIM`, `KELAS_ID`, `KODE_PERTEMUAN`, `TANGGAL`, `STATUS`, `METODE`) VALUES
(1, 'A010324001', 'TIK01', 0, '2026-05-02', 'H', 'MANUAL'),
(2, 'A010324002', 'TIK01', 0, '2026-05-02', 'S', 'MANUAL'),
(3, 'A010324001', 'TIK01', 3, '2026-05-02', 'H', 'MANUAL'),
(4, 'A010324002', 'TIK01', 3, '2026-05-02', 'S', 'MANUAL'),
(5, 'A010324003', 'TIK02', 1, '2026-05-02', 'H', 'QR'),
(6, 'A010324003', 'TIK02', 2, '2026-05-10', 'A', 'MANUAL'),
(7, 'A010324003', 'TIK02', 3, '2026-05-02', 'H', 'QR');

-- --------------------------------------------------------

--
-- Table structure for table `absensi_pegawai`
--

CREATE TABLE `absensi_pegawai` (
  `ID_ABSENSI` int NOT NULL,
  `NIP` varchar(20) COLLATE utf8mb4_general_ci NOT NULL,
  `WAKTU_MASUK` time DEFAULT NULL,
  `WAKTU_KELUAR` time DEFAULT NULL,
  `TANGGAL` date DEFAULT NULL,
  `KETERANGAN` text COLLATE utf8mb4_general_ci
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `absensi_pegawai`
--

INSERT INTO `absensi_pegawai` (`ID_ABSENSI`, `NIP`, `WAKTU_MASUK`, `WAKTU_KELUAR`, `TANGGAL`, `KETERANGAN`) VALUES
(1, 'P001', '08:00:00', '16:00:00', '2026-05-01', 'Hadir'),
(2, 'P002', '08:05:00', '16:00:00', '2026-05-01', 'Hadir'),
(3, 'P003', '08:10:00', '16:00:00', '2026-05-01', 'Terlambat'),
(4, 'P004', '08:00:00', '16:00:00', '2026-05-01', 'Hadir'),
(5, 'P005', '08:00:00', '15:30:00', '2026-05-01', 'Izin'),
(6, 'P006', '08:00:00', '16:00:00', '2026-05-01', 'Hadir'),
(7, 'P007', '08:20:00', '16:00:00', '2026-05-01', 'Terlambat'),
(8, 'P008', '08:00:00', '16:00:00', '2026-05-01', 'Hadir'),
(9, 'P009', '08:00:00', '16:00:00', '2026-05-01', 'Hadir'),
(10, 'P010', '08:30:00', '16:00:00', '2026-05-01', 'Terlambat'),
(11, 'P011', '08:00:00', '16:00:00', '2026-05-01', 'Hadir'),
(12, 'P012', '08:00:00', '16:00:00', '2026-05-01', 'Hadir'),
(13, 'P013', '08:00:00', '16:00:00', '2026-05-01', 'Hadir'),
(14, 'P014', '08:05:00', '16:00:00', '2026-05-01', 'Hadir'),
(15, 'P015', '08:00:00', '16:00:00', '2026-05-01', 'Hadir');

-- --------------------------------------------------------

--
-- Table structure for table `cache`
--

CREATE TABLE `cache` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` bigint NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cache_locks`
--

CREATE TABLE `cache_locks` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `owner` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` bigint NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `dosen`
--

CREATE TABLE `dosen` (
  `NIP_DOSEN` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `DOSEN_NAMA` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `ID_USER` bigint UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `dosen`
--

INSERT INTO `dosen` (`NIP_DOSEN`, `DOSEN_NAMA`, `ID_USER`, `created_at`, `updated_at`) VALUES
('198001012005011001', 'Febri', 5, NULL, NULL),
('198102022006022002', 'Aisyah', 3, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `failed_jobs`
--

CREATE TABLE `failed_jobs` (
  `id` bigint UNSIGNED NOT NULL,
  `uuid` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `connection` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `queue` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `exception` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `jabatan`
--

CREATE TABLE `jabatan` (
  `ID_JABATAN` varchar(10) COLLATE utf8mb4_general_ci NOT NULL,
  `NAMA_JABATAN` varchar(30) COLLATE utf8mb4_general_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `jabatan`
--

INSERT INTO `jabatan` (`ID_JABATAN`, `NAMA_JABATAN`) VALUES
('J01', 'Kepala Administrasi'),
('J02', 'Staff Akademik'),
('J03', 'Staff Keuangan'),
('J04', 'IT Support'),
('J05', 'Pustakawan'),
('J06', 'Laboran'),
('J07', 'Staff Kemahasiswaan'),
('J08', 'Staff Umum'),
('J09', 'Staff Kepegawaian'),
('J10', 'Teknisi');

-- --------------------------------------------------------

--
-- Table structure for table `jadwal_kuliah`
--

CREATE TABLE `jadwal_kuliah` (
  `id` bigint UNSIGNED NOT NULL,
  `KELAS_ID` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `HARI` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `JAM_MULAI` time NOT NULL,
  `JAM_SELESAI` time NOT NULL,
  `RUANG` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `jadwal_kuliah`
--

INSERT INTO `jadwal_kuliah` (`id`, `KELAS_ID`, `HARI`, `JAM_MULAI`, `JAM_SELESAI`, `RUANG`, `created_at`, `updated_at`) VALUES
(1, 'TIF-A', 'Senin', '08:00:00', '10:00:00', 'Lab 1', '2026-05-10 09:47:10', '2026-05-10 09:47:10');

-- --------------------------------------------------------

--
-- Table structure for table `jobs`
--

CREATE TABLE `jobs` (
  `id` bigint UNSIGNED NOT NULL,
  `queue` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `attempts` smallint UNSIGNED NOT NULL,
  `reserved_at` int UNSIGNED DEFAULT NULL,
  `available_at` int UNSIGNED NOT NULL,
  `created_at` int UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `job_batches`
--

CREATE TABLE `job_batches` (
  `id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `total_jobs` int NOT NULL,
  `pending_jobs` int NOT NULL,
  `failed_jobs` int NOT NULL,
  `failed_job_ids` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `options` mediumtext COLLATE utf8mb4_unicode_ci,
  `cancelled_at` int DEFAULT NULL,
  `created_at` int NOT NULL,
  `finished_at` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `kelas`
--

CREATE TABLE `kelas` (
  `ID_KELAS` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `NAMA_KELAS` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `NIP_DOSEN` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `KODE_MK` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `kelas`
--

INSERT INTO `kelas` (`ID_KELAS`, `NAMA_KELAS`, `NIP_DOSEN`, `KODE_MK`) VALUES
('TIK01', 'Pemrograman Web', '198001012005011001', 'IF101');

-- --------------------------------------------------------

--
-- Table structure for table `kelas_sessions`
--

CREATE TABLE `kelas_sessions` (
  `id` bigint UNSIGNED NOT NULL,
  `KELAS_ID` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `KODE_PERTEMUAN` tinyint UNSIGNED NOT NULL,
  `IS_ACTIVE` tinyint(1) NOT NULL DEFAULT '1',
  `STARTED_AT` timestamp NOT NULL,
  `ENDED_AT` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `kelas_sessions`
--

INSERT INTO `kelas_sessions` (`id`, `KELAS_ID`, `KODE_PERTEMUAN`, `IS_ACTIVE`, `STARTED_AT`, `ENDED_AT`, `created_at`, `updated_at`) VALUES
(1, 'TIK01', 1, 0, '2026-05-02 08:31:13', '2026-05-02 08:32:14', '2026-05-02 08:31:13', '2026-05-02 08:32:14'),
(2, 'TIK01', 2, 0, '2026-05-02 08:50:35', '2026-05-02 08:50:56', '2026-05-02 08:50:35', '2026-05-02 08:50:56'),
(3, 'TIK01', 3, 0, '2026-05-02 08:52:10', '2026-05-02 09:00:38', '2026-05-02 08:52:10', '2026-05-02 09:00:38'),
(4, 'TIK02', 1, 0, '2026-05-02 09:01:11', '2026-05-02 09:41:06', '2026-05-02 09:01:11', '2026-05-02 09:41:06'),
(5, 'TIK01', 4, 0, '2026-05-02 09:32:01', '2026-05-02 09:39:57', '2026-05-02 09:32:01', '2026-05-02 09:39:57'),
(6, 'TIK02', 2, 0, '2026-05-02 09:41:11', '2026-05-02 09:46:46', '2026-05-02 09:41:11', '2026-05-02 09:46:46'),
(7, 'TIK02', 3, 0, '2026-05-02 09:46:52', '2026-05-10 02:01:57', '2026-05-02 09:46:52', '2026-05-10 02:01:57'),
(8, 'TIK01', 5, 1, '2026-05-10 04:03:00', NULL, '2026-05-10 04:03:00', '2026-05-10 04:03:00');

-- --------------------------------------------------------

--
-- Table structure for table `mata_kuliah`
--

CREATE TABLE `mata_kuliah` (
  `KODE_MK` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `NAMA_MK` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `SKS` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `memiliki`
--

CREATE TABLE `memiliki` (
  `ID_JABATAN` varchar(10) COLLATE utf8mb4_general_ci NOT NULL,
  `NIP` varchar(20) COLLATE utf8mb4_general_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `memiliki`
--

INSERT INTO `memiliki` (`ID_JABATAN`, `NIP`) VALUES
('J01', 'P001'),
('J02', 'P004'),
('J02', 'P008'),
('J02', 'P013'),
('J03', 'P002'),
('J03', 'P014'),
('J04', 'P003'),
('J04', 'P012'),
('J05', 'P005'),
('J05', 'P015'),
('J06', 'P006'),
('J07', 'P007'),
('J08', 'P009'),
('J09', 'P010'),
('J10', 'P011');

-- --------------------------------------------------------

--
-- Table structure for table `migrations`
--

CREATE TABLE `migrations` (
  `id` int UNSIGNED NOT NULL,
  `migration` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(1, '0001_01_01_000000_create_users_table', 1),
(2, '0001_01_01_000001_create_cache_table', 1),
(3, '0001_01_01_000002_create_jobs_table', 1),
(4, '2026_05_02_052716_create_personal_access_tokens_table', 1),
(5, '2026_05_02_061524_create_qr_sessions_table', 2),
(6, '2026_05_02_065955_create_absensi_mahasiswa_table', 3),
(7, '2026_05_02_074011_add_role_to_users_table', 4),
(8, '2026_05_02_153237_add_pertemuan_to_absensi_mahasiswa', 5),
(9, '2026_05_02_153826_rename_pertemuan_column', 6),
(10, '2026_05_02_154745_add_kode_pertemuan_to_qr_sessions', 7),
(11, '2026_05_02_160553_add_role_to_users_table', 8),
(12, '2026_05_02_161012_create_kelas_sessions_table', 9),
(15, '2026_05_10_093259_create_kelas_table', 10),
(16, '2026_05_10_093344_create_mata_kuliah_table', 10),
(17, '2026_05_10_094549_create_jadwal_kuliah_table', 10),
(18, '2026_05_10_112521_create_roles_table', 11),
(19, '2026_05_10_113123_add_id_role_to_users_table', 12),
(20, '2026_05_10_113610_create_dosen_table', 13);

-- --------------------------------------------------------

--
-- Table structure for table `password_reset_tokens`
--

CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pegawai`
--

CREATE TABLE `pegawai` (
  `NIP` varchar(20) COLLATE utf8mb4_general_ci NOT NULL,
  `NIK` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `NAMA_PEGAWAI` varchar(30) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `JENIS_KELAMIN` char(10) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `ID_PROVINSI` varchar(10) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `ALAMAT` varchar(25) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `ID_KAB` varchar(10) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `UNIT_KERJA` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `ID_USER` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `pegawai`
--

INSERT INTO `pegawai` (`NIP`, `NIK`, `NAMA_PEGAWAI`, `JENIS_KELAMIN`, `ID_PROVINSI`, `ALAMAT`, `ID_KAB`, `UNIT_KERJA`, `ID_USER`) VALUES
('P001', '630101001', 'Alfyan', 'Laki-laki', 'KALSEL', 'Banjarmasin', 'BJM', 'Administrasi Akademik', 1),
('P002', '630101002', 'Darrel', 'Laki-laki', 'KALSEL', 'Banjarbaru', 'BJB', 'Keuangan', 2),
('P003', '630101003', 'Sonny', 'Laki-laki', 'KALSEL', 'Martapura', 'MTP', 'IT Support', 3),
('P004', '630101004', 'Rizky', 'Laki-laki', 'KALSEL', 'Pelaihari', 'PLH', 'BAAK', 4),
('P005', '630101005', 'Jasmine', 'Perempuan', 'KALSEL', 'Barabai', 'BRB', 'Perpustakaan', 5),
('P006', '630101006', 'Rio', 'Laki-laki', 'KALSEL', 'Amuntai', 'AMT', 'Laboratorium', 6),
('P007', '630101007', 'Riyan', 'Laki-laki', 'KALSEL', 'Kandangan', 'KDG', 'Kemahasiswaan', 7),
('P008', '630101008', 'Aisya', 'Perempuan', 'KALSEL', 'Banjarmasin', 'BJM', 'Akademik', 8),
('P009', '630101009', 'Darmawan', 'Laki-laki', 'KALSEL', 'Rantau', 'RNT', 'Umum', 9),
('P010', '630101010', 'Losong', 'Laki-laki', 'KALSEL', 'Marabahan', 'MRB', 'Kepegawaian', 10),
('P011', '630101011', 'Yuzar', 'Laki-laki', 'KALSEL', 'Batulicin', 'BTC', 'Teknisi', 11),
('P012', '630101012', 'Wicaksono', 'Laki-laki', 'KALSEL', 'Kotabaru', 'KTB', 'IT Support', 12),
('P013', '630101013', 'Yori', 'Perempuan', 'KALSEL', 'Tanjung', 'TJG', 'Administrasi', 13),
('P014', '630101014', 'Febri', 'Laki-laki', 'KALSEL', 'Paringin', 'PRG', 'Akademik', 14),
('P015', '630101015', 'Novi', 'Perempuan', 'KALSEL', 'Banjarmasin', 'BJM', 'Perpustakaan', 15);

-- --------------------------------------------------------

--
-- Table structure for table `personal_access_tokens`
--

CREATE TABLE `personal_access_tokens` (
  `id` bigint UNSIGNED NOT NULL,
  `tokenable_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tokenable_id` bigint UNSIGNED NOT NULL,
  `name` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `abilities` text COLLATE utf8mb4_unicode_ci,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `personal_access_tokens`
--

INSERT INTO `personal_access_tokens` (`id`, `tokenable_type`, `tokenable_id`, `name`, `token`, `abilities`, `last_used_at`, `expires_at`, `created_at`, `updated_at`) VALUES
(1, 'App\\Models\\User', 1, 'auth_token', '4fec950e1e22a2eedfa155b7aa3afd1135c08efb8d6d3ae6704ce34a58bbccef', '[\"*\"]', '2026-05-10 04:10:04', NULL, '2026-05-02 08:02:11', '2026-05-10 04:10:04'),
(2, 'App\\Models\\User', 1, 'auth_token', 'a4cfd7ce82068ffc6172d74016ad13b04370b9c5e0fb4bb94aa3b71f402830bb', '[\"*\"]', NULL, NULL, '2026-05-02 08:41:45', '2026-05-02 08:41:45'),
(3, 'App\\Models\\User', 1, 'auth_token', '192451777855d255f77b8825527a31951a0ec7228e2fbb2c147729f3941ad1b0', '[\"*\"]', NULL, NULL, '2026-05-02 09:22:36', '2026-05-02 09:22:36'),
(4, 'App\\Models\\User', 1, 'auth_token', '39acc7ead87680e7442908572c99708916c3a5214e5ad423d8cbac818815b4c0', '[\"*\"]', NULL, NULL, '2026-05-02 09:28:21', '2026-05-02 09:28:21'),
(5, 'App\\Models\\User', 1, 'auth_token', '123668616196a3487a9bd0108d0dfda09bf99cdd5c8294fd29aedfdecd9d69b9', '[\"*\"]', NULL, NULL, '2026-05-02 09:28:40', '2026-05-02 09:28:40'),
(6, 'App\\Models\\User', 1, 'auth_token', 'dfd8d5b657f7ac4c218372b10666bfac63a941d869f6d438bfa79a83b65a2e73', '[\"*\"]', NULL, NULL, '2026-05-02 09:39:21', '2026-05-02 09:39:21'),
(7, 'App\\Models\\User', 3, 'auth_token', 'aebcb07bfe8a93f45200279c31f2638671fad78e0bae6041b6dbda262d299c1f', '[\"*\"]', NULL, NULL, '2026-05-03 05:15:12', '2026-05-03 05:15:12'),
(8, 'App\\Models\\User', 3, 'auth_token', '458087149dba3325377072503b6ca2e8d2da1cda2eb00541e9529886dfbb14be', '[\"*\"]', NULL, NULL, '2026-05-03 05:29:57', '2026-05-03 05:29:57'),
(9, 'App\\Models\\User', 1, 'auth_token', 'da41dc6febd9e72dc9aa542b4e0ff9c941b1973b92d815ca25a1449851abc66c', '[\"*\"]', NULL, NULL, '2026-05-03 05:34:42', '2026-05-03 05:34:42'),
(10, 'App\\Models\\User', 1, 'auth_token', '77f703fb7e6e500b74c82f3a39ed8be0fa17d1c32969069aef32ab81dc1ede3e', '[\"*\"]', NULL, NULL, '2026-05-03 05:50:01', '2026-05-03 05:50:01'),
(11, 'App\\Models\\User', 1, 'auth_token', '9d5b45f45485a488a378853ec11cddc8f8fbe9e0a2c0bd276af5b843a5347a1e', '[\"*\"]', '2026-05-10 02:21:37', NULL, '2026-05-03 05:51:46', '2026-05-10 02:21:37'),
(12, 'App\\Models\\User', 3, 'auth_token', '01edfef10c4a4b709489915ce6065ea5228c01e3144ca61c2584b83c845983a8', '[\"*\"]', '2026-05-10 01:58:37', NULL, '2026-05-10 01:55:49', '2026-05-10 01:58:37'),
(13, 'App\\Models\\User', 3, 'auth_token', 'd650d61f64642ae6cd143b03241c9eeec7a7cf5b30349e0be2a76a732c7980ba', '[\"*\"]', '2026-05-10 02:18:03', NULL, '2026-05-10 02:00:30', '2026-05-10 02:18:03'),
(14, 'App\\Models\\User', 3, 'auth_token', 'da46b9f770a9a653909ed8263fdb17fb18b35f8634d9f63190a832a0b81425ed', '[\"*\"]', '2026-05-10 03:48:12', NULL, '2026-05-10 03:45:55', '2026-05-10 03:48:12'),
(15, 'App\\Models\\User', 5, 'auth_token', '63cb417bf8df14d46089517694425690fb6df01cf4ca199b3ebfa6a7c4d2605c', '[\"*\"]', '2026-05-10 03:58:48', NULL, '2026-05-10 03:57:26', '2026-05-10 03:58:48'),
(16, 'App\\Models\\User', 5, 'auth_token', '8e72d967c4253830e420a5df11038dc414072df8fef26419ce2c0ee8de72288b', '[\"*\"]', '2026-05-10 04:00:09', NULL, '2026-05-10 04:00:01', '2026-05-10 04:00:09'),
(17, 'App\\Models\\User', 5, 'auth_token', 'a471bbc5e35e564cffce5bcc6d31ae9193e698b0695a13aa4d0b6277cfac2a59', '[\"*\"]', '2026-05-10 04:10:21', NULL, '2026-05-10 04:02:41', '2026-05-10 04:10:21'),
(18, 'App\\Models\\User', 5, 'auth_token', '5dcdb2fb2b760ce8da33fa659d054d46031934e85e0b9b1f7499e73010d08a07', '[\"*\"]', '2026-05-10 04:13:18', NULL, '2026-05-10 04:12:04', '2026-05-10 04:13:18');

-- --------------------------------------------------------

--
-- Table structure for table `qr_sessions`
--

CREATE TABLE `qr_sessions` (
  `id` bigint UNSIGNED NOT NULL,
  `KELAS_ID` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `KODE_PERTEMUAN` tinyint UNSIGNED NOT NULL,
  `TOKEN` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `EXPIRED_AT` timestamp NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `qr_sessions`
--

INSERT INTO `qr_sessions` (`id`, `KELAS_ID`, `KODE_PERTEMUAN`, `TOKEN`, `EXPIRED_AT`) VALUES
(3, 'KLS02', 0, 'n9tXEixLtoq0plGKTthMgwhR9kuZ6jYlujCI8uG1', '2026-05-01 22:31:09'),
(9, 'KLS01', 0, 'W8lZUrmMAXag0NVHYW4RlRCsN8WOjyJCjP6qO5Nk', '2026-05-01 22:41:13'),
(10, 'TIK01', 0, 's2gQOJvwe67WnHceL6S2WT6t7AyGBtXLcXxFz9mE', '2026-05-01 23:34:18'),
(11, 'TIK01', 1, 'BK45bX2ZLfbjnNBmwcGyTigtfGoJ5KPS6j4pmWPX', '2026-05-02 08:09:48'),
(12, 'TIK01', 3, '9HeJA0aMroCSIn4s3UtiApmvrvkltf8PKmdSqEke', '2026-05-02 08:53:03'),
(13, 'TIK01', 3, 'wVD5eVvn96mCLJcxaADZl9adO2R3LyAD112kNcTV', '2026-05-02 08:55:57'),
(14, 'TIK01', 3, 'OfXTQu4Ue95FDngU40uq73ZqiVny2JDzLZuQvYfu', '2026-05-02 08:57:53'),
(15, 'TIK01', 3, 'Y69FKPHqcJtyCxitEMbp4DI2IF5y7Ma4gxdYB9GM', '2026-05-02 08:59:16'),
(16, 'TIK01', 3, 'BeOOsTOIKvQc2iHNC0w7m85Pmg2RBrOSRyO7bOkR', '2026-05-02 09:00:34'),
(17, 'TIK02', 1, 'VTPxyiq9fdfQd8nHlQpHhjCRzXj3dOjctcgc8JiD', '2026-05-02 09:01:25'),
(18, 'TIK01', 4, 'TIaBjk8FqX2iDkLqdVLBa8GiKHGJBPaxSP3952kt', '2026-05-02 09:33:31'),
(19, 'TIK02', 1, 'LNg2g9eQjDAUdOHgNwGHXJV8rxXvHkfa45Nlj46g', '2026-05-02 09:34:35'),
(20, 'TIK02', 1, 'vPmb6qRV5filSunVIeJzeIQNMoUpqI8kGrfGQzWA', '2026-05-02 09:38:49'),
(21, 'TIK02', 2, 'GNqouvrlqUaz04quPmdiIDVhapojuOtgmdDiHYZA', '2026-05-02 09:42:24'),
(22, 'TIK02', 2, 'Z7RoTvnSwqSPhGNW2osyoy2bLZJQ8rzg7HdH5Nit', '2026-05-02 09:43:54'),
(23, 'TIK02', 2, '62ioZlOjlRDE9BEv5tfdZ4Jsha4ABYH6gqq2lPvR', '2026-05-02 09:45:13'),
(24, 'TIK02', 2, 'GQh5pWboMQuRrFyAdm1sib7FE0FOaqSGrYsWvnAJ', '2026-05-02 09:46:41'),
(25, 'TIK02', 3, 'T2satuMEnLqTpDn57GIXNEBwhZn8BrfEoJe6wcZf', '2026-05-02 09:47:08'),
(26, 'TIK01', 5, 'bJ9EzA7KkE1NXQiZvNMoNOXYOXImzPpp5cT4RQz4', '2026-05-10 04:12:41');

-- --------------------------------------------------------

--
-- Table structure for table `roles`
--

CREATE TABLE `roles` (
  `ID_ROLE` bigint UNSIGNED NOT NULL,
  `NAMA_ROLE` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `roles`
--

INSERT INTO `roles` (`ID_ROLE`, `NAMA_ROLE`) VALUES
(1, 'admin'),
(2, 'dosen');

-- --------------------------------------------------------

--
-- Table structure for table `sessions`
--

CREATE TABLE `sessions` (
  `id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` bigint UNSIGNED DEFAULT NULL,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` text COLLATE utf8mb4_unicode_ci,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_activity` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` bigint UNSIGNED NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'dosen',
  `ID_ROLE` bigint UNSIGNED DEFAULT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `remember_token` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `role`, `ID_ROLE`, `email_verified_at`, `password`, `remember_token`, `created_at`, `updated_at`) VALUES
(1, 'Alfyan', 'alfyan@email.com', 'admin', 1, NULL, '$2y$12$D70znlMdxOkucqtYaMeGOOpX8IXJKfpZ6R8FMs89tp12DB/jpgV8C', NULL, '2026-05-02 07:58:50', '2026-05-02 07:58:50'),
(3, 'Aisyah', 'aisyah@email.com', 'dosen', 2, NULL, '$2y$12$88Luw8M9BTbXGB6ZoEXSVOj3kg6r7Me.qBmKpnEZVU1qKS8uaQUxe', NULL, '2026-05-03 05:13:12', '2026-05-03 05:13:12'),
(4, 'Darrel', 'Darrel@email.com', 'admin', 1, NULL, '$2y$12$IP5saEL8a5RrGUZIQ8RauuUSsWBCF.W9OC21oIlCYMyds6yZ0wPka', NULL, '2026-05-03 05:18:41', '2026-05-03 05:18:41'),
(5, 'Febri', 'Febri@email.com', 'dosen', 2, NULL, '$2y$12$IP5saEL8a5RrGUZIQ8RauuUSsWBCF.W9OC21oIlCYMyds6yZ0wPka', NULL, '2026-05-03 05:18:41', '2026-05-03 05:18:41');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `absensi_mahasiswa`
--
ALTER TABLE `absensi_mahasiswa`
  ADD PRIMARY KEY (`ID_ABSENSI`);

--
-- Indexes for table `absensi_pegawai`
--
ALTER TABLE `absensi_pegawai`
  ADD PRIMARY KEY (`ID_ABSENSI`),
  ADD KEY `NIP` (`NIP`);

--
-- Indexes for table `cache`
--
ALTER TABLE `cache`
  ADD PRIMARY KEY (`key`),
  ADD KEY `cache_expiration_index` (`expiration`);

--
-- Indexes for table `cache_locks`
--
ALTER TABLE `cache_locks`
  ADD PRIMARY KEY (`key`),
  ADD KEY `cache_locks_expiration_index` (`expiration`);

--
-- Indexes for table `dosen`
--
ALTER TABLE `dosen`
  ADD PRIMARY KEY (`NIP_DOSEN`),
  ADD KEY `dosen_id_user_foreign` (`ID_USER`);

--
-- Indexes for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`);

--
-- Indexes for table `jabatan`
--
ALTER TABLE `jabatan`
  ADD PRIMARY KEY (`ID_JABATAN`);

--
-- Indexes for table `jadwal_kuliah`
--
ALTER TABLE `jadwal_kuliah`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `jobs`
--
ALTER TABLE `jobs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `jobs_queue_index` (`queue`);

--
-- Indexes for table `job_batches`
--
ALTER TABLE `job_batches`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `kelas`
--
ALTER TABLE `kelas`
  ADD PRIMARY KEY (`ID_KELAS`);

--
-- Indexes for table `kelas_sessions`
--
ALTER TABLE `kelas_sessions`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `mata_kuliah`
--
ALTER TABLE `mata_kuliah`
  ADD PRIMARY KEY (`KODE_MK`);

--
-- Indexes for table `memiliki`
--
ALTER TABLE `memiliki`
  ADD PRIMARY KEY (`ID_JABATAN`,`NIP`),
  ADD KEY `ID_JABATAN` (`ID_JABATAN`),
  ADD KEY `NIP` (`NIP`);

--
-- Indexes for table `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `password_reset_tokens`
--
ALTER TABLE `password_reset_tokens`
  ADD PRIMARY KEY (`email`);

--
-- Indexes for table `pegawai`
--
ALTER TABLE `pegawai`
  ADD PRIMARY KEY (`NIP`);

--
-- Indexes for table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  ADD KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`),
  ADD KEY `personal_access_tokens_expires_at_index` (`expires_at`);

--
-- Indexes for table `qr_sessions`
--
ALTER TABLE `qr_sessions`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`ID_ROLE`);

--
-- Indexes for table `sessions`
--
ALTER TABLE `sessions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sessions_user_id_index` (`user_id`),
  ADD KEY `sessions_last_activity_index` (`last_activity`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `users_email_unique` (`email`),
  ADD KEY `users_id_role_foreign` (`ID_ROLE`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `absensi_mahasiswa`
--
ALTER TABLE `absensi_mahasiswa`
  MODIFY `ID_ABSENSI` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `absensi_pegawai`
--
ALTER TABLE `absensi_pegawai`
  MODIFY `ID_ABSENSI` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `jadwal_kuliah`
--
ALTER TABLE `jadwal_kuliah`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `jobs`
--
ALTER TABLE `jobs`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `kelas_sessions`
--
ALTER TABLE `kelas_sessions`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT for table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT for table `qr_sessions`
--
ALTER TABLE `qr_sessions`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT for table `roles`
--
ALTER TABLE `roles`
  MODIFY `ID_ROLE` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `absensi_pegawai`
--
ALTER TABLE `absensi_pegawai`
  ADD CONSTRAINT `FK_RELATIONSHIP_2` FOREIGN KEY (`NIP`) REFERENCES `pegawai` (`NIP`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `dosen`
--
ALTER TABLE `dosen`
  ADD CONSTRAINT `dosen_id_user_foreign` FOREIGN KEY (`ID_USER`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `memiliki`
--
ALTER TABLE `memiliki`
  ADD CONSTRAINT `FK_MEMILIKI` FOREIGN KEY (`ID_JABATAN`) REFERENCES `jabatan` (`ID_JABATAN`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_MEMILIKI2` FOREIGN KEY (`NIP`) REFERENCES `pegawai` (`NIP`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `users_id_role_foreign` FOREIGN KEY (`ID_ROLE`) REFERENCES `roles` (`ID_ROLE`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
