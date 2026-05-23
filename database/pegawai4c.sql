-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: May 23, 2026 at 04:48 AM
-- Server version: 10.4.28-MariaDB
-- PHP Version: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `pegawai4c`
--

-- --------------------------------------------------------

--
-- Table structure for table `absensi_mahasiswa`
--

DROP TABLE IF EXISTS `absensi_mahasiswa`;
CREATE TABLE `absensi_mahasiswa` (
  `ID_ABSENSI` bigint(20) UNSIGNED NOT NULL,
  `NIM` varchar(255) NOT NULL,
  `KELAS_ID` varchar(255) NOT NULL,
  `KODE_PERTEMUAN` int(11) NOT NULL,
  `TANGGAL` date NOT NULL,
  `STATUS` enum('H','S','I','A') NOT NULL,
  `METODE` varchar(255) NOT NULL
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

DROP TABLE IF EXISTS `absensi_pegawai`;
CREATE TABLE `absensi_pegawai` (
  `id_absensi` int(11) NOT NULL,
  `id_pegawai` int(11) NOT NULL,
  `tanggal` date NOT NULL,
  `waktu_masuk` time DEFAULT NULL,
  `waktu_keluar` time DEFAULT NULL,
  `keterangan` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `absensi_pegawai`
--

INSERT INTO `absensi_pegawai` (`id_absensi`, `id_pegawai`, `tanggal`, `waktu_masuk`, `waktu_keluar`, `keterangan`) VALUES
(1, 5, '2026-05-22', '08:47:14', '08:49:35', NULL),
(2, 3, '2026-05-22', '08:54:55', '08:55:34', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `cache`
--

DROP TABLE IF EXISTS `cache`;
CREATE TABLE `cache` (
  `key` varchar(255) NOT NULL,
  `value` mediumtext NOT NULL,
  `expiration` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cache_locks`
--

DROP TABLE IF EXISTS `cache_locks`;
CREATE TABLE `cache_locks` (
  `key` varchar(255) NOT NULL,
  `owner` varchar(255) NOT NULL,
  `expiration` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `dosen`
--

DROP TABLE IF EXISTS `dosen`;
CREATE TABLE `dosen` (
  `id_dosen` int(11) NOT NULL,
  `id_pegawai` smallint(6) DEFAULT NULL,
  `id_user` bigint(20) UNSIGNED DEFAULT NULL,
  `nama_dosen` varchar(60) NOT NULL,
  `panggilan` varchar(150) DEFAULT NULL,
  `jk` char(1) DEFAULT NULL,
  `nidn` char(10) DEFAULT NULL,
  `nip_baru` varchar(50) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `alamat` varchar(255) DEFAULT NULL,
  `id_jurusan` tinyint(4) DEFAULT NULL,
  `id_prodi` smallint(6) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `status_aktif` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `dosen`
--

INSERT INTO `dosen` (`id_dosen`, `id_pegawai`, `id_user`, `nama_dosen`, `panggilan`, `jk`, `nidn`, `nip_baru`, `email`, `alamat`, `id_jurusan`, `id_prodi`, `created_at`, `updated_at`, `status_aktif`) VALUES
(1, 16, NULL, 'ARIFIN NOOR ASYIKIN, ST, M.T.', 'ARIFIN NOOR ASYIKIN', 'L', '0002127602', '197612022002121002', '', 'Banjarmasin', 3, 1, NULL, NULL, 1),
(2, 17, NULL, 'AGUS SETIYO BUDI N, ST, M.KOM', 'AGUS SETIYO BUDI N', 'L', '0011087508', '197508112000121002', '', 'Banjarmasin', 3, 1, NULL, NULL, 1),
(3, 18, NULL, 'SUHADI, A.MD', 'SUHADI', 'L', '', '196506171990031003', '', NULL, 3, 3, NULL, NULL, 1),
(4, 19, NULL, 'DRA. HJ. MASNUNAWATI, MM.AP', 'HJ. MASNUNAWATI', 'P', '', '196403151988032002', '', 'Banjarmasin', 0, 0, NULL, NULL, 1),
(5, 20, NULL, 'HENDRA MARS SETIAWAN, ST', 'HENDRA MARS SETIAWAN', 'L', '', '197903222002121003', '', 'Banjarmasin', 3, 3, NULL, NULL, 1),
(6, 21, NULL, 'SYAIFUL BACHRI, S.SOS.', 'SYAIFUL BACHRI', 'L', '', '195911171983031001', '', 'Banjarmasin', 0, 0, NULL, NULL, 1),
(7, 22, NULL, 'SUKARMAN', 'SUKARMAN', 'L', '', '196410011992031002', '', 'Banjarbaru', 3, 3, NULL, NULL, 1),
(8, 23, NULL, 'SUBANDI, ST, M. KOM', 'SUBANDI', 'L', '', '', '', NULL, 3, 1, NULL, NULL, 1),
(9, 24, NULL, 'YOENIE INDRASARY, ST.,MT', 'YOENIE INDRASARY', 'P', '', '', '', NULL, 3, 1, NULL, NULL, 1),
(10, 25, NULL, 'GUNAWAN RUDI CAHYONO, ST, M.T.', 'GUNAWAN RUDI CAHYONO', 'L', '', '', '', NULL, 3, 2, NULL, NULL, 1),
(11, 26, NULL, 'RAHIMI FITRI, S.KOM.,M. KOM', 'RAHIMI FITRI', 'P', '', '', '', NULL, 3, 1, NULL, NULL, 1),
(12, 27, NULL, 'ISNA WARDIAH, S.PD.,M.PD', 'ISNA WARDIAH', 'P', '', '', '', NULL, 3, 1, NULL, NULL, 1),
(13, 28, NULL, 'DR. KUN NURSYAIFUL PRIYO PAMUNGKAS, S.KOM.,M.KOM', 'KUN NURSYAIFUL PRIYO PAMUNGKAS', 'L', '', '', '', NULL, 3, 1, NULL, NULL, 1),
(14, 29, NULL, 'Reza Fauzan', 'Reza Fauzan', 'L', '', '', '', NULL, 3, 1, NULL, NULL, 1),
(15, 30, NULL, 'ZAIYAN AHYADI, ST, M.SC', 'ZAIYAN AHYADI', 'L', '', '', '', NULL, 3, 2, NULL, NULL, 1),
(16, 31, NULL, 'M. NOOR', 'M. NOOR', 'L', '', '', '', NULL, 1, 6, NULL, NULL, 1),
(17, 32, NULL, 'M. HELMY NOOR, S.ST, M.T.', 'M. HELMY NOOR', 'L', '', '', '', NULL, 3, 1, NULL, NULL, 1),
(18, 33, NULL, 'FUAD SHOLIHIN, S.T., M.KOM.', 'FUAD SHOLIHIN', 'L', '', '', '', NULL, 3, 1, NULL, NULL, 1),
(19, 34, NULL, 'IDA HASTUTI, SST , M.T.', 'IDA HASTUTI', 'P', '', '', '', NULL, 3, 1, NULL, NULL, 1),
(20, 35, NULL, 'RINOVA FIRMAN CAHYANI, S.SI.,M.PD', 'RINOVA FIRMAN CAHYANI', 'L', '', '', '', NULL, 1, 4, NULL, NULL, 1),
(21, 36, NULL, 'AUNUR RAFIK, ST, MT', 'AUNUR RAFIK', 'L', '', '', '', NULL, 1, 6, NULL, NULL, 1),
(22, 37, NULL, 'NURFITRIAH, S.PD, MA', 'NURFITRIAH', 'P', '', '', '', NULL, 1, 4, NULL, NULL, 1),
(23, 38, NULL, 'DESSY LESTARI SAPTARINI, ST.,M.ENG', 'DESSY LESTARI SAPTARINI', 'P', '', '', '', NULL, 1, 4, NULL, NULL, 1),
(24, 39, NULL, 'RUSPIANSYAH, S.T, M.T.', 'RUSPIANSYAH', 'L', '', '', '', NULL, 1, 6, NULL, NULL, 1),
(25, 40, NULL, 'AKHMAD RAMDANI, S.H', 'AKHMAD RAMDANI', 'L', '', '', '', NULL, 1, 6, NULL, NULL, 1),
(26, 41, NULL, 'TITIES EKOSUSILOWATI, M.SI', 'TITIES EKOSUSILOWATI', '', '', '', '', NULL, 0, 0, NULL, NULL, 1),
(27, 42, NULL, 'USAMA, S.PDI', 'USAMA', '', '', '', '', NULL, 0, 0, NULL, NULL, 1),
(28, 43, NULL, 'DRS. H.M.KUSASI, M.SI', 'H.M.KUSASI', '', '', '', '', NULL, 0, 0, NULL, NULL, 1),
(29, 44, NULL, 'R. OTTO KESUMARWANTO, MT', 'R. OTTO KESUMARWANTO', '', '', '', '', NULL, 0, 0, NULL, NULL, 1),
(30, 45, NULL, 'H. SYAMSUDIN NOOR, ST, M.T.', 'H. SYAMSUDIN NOOR', '', '', '', '', NULL, 3, 3, NULL, NULL, 1),
(31, 46, NULL, 'Dr. REZA ADHI FAJAR, ST, MT', 'REZA ADHI FAJAR', '', '', '', '', NULL, 1, 4, NULL, NULL, 1),
(32, 47, NULL, 'AHMAD RIZANI, ST, MT', 'AHMAD RIZANI', '', '', '', '', NULL, 1, 4, NULL, NULL, 1),
(33, 48, NULL, 'MUHAMMAD FIRDAUS, ST, MT', 'MUHAMMAD FIRDAUS', '', '', '', '', NULL, 1, 6, NULL, NULL, 1),
(34, 49, NULL, 'FERRY SOBATNU, ST.,MT', 'FERRY SOBATNU', '', '', '', '', NULL, 1, 5, NULL, NULL, 1),
(35, 50, NULL, 'MUHAMMAD AMRIL ASY\'ARI, S.T.,M.ENG', 'MUHAMMAD AMRIL ASY\'ARI', '', '', '', '', NULL, 1, 4, NULL, NULL, 1),
(40, 5, 5, 'Febri', 'Febri', 'L', '', '', '', 'Paringin', 0, 0, NULL, NULL, 1),
(41, 8, 8, 'Aisya', 'Aisya', 'P', '', '', '', 'Banjarmasin', 0, 0, NULL, NULL, 1),
(53, 7, 7, 'Riyan', 'Riyan', 'L', NULL, NULL, 'Riyan@email.com', 'Kandangan', 1, 6, NULL, NULL, 1);

-- --------------------------------------------------------

--
-- Table structure for table `failed_jobs`
--

DROP TABLE IF EXISTS `failed_jobs`;
CREATE TABLE `failed_jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `uuid` varchar(255) NOT NULL,
  `connection` text NOT NULL,
  `queue` text NOT NULL,
  `payload` longtext NOT NULL,
  `exception` longtext NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `jabatan`
--

DROP TABLE IF EXISTS `jabatan`;
CREATE TABLE `jabatan` (
  `id_jabatan` varchar(10) NOT NULL,
  `nama_jabatan` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `jabatan`
--

INSERT INTO `jabatan` (`id_jabatan`, `nama_jabatan`) VALUES
('J01', 'Kepala Administrasi'),
('J02', 'Staff Akademik'),
('J03', 'Staff Keuangan'),
('J04', 'IT Support'),
('J05', 'Pustakawan'),
('J06', 'Laboran'),
('J07', 'Staff Kemahasiswaan'),
('J08', 'Staff Umum'),
('J09', 'Staff Kepegawaian'),
('J10', 'Teknisi'),
('J11', 'Dosen');

-- --------------------------------------------------------

--
-- Table structure for table `jadwal_kuliah`
--

DROP TABLE IF EXISTS `jadwal_kuliah`;
CREATE TABLE `jadwal_kuliah` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `KELAS_ID` varchar(255) NOT NULL,
  `HARI` varchar(255) NOT NULL,
  `JAM_MULAI` time NOT NULL,
  `JAM_SELESAI` time NOT NULL,
  `RUANG` varchar(255) NOT NULL,
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

DROP TABLE IF EXISTS `jobs`;
CREATE TABLE `jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `queue` varchar(255) NOT NULL,
  `payload` longtext NOT NULL,
  `attempts` smallint(5) UNSIGNED NOT NULL,
  `reserved_at` int(10) UNSIGNED DEFAULT NULL,
  `available_at` int(10) UNSIGNED NOT NULL,
  `created_at` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `job_batches`
--

DROP TABLE IF EXISTS `job_batches`;
CREATE TABLE `job_batches` (
  `id` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `total_jobs` int(11) NOT NULL,
  `pending_jobs` int(11) NOT NULL,
  `failed_jobs` int(11) NOT NULL,
  `failed_job_ids` longtext NOT NULL,
  `options` mediumtext DEFAULT NULL,
  `cancelled_at` int(11) DEFAULT NULL,
  `created_at` int(11) NOT NULL,
  `finished_at` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `kelas`
--

DROP TABLE IF EXISTS `kelas`;
CREATE TABLE `kelas` (
  `ID_KELAS` varchar(255) NOT NULL,
  `NAMA_KELAS` varchar(255) NOT NULL,
  `NIP_DOSEN` varchar(255) NOT NULL,
  `KODE_MK` varchar(255) DEFAULT NULL
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

DROP TABLE IF EXISTS `kelas_sessions`;
CREATE TABLE `kelas_sessions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `KELAS_ID` varchar(255) NOT NULL,
  `KODE_PERTEMUAN` tinyint(3) UNSIGNED NOT NULL,
  `IS_ACTIVE` tinyint(1) NOT NULL DEFAULT 1,
  `STARTED_AT` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
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

DROP TABLE IF EXISTS `mata_kuliah`;
CREATE TABLE `mata_kuliah` (
  `KODE_MK` varchar(255) NOT NULL,
  `NAMA_MK` varchar(255) NOT NULL,
  `SKS` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `materi_kelas`
--

DROP TABLE IF EXISTS `materi_kelas`;
CREATE TABLE `materi_kelas` (
  `id_materi` int(11) NOT NULL,
  `id_dosen` int(11) NOT NULL,
  `id_kelas` varchar(20) NOT NULL,
  `id_mk` varchar(20) NOT NULL,
  `id_kelas_session` int(11) DEFAULT NULL,
  `judul` varchar(150) NOT NULL,
  `deskripsi` text DEFAULT NULL,
  `file_path` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `materi_kelas`
--

INSERT INTO `materi_kelas` (`id_materi`, `id_dosen`, `id_kelas`, `id_mk`, `id_kelas_session`, `judul`, `deskripsi`, `file_path`, `created_at`, `updated_at`) VALUES
(1, 40, '1', '', 2, 'Pengenalan Laravel Service Layer', 'Dasar service layer dan MVC', 'materi/WsAWglbwL2CM7OVcNnoObelUySLQr2DlMezqc0bB.pdf', '2026-05-22 07:01:48', '2026-05-22 07:01:48'),
(2, 40, 'TIK01', '', 2, 'Pengenalan Laravel Service Layer', 'Dasar service layer dan MVC', 'materi/L1R65VIWVuGA3Ggmltr68UZ4EmK09GHs0H6FkQZu.pdf', '2026-05-22 07:08:22', '2026-05-22 07:08:22'),
(3, 40, 'TIK02', '', 2, 'Pengenalan Laravel Service Layer', 'Dasar service layer dan MVC', 'materi/Q7EbELZTe9v4IR5Ytf9KKtKGluBIzLPfAbKq7fTr.pdf', '2026-05-22 07:12:52', '2026-05-22 07:12:52'),
(4, 53, '1', '1', 2, 'Pengenalan Laravel Service Layer', 'Dasar service layer dan MVC', 'materi/B7R0aDWsgNGFRJ42TWRxnftuqNIDhwfPiIi94rSs.pdf', '2026-05-22 08:08:22', '2026-05-22 08:08:22'),
(5, 53, '2', '1', 2, 'Pengenalan Laravel Service Layer', 'Dasar service layer dan MVC', 'materi/A01K8nTkJnJLWu9AwPpf7QBtjXYt99QxxqWOf82c.pdf', '2026-05-22 08:09:00', '2026-05-22 08:09:00');

-- --------------------------------------------------------

--
-- Table structure for table `memiliki`
--

DROP TABLE IF EXISTS `memiliki`;
CREATE TABLE `memiliki` (
  `id_jabatan` varchar(10) NOT NULL,
  `nip` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `memiliki`
--

INSERT INTO `memiliki` (`id_jabatan`, `nip`) VALUES
('J01', 'P001'),
('J02', 'P004'),
('J02', 'P013'),
('J03', 'P002'),
('J04', 'P003'),
('J04', 'P012'),
('J05', 'P005'),
('J05', 'P015'),
('J06', 'P006'),
('J07', 'P007'),
('J08', 'P009'),
('J09', 'P010'),
('J10', 'P011'),
('J11', 'P008'),
('J11', 'P014');

-- --------------------------------------------------------

--
-- Table structure for table `migrations`
--

DROP TABLE IF EXISTS `migrations`;
CREATE TABLE `migrations` (
  `id` int(10) UNSIGNED NOT NULL,
  `migration` varchar(255) NOT NULL,
  `batch` int(11) NOT NULL
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

DROP TABLE IF EXISTS `password_reset_tokens`;
CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) NOT NULL,
  `token` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pegawai`
--

DROP TABLE IF EXISTS `pegawai`;
CREATE TABLE `pegawai` (
  `id_pegawai` int(11) NOT NULL,
  `nip` varchar(20) NOT NULL,
  `nik` varchar(20) DEFAULT NULL,
  `nama_pegawai` varchar(60) NOT NULL,
  `jenis_kelamin` char(1) DEFAULT NULL,
  `alamat` varchar(255) DEFAULT NULL,
  `unit_kerja` varchar(100) DEFAULT NULL,
  `id_user` bigint(20) UNSIGNED DEFAULT NULL,
  `status_aktif` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `pegawai`
--

INSERT INTO `pegawai` (`id_pegawai`, `nip`, `nik`, `nama_pegawai`, `jenis_kelamin`, `alamat`, `unit_kerja`, `id_user`, `status_aktif`) VALUES
(1, 'P001', '630101001', 'Alfyan', 'L', 'Banjarmasin', 'Administrasi Akademik', 1, 1),
(2, 'P002', '630101002', 'Darrel', 'L', 'Banjarbaru', 'Keuangan', 4, 1),
(3, 'P003', '630101003', 'Sonny', 'L', 'Martapura', 'IT Support', 3, 1),
(4, 'P004', '630101004', 'Rizky', 'L', 'Pelaihari', 'BAAK', 4, 1),
(5, 'P014', '630101014', 'Febri', 'L', 'Paringin', 'Dosen', 5, 1),
(6, 'P006', '630101006', 'Rio', 'L', 'Amuntai', 'Laboratorium', 6, 1),
(7, 'P007', '630101007', 'Riyan', 'L', 'Kandangan', 'Dosen', 7, 1),
(8, 'P008', '630101008', 'Aisya', 'P', 'Banjarmasin', 'Dosen', 8, 1),
(9, 'P009', '630101009', 'Darmawan', 'L', 'Rantau', 'Umum', 9, 1),
(10, 'P010', '630101010', 'Losong', 'L', 'Marabahan', 'Kepegawaian', 10, 1),
(11, 'P011', '630101011', 'Yuzar', 'L', 'Batulicin', 'Teknisi', 11, 1),
(12, 'P012', '630101012', 'Wicaksono', 'L', 'Kotabaru', 'IT Support', 12, 1),
(13, 'P013', '630101013', 'Yori', 'P', 'Tanjung', 'Administrasi', 13, 1),
(14, 'P005', '630101005', 'Jasmine', 'P', 'Barabai', 'Perpustakaan', 14, 1),
(15, 'P015', '630101015', 'Novi', 'P', 'Banjarmasin', 'Perpustakaan', 15, 1),
(18, 'P016', NULL, 'ARIFIN NOOR ASYIKIN', 'L', 'Banjarmasin', 'Dosen', NULL, 1),
(19, 'P017', NULL, 'AGUS SETIYO BUDI N', 'L', 'Banjarmasin', 'Dosen', NULL, 1),
(20, 'P018', NULL, 'SUHADI', 'L', NULL, 'Dosen', NULL, 1),
(21, 'P019', NULL, 'HJ. MASNUNAWATI', 'P', 'Banjarmasin', 'Dosen', NULL, 1),
(22, 'P020', NULL, 'HENDRA MARS SETIAWAN', 'L', 'Banjarmasin', 'Dosen', NULL, 1),
(23, 'P021', NULL, 'SYAIFUL BACHRI', 'L', 'Banjarmasin', 'Dosen', NULL, 1),
(24, 'P022', NULL, 'SUKARMAN', 'L', 'Banjarbaru', 'Dosen', NULL, 1),
(25, 'P023', NULL, 'SUBANDI', NULL, NULL, 'Dosen', NULL, 1),
(26, 'P024', NULL, 'YOENIE INDRASARY', NULL, NULL, 'Dosen', NULL, 1),
(27, 'P025', NULL, 'GUNAWAN RUDI CAHYONO', NULL, NULL, 'Dosen', NULL, 1),
(28, 'P026', NULL, 'RAHIMI FITRI', NULL, NULL, 'Dosen', NULL, 1),
(29, 'P027', NULL, 'ISNA WARDIAH', NULL, NULL, 'Dosen', NULL, 1),
(30, 'P028', NULL, 'KUN NURSYAIFUL PRIYO PAMUNGKAS', NULL, NULL, 'Dosen', NULL, 1),
(31, 'P029', NULL, 'Reza Fauzan', NULL, NULL, 'Dosen', NULL, 1),
(32, 'P030', NULL, 'ZAIYAN AHYADI', NULL, NULL, 'Dosen', NULL, 1),
(33, 'P031', NULL, 'M. NOOR', NULL, NULL, 'Dosen', NULL, 1),
(34, 'P032', NULL, 'M. HELMY NOOR', NULL, NULL, 'Dosen', NULL, 1),
(35, 'P033', NULL, 'FUAD SHOLIHIN', NULL, NULL, 'Dosen', NULL, 1),
(36, 'P034', NULL, 'IDA HASTUTI', NULL, NULL, 'Dosen', NULL, 1),
(37, 'P035', NULL, 'RINOVA FIRMAN CAHYANI', NULL, NULL, 'Dosen', NULL, 1),
(38, 'P036', NULL, 'AUNUR RAFIK', NULL, NULL, 'Dosen', NULL, 1),
(39, 'P037', NULL, 'NURFITRIAH', NULL, NULL, 'Dosen', NULL, 1),
(40, 'P038', NULL, 'DESSY LESTARI SAPTARINI', NULL, NULL, 'Dosen', NULL, 1),
(41, 'P039', NULL, 'RUSPIANSYAH', NULL, NULL, 'Dosen', NULL, 1),
(42, 'P040', NULL, 'AKHMAD RAMDANI', NULL, NULL, 'Dosen', NULL, 1),
(43, 'P041', NULL, 'TITIES EKOSUSILOWATI', NULL, NULL, 'Dosen', NULL, 1),
(44, 'P042', NULL, 'USAMA', NULL, NULL, 'Dosen', NULL, 1),
(45, 'P043', NULL, 'H.M.KUSASI', NULL, NULL, 'Dosen', NULL, 1),
(46, 'P044', NULL, 'R. OTTO KESUMARWANTO', NULL, NULL, 'Dosen', NULL, 1),
(47, 'P045', NULL, 'H. SYAMSUDIN NOOR', NULL, NULL, 'Dosen', NULL, 1),
(48, 'P046', NULL, 'REZA ADHI FAJAR', NULL, NULL, 'Dosen', NULL, 1),
(49, 'P047', NULL, 'AHMAD RIZANI', NULL, NULL, 'Dosen', NULL, 1),
(50, 'P048', NULL, 'MUHAMMAD FIRDAUS', NULL, NULL, 'Dosen', NULL, 1),
(51, 'P049', NULL, 'FERRY SOBATNU', NULL, NULL, 'Dosen', NULL, 1),
(52, 'P050', NULL, 'MUHAMMAD AMRIL ASY\'ARI', NULL, NULL, 'Dosen', NULL, 1);

-- --------------------------------------------------------

--
-- Table structure for table `personal_access_tokens`
--

DROP TABLE IF EXISTS `personal_access_tokens`;
CREATE TABLE `personal_access_tokens` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `tokenable_type` varchar(255) NOT NULL,
  `tokenable_id` bigint(20) UNSIGNED NOT NULL,
  `name` text NOT NULL,
  `token` varchar(64) NOT NULL,
  `abilities` text DEFAULT NULL,
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
(18, 'App\\Models\\User', 5, 'auth_token', '5dcdb2fb2b760ce8da33fa659d054d46031934e85e0b9b1f7499e73010d08a07', '[\"*\"]', '2026-05-10 04:13:18', NULL, '2026-05-10 04:12:04', '2026-05-10 04:13:18'),
(19, 'App\\Models\\User', 5, 'auth_token', '43abbfe0d44d25c4dabececdf31d48dcc16199a7e2376a2741943b5c7a02ff21', '[\"*\"]', NULL, NULL, '2026-05-12 03:50:02', '2026-05-12 03:50:02'),
(20, 'App\\Models\\User', 5, 'auth_token', '3ad38a9b89ebc1bc116d3d755f657e1a1c53f0ab857ec3afd6ce3ab18fd02ca7', '[\"*\"]', NULL, NULL, '2026-05-12 04:04:21', '2026-05-12 04:04:21'),
(21, 'App\\Models\\User', 5, 'auth_token', 'cb41dd727fde0cdef2decb95d03460304c0585f05c7fd97954980de5097a47b9', '[\"*\"]', NULL, NULL, '2026-05-12 04:05:43', '2026-05-12 04:05:43'),
(22, 'App\\Models\\User', 5, 'auth_token', 'dfaca32a8f55d08711ab4a7525b4eb2762e53638a223f66ca9e50d7efa13801a', '[\"*\"]', NULL, NULL, '2026-05-12 04:06:23', '2026-05-12 04:06:23'),
(23, 'App\\Models\\User', 5, 'auth_token', 'aaf0c18e7fea7d344c60cfc8220459735bf61640b5805c17214bae637d063edb', '[\"*\"]', NULL, NULL, '2026-05-21 22:39:28', '2026-05-21 22:39:28'),
(24, 'App\\Models\\User', 5, 'auth_token', 'b127d6dfdda600e88ca92ea73394e764197edfcb41da5ac5dbffb095ed0b130e', '[\"*\"]', NULL, NULL, '2026-05-21 22:48:46', '2026-05-21 22:48:46'),
(25, 'App\\Models\\User', 1, 'auth_token', 'ff8c93384fe7977feae576a295aff4f5d946c8e40b26d8c7e54a767708a5ced0', '[\"*\"]', '2026-05-21 22:54:05', NULL, '2026-05-21 22:53:43', '2026-05-21 22:54:05'),
(26, 'App\\Models\\User', 5, 'auth_token', '8ffd8d627d95745af99ee7083808e0ff4d10ba29410fe3cde78479995dd10b2d', '[\"*\"]', NULL, NULL, '2026-05-21 22:57:19', '2026-05-21 22:57:19'),
(27, 'App\\Models\\User', 5, 'auth_token', 'e124713a6f8a48baf0da83d8297816580747b9513675c90d1090f0fe6dcf1201', '[\"*\"]', NULL, NULL, '2026-05-21 23:06:58', '2026-05-21 23:06:58'),
(28, 'App\\Models\\User', 1, 'auth_token', 'deeb1de2d057c8798b6b8ec7bf0923a0529e044c61f1cb1e050fd7045cdc69c3', '[\"*\"]', '2026-05-21 23:07:16', NULL, '2026-05-21 23:07:01', '2026-05-21 23:07:16'),
(29, 'App\\Models\\User', 1, 'auth_token', '5ffedf598a8e2756606db23668e5d0d31cffed97a36bb5774464062881e72df0', '[\"*\"]', '2026-05-21 23:11:16', NULL, '2026-05-21 23:11:06', '2026-05-21 23:11:16'),
(30, 'App\\Models\\User', 1, 'auth_token', 'f9ecd5e6bb719757d7f87deebd38e45ff06c1fb529cb7b58e7bda1a342b3bf9e', '[\"*\"]', '2026-05-22 00:06:00', NULL, '2026-05-22 00:05:17', '2026-05-22 00:06:00'),
(31, 'App\\Models\\User', 5, 'auth_token', '92b7f1ff6c313a62a531c076612a44636d58c8d36401493f5c2238fdcdf18383', '[\"*\"]', NULL, NULL, '2026-05-22 00:20:18', '2026-05-22 00:20:18'),
(32, 'App\\Models\\User', 1, 'auth_token', 'bd7ee73233798e70e48faadcc8079cc79678a6ff34f3e3f35c1890a2a4139e98', '[\"*\"]', '2026-05-22 01:52:30', NULL, '2026-05-22 00:20:39', '2026-05-22 01:52:30'),
(33, 'App\\Models\\User', 5, 'auth_token', 'fa696e77f3ed03adeae17abcc00beb6fb4c0316c537607cf6e8ce2aa9c167e01', '[\"*\"]', '2026-05-22 00:53:58', NULL, '2026-05-22 00:45:43', '2026-05-22 00:53:58'),
(34, 'App\\Models\\User', 3, 'auth_token', '5d0ab5fa32e32f2ebe601440fecad735bdb91799054644079e93df1e9c94f9c5', '[\"*\"]', '2026-05-22 00:55:40', NULL, '2026-05-22 00:54:49', '2026-05-22 00:55:40'),
(35, 'App\\Models\\User', 5, 'auth_token', 'ffde0f1160f72d5a6cc63c8d79dba0b5512427ac36b054112dfef1bc2c26353f', '[\"*\"]', '2026-05-22 07:29:54', NULL, '2026-05-22 00:56:14', '2026-05-22 07:29:54'),
(36, 'App\\Models\\User', 6, 'auth_token', 'e30eb55a4fe72b28e285f637b12a0027bb29e15010b33daa311ea27962e1b575', '[\"*\"]', NULL, NULL, '2026-05-22 07:54:28', '2026-05-22 07:54:28'),
(37, 'App\\Models\\User', 7, 'auth_token', '4d58dff2a5dde22a44cf1965662bce4c673f57eb11ae7f1ea46cbdbd33521757', '[\"*\"]', '2026-05-22 08:00:55', NULL, '2026-05-22 07:58:44', '2026-05-22 08:00:55'),
(38, 'App\\Models\\User', 7, 'auth_token', '2b67bdc12d0b1f10a16868a1a59da515fbebd6fe19e6c3ef4ca65023cbf3db0c', '[\"*\"]', '2026-05-22 08:04:20', NULL, '2026-05-22 08:01:32', '2026-05-22 08:04:20'),
(39, 'App\\Models\\User', 7, 'auth_token', '18eb41d097be400d923e81ed031b33053aecc5d60e4681fd32c2ecfb0febf2e9', '[\"*\"]', '2026-05-22 08:11:29', NULL, '2026-05-22 08:05:23', '2026-05-22 08:11:29');

-- --------------------------------------------------------

--
-- Table structure for table `peserta_kelas_mk`
--

DROP TABLE IF EXISTS `peserta_kelas_mk`;
CREATE TABLE `peserta_kelas_mk` (
  `id_peserta_kelas_mk` int(11) NOT NULL,
  `id_kelas` varchar(20) NOT NULL,
  `id_mk` varchar(20) NOT NULL,
  `id_pegawai` int(11) NOT NULL,
  `no_urut` int(11) NOT NULL,
  `nim` varchar(20) NOT NULL,
  `nama` varchar(100) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `peserta_kelas_mk`
--

INSERT INTO `peserta_kelas_mk` (`id_peserta_kelas_mk`, `id_kelas`, `id_mk`, `id_pegawai`, `no_urut`, `nim`, `nama`, `created_at`, `updated_at`) VALUES
(1, '1', '1', 7, 1, 'C001', 'Budi', NULL, NULL),
(2, '1', '1', 7, 2, 'C002', 'Dessy', NULL, NULL),
(3, '1', '1', 7, 3, 'C003', 'Zaky', NULL, NULL),
(4, '1', '1', 7, 4, 'C005', 'Rahmat', NULL, NULL),
(5, '1', '1', 7, 5, 'C006', 'Halimah', NULL, NULL),
(6, '1', '2', 3, 1, 'C001', 'Budi', NULL, NULL),
(7, '1', '2', 3, 2, 'C002', 'Dessy', NULL, NULL),
(8, '1', '2', 3, 3, 'C003', 'Zaky', NULL, NULL),
(11, '1', '3', 2, 2, 'C001', 'Budi', NULL, NULL),
(12, '1', '3', 2, 3, 'C002', 'Dessy', NULL, NULL),
(16, '2', '1', 7, 2, 'C001', 'Budi', NULL, NULL),
(17, '2', '1', 7, 2, 'C002', 'Dessy', NULL, NULL),
(21, '2', '2', 3, 1, 'C001', 'Budi', NULL, NULL),
(22, '2', '2', 3, 2, 'C002', 'Dessy', NULL, NULL),
(26, '2', '3', 2, 2, 'C001', 'Budi', NULL, NULL),
(27, '2', '3', 2, 3, 'C002', 'Dessy', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `qr_sessions`
--

DROP TABLE IF EXISTS `qr_sessions`;
CREATE TABLE `qr_sessions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `KELAS_ID` varchar(255) NOT NULL,
  `KODE_PERTEMUAN` tinyint(3) UNSIGNED NOT NULL,
  `TOKEN` varchar(255) NOT NULL,
  `EXPIRED_AT` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
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

DROP TABLE IF EXISTS `roles`;
CREATE TABLE `roles` (
  `ID_ROLE` bigint(20) UNSIGNED NOT NULL,
  `NAMA_ROLE` varchar(255) NOT NULL
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

DROP TABLE IF EXISTS `sessions`;
CREATE TABLE `sessions` (
  `id` varchar(255) NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `payload` longtext NOT NULL,
  `last_activity` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `sessions`
--

INSERT INTO `sessions` (`id`, `user_id`, `ip_address`, `user_agent`, `payload`, `last_activity`) VALUES
('fJUXDCpRbdCK4Py3d5lH2HFG7zTAbahHcCjP58du', NULL, '192.168.18.5', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36 Edg/148.0.0.0', 'eyJfdG9rZW4iOiJtZDVON01OOHhOMXlFNXd0Vm1ySFpnSVBTSHdyMVpDQ1g1aDhadm44IiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cLzE5Mi4xNjguMTguNTo4MDAwIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1778586004),
('wBwm1MOyMCyGsMh9IQ4gXROpZ0jiy55jC4Iout0u', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36 Edg/148.0.0.0', 'eyJfdG9rZW4iOiJ3SVNSRGx1VHhTMEcyblQ3ZUhaT3NDelFTellnb3RLRGNIOWFsbnAzIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cLzEyNy4wLjAuMTo4MDAwIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1779431885),
('XwVPZgMvbZ50qVs7z006WzfSZo06Umm35jQVGkIe', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36 Edg/148.0.0.0', 'eyJfdG9rZW4iOiJ6OWtIcGlvWk5sNWcyNzlSUHhxYjk0NXFMenBZTjE1cDBJTGhoUmZmIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL2luc2VydGVkLWJhY2t1cC1oaXQtaGludC50cnljbG91ZGZsYXJlLmNvbSIsInJvdXRlIjpudWxsfSwiX2ZsYXNoIjp7Im9sZCI6W10sIm5ldyI6W119fQ==', 1779450295);

-- --------------------------------------------------------

--
-- Table structure for table `tugas_kelas`
--

DROP TABLE IF EXISTS `tugas_kelas`;
CREATE TABLE `tugas_kelas` (
  `id_tugas` int(11) NOT NULL,
  `id_dosen` int(11) NOT NULL,
  `id_kelas` varchar(20) NOT NULL,
  `id_mk` varchar(20) NOT NULL,
  `judul` varchar(150) NOT NULL,
  `deskripsi` text DEFAULT NULL,
  `deadline` datetime DEFAULT NULL,
  `file_path` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `tugas_kelas`
--

INSERT INTO `tugas_kelas` (`id_tugas`, `id_dosen`, `id_kelas`, `id_mk`, `judul`, `deskripsi`, `deadline`, `file_path`, `created_at`, `updated_at`) VALUES
(1, 40, 'TIK01', '', 'Tugas CRUD Laravel', 'Membuat CRUD menggunakan Service Layer.', '2026-05-30 23:59:59', 'tugas/ItFCKtselv0WnRVOWDLrRaBpfTxp7W1NfkS6CWOu.pdf', '2026-05-22 07:10:55', '2026-05-22 07:10:55'),
(2, 40, 'TIK02', '', 'Tugas CRUD Laravel', 'Membuat CRUD menggunakan Service Layer.', '2026-05-30 23:59:59', 'tugas/wiyIv3EeSBE7m9Rwpb3usonu1lJSYKgAkd2pUwdu.pdf', '2026-05-22 07:11:50', '2026-05-22 07:11:50'),
(3, 53, '1', '1', 'Tugas CRUD Laravel', 'Membuat CRUD menggunakan Service Layer.', '2026-05-30 23:59:59', 'tugas/XkWaSOmgL7WLvBDcWBH7WvuzTpj9GScLZLRV4W5w.pdf', '2026-05-22 08:10:57', '2026-05-22 08:10:57');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `role` varchar(255) NOT NULL DEFAULT 'dosen',
  `ID_ROLE` bigint(20) UNSIGNED DEFAULT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `remember_token` varchar(100) DEFAULT NULL,
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
(5, 'Febri', 'Febri@email.com', 'dosen', 2, NULL, '$2y$12$IP5saEL8a5RrGUZIQ8RauuUSsWBCF.W9OC21oIlCYMyds6yZ0wPka', NULL, '2026-05-03 05:18:41', '2026-05-03 05:18:41'),
(7, 'Riyan', 'Riyan@email.com', 'dosen', 2, NULL, '$2y$12$IP5saEL8a5RrGUZIQ8RauuUSsWBCF.W9OC21oIlCYMyds6yZ0wPka', NULL, '2026-05-22 15:52:13', '2026-05-22 15:52:18');

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
  ADD PRIMARY KEY (`id_absensi`),
  ADD KEY `fk_absensi_pegawai` (`id_pegawai`);

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
  ADD PRIMARY KEY (`id_dosen`);

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
  ADD PRIMARY KEY (`id_jabatan`);

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
-- Indexes for table `materi_kelas`
--
ALTER TABLE `materi_kelas`
  ADD PRIMARY KEY (`id_materi`);

--
-- Indexes for table `memiliki`
--
ALTER TABLE `memiliki`
  ADD PRIMARY KEY (`id_jabatan`,`nip`),
  ADD KEY `fk_memiliki_pegawai` (`nip`);

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
  ADD PRIMARY KEY (`id_pegawai`),
  ADD UNIQUE KEY `nip` (`nip`);

--
-- Indexes for table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  ADD KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`),
  ADD KEY `personal_access_tokens_expires_at_index` (`expires_at`);

--
-- Indexes for table `peserta_kelas_mk`
--
ALTER TABLE `peserta_kelas_mk`
  ADD PRIMARY KEY (`id_peserta_kelas_mk`);

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
-- Indexes for table `tugas_kelas`
--
ALTER TABLE `tugas_kelas`
  ADD PRIMARY KEY (`id_tugas`);

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
  MODIFY `ID_ABSENSI` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `absensi_pegawai`
--
ALTER TABLE `absensi_pegawai`
  MODIFY `id_absensi` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `dosen`
--
ALTER TABLE `dosen`
  MODIFY `id_dosen` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=54;

--
-- AUTO_INCREMENT for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `jadwal_kuliah`
--
ALTER TABLE `jadwal_kuliah`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `jobs`
--
ALTER TABLE `jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `kelas_sessions`
--
ALTER TABLE `kelas_sessions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `materi_kelas`
--
ALTER TABLE `materi_kelas`
  MODIFY `id_materi` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT for table `pegawai`
--
ALTER TABLE `pegawai`
  MODIFY `id_pegawai` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=53;

--
-- AUTO_INCREMENT for table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=40;

--
-- AUTO_INCREMENT for table `peserta_kelas_mk`
--
ALTER TABLE `peserta_kelas_mk`
  MODIFY `id_peserta_kelas_mk` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=28;

--
-- AUTO_INCREMENT for table `qr_sessions`
--
ALTER TABLE `qr_sessions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT for table `roles`
--
ALTER TABLE `roles`
  MODIFY `ID_ROLE` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `tugas_kelas`
--
ALTER TABLE `tugas_kelas`
  MODIFY `id_tugas` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `absensi_pegawai`
--
ALTER TABLE `absensi_pegawai`
  ADD CONSTRAINT `fk_absensi_pegawai` FOREIGN KEY (`id_pegawai`) REFERENCES `pegawai` (`id_pegawai`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `memiliki`
--
ALTER TABLE `memiliki`
  ADD CONSTRAINT `fk_memiliki_jabatan` FOREIGN KEY (`id_jabatan`) REFERENCES `jabatan` (`id_jabatan`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_memiliki_pegawai` FOREIGN KEY (`nip`) REFERENCES `pegawai` (`nip`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `users_id_role_foreign` FOREIGN KEY (`ID_ROLE`) REFERENCES `roles` (`ID_ROLE`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;