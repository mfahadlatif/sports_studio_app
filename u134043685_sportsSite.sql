-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Generation Time: Mar 04, 2026 at 06:37 PM
-- Server version: 11.8.3-MariaDB-log
-- PHP Version: 7.2.34
SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";
/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */
;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */
;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */
;
/*!40101 SET NAMES utf8mb4 */
;
--
-- Database: `u134043685_sportsSite`
--

-- --------------------------------------------------------
--
-- Table structure for table `bookings`
--

CREATE TABLE `bookings` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `customer_name` varchar(255) DEFAULT NULL,
  `customer_phone` varchar(255) DEFAULT NULL,
  `customer_email` varchar(255) DEFAULT NULL,
  `ground_id` bigint(20) UNSIGNED NOT NULL,
  `start_time` datetime NOT NULL,
  `end_time` datetime NOT NULL,
  `total_price` decimal(8, 2) NOT NULL,
  `players` int(11) NOT NULL DEFAULT 1,
  `status` varchar(255) NOT NULL DEFAULT 'pending',
  `rejection_reason` text DEFAULT NULL,
  `payment_status` varchar(255) NOT NULL DEFAULT 'pending',
  `payment_expires_at` timestamp NULL DEFAULT NULL,
  `payment_method` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
--
-- Dumping data for table `bookings`
--

INSERT INTO `bookings` (
    `id`,
    `user_id`,
    `customer_name`,
    `customer_phone`,
    `customer_email`,
    `ground_id`,
    `start_time`,
    `end_time`,
    `total_price`,
    `players`,
    `status`,
    `rejection_reason`,
    `payment_status`,
    `payment_expires_at`,
    `payment_method`,
    `created_at`,
    `updated_at`
  )
VALUES (
    22,
    27,
    NULL,
    NULL,
    NULL,
    7,
    '2026-03-06 15:00:00',
    '2026-03-06 18:00:00',
    2999.00,
    20,
    'cancelled',
    NULL,
    'unpaid',
    '2026-03-04 04:22:41',
    'cash',
    '2026-03-04 04:02:41',
    '2026-03-04 04:17:17'
  ),
  (
    23,
    27,
    NULL,
    NULL,
    NULL,
    7,
    '2026-03-06 19:00:00',
    '2026-03-06 21:00:00',
    2000.00,
    12,
    'cancelled',
    NULL,
    'refunded',
    '2026-03-04 04:38:14',
    'cash',
    '2026-03-04 04:18:14',
    '2026-03-04 04:50:10'
  ),
  (
    24,
    27,
    NULL,
    NULL,
    NULL,
    7,
    '2026-03-06 19:00:00',
    '2026-03-06 21:00:00',
    2000.00,
    12,
    'cancelled',
    NULL,
    'refunded',
    '2026-03-04 04:39:21',
    'cash',
    '2026-03-04 04:19:21',
    '2026-03-04 04:50:01'
  ),
  (
    25,
    27,
    NULL,
    NULL,
    NULL,
    7,
    '2026-03-07 18:00:00',
    '2026-03-07 20:00:00',
    2000.00,
    8,
    'cancelled',
    NULL,
    'refunded',
    '2026-03-04 04:49:25',
    'cash',
    '2026-03-04 04:29:25',
    '2026-03-04 04:49:57'
  ),
  (
    26,
    27,
    NULL,
    NULL,
    NULL,
    7,
    '2026-03-07 10:00:00',
    '2026-03-07 11:00:00',
    1001.00,
    2,
    'cancelled',
    NULL,
    'refunded',
    '2026-03-04 05:03:13',
    'cash',
    '2026-03-04 04:43:13',
    '2026-03-04 04:49:52'
  ),
  (
    27,
    27,
    NULL,
    NULL,
    NULL,
    7,
    '2026-03-04 10:00:00',
    '2026-03-04 12:00:00',
    2000.00,
    2,
    'cancelled',
    NULL,
    'unpaid',
    '2026-03-04 05:11:07',
    'cash',
    '2026-03-04 04:51:07',
    '2026-03-04 04:56:24'
  ),
  (
    28,
    27,
    NULL,
    NULL,
    NULL,
    7,
    '2026-03-04 10:00:00',
    '2026-03-04 13:00:00',
    2999.00,
    2,
    'cancelled',
    NULL,
    'unpaid',
    '2026-03-04 05:17:05',
    'cash',
    '2026-03-04 04:57:05',
    '2026-03-04 05:49:26'
  ),
  (
    29,
    27,
    NULL,
    NULL,
    NULL,
    7,
    '2026-03-04 10:00:00',
    '2026-03-04 13:00:00',
    2999.00,
    2,
    'cancelled',
    NULL,
    'unpaid',
    '2026-03-04 05:17:08',
    'cash',
    '2026-03-04 04:57:08',
    '2026-03-04 05:49:26'
  ),
  (
    30,
    27,
    NULL,
    NULL,
    NULL,
    7,
    '2026-03-05 10:00:00',
    '2026-03-05 13:00:00',
    2999.00,
    2,
    'cancelled',
    NULL,
    'unpaid',
    '2026-03-04 05:24:02',
    'cash',
    '2026-03-04 05:04:02',
    '2026-03-04 05:49:26'
  ),
  (
    31,
    27,
    NULL,
    NULL,
    NULL,
    7,
    '2026-03-04 11:00:00',
    '2026-03-04 13:00:00',
    2000.00,
    2,
    'cancelled',
    NULL,
    'unpaid',
    '2026-03-04 05:33:24',
    'cash',
    '2026-03-04 05:13:24',
    '2026-03-04 05:49:26'
  ),
  (
    32,
    27,
    NULL,
    NULL,
    NULL,
    7,
    '2026-03-04 19:00:00',
    '2026-03-04 21:00:00',
    2000.00,
    2,
    'cancelled',
    NULL,
    'unpaid',
    '2026-03-04 05:44:47',
    'cash',
    '2026-03-04 05:24:47',
    '2026-03-04 05:49:26'
  ),
  (
    33,
    27,
    NULL,
    NULL,
    NULL,
    7,
    '2026-03-04 11:00:00',
    '2026-03-04 13:00:00',
    2000.00,
    2,
    'cancelled',
    NULL,
    'unpaid',
    '2026-03-04 06:10:01',
    'cash',
    '2026-03-04 05:50:01',
    '2026-03-04 06:14:23'
  ),
  (
    34,
    27,
    NULL,
    NULL,
    NULL,
    7,
    '2026-03-04 12:00:00',
    '2026-03-04 14:00:00',
    2000.00,
    2,
    'cancelled',
    NULL,
    'unpaid',
    '2026-03-04 06:34:42',
    'cash',
    '2026-03-04 06:14:42',
    '2026-03-04 06:40:15'
  ),
  (
    35,
    27,
    NULL,
    NULL,
    NULL,
    7,
    '2026-03-04 12:00:00',
    '2026-03-04 14:00:00',
    2000.00,
    2,
    'cancelled',
    NULL,
    'unpaid',
    '2026-03-04 06:57:39',
    'cash',
    '2026-03-04 06:37:39',
    '2026-03-04 06:59:29'
  ),
  (
    36,
    27,
    NULL,
    NULL,
    NULL,
    7,
    '2026-03-04 12:00:00',
    '2026-03-04 14:00:00',
    2000.00,
    2,
    'cancelled',
    NULL,
    'unpaid',
    '2026-03-04 07:19:59',
    'cash',
    '2026-03-04 06:59:59',
    '2026-03-04 07:25:03'
  ),
  (
    37,
    27,
    NULL,
    NULL,
    NULL,
    7,
    '2026-03-04 13:00:00',
    '2026-03-04 15:00:00',
    2000.00,
    2,
    'cancelled',
    NULL,
    'unpaid',
    '2026-03-04 07:58:06',
    'cash',
    '2026-03-04 07:38:06',
    '2026-03-04 08:56:28'
  ),
  (
    38,
    27,
    NULL,
    NULL,
    NULL,
    7,
    '2026-03-04 13:00:00',
    '2026-03-04 15:00:00',
    2000.00,
    2,
    'cancelled',
    NULL,
    'unpaid',
    '2026-03-04 08:18:24',
    'cash',
    '2026-03-04 07:58:24',
    '2026-03-04 08:56:28'
  ),
  (
    39,
    27,
    NULL,
    NULL,
    NULL,
    7,
    '2026-03-04 13:00:00',
    '2026-03-04 15:00:00',
    2000.00,
    2,
    'cancelled',
    NULL,
    'unpaid',
    '2026-03-04 08:18:28',
    'cash',
    '2026-03-04 07:58:28',
    '2026-03-04 08:56:28'
  ),
  (
    40,
    27,
    NULL,
    NULL,
    NULL,
    7,
    '2026-03-04 14:00:00',
    '2026-03-04 16:00:00',
    2000.00,
    2,
    'cancelled',
    NULL,
    'unpaid',
    '2026-03-04 08:38:49',
    'cash',
    '2026-03-04 08:18:49',
    '2026-03-04 08:56:28'
  ),
  (
    41,
    27,
    NULL,
    NULL,
    NULL,
    7,
    '2026-03-04 14:00:00',
    '2026-03-04 16:00:00',
    2000.00,
    2,
    'cancelled',
    NULL,
    'unpaid',
    '2026-03-04 09:16:57',
    'cash',
    '2026-03-04 08:56:58',
    '2026-03-04 09:22:23'
  ),
  (
    42,
    27,
    NULL,
    NULL,
    NULL,
    7,
    '2026-03-04 15:00:00',
    '2026-03-04 17:00:00',
    2000.00,
    2,
    'cancelled',
    NULL,
    'unpaid',
    '2026-03-04 09:52:30',
    'cash',
    '2026-03-04 09:32:30',
    '2026-03-04 10:11:23'
  );
-- --------------------------------------------------------
--
-- Table structure for table `cache`
--

CREATE TABLE `cache` (
  `key` varchar(255) NOT NULL,
  `value` mediumtext NOT NULL,
  `expiration` int(11) NOT NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
--
-- Dumping data for table `cache`
--

INSERT INTO `cache` (`key`, `value`, `expiration`)
VALUES (
    'laravel-cache-424f74a6a7ed4d4ed4761507ebcd209a6ef0937b',
    'i:2;',
    1770723564
  ),
  (
    'laravel-cache-424f74a6a7ed4d4ed4761507ebcd209a6ef0937b:timer',
    'i:1770723563;',
    1770723563
  ),
  (
    'laravel-cache-ac3478d69a3c81fa62e60f5c3696165a4e5e6ac4',
    'i:2;',
    1770724028
  ),
  (
    'laravel-cache-ac3478d69a3c81fa62e60f5c3696165a4e5e6ac4:timer',
    'i:1770724028;',
    1770724028
  ),
  (
    'sports-studio-cache-0ade7c2cf97f75d009975f4d720d1fa6c19f4897',
    'i:2;',
    1772617090
  ),
  (
    'sports-studio-cache-0ade7c2cf97f75d009975f4d720d1fa6c19f4897:timer',
    'i:1772617090;',
    1772617090
  ),
  (
    'sports-studio-cache-34d877cbf31de6c8b3e6e97d76512cd76eae6a23',
    'i:1;',
    1772618088
  ),
  (
    'sports-studio-cache-34d877cbf31de6c8b3e6e97d76512cd76eae6a23:timer',
    'i:1772618088;',
    1772618088
  ),
  (
    'sports-studio-cache-4a0d039fb73fce8b505895401796c0572b992d45',
    'i:3;',
    1772631409
  ),
  (
    'sports-studio-cache-4a0d039fb73fce8b505895401796c0572b992d45:timer',
    'i:1772631409;',
    1772631409
  ),
  (
    'sports-studio-cache-83a82b16c84cdb31fd8266f64d56193a7aa29968',
    'i:1;',
    1772648581
  ),
  (
    'sports-studio-cache-83a82b16c84cdb31fd8266f64d56193a7aa29968:timer',
    'i:1772648581;',
    1772648581
  ),
  (
    'sports-studio-cache-887309d048beef83ad3eabf2a79a64a389ab1c9f',
    'i:3;',
    1772616466
  ),
  (
    'sports-studio-cache-887309d048beef83ad3eabf2a79a64a389ab1c9f:timer',
    'i:1772616466;',
    1772616466
  ),
  (
    'sports-studio-cache-bc33ea4e26e5e1af1408321416956113a4658763',
    'i:8;',
    1772649414
  ),
  (
    'sports-studio-cache-bc33ea4e26e5e1af1408321416956113a4658763:timer',
    'i:1772649414;',
    1772649414
  ),
  (
    'sports-studio-cache-be1c8625ffbdd93ac15c39acb081a69e000a0520',
    'i:1;',
    1772613171
  ),
  (
    'sports-studio-cache-be1c8625ffbdd93ac15c39acb081a69e000a0520:timer',
    'i:1772613171;',
    1772613171
  ),
  (
    'sports-studio-cache-ca7a9fda3771c46e991c895d8fbdd628037b06ae',
    'i:2;',
    1772649027
  ),
  (
    'sports-studio-cache-ca7a9fda3771c46e991c895d8fbdd628037b06ae:timer',
    'i:1772649027;',
    1772649027
  ),
  (
    'sports-studio-cache-d435a6cdd786300dff204ee7c2ef942d3e9034e2',
    'i:3;',
    1772631529
  ),
  (
    'sports-studio-cache-d435a6cdd786300dff204ee7c2ef942d3e9034e2:timer',
    'i:1772631529;',
    1772631529
  ),
  (
    'sports-studio-cache-f6e1126cedebf23e1463aee73f9df08783640400',
    'i:6;',
    1772649410
  ),
  (
    'sports-studio-cache-f6e1126cedebf23e1463aee73f9df08783640400:timer',
    'i:1772649410;',
    1772649410
  ),
  (
    'sports-studio-cache-otp_+923088960983',
    'i:564973;',
    1772632079
  ),
  (
    'sports-studio-cache-otp_3421316906',
    'i:135575;',
    1772635709
  ),
  (
    'sportspot-cache-0716d9708d321ffb6a00818614779e779925365c',
    'i:2;',
    1772281028
  ),
  (
    'sportspot-cache-0716d9708d321ffb6a00818614779e779925365c:timer',
    'i:1772281028;',
    1772281028
  ),
  (
    'sportspot-cache-0ade7c2cf97f75d009975f4d720d1fa6c19f4897',
    'i:4;',
    1772531505
  ),
  (
    'sportspot-cache-0ade7c2cf97f75d009975f4d720d1fa6c19f4897:timer',
    'i:1772531505;',
    1772531505
  ),
  (
    'sportspot-cache-0c762b9e5511e5ab7e6f08f01ef21d8c7dcd3800',
    'i:2;',
    1771435654
  ),
  (
    'sportspot-cache-0c762b9e5511e5ab7e6f08f01ef21d8c7dcd3800:timer',
    'i:1771435654;',
    1771435654
  ),
  (
    'sportspot-cache-12c6fc06c99a462375eeb3f43dfd832b08ca9e17',
    'i:9;',
    1772283225
  ),
  (
    'sportspot-cache-12c6fc06c99a462375eeb3f43dfd832b08ca9e17:timer',
    'i:1772283225;',
    1772283225
  ),
  (
    'sportspot-cache-1574bddb75c78a6fd2251d61e2993b5146201319',
    'i:7;',
    1772207674
  ),
  (
    'sportspot-cache-1574bddb75c78a6fd2251d61e2993b5146201319:timer',
    'i:1772207674;',
    1772207674
  ),
  (
    'sportspot-cache-17ba0791499db908433b80f37c5fbc89b870084b',
    'i:4;',
    1771730254
  ),
  (
    'sportspot-cache-17ba0791499db908433b80f37c5fbc89b870084b:timer',
    'i:1771730254;',
    1771730254
  ),
  (
    'sportspot-cache-1fbf9a1af692cac325bccf821f5b7fd0d7805827',
    'i:1;',
    1771648709
  ),
  (
    'sportspot-cache-1fbf9a1af692cac325bccf821f5b7fd0d7805827:timer',
    'i:1771648709;',
    1771648709
  ),
  (
    'sportspot-cache-200061ea8852a3bea5af7feae50ef41bc22212d4',
    'i:1;',
    1771519163
  ),
  (
    'sportspot-cache-200061ea8852a3bea5af7feae50ef41bc22212d4:timer',
    'i:1771519163;',
    1771519163
  ),
  (
    'sportspot-cache-2cf4be5f10196929d9224cc3c248f37c57a8fda1',
    'i:1;',
    1772123379
  ),
  (
    'sportspot-cache-2cf4be5f10196929d9224cc3c248f37c57a8fda1:timer',
    'i:1772123379;',
    1772123379
  ),
  (
    'sportspot-cache-424f74a6a7ed4d4ed4761507ebcd209a6ef0937b',
    'i:2;',
    1770811311
  ),
  (
    'sportspot-cache-424f74a6a7ed4d4ed4761507ebcd209a6ef0937b:timer',
    'i:1770811311;',
    1770811311
  ),
  (
    'sportspot-cache-472b07b9fcf2c2451e8781e944bf5f77cd8457c8',
    'i:6;',
    1772237244
  ),
  (
    'sportspot-cache-472b07b9fcf2c2451e8781e944bf5f77cd8457c8:timer',
    'i:1772237244;',
    1772237244
  ),
  (
    'sportspot-cache-4a0d039fb73fce8b505895401796c0572b992d45',
    'i:3;',
    1772429946
  ),
  (
    'sportspot-cache-4a0d039fb73fce8b505895401796c0572b992d45:timer',
    'i:1772429946;',
    1772429946
  ),
  (
    'sportspot-cache-4af45190aa56b9467201d51f803174b25857c74b',
    'i:1;',
    1772207989
  ),
  (
    'sportspot-cache-4af45190aa56b9467201d51f803174b25857c74b:timer',
    'i:1772207989;',
    1772207989
  ),
  (
    'sportspot-cache-4b2b5bf2bda7c44313c3da8270c69fc7d7202981',
    'i:4;',
    1771326103
  ),
  (
    'sportspot-cache-4b2b5bf2bda7c44313c3da8270c69fc7d7202981:timer',
    'i:1771326103;',
    1771326103
  ),
  (
    'sportspot-cache-4d134bc072212ace2df385dae143139da74ec0ef',
    'i:3;',
    1772531753
  ),
  (
    'sportspot-cache-4d134bc072212ace2df385dae143139da74ec0ef:timer',
    'i:1772531753;',
    1772531753
  ),
  (
    'sportspot-cache-7b52009b64fd0a2a49e6d8a939753077792b0554',
    'i:1;',
    1772046656
  ),
  (
    'sportspot-cache-7b52009b64fd0a2a49e6d8a939753077792b0554:timer',
    'i:1772046656;',
    1772046656
  ),
  (
    'sportspot-cache-83a82b16c84cdb31fd8266f64d56193a7aa29968',
    'i:2;',
    1772531721
  ),
  (
    'sportspot-cache-83a82b16c84cdb31fd8266f64d56193a7aa29968:timer',
    'i:1772531721;',
    1772531721
  ),
  (
    'sportspot-cache-887309d048beef83ad3eabf2a79a64a389ab1c9f',
    'i:20;',
    1772597261
  ),
  (
    'sportspot-cache-887309d048beef83ad3eabf2a79a64a389ab1c9f:timer',
    'i:1772597261;',
    1772597261
  ),
  (
    'sportspot-cache-8be0f8294a2d5efb2972be5512b4eb28721e70c4',
    'i:1;',
    1772212271
  ),
  (
    'sportspot-cache-8be0f8294a2d5efb2972be5512b4eb28721e70c4:timer',
    'i:1772212271;',
    1772212271
  ),
  (
    'sportspot-cache-8be6ab4c79c6241fb58c60a059c388df5a1d6ca0',
    'i:1;',
    1771764924
  ),
  (
    'sportspot-cache-8be6ab4c79c6241fb58c60a059c388df5a1d6ca0:timer',
    'i:1771764924;',
    1771764924
  ),
  (
    'sportspot-cache-902ba3cda1883801594b6e1b452790cc53948fda',
    'i:19;',
    1770799366
  ),
  (
    'sportspot-cache-902ba3cda1883801594b6e1b452790cc53948fda:timer',
    'i:1770799366;',
    1770799366
  ),
  (
    'sportspot-cache-91032ad7bbcb6cf72875e8e8207dcfba80173f7c',
    'i:5;',
    1771867446
  ),
  (
    'sportspot-cache-91032ad7bbcb6cf72875e8e8207dcfba80173f7c:timer',
    'i:1771867446;',
    1771867446
  ),
  (
    'sportspot-cache-9e2d5dae31ac588876060734ac0b172017d9a67d',
    'i:1;',
    1772139203
  ),
  (
    'sportspot-cache-9e2d5dae31ac588876060734ac0b172017d9a67d:timer',
    'i:1772139203;',
    1772139203
  ),
  (
    'sportspot-cache-9e6a55b6b4563e652a23be9d623ca5055c356940',
    'i:2;',
    1771767368
  ),
  (
    'sportspot-cache-9e6a55b6b4563e652a23be9d623ca5055c356940:timer',
    'i:1771767368;',
    1771767368
  ),
  (
    'sportspot-cache-ac3478d69a3c81fa62e60f5c3696165a4e5e6ac4',
    'i:1;',
    1772348365
  ),
  (
    'sportspot-cache-ac3478d69a3c81fa62e60f5c3696165a4e5e6ac4:timer',
    'i:1772348365;',
    1772348365
  ),
  (
    'sportspot-cache-ada27b57f3f3093c79f271b915c3f355068a86af',
    'i:1;',
    1772207080
  ),
  (
    'sportspot-cache-ada27b57f3f3093c79f271b915c3f355068a86af:timer',
    'i:1772207080;',
    1772207080
  ),
  (
    'sportspot-cache-b1d5781111d84f7b3fe45a0852e59758cd7a87e5',
    'i:1;',
    1771729982
  ),
  (
    'sportspot-cache-b1d5781111d84f7b3fe45a0852e59758cd7a87e5:timer',
    'i:1771729982;',
    1771729982
  ),
  (
    'sportspot-cache-b3f0c7f6bb763af1be91d9e74eabfeb199dc1f1f',
    'i:1;',
    1771897752
  ),
  (
    'sportspot-cache-b3f0c7f6bb763af1be91d9e74eabfeb199dc1f1f:timer',
    'i:1771897752;',
    1771897752
  ),
  (
    'sportspot-cache-bc33ea4e26e5e1af1408321416956113a4658763',
    'i:2;',
    1772597654
  ),
  (
    'sportspot-cache-bc33ea4e26e5e1af1408321416956113a4658763:timer',
    'i:1772597654;',
    1772597654
  ),
  (
    'sportspot-cache-bf158b49f5818e0a48bf8b8addd42bc651185d27',
    'i:1;',
    1771324764
  ),
  (
    'sportspot-cache-bf158b49f5818e0a48bf8b8addd42bc651185d27:timer',
    'i:1771324764;',
    1771324764
  ),
  (
    'sportspot-cache-c1dfd96eea8cc2b62785275bca38ac261256e278',
    'i:7;',
    1770798946
  ),
  (
    'sportspot-cache-c1dfd96eea8cc2b62785275bca38ac261256e278:timer',
    'i:1770798946;',
    1770798946
  ),
  (
    'sportspot-cache-c843361c38e14124738fafdb179131b432eca4ae',
    'i:1;',
    1772001465
  ),
  (
    'sportspot-cache-c843361c38e14124738fafdb179131b432eca4ae:timer',
    'i:1772001465;',
    1772001465
  ),
  (
    'sportspot-cache-ca7a9fda3771c46e991c895d8fbdd628037b06ae',
    'i:1;',
    1772597268
  ),
  (
    'sportspot-cache-ca7a9fda3771c46e991c895d8fbdd628037b06ae:timer',
    'i:1772597268;',
    1772597268
  ),
  (
    'sportspot-cache-d435a6cdd786300dff204ee7c2ef942d3e9034e2',
    'i:3;',
    1772430012
  ),
  (
    'sportspot-cache-d435a6cdd786300dff204ee7c2ef942d3e9034e2:timer',
    'i:1772430012;',
    1772430012
  ),
  (
    'sportspot-cache-e94882e1182670dbfa76526c0c8867f0c27cd65c',
    'i:1;',
    1772290885
  ),
  (
    'sportspot-cache-e94882e1182670dbfa76526c0c8867f0c27cd65c:timer',
    'i:1772290885;',
    1772290885
  ),
  (
    'sportspot-cache-f6e1126cedebf23e1463aee73f9df08783640400',
    'i:23;',
    1772596671
  ),
  (
    'sportspot-cache-f6e1126cedebf23e1463aee73f9df08783640400:timer',
    'i:1772596671;',
    1772596671
  ),
  (
    'sportspot-cache-fa35e192121eabf3dabf9f5ea6abdbcbc107ac3b',
    'i:1;',
    1771657759
  ),
  (
    'sportspot-cache-fa35e192121eabf3dabf9f5ea6abdbcbc107ac3b:timer',
    'i:1771657759;',
    1771657759
  ),
  (
    'sportspot-cache-fe5dbbcea5ce7e2988b8c69bcfdfde8904aabc1f',
    'i:6;',
    1770811310
  ),
  (
    'sportspot-cache-fe5dbbcea5ce7e2988b8c69bcfdfde8904aabc1f:timer',
    'i:1770811310;',
    1770811310
  ),
  (
    'sportspot-cache-otp_+923088960983',
    'i:720628;',
    1772430596
  ),
  (
    'sportspot-cache-otp_03088960983',
    'i:974183;',
    1772430552
  ),
  (
    'sportspot-cache-otp_3154187',
    'i:310956;',
    1772530935
  ),
  (
    'sportspot-cache-otp_3154187244',
    'i:533936;',
    1772530949
  );
-- --------------------------------------------------------
--
-- Table structure for table `cache_locks`
--

CREATE TABLE `cache_locks` (
  `key` varchar(255) NOT NULL,
  `owner` varchar(255) NOT NULL,
  `expiration` int(11) NOT NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- --------------------------------------------------------
--
-- Table structure for table `complexes`
--

CREATE TABLE `complexes` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `owner_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `slug` varchar(255) DEFAULT NULL,
  `address` text NOT NULL,
  `latitude` decimal(10, 8) DEFAULT NULL,
  `longitude` decimal(11, 8) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `rating` decimal(3, 2) NOT NULL DEFAULT 0.00,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `images` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`images`)),
  `amenities` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`amenities`)),
  `status` varchar(255) NOT NULL DEFAULT 'active'
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
--
-- Dumping data for table `complexes`
--

INSERT INTO `complexes` (
    `id`,
    `owner_id`,
    `name`,
    `slug`,
    `address`,
    `latitude`,
    `longitude`,
    `description`,
    `rating`,
    `created_at`,
    `updated_at`,
    `images`,
    `amenities`,
    `status`
  )
VALUES (
    11,
    26,
    'Test',
    'test-ZXVE2',
    'Lahore, Lahore City Tehsil, Lahore District, Lahore Division, Punjab, 54500, Pakistan',
    31.56568220,
    74.31418290,
    'dsc',
    0.00,
    '2026-03-04 03:58:55',
    '2026-03-04 03:58:55',
    '[\"uploads\\/media\\/1772596731_screenshot-0302-183804.png\"]',
    '[\"parking\",\"washrooms\",\"cafe\",\"equipment\"]',
    'active'
  );
-- --------------------------------------------------------
--
-- Table structure for table `deals`
--

CREATE TABLE `deals` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `code` varchar(255) DEFAULT NULL,
  `discount_percentage` decimal(5, 2) NOT NULL,
  `valid_until` datetime NOT NULL,
  `applicable_sports` varchar(255) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `color_theme` varchar(255) NOT NULL DEFAULT 'from-primary to-primary/80',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `owner_id` bigint(20) UNSIGNED DEFAULT NULL,
  `ground_id` bigint(20) UNSIGNED DEFAULT NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- --------------------------------------------------------
--
-- Table structure for table `events`
--

CREATE TABLE `events` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `organizer_id` bigint(20) UNSIGNED NOT NULL,
  `booking_id` bigint(20) UNSIGNED DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `slug` varchar(255) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `start_time` datetime NOT NULL,
  `end_time` datetime NOT NULL,
  `registration_fee` decimal(8, 2) NOT NULL DEFAULT 0.00,
  `max_participants` int(11) DEFAULT NULL,
  `status` varchar(255) NOT NULL DEFAULT 'upcoming',
  `event_type` varchar(255) NOT NULL DEFAULT 'public',
  `is_vip` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `image` varchar(255) DEFAULT NULL,
  `images` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`images`)),
  `location` varchar(255) DEFAULT NULL,
  `latitude` decimal(10, 8) DEFAULT NULL,
  `longitude` decimal(11, 8) DEFAULT NULL,
  `rules` text DEFAULT NULL,
  `safety_policy` text DEFAULT NULL,
  `schedule` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`schedule`))
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- --------------------------------------------------------
--
-- Table structure for table `event_participants`
--

CREATE TABLE `event_participants` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `event_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `is_manual` tinyint(1) NOT NULL DEFAULT 0,
  `status` varchar(255) NOT NULL DEFAULT 'pending',
  `payment_expires_at` timestamp NULL DEFAULT NULL,
  `payment_status` varchar(255) NOT NULL DEFAULT 'unpaid',
  `payment_method` varchar(255) DEFAULT NULL,
  `rejection_reason` text DEFAULT NULL,
  `message` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- --------------------------------------------------------
--
-- Table structure for table `failed_jobs`
--

CREATE TABLE `failed_jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `uuid` varchar(255) NOT NULL,
  `connection` text NOT NULL,
  `queue` text NOT NULL,
  `payload` longtext NOT NULL,
  `exception` longtext NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- --------------------------------------------------------
--
-- Table structure for table `favorites`
--

CREATE TABLE `favorites` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `ground_id` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- --------------------------------------------------------
--
-- Table structure for table `grounds`
--

CREATE TABLE `grounds` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `complex_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `slug` varchar(255) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `price_per_hour` decimal(8, 2) NOT NULL,
  `opening_time` time NOT NULL DEFAULT '08:00:00',
  `closing_time` time NOT NULL DEFAULT '22:00:00',
  `dimensions` varchar(255) DEFAULT NULL,
  `type` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `images` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`images`)),
  `amenities` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`amenities`)),
  `lighting` tinyint(1) NOT NULL DEFAULT 1,
  `status` varchar(255) NOT NULL DEFAULT 'active'
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
--
-- Dumping data for table `grounds`
--

INSERT INTO `grounds` (
    `id`,
    `complex_id`,
    `name`,
    `slug`,
    `description`,
    `price_per_hour`,
    `opening_time`,
    `closing_time`,
    `dimensions`,
    `type`,
    `created_at`,
    `updated_at`,
    `images`,
    `amenities`,
    `lighting`,
    `status`
  )
VALUES (
    7,
    11,
    'Cricket',
    'cricket-g79nD',
    'test',
    999.00,
    '08:00:00',
    '22:00:00',
    '100x40 ft',
    'hockey',
    '2026-03-04 04:00:01',
    '2026-03-04 04:00:01',
    '[\"https:\\/\\/sportstudio.squarenex.com\\/backend\\/public\\/uploads\\/media\\/1772596796_gemini-generated-image-j8mfifj8mfifj8mf-1-removebg-preview-fotor-20260226132126.png\",\"https:\\/\\/sportstudio.squarenex.com\\/backend\\/public\\/uploads\\/media\\/1772596797_screenshot-0302-184002.png\",\"https:\\/\\/sportstudio.squarenex.com\\/backend\\/public\\/uploads\\/media\\/1772596797_gemini-generated-image-q4alvaq4alvaq4al.png\"]',
    '[\"parking\",\"lighting\",\"lockers\",\"equipment\"]',
    1,
    'active'
  );
-- --------------------------------------------------------
--
-- Table structure for table `jobs`
--

CREATE TABLE `jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `queue` varchar(255) NOT NULL,
  `payload` longtext NOT NULL,
  `attempts` tinyint(3) UNSIGNED NOT NULL,
  `reserved_at` int(10) UNSIGNED DEFAULT NULL,
  `available_at` int(10) UNSIGNED NOT NULL,
  `created_at` int(10) UNSIGNED NOT NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- --------------------------------------------------------
--
-- Table structure for table `job_batches`
--

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
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- --------------------------------------------------------
--
-- Table structure for table `media`
--

CREATE TABLE `media` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `model_type` varchar(255) NOT NULL,
  `model_id` bigint(20) UNSIGNED NOT NULL,
  `file_path` varchar(255) NOT NULL,
  `file_type` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- --------------------------------------------------------
--
-- Table structure for table `migrations`
--

CREATE TABLE `migrations` (
  `id` int(10) UNSIGNED NOT NULL,
  `migration` varchar(255) NOT NULL,
  `batch` int(11) NOT NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
--
-- Dumping data for table `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`)
VALUES (16, '2026_01_27_085522_create_deals_table', 1),
  (17, '2026_01_27_100221_add_images_to_tables', 1),
  (
    18,
    '2026_01_28_063424_add_slug_to_grounds_table',
    1
  ),
  (
    19,
    '2026_01_28_071839_add_extra_fields_to_grounds_and_events_tables',
    1
  ),
  (
    20,
    '2026_01_28_112158_add_players_to_bookings_table',
    1
  ),
  (
    21,
    '2026_01_28_114710_create_notifications_table',
    1
  ),
  (
    22,
    '2026_02_03_143000_add_details_to_complexes_table',
    1
  ),
  (
    23,
    '2026_02_04_114430_create_favorites_table',
    1
  ),
  (
    24,
    '2026_02_06_031153_add_images_to_events_table',
    1
  ),
  (
    25,
    '2026_02_06_033250_create_event_participants_table',
    1
  ),
  (
    26,
    '2026_02_06_093202_add_lat_lng_to_complexes_and_events',
    1
  ),
  (
    27,
    '2026_02_06_095531_add_google_id_to_users_table',
    1
  ),
  (
    28,
    '2026_02_06_100812_add_rejection_reason_to_bookings_table',
    1
  ),
  (
    29,
    '2026_02_06_101201_add_rejection_reason_to_event_participants_table',
    1
  ),
  (
    30,
    '2026_02_06_102043_add_payment_method_to_bookings_and_participants',
    1
  ),
  (
    31,
    '2026_02_06_105117_add_slug_to_complexes_table',
    1
  ),
  (32, '2026_02_06_112926_create_reviews_table', 1),
  (
    33,
    '2026_02_06_130330_add_operating_hours_to_grounds_table',
    1
  ),
  (
    34,
    '2026_02_06_185000_add_payment_status_to_event_participants',
    1
  ),
  (
    35,
    '2026_02_09_052341_add_fcm_token_to_users_table',
    1
  ),
  (
    36,
    '2026_02_09_120020_add_phone_verified_at_to_users_table',
    1
  ),
  (
    37,
    '2026_02_09_132105_add_event_type_to_events_table',
    1
  ),
  (
    38,
    '2026_02_10_091653_add_payment_expires_at_to_bookings_and_participants_table',
    2
  ),
  (39, '2026_02_10_121643_create_teams_table', 2),
  (
    40,
    '2026_02_10_121644_create_team_members_table',
    2
  ),
  (
    41,
    '2026_02_10_135713_make_user_id_nullable_on_bookings_table',
    3
  ),
  (
    42,
    '2026_02_11_094001_add_customer_email_to_bookings_table',
    4
  ),
  (
    43,
    '2026_02_11_105635_add_status_to_grounds_table',
    5
  ),
  (
    44,
    '2026_02_11_115311_add_owner_and_ground_to_deals_table',
    6
  );
-- --------------------------------------------------------
--
-- Table structure for table `notifications`
--

CREATE TABLE `notifications` (
  `id` char(36) NOT NULL,
  `type` varchar(255) NOT NULL,
  `notifiable_type` varchar(255) NOT NULL,
  `notifiable_id` bigint(20) UNSIGNED NOT NULL,
  `data` text NOT NULL,
  `read_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
--
-- Dumping data for table `notifications`
--

INSERT INTO `notifications` (
    `id`,
    `type`,
    `notifiable_type`,
    `notifiable_id`,
    `data`,
    `read_at`,
    `created_at`,
    `updated_at`
  )
VALUES (
    '049a2fb4-37ce-4d1b-be74-96b9c8ecf99a',
    'App\\Notifications\\BookingStatusNotification',
    'App\\Models\\User',
    27,
    '{\"booking_id\":23,\"title\":\"Booking Status Updated\",\"message\":\"Your booking status for Cricket has been updated to cancelled\",\"type\":\"booking\",\"icon\":\"Calendar\",\"link\":\"\\/my-bookings\"}',
    NULL,
    '2026-03-04 04:50:10',
    '2026-03-04 04:50:10'
  ),
  (
    '04d1c283-b89b-4bb2-b90e-0de183c50710',
    'App\\Notifications\\BookingStatusNotification',
    'App\\Models\\User',
    27,
    '{\"booking_id\":29,\"title\":\"Booking Created\",\"message\":\"Your booking for Cricket has been created.\",\"type\":\"booking\",\"icon\":\"Calendar\",\"link\":\"\\/my-bookings\"}',
    NULL,
    '2026-03-04 04:57:08',
    '2026-03-04 04:57:08'
  ),
  (
    '08ec5300-fe9c-417e-9d14-fe058f8137d3',
    'App\\Notifications\\BookingStatusNotification',
    'App\\Models\\User',
    27,
    '{\"booking_id\":39,\"title\":\"Booking Created\",\"message\":\"Your booking for Cricket has been created.\",\"type\":\"booking\",\"icon\":\"Calendar\",\"link\":\"\\/my-bookings\"}',
    NULL,
    '2026-03-04 07:58:28',
    '2026-03-04 07:58:28'
  ),
  (
    '10a82081-1ef5-4832-a114-d5599707a042',
    'App\\Notifications\\BookingStatusNotification',
    'App\\Models\\User',
    27,
    '{\"booking_id\":25,\"title\":\"Booking Status Updated\",\"message\":\"Your booking status for Cricket has been updated to cancelled\",\"type\":\"booking\",\"icon\":\"Calendar\",\"link\":\"\\/my-bookings\"}',
    NULL,
    '2026-03-04 04:49:57',
    '2026-03-04 04:49:57'
  ),
  (
    '13142e6a-04c7-4773-82c0-6dc1905ea2b2',
    'App\\Notifications\\BookingStatusNotification',
    'App\\Models\\User',
    27,
    '{\"booking_id\":26,\"title\":\"Booking Created\",\"message\":\"Your booking for Cricket has been created.\",\"type\":\"booking\",\"icon\":\"Calendar\",\"link\":\"\\/my-bookings\"}',
    NULL,
    '2026-03-04 04:43:13',
    '2026-03-04 04:43:13'
  ),
  (
    '14314478-4c59-4b48-9078-ba28b8c20bee',
    'App\\Notifications\\WelcomeNotification',
    'App\\Models\\User',
    26,
    '{\"title\":\"Welcome to SportSpot!\",\"message\":\"Thanks for joining our platform. Start exploring featured grounds and upcoming events now!\",\"type\":\"welcome\",\"icon\":\"Sparkles\"}',
    NULL,
    '2026-03-04 03:58:03',
    '2026-03-04 03:58:03'
  ),
  (
    '22dc6e81-493b-438e-ad4e-c3ebbfffd972',
    'App\\Notifications\\BookingStatusNotification',
    'App\\Models\\User',
    27,
    '{\"booking_id\":40,\"title\":\"Booking Created\",\"message\":\"Your booking for Cricket has been created.\",\"type\":\"booking\",\"icon\":\"Calendar\",\"link\":\"\\/my-bookings\"}',
    NULL,
    '2026-03-04 08:18:49',
    '2026-03-04 08:18:49'
  ),
  (
    '2d037947-3b8c-412d-b095-15f34f9fa45a',
    'App\\Notifications\\BookingStatusNotification',
    'App\\Models\\User',
    27,
    '{\"booking_id\":22,\"title\":\"Booking Created\",\"message\":\"Your booking for Cricket has been created.\",\"type\":\"booking\",\"icon\":\"Calendar\",\"link\":\"\\/my-bookings\"}',
    NULL,
    '2026-03-04 04:02:41',
    '2026-03-04 04:02:41'
  ),
  (
    '308b7c07-5c5c-496b-b5f7-45dcf0012b4b',
    'App\\Notifications\\BookingStatusNotification',
    'App\\Models\\User',
    27,
    '{\"booking_id\":30,\"title\":\"Booking Created\",\"message\":\"Your booking for Cricket has been created.\",\"type\":\"booking\",\"icon\":\"Calendar\",\"link\":\"\\/my-bookings\"}',
    NULL,
    '2026-03-04 05:04:02',
    '2026-03-04 05:04:02'
  ),
  (
    '406be046-4f88-4733-8079-00b25bda52b8',
    'App\\Notifications\\BookingStatusNotification',
    'App\\Models\\User',
    27,
    '{\"booking_id\":22,\"title\":\"Booking Status Updated\",\"message\":\"Your booking status for Cricket has been updated to cancelled\",\"type\":\"booking\",\"icon\":\"Calendar\",\"link\":\"\\/my-bookings\"}',
    NULL,
    '2026-03-04 04:17:17',
    '2026-03-04 04:17:17'
  ),
  (
    '4ea55c24-4144-4c84-97a8-51eec70e6098',
    'App\\Notifications\\BookingStatusNotification',
    'App\\Models\\User',
    27,
    '{\"booking_id\":27,\"title\":\"Booking Status Updated\",\"message\":\"Your booking status for Cricket has been updated to cancelled\",\"type\":\"booking\",\"icon\":\"Calendar\",\"link\":\"\\/my-bookings\"}',
    NULL,
    '2026-03-04 04:56:24',
    '2026-03-04 04:56:24'
  ),
  (
    '53706a60-ef77-4e20-926c-27433e574e03',
    'App\\Notifications\\BookingStatusNotification',
    'App\\Models\\User',
    27,
    '{\"booking_id\":27,\"title\":\"Booking Created\",\"message\":\"Your booking for Cricket has been created.\",\"type\":\"booking\",\"icon\":\"Calendar\",\"link\":\"\\/my-bookings\"}',
    NULL,
    '2026-03-04 04:51:07',
    '2026-03-04 04:51:07'
  ),
  (
    '59873679-d435-442b-aedf-b111fff763aa',
    'App\\Notifications\\WelcomeNotification',
    'App\\Models\\User',
    25,
    '{\"title\":\"Welcome to SportSpot!\",\"message\":\"Thanks for joining our platform. Start exploring featured grounds and upcoming events now!\",\"type\":\"welcome\",\"icon\":\"Sparkles\"}',
    '2026-03-04 22:12:43',
    '2026-03-03 20:44:27',
    '2026-03-04 22:12:43'
  ),
  (
    '5f09b805-8dcc-4da2-a6d1-5093fa205e4d',
    'App\\Notifications\\BookingStatusNotification',
    'App\\Models\\User',
    27,
    '{\"booking_id\":22,\"title\":\"Booking Status Updated\",\"message\":\"Your booking status for Cricket has been updated to confirmed\",\"type\":\"booking\",\"icon\":\"Calendar\",\"link\":\"\\/my-bookings\"}',
    NULL,
    '2026-03-04 04:07:22',
    '2026-03-04 04:07:22'
  ),
  (
    '60cf0cf6-5e90-4a35-b964-e3474abb3e1d',
    'App\\Notifications\\BookingStatusNotification',
    'App\\Models\\User',
    27,
    '{\"booking_id\":38,\"title\":\"Booking Created\",\"message\":\"Your booking for Cricket has been created.\",\"type\":\"booking\",\"icon\":\"Calendar\",\"link\":\"\\/my-bookings\"}',
    NULL,
    '2026-03-04 07:58:24',
    '2026-03-04 07:58:24'
  ),
  (
    '6341384d-3e6b-4f7f-8647-3806e3b907ee',
    'App\\Notifications\\BookingStatusNotification',
    'App\\Models\\User',
    27,
    '{\"booking_id\":31,\"title\":\"Booking Created\",\"message\":\"Your booking for Cricket has been created.\",\"type\":\"booking\",\"icon\":\"Calendar\",\"link\":\"\\/my-bookings\"}',
    NULL,
    '2026-03-04 05:13:24',
    '2026-03-04 05:13:24'
  ),
  (
    '6b2612d2-83a8-43a0-ab69-4a9325455262',
    'App\\Notifications\\BookingStatusNotification',
    'App\\Models\\User',
    27,
    '{\"booking_id\":42,\"title\":\"Booking Created\",\"message\":\"Your booking for Cricket has been created.\",\"type\":\"booking\",\"icon\":\"Calendar\",\"link\":\"\\/my-bookings\"}',
    NULL,
    '2026-03-04 09:32:30',
    '2026-03-04 09:32:30'
  ),
  (
    '6e5d5fc2-7847-4259-b84f-daf410cdbe66',
    'App\\Notifications\\BookingStatusNotification',
    'App\\Models\\User',
    27,
    '{\"booking_id\":37,\"title\":\"Booking Created\",\"message\":\"Your booking for Cricket has been created.\",\"type\":\"booking\",\"icon\":\"Calendar\",\"link\":\"\\/my-bookings\"}',
    NULL,
    '2026-03-04 07:38:06',
    '2026-03-04 07:38:06'
  ),
  (
    '74273579-7aaa-4057-99f9-cc2a41eadead',
    'App\\Notifications\\BookingStatusNotification',
    'App\\Models\\User',
    27,
    '{\"booking_id\":33,\"title\":\"Booking Created\",\"message\":\"Your booking for Cricket has been created.\",\"type\":\"booking\",\"icon\":\"Calendar\",\"link\":\"\\/my-bookings\"}',
    NULL,
    '2026-03-04 05:50:01',
    '2026-03-04 05:50:01'
  ),
  (
    '761f35ed-5f0f-4cd8-afc2-767e13d6cc84',
    'App\\Notifications\\BookingStatusNotification',
    'App\\Models\\User',
    27,
    '{\"booking_id\":25,\"title\":\"Booking Created\",\"message\":\"Your booking for Cricket has been created.\",\"type\":\"booking\",\"icon\":\"Calendar\",\"link\":\"\\/my-bookings\"}',
    NULL,
    '2026-03-04 04:29:25',
    '2026-03-04 04:29:25'
  ),
  (
    '8422baa5-372d-4bde-8a32-1218acec8249',
    'App\\Notifications\\BookingStatusNotification',
    'App\\Models\\User',
    27,
    '{\"booking_id\":41,\"title\":\"Booking Created\",\"message\":\"Your booking for Cricket has been created.\",\"type\":\"booking\",\"icon\":\"Calendar\",\"link\":\"\\/my-bookings\"}',
    NULL,
    '2026-03-04 08:56:58',
    '2026-03-04 08:56:58'
  ),
  (
    '8eb55b1a-08e5-45f1-862a-ca3321b2d7db',
    'App\\Notifications\\BookingStatusNotification',
    'App\\Models\\User',
    27,
    '{\"booking_id\":23,\"title\":\"Booking Created\",\"message\":\"Your booking for Cricket has been created.\",\"type\":\"booking\",\"icon\":\"Calendar\",\"link\":\"\\/my-bookings\"}',
    NULL,
    '2026-03-04 04:18:14',
    '2026-03-04 04:18:14'
  ),
  (
    '8f6c4702-3cc7-4c71-8546-270b43ea4b27',
    'App\\Notifications\\BookingStatusNotification',
    'App\\Models\\User',
    27,
    '{\"booking_id\":36,\"title\":\"Booking Created\",\"message\":\"Your booking for Cricket has been created.\",\"type\":\"booking\",\"icon\":\"Calendar\",\"link\":\"\\/my-bookings\"}',
    NULL,
    '2026-03-04 06:59:59',
    '2026-03-04 06:59:59'
  ),
  (
    '9ddad68e-a70b-4824-8b4b-901fc962c0b7',
    'App\\Notifications\\BookingStatusNotification',
    'App\\Models\\User',
    27,
    '{\"booking_id\":28,\"title\":\"Booking Created\",\"message\":\"Your booking for Cricket has been created.\",\"type\":\"booking\",\"icon\":\"Calendar\",\"link\":\"\\/my-bookings\"}',
    NULL,
    '2026-03-04 04:57:05',
    '2026-03-04 04:57:05'
  ),
  (
    'b7942611-f80e-4890-9025-42e3059d2694',
    'App\\Notifications\\BookingStatusNotification',
    'App\\Models\\User',
    27,
    '{\"booking_id\":35,\"title\":\"Booking Created\",\"message\":\"Your booking for Cricket has been created.\",\"type\":\"booking\",\"icon\":\"Calendar\",\"link\":\"\\/my-bookings\"}',
    NULL,
    '2026-03-04 06:37:40',
    '2026-03-04 06:37:40'
  ),
  (
    'c5d58520-8137-4859-9c39-cfb1cafc731e',
    'App\\Notifications\\WelcomeNotification',
    'App\\Models\\User',
    27,
    '{\"title\":\"Welcome to SportSpot!\",\"message\":\"Thanks for joining our platform. Start exploring featured grounds and upcoming events now!\",\"type\":\"welcome\",\"icon\":\"Sparkles\"}',
    NULL,
    '2026-03-04 04:01:12',
    '2026-03-04 04:01:12'
  ),
  (
    'd4ee30cf-12db-4157-a4c3-5b20fb1bf507',
    'App\\Notifications\\BookingStatusNotification',
    'App\\Models\\User',
    27,
    '{\"booking_id\":24,\"title\":\"Booking Created\",\"message\":\"Your booking for Cricket has been created.\",\"type\":\"booking\",\"icon\":\"Calendar\",\"link\":\"\\/my-bookings\"}',
    NULL,
    '2026-03-04 04:19:21',
    '2026-03-04 04:19:21'
  ),
  (
    'e03e2725-6152-461a-bbec-9cc7e4528027',
    'App\\Notifications\\BookingStatusNotification',
    'App\\Models\\User',
    27,
    '{\"booking_id\":32,\"title\":\"Booking Created\",\"message\":\"Your booking for Cricket has been created.\",\"type\":\"booking\",\"icon\":\"Calendar\",\"link\":\"\\/my-bookings\"}',
    NULL,
    '2026-03-04 05:24:47',
    '2026-03-04 05:24:47'
  ),
  (
    'eca1215f-4bff-4509-bdbc-5add2f5bcaaf',
    'App\\Notifications\\BookingStatusNotification',
    'App\\Models\\User',
    27,
    '{\"booking_id\":24,\"title\":\"Booking Status Updated\",\"message\":\"Your booking status for Cricket has been updated to cancelled\",\"type\":\"booking\",\"icon\":\"Calendar\",\"link\":\"\\/my-bookings\"}',
    NULL,
    '2026-03-04 04:50:01',
    '2026-03-04 04:50:01'
  ),
  (
    'f53a3f02-7c0f-4934-bd2f-a3efbdfbf770',
    'App\\Notifications\\BookingStatusNotification',
    'App\\Models\\User',
    27,
    '{\"booking_id\":26,\"title\":\"Booking Status Updated\",\"message\":\"Your booking status for Cricket has been updated to cancelled\",\"type\":\"booking\",\"icon\":\"Calendar\",\"link\":\"\\/my-bookings\"}',
    NULL,
    '2026-03-04 04:49:52',
    '2026-03-04 04:49:52'
  ),
  (
    'f57619b4-7f9e-49df-b5d2-aa7909e37926',
    'App\\Notifications\\BookingStatusNotification',
    'App\\Models\\User',
    27,
    '{\"booking_id\":34,\"title\":\"Booking Created\",\"message\":\"Your booking for Cricket has been created.\",\"type\":\"booking\",\"icon\":\"Calendar\",\"link\":\"\\/my-bookings\"}',
    NULL,
    '2026-03-04 06:14:42',
    '2026-03-04 06:14:42'
  );
-- --------------------------------------------------------
--
-- Table structure for table `password_reset_tokens`
--

CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) NOT NULL,
  `token` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- --------------------------------------------------------
--
-- Table structure for table `personal_access_tokens`
--

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
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
--
-- Dumping data for table `personal_access_tokens`
--

INSERT INTO `personal_access_tokens` (
    `id`,
    `tokenable_type`,
    `tokenable_id`,
    `name`,
    `token`,
    `abilities`,
    `last_used_at`,
    `expires_at`,
    `created_at`,
    `updated_at`
  )
VALUES (
    5,
    'App\\Models\\User',
    5,
    'auth_token',
    '41ebcd0074b3e9a35f43884026ba476c63c1ccb86042e949534fd3ab1cecf44d',
    '[\"*\"]',
    NULL,
    NULL,
    '2026-02-10 06:38:33',
    '2026-02-10 06:38:33'
  ),
  (
    6,
    'App\\Models\\User',
    5,
    'auth_token',
    '6c093ab1daac191c70c167dd22683814f5e37a0388d4c68db56ed52c15aea443',
    '[\"*\"]',
    '2026-02-10 09:14:42',
    NULL,
    '2026-02-10 06:38:34',
    '2026-02-10 09:14:42'
  ),
  (
    8,
    'App\\Models\\User',
    6,
    'auth_token',
    'f944fae23322608b6204c1add75d4d510f401c67c2087163ae018f7fce328071',
    '[\"*\"]',
    NULL,
    NULL,
    '2026-02-10 09:15:56',
    '2026-02-10 09:15:56'
  ),
  (
    10,
    'App\\Models\\User',
    7,
    'auth_token',
    '35b9db505433b66a5c887a1de64a17a6e17cf9a4f084f523b97a14e5b5b7b8e0',
    '[\"*\"]',
    NULL,
    NULL,
    '2026-02-11 03:36:02',
    '2026-02-11 03:36:02'
  ),
  (
    11,
    'App\\Models\\User',
    7,
    'auth_token',
    '96c548558da66cd1a32fec5eb6a46c8eceaa54806b4b8b6555e1e6aa632b8708',
    '[\"*\"]',
    '2026-02-11 03:37:49',
    NULL,
    '2026-02-11 03:36:03',
    '2026-02-11 03:37:49'
  ),
  (
    13,
    'App\\Models\\User',
    8,
    'auth_token',
    '3cf7aa00a381bda56bd84a4899b208a56173394d29d4c7a02a21fe66aac66217',
    '[\"*\"]',
    NULL,
    NULL,
    '2026-02-11 03:44:18',
    '2026-02-11 03:44:18'
  ),
  (
    14,
    'App\\Models\\User',
    8,
    'auth_token',
    '225111a821736bd1b52095967e4af28c5d3fc4fc6b3560c1a2d43c9bf598140b',
    '[\"*\"]',
    '2026-02-11 03:54:07',
    NULL,
    '2026-02-11 03:44:18',
    '2026-02-11 03:54:07'
  ),
  (
    15,
    'App\\Models\\User',
    8,
    'auth_token',
    '85b966986a818d2e57bcc3c6e630572d6214d777725f8e261cd0b3927bdd5d79',
    '[\"*\"]',
    '2026-02-11 07:00:52',
    NULL,
    '2026-02-11 03:54:26',
    '2026-02-11 07:00:52'
  ),
  (
    17,
    'App\\Models\\User',
    9,
    'auth_token',
    '2b27b9315dca11360b327f36f22e716e54a25902d49d1db8ca2a88e8505a5346',
    '[\"*\"]',
    '2026-03-03 09:50:46',
    NULL,
    '2026-02-17 10:57:45',
    '2026-03-03 09:50:46'
  ),
  (
    18,
    'App\\Models\\User',
    10,
    'auth_token',
    '2302206746e53efec0817039a4d2595babdef8f8df2736537ace2cee4df5d37b',
    '[\"*\"]',
    '2026-02-22 03:12:02',
    NULL,
    '2026-02-17 11:01:01',
    '2026-02-22 03:12:02'
  ),
  (
    19,
    'App\\Models\\User',
    11,
    'auth_token',
    'e32cdc64c3a05f8d5cea3ae3fc57994b2a139bcba1b191bcda6bde3acccae050',
    '[\"*\"]',
    '2026-02-18 13:35:20',
    NULL,
    '2026-02-18 13:34:47',
    '2026-02-18 13:35:20'
  ),
  (
    20,
    'App\\Models\\User',
    11,
    'auth_token',
    'd531d9d49cad205405db5976a9eb3b64d632e6393147f8d9f0963339e1d257f9',
    '[\"*\"]',
    '2026-02-19 16:38:25',
    NULL,
    '2026-02-19 16:38:23',
    '2026-02-19 16:38:25'
  ),
  (
    22,
    'App\\Models\\User',
    12,
    'auth_token',
    'e42aae361e0d5b1cfaa9af85a5b728fcef5272f642feeb3415e3ad178133c349',
    '[\"*\"]',
    '2026-02-25 19:09:56',
    NULL,
    '2026-02-20 07:29:16',
    '2026-02-25 19:09:56'
  ),
  (
    23,
    'App\\Models\\User',
    14,
    'auth_token',
    'cfab420920dd3174a4a91318cd789cd2b53621ef2e92c258fbd85bf95e000ce9',
    '[\"*\"]',
    NULL,
    NULL,
    '2026-02-21 03:36:58',
    '2026-02-21 03:36:58'
  ),
  (
    24,
    'App\\Models\\User',
    14,
    'auth_token',
    '0d433c3d939f12579625cfd25fd9d6c24bf338a33075e9c8a358371b943ab37c',
    '[\"*\"]',
    NULL,
    NULL,
    '2026-02-21 03:47:27',
    '2026-02-21 03:47:27'
  ),
  (
    25,
    'App\\Models\\User',
    14,
    'auth_token',
    'ef448deaf4fdeff9ae371ace2ae4e762db1b94db289eed07909af4b02a227f52',
    '[\"*\"]',
    '2026-02-21 07:08:19',
    NULL,
    '2026-02-21 04:04:08',
    '2026-02-21 07:08:19'
  ),
  (
    26,
    'App\\Models\\User',
    14,
    'auth_token',
    '9b2a556d514e3cba7fb45c0cc903f20d76257791c2a58411b7d3f88fbd0f1251',
    '[\"*\"]',
    '2026-02-21 04:12:18',
    NULL,
    '2026-02-21 04:12:15',
    '2026-02-21 04:12:18'
  ),
  (
    27,
    'App\\Models\\User',
    14,
    'auth_token',
    '549f2dd730a64c8b76320706c6600ae94742fcbb335ed52c47e5ba542b58d145',
    '[\"*\"]',
    '2026-02-21 04:35:19',
    NULL,
    '2026-02-21 04:35:14',
    '2026-02-21 04:35:19'
  ),
  (
    28,
    'App\\Models\\User',
    15,
    'auth_token',
    '70a9a0b38114052c4638497ccc285cfa73abad849dc3adf990a77e028f4eaa95',
    '[\"*\"]',
    NULL,
    NULL,
    '2026-02-21 17:41:59',
    '2026-02-21 17:41:59'
  ),
  (
    29,
    'App\\Models\\User',
    15,
    'auth_token',
    'aea232c6b39deacea649a19025df5548db6cd59351233ab4ce2b8ddf2a79c2e0',
    '[\"*\"]',
    NULL,
    NULL,
    '2026-02-21 17:43:39',
    '2026-02-21 17:43:39'
  ),
  (
    30,
    'App\\Models\\User',
    16,
    'auth_token',
    'd6e1e7b6cb69f71e84583df59ba86ee67d56e58201838ab0905b283bdc04de93',
    '[\"*\"]',
    '2026-02-21 19:12:02',
    NULL,
    '2026-02-21 19:10:52',
    '2026-02-21 19:12:02'
  ),
  (
    31,
    'App\\Models\\User',
    16,
    'auth_token',
    '48f104f510ecee00f4187c443fb7da645ff99cc8c208250bc85b6b32da34c3e2',
    '[\"*\"]',
    '2026-02-22 01:45:26',
    NULL,
    '2026-02-22 01:45:23',
    '2026-02-22 01:45:26'
  ),
  (
    32,
    'App\\Models\\User',
    17,
    'auth_token',
    '647b0e985dd1428525e6a31fd769398947fd1d63d9a87aee6a89f8572047b7d7',
    '[\"*\"]',
    '2026-02-22 02:37:39',
    NULL,
    '2026-02-22 02:35:21',
    '2026-02-22 02:37:39'
  ),
  (
    33,
    'App\\Models\\User',
    17,
    'auth_token',
    '0eacdb49350fe617c31bfeeeda579cfc75dbcf88e8c2bc3519ba07eae58cef37',
    '[\"*\"]',
    '2026-02-28 12:16:10',
    NULL,
    '2026-02-22 03:00:01',
    '2026-02-28 12:16:10'
  ),
  (
    40,
    'App\\Models\\User',
    16,
    'auth_token',
    'ba5abb18551552d89a6b6374f47fb68484fccead50aa03249e27c7a5dc503dbc',
    '[\"*\"]',
    '2026-02-22 04:21:12',
    NULL,
    '2026-02-22 04:16:33',
    '2026-02-22 04:21:12'
  ),
  (
    41,
    'App\\Models\\User',
    16,
    'auth_token',
    'd357fdce1123fc672d417a049f4103babe17765826b30d9fe6a2a94d553eea64',
    '[\"*\"]',
    '2026-02-22 04:31:58',
    NULL,
    '2026-02-22 04:31:47',
    '2026-02-22 04:31:58'
  ),
  (
    42,
    'App\\Models\\User',
    16,
    'auth_token',
    '15735f6dcbcd1b04dd339c3e151ac0a8b12b17f9399a97193d664f67405c3b9f',
    '[\"*\"]',
    '2026-02-22 04:33:49',
    NULL,
    '2026-02-22 04:33:20',
    '2026-02-22 04:33:49'
  ),
  (
    44,
    'App\\Models\\User',
    16,
    'auth_token',
    '9de73c53abddceb616b280a8e86932fbfa1f70bfe3decad793bd5fc43ba40000',
    '[\"*\"]',
    '2026-02-23 02:27:24',
    NULL,
    '2026-02-22 04:54:29',
    '2026-02-23 02:27:24'
  ),
  (
    45,
    'App\\Models\\User',
    18,
    'auth_token',
    '726908f3a64a05bf8461ff105bf4d20a705f604bff910c59b09a2130349b1ffd',
    '[\"*\"]',
    '2026-02-22 13:36:02',
    NULL,
    '2026-02-22 12:54:33',
    '2026-02-22 13:36:02'
  ),
  (
    46,
    'App\\Models\\User',
    19,
    'auth_token',
    'dc54072771adeb7b286246c9d08af3f0edcfa0298864a655e1ce2b792a147f92',
    '[\"*\"]',
    '2026-02-24 01:48:12',
    NULL,
    '2026-02-22 13:36:41',
    '2026-02-24 01:48:12'
  ),
  (
    47,
    'App\\Models\\User',
    9,
    'auth_token',
    'f191caf22e7752b31549f0c8ed2e2b312afa9d004ab9f118c3d0039cb7df6c88',
    '[\"*\"]',
    '2026-02-22 18:26:24',
    NULL,
    '2026-02-22 18:26:11',
    '2026-02-22 18:26:24'
  ),
  (
    48,
    'App\\Models\\User',
    9,
    'auth_token',
    '1732354e12cd0033da6c23fb8a727b183c0ecc5023f97d6767cf82f7326d0c6f',
    '[\"*\"]',
    '2026-02-22 18:30:13',
    NULL,
    '2026-02-22 18:26:31',
    '2026-02-22 18:30:13'
  ),
  (
    49,
    'App\\Models\\User',
    9,
    'auth_token',
    '0f352df2bcc265e2527d99944bdba316f97501ff8caa74f9ad40a9c3101e6d7f',
    '[\"*\"]',
    '2026-02-22 18:30:45',
    NULL,
    '2026-02-22 18:30:32',
    '2026-02-22 18:30:45'
  ),
  (
    50,
    'App\\Models\\User',
    9,
    'auth_token',
    '396167b2eee6369a888904f0de8f791c1bc84cb84a8f3647515088e9684f0e0f',
    '[\"*\"]',
    '2026-02-23 07:11:03',
    NULL,
    '2026-02-22 18:31:08',
    '2026-02-23 07:11:03'
  ),
  (
    51,
    'App\\Models\\User',
    16,
    'auth_token',
    '0bf1e79a9c1a0e79a124389ba88b793b637fb257499a5b8994f4b1d2456e5991',
    '[\"*\"]',
    '2026-02-23 02:38:59',
    NULL,
    '2026-02-23 02:27:26',
    '2026-02-23 02:38:59'
  ),
  (
    53,
    'App\\Models\\User',
    16,
    'auth_token',
    '7228735bc52c4833f94aad8987dd2fa60e5cbbede7c93d7e00dbb72536e1011f',
    '[\"*\"]',
    '2026-02-23 09:24:11',
    NULL,
    '2026-02-23 03:17:10',
    '2026-02-23 09:24:11'
  ),
  (
    54,
    'App\\Models\\User',
    9,
    'auth_token',
    '73637767f1d696fa0e9252ca670bfecd7c5360e8f83c06f0aee4aa4f91f734bd',
    '[\"*\"]',
    '2026-02-23 08:55:11',
    NULL,
    '2026-02-23 07:12:15',
    '2026-02-23 08:55:11'
  ),
  (
    56,
    'App\\Models\\User',
    9,
    'auth_token',
    'a0dd0ca5846387ea3237ef551cd5aa3e6bdc4179f13b3e1cb34ad5e0b62e2d29',
    '[\"*\"]',
    '2026-02-23 09:39:12',
    NULL,
    '2026-02-23 08:55:47',
    '2026-02-23 09:39:12'
  ),
  (
    57,
    'App\\Models\\User',
    9,
    'auth_token',
    '650f5d06e0ad2e42841152a7cb582e1301d55af7852ca3613d89179a6855114d',
    '[\"*\"]',
    '2026-03-04 09:37:12',
    NULL,
    '2026-02-23 08:58:05',
    '2026-03-04 09:37:12'
  ),
  (
    58,
    'App\\Models\\User',
    5,
    'auth_token',
    'd83144edead0010c66c5767025c2c897beb66a487aece8058a2d6c4e43aea9fb',
    '[\"*\"]',
    '2026-02-23 09:42:11',
    NULL,
    '2026-02-23 09:24:19',
    '2026-02-23 09:42:11'
  ),
  (
    59,
    'App\\Models\\User',
    9,
    'auth_token',
    'aac791d71574c9047bfafb30def48844e0e36ba8ef45adff7699a32e602494d8',
    '[\"*\"]',
    '2026-02-23 09:44:32',
    NULL,
    '2026-02-23 09:39:31',
    '2026-02-23 09:44:32'
  ),
  (
    60,
    'App\\Models\\User',
    20,
    'auth_token',
    '87f3f1c2aa33cdf896814ff7b8c789930309e40084ec79d1ba91bc5237dd0cef',
    '[\"*\"]',
    '2026-02-23 17:23:18',
    NULL,
    '2026-02-23 09:48:14',
    '2026-02-23 17:23:18'
  ),
  (
    62,
    'App\\Models\\User',
    5,
    'auth_token',
    'd3c2f47deed6194177256e6f99ecc832721a497079105bfaa47a9ce085774dfa',
    '[\"*\"]',
    '2026-02-24 07:56:40',
    NULL,
    '2026-02-23 09:55:40',
    '2026-02-24 07:56:40'
  ),
  (
    63,
    'App\\Models\\User',
    9,
    'auth_token',
    '6c87c0e6f95c8452c5caf8e394b83f2da8542fa5e5420ebf23a44265496e1038',
    '[\"*\"]',
    '2026-02-23 10:10:36',
    NULL,
    '2026-02-23 09:56:49',
    '2026-02-23 10:10:36'
  ),
  (
    64,
    'App\\Models\\User',
    9,
    'auth_token',
    'efb7a9458b02a7a59cbdab68ebbedc042cee815ad641dcda2a98c41be7b55f2d',
    '[\"*\"]',
    '2026-02-23 17:02:48',
    NULL,
    '2026-02-23 10:10:45',
    '2026-02-23 17:02:48'
  ),
  (
    65,
    'App\\Models\\User',
    9,
    'auth_token',
    '2d834cef7384c8deba44e1d7b81ca4b4dbe1521aca8846fab6eabb87f87a9497',
    '[\"*\"]',
    '2026-02-23 17:07:14',
    NULL,
    '2026-02-23 17:03:13',
    '2026-02-23 17:07:14'
  ),
  (
    66,
    'App\\Models\\User',
    9,
    'auth_token',
    'a2fbea5bcf3bf1ded1f9eafbb298e1ddfc87866e7e52a36beb5e1ba2b0fd8078',
    '[\"*\"]',
    '2026-02-23 17:16:03',
    NULL,
    '2026-02-23 17:07:29',
    '2026-02-23 17:16:03'
  ),
  (
    67,
    'App\\Models\\User',
    9,
    'auth_token',
    '635c155a0804683c710cabf8707e5e4802b4e79036b46b8ada984daca47ee99d',
    '[\"*\"]',
    '2026-02-23 17:18:54',
    NULL,
    '2026-02-23 17:16:44',
    '2026-02-23 17:18:54'
  ),
  (
    69,
    'App\\Models\\User',
    16,
    'auth_token',
    '834c155a8ea8e807b12de57f93bf7b3ea7bb44cf5410116a5a8c55d7ffc5ddd3',
    '[\"*\"]',
    '2026-02-25 07:33:26',
    NULL,
    '2026-02-24 07:57:45',
    '2026-02-25 07:33:26'
  ),
  (
    70,
    'App\\Models\\User',
    5,
    'auth_token',
    '470371bd750ff9e636ef52e1e3deba5969eccd72df2621f9e6d4c659ac683b3d',
    '[\"*\"]',
    '2026-02-25 07:34:59',
    NULL,
    '2026-02-25 07:33:32',
    '2026-02-25 07:34:59'
  ),
  (
    72,
    'App\\Models\\User',
    5,
    'auth_token',
    '051604c2c60a7e6570752553fb627e6015dc35373155e791aee96ffe09ac488f',
    '[\"*\"]',
    '2026-02-25 18:18:03',
    NULL,
    '2026-02-25 18:17:33',
    '2026-02-25 18:18:03'
  ),
  (
    76,
    'App\\Models\\User',
    16,
    'auth_token',
    '126df00cb67022c322981198f6807867d5d2c0b895d26bed1b631292f61f93f2',
    '[\"*\"]',
    '2026-02-27 01:50:04',
    NULL,
    '2026-02-26 20:36:11',
    '2026-02-27 01:50:04'
  ),
  (
    78,
    'App\\Models\\User',
    5,
    'auth_token',
    'a6733ceae9b7774f85cdfc27b379e34be7c09db6eb3411c5cdfa407173990fe3',
    '[\"*\"]',
    '2026-02-27 02:26:20',
    NULL,
    '2026-02-27 02:25:05',
    '2026-02-27 02:26:20'
  ),
  (
    82,
    'App\\Models\\User',
    21,
    'auth_token',
    'e09c846f1dea5b98ddf1066097b75ede8e2721219550ae1e8c4d67f4040bbbb9',
    '[\"*\"]',
    NULL,
    NULL,
    '2026-02-27 15:56:09',
    '2026-02-27 15:56:09'
  ),
  (
    84,
    'App\\Models\\User',
    21,
    'auth_token',
    '0148cba826adbcba934afa9c40889c6146b9eaa74a4af0f5a53a694c5b117106',
    '[\"*\"]',
    '2026-02-28 00:06:25',
    NULL,
    '2026-02-27 17:06:51',
    '2026-02-28 00:06:25'
  ),
  (
    85,
    'App\\Models\\User',
    5,
    'auth_token',
    '5bdba1bb9c676189b4c309539ae1c81d4bec92cd8fa2d0f2d8cec1dd2dafd30a',
    '[\"*\"]',
    '2026-02-28 12:17:40',
    NULL,
    '2026-02-27 17:21:32',
    '2026-02-28 12:17:40'
  ),
  (
    86,
    'App\\Models\\User',
    5,
    'auth_token',
    '505241c5aea88bc1b25d0e9d88db6f9256b0a09748f25542888ebaf477aad619',
    '[\"*\"]',
    '2026-03-01 06:58:25',
    NULL,
    '2026-02-28 00:10:38',
    '2026-03-01 06:58:25'
  ),
  (
    87,
    'App\\Models\\User',
    5,
    'auth_token',
    '8696f8aad8e4ded81701c5c4ef2dbfaa793336edae04caa2dcac10094d5d673e',
    '[\"*\"]',
    '2026-02-28 12:20:01',
    NULL,
    '2026-02-28 12:18:20',
    '2026-02-28 12:20:01'
  ),
  (
    89,
    'App\\Models\\User',
    5,
    'auth_token',
    'adc6db78a3205b02a47531fe346efef428adf2a22f9c112fba27ab2424c7dd60',
    '[\"*\"]',
    '2026-02-28 12:52:04',
    NULL,
    '2026-02-28 12:22:51',
    '2026-02-28 12:52:04'
  ),
  (
    90,
    'App\\Models\\User',
    22,
    'auth_token',
    'f2bad7bf0b1efaa15b3a4c117b345b287a39e736d42d7bbbaa73f122cf680e6c',
    '[\"*\"]',
    '2026-02-28 12:52:57',
    NULL,
    '2026-02-28 12:46:37',
    '2026-02-28 12:52:57'
  ),
  (
    91,
    'App\\Models\\User',
    23,
    'auth_token',
    'f3450fd021f19fa538e76638b2043d1af963c05100ac95a01f0ef90abadce12b',
    '[\"*\"]',
    '2026-03-04 06:49:01',
    NULL,
    '2026-03-01 13:52:07',
    '2026-03-04 06:49:01'
  ),
  (
    92,
    'App\\Models\\User',
    23,
    'auth_token',
    'ceb0e40ba6e0471960f2a6a2fc7c3eba95a916d6638941fd6efe03126a7a52f1',
    '[\"*\"]',
    '2026-03-02 05:39:56',
    NULL,
    '2026-03-02 05:38:07',
    '2026-03-02 05:39:56'
  ),
  (
    93,
    'App\\Models\\User',
    24,
    'auth_token',
    '6a1f4b08004d5bd6d88f7a9e5770e45a3da8b8283b7fd75ae625e92b2411a361',
    '[\"*\"]',
    '2026-03-03 09:55:11',
    NULL,
    '2026-03-03 09:30:59',
    '2026-03-03 09:55:11'
  ),
  (
    95,
    'App\\Models\\User',
    26,
    'auth_token',
    '57d10d68940bbd561e62a23e9d78578e49bc667fbf3c6572ebb1af1690c25c50',
    '[\"*\"]',
    NULL,
    NULL,
    '2026-03-04 03:58:05',
    '2026-03-04 03:58:05'
  ),
  (
    96,
    'App\\Models\\User',
    26,
    'auth_token',
    '516c2fa54a35589e653e8201d47f4aa9b16c6c9389d6ff71d947436bf4fa4d09',
    '[\"*\"]',
    '2026-03-04 09:26:47',
    NULL,
    '2026-03-04 03:58:06',
    '2026-03-04 09:26:47'
  ),
  (
    98,
    'App\\Models\\User',
    27,
    'auth_token',
    '445669d96bc2ad09a40cbe6ae35fc8e8bae24ed8f139f1185529917bde543d79',
    '[\"*\"]',
    '2026-03-04 19:36:19',
    NULL,
    '2026-03-04 04:49:44',
    '2026-03-04 19:36:19'
  ),
  (
    99,
    'App\\Models\\User',
    23,
    'auth_token',
    '605e7402d323aaa284b66e110e545da16028718a2e30f3cef073a3c1ca89afe2',
    '[\"*\"]',
    '2026-03-04 13:38:39',
    NULL,
    '2026-03-04 13:35:50',
    '2026-03-04 13:38:39'
  ),
  (
    100,
    'App\\Models\\User',
    25,
    'auth_token',
    'b0c36b262a0a034cac6ccf689ee77bff3545d9a0cf71af938b974875b6eee6d5',
    '[\"*\"]',
    '2026-03-04 23:37:05',
    NULL,
    '2026-03-04 14:28:57',
    '2026-03-04 23:37:05'
  ),
  (
    101,
    'App\\Models\\User',
    27,
    'auth_token',
    'edbcf86f5088e0d7ae09c1605537f29c891b65080f8d892edce53e788ae291d4',
    '[\"*\"]',
    '2026-03-04 23:36:13',
    NULL,
    '2026-03-04 19:36:26',
    '2026-03-04 23:36:13'
  ),
  (
    102,
    'App\\Models\\User',
    9,
    'auth_token',
    '14bf845a92819875488eb053ff76e73fcb9719eabe80631f8cfd851b1a8ccde9',
    '[\"*\"]',
    NULL,
    NULL,
    '2026-03-04 23:22:02',
    '2026-03-04 23:22:02'
  );
-- --------------------------------------------------------
--
-- Table structure for table `reviews`
--

CREATE TABLE `reviews` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `ground_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `user_name` varchar(255) DEFAULT NULL,
  `rating` tinyint(3) UNSIGNED NOT NULL,
  `comment` text NOT NULL,
  `status` varchar(255) NOT NULL DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- --------------------------------------------------------
--
-- Table structure for table `sessions`
--

CREATE TABLE `sessions` (
  `id` varchar(255) NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `payload` longtext NOT NULL,
  `last_activity` int(11) NOT NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- --------------------------------------------------------
--
-- Table structure for table `teams`
--

CREATE TABLE `teams` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `sport` varchar(255) DEFAULT NULL,
  `logo` varchar(255) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `owner_id` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
--
-- Dumping data for table `teams`
--

INSERT INTO `teams` (
    `id`,
    `name`,
    `sport`,
    `logo`,
    `description`,
    `owner_id`,
    `created_at`,
    `updated_at`
  )
VALUES (
    1,
    'hji',
    'Cricket',
    NULL,
    'kki',
    25,
    '2026-03-04 21:59:58',
    '2026-03-04 21:59:58'
  );
-- --------------------------------------------------------
--
-- Table structure for table `team_members`
--

CREATE TABLE `team_members` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `team_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `role` varchar(255) NOT NULL DEFAULT 'player',
  `status` varchar(255) NOT NULL DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
--
-- Dumping data for table `team_members`
--

INSERT INTO `team_members` (
    `id`,
    `team_id`,
    `user_id`,
    `role`,
    `status`,
    `created_at`,
    `updated_at`
  )
VALUES (
    1,
    1,
    25,
    'captain',
    'active',
    '2026-03-04 21:59:58',
    '2026-03-04 21:59:58'
  );
-- --------------------------------------------------------
--
-- Table structure for table `transactions`
--

CREATE TABLE `transactions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(255) NOT NULL,
  `category` varchar(255) DEFAULT NULL,
  `amount` decimal(10, 2) NOT NULL,
  `type` varchar(255) NOT NULL,
  `date` date NOT NULL,
  `description` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- --------------------------------------------------------
--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `google_id` varchar(255) DEFAULT NULL,
  `apple_id` varchar(255) DEFAULT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `remember_token` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `business_name` varchar(255) DEFAULT NULL,
  `notification_preferences` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`notification_preferences`)),
  `fcm_token` varchar(255) DEFAULT NULL,
  `phone_verified_at` timestamp NULL DEFAULT NULL,
  `role` varchar(255) NOT NULL DEFAULT 'user',
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `avatar` varchar(255) DEFAULT NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
--
-- Dumping data for table `users`
--

INSERT INTO `users` (
    `id`,
    `name`,
    `email`,
    `google_id`,
    `apple_id`,
    `email_verified_at`,
    `password`,
    `remember_token`,
    `created_at`,
    `updated_at`,
    `phone`,
    `business_name`,
    `notification_preferences`,
    `fcm_token`,
    `phone_verified_at`,
    `role`,
    `is_active`,
    `avatar`
  )
VALUES (
    8,
    'usman',
    'usman4321@gmail.com',
    NULL,
    NULL,
    NULL,
    '$2y$12$Cf0xtdwFmqkqQghQYylMa.uFkFW0Q0Ur8EEtTxEvgUUJrVb/E8gBu',
    NULL,
    '2026-02-11 03:44:03',
    '2026-02-11 03:44:03',
    '987654321',
    NULL,
    NULL,
    NULL,
    NULL,
    'owner',
    1,
    NULL
  ),
  (
    9,
    'Zeeshan Shafique',
    'zeeshanshafique846@gmail.com',
    '116444353714886110917',
    NULL,
    NULL,
    '$2y$12$9UogHoZF.JFi9C4wBhdH4OFA9L5vZe6XqH9w5w70nqj6d31v2ekh.',
    NULL,
    '2026-02-17 10:56:24',
    '2026-02-23 08:54:39',
    '+923061930516',
    NULL,
    NULL,
    NULL,
    NULL,
    'owner',
    1,
    'https://lh3.googleusercontent.com/a/ACg8ocIyC70T5uOCtk2fWZF-Q0MkNFG4YkM82ozdUuWLKU0U4Npp1R4=s96-c'
  ),
  (
    12,
    'M Haris Kamboh',
    'harisprofessional222@gmail.com',
    '111697365337214904510',
    NULL,
    NULL,
    '$2y$12$yC8tBkK.8m5IBUhjkawZx.XPhId717R3FtghjkEPfEihFTLupLWN2',
    NULL,
    '2026-02-20 07:24:10',
    '2026-02-20 07:30:25',
    '+9203038036112',
    NULL,
    NULL,
    NULL,
    NULL,
    'user',
    1,
    '/storage/avatars/cloIiaMQyjbfcLnGjLwubRXUom8Us4fkekrft1SR.png'
  ),
  (
    13,
    'Test User',
    'testr1@test.com',
    NULL,
    NULL,
    NULL,
    '$2y$12$tVGt99GdF2kVPEIj9T8AJ.PWAFuKWJyPdlidABnJsSzmeSB6UgvKS',
    NULL,
    '2026-02-21 03:21:41',
    '2026-02-21 03:21:41',
    '12345678',
    NULL,
    NULL,
    NULL,
    NULL,
    'user',
    1,
    NULL
  ),
  (
    14,
    'Test User 2',
    'tester3@test.com',
    NULL,
    NULL,
    NULL,
    '$2y$12$9/bfNwesil04ZrL7SdUfJeHY62wN3K723EAYbUE.VPgcj9gsdgwi2',
    NULL,
    '2026-02-21 03:36:58',
    '2026-02-21 03:36:58',
    '123456789',
    NULL,
    NULL,
    NULL,
    NULL,
    'user',
    1,
    NULL
  ),
  (
    15,
    'Test User',
    'testuser_unique_123@example.com',
    NULL,
    NULL,
    NULL,
    '$2y$12$yuHGh2kgrVjvM9UnKl4dW.AMhlDV1YgL7lsaXiRHAMVmrZwWbc2WO',
    NULL,
    '2026-02-21 17:41:58',
    '2026-02-21 17:41:58',
    '03001234567',
    NULL,
    NULL,
    NULL,
    NULL,
    'user',
    1,
    NULL
  ),
  (
    20,
    'SquareNex Technologies',
    'squarenextechnologies@gmail.com',
    '105998976066316938755',
    NULL,
    NULL,
    '$2y$12$3eGdGnjpdUazQTDGBn/dE.Xm8uG8/C09QJ0jypMv0kR1Y9RFEh73O',
    NULL,
    '2026-02-23 09:48:14',
    '2026-02-23 17:23:16',
    '03154187244',
    NULL,
    NULL,
    NULL,
    '2026-02-23 17:23:16',
    'user',
    1,
    'https://lh3.googleusercontent.com/a/ACg8ocJN-m5ETgt4tqGfo5lOkL7t36NOZv7yJOildl8E3he3PhAyQQ=s96-c'
  ),
  (
    22,
    'Muhammad Kashif',
    'muhammadkashifdeveloper@gmail.com',
    '107759381360258888614',
    NULL,
    NULL,
    '$2y$12$YWieTyvEzUxvzbeyh7JeKeuncepJjkzfkJBcFJck6v2keXFQw8.UC',
    NULL,
    '2026-02-28 12:46:36',
    '2026-02-28 12:47:57',
    '+923415808822',
    NULL,
    NULL,
    NULL,
    '2026-02-28 12:47:57',
    'user',
    1,
    'https://lh3.googleusercontent.com/a/ACg8ocKkEBYSe-Ey_sJ5m14SEG-G7glFhwBOQ_SESx4BlX5Z5vgLhg=s96-c'
  ),
  (
    23,
    'Shahzad Irshad',
    'shahzadirshad045@gmail.com',
    NULL,
    NULL,
    NULL,
    '$2y$12$8gPVk7ohuhmCXL6ZuTz6ceuKHY99WvOHTps47uWPmJ87z0xqE3DN6',
    NULL,
    '2026-03-01 13:52:07',
    '2026-03-02 05:39:56',
    '+923088960983',
    NULL,
    NULL,
    NULL,
    NULL,
    'user',
    1,
    NULL
  ),
  (
    24,
    'Zeeshan Shafique',
    'zeeshanshafique846+2@gmail.com',
    NULL,
    NULL,
    NULL,
    '$2y$12$UoFJuaTdNnQorJUTtaZNpOcfQt4z1lCRT3qeVOD9GUwZXVj0rhaTK',
    NULL,
    '2026-03-03 09:30:59',
    '2026-03-03 09:32:29',
    '3154187244',
    NULL,
    NULL,
    NULL,
    NULL,
    'user',
    1,
    NULL
  ),
  (
    25,
    'Fahad Latif',
    'fahadlatif752@gmail.com',
    '102653151814827717029',
    NULL,
    NULL,
    '$2y$12$yMwftph8f85taYGvxrBr0.tUZa9vZ89z1hQ/LF4TLoa6XR6jFcjXa',
    NULL,
    '2026-03-03 20:44:27',
    '2026-03-04 23:18:40',
    '+923061930513',
    NULL,
    NULL,
    NULL,
    '2026-03-04 21:57:16',
    'user',
    1,
    'uploads/avatars/1772648320_25.jpg'
  ),
  (
    26,
    'Fahad Latif',
    'mfahadlatif736@gmail.com',
    NULL,
    NULL,
    NULL,
    '$2y$12$N7kdTv/CnBPJdfhqXWHUjuCmKGT7X.qXab4oc0X5Dx6pGWF14y9yS',
    NULL,
    '2026-03-04 03:58:03',
    '2026-03-04 03:58:03',
    '3421316906',
    NULL,
    NULL,
    NULL,
    NULL,
    'owner',
    1,
    NULL
  ),
  (
    27,
    'Ahsan Ali',
    'coxjordon38@gmail.com',
    '115549205437875917104',
    NULL,
    NULL,
    '$2y$12$de3B0uJRnNRXFZF.ezo1hOJTrOEhwuX07tXdrwuwGNZTs.eQ/Krhe',
    NULL,
    '2026-03-04 04:01:12',
    '2026-03-04 04:01:57',
    '+923061930513',
    NULL,
    NULL,
    NULL,
    '2026-03-04 04:01:57',
    'user',
    1,
    'https://lh3.googleusercontent.com/a/ACg8ocJcsd_RbTK456u6VN59jYu8WXWHEip7251WOP4X_xpoAc_L4w=s96-c'
  );
--
-- Indexes for dumped tables
--

--
-- Indexes for table `bookings`
--
ALTER TABLE `bookings`
ADD PRIMARY KEY (`id`),
  ADD KEY `bookings_user_id_foreign` (`user_id`),
  ADD KEY `bookings_ground_id_foreign` (`ground_id`);
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
-- Indexes for table `complexes`
--
ALTER TABLE `complexes`
ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `complexes_slug_unique` (`slug`),
  ADD KEY `complexes_owner_id_foreign` (`owner_id`);
--
-- Indexes for table `deals`
--
ALTER TABLE `deals`
ADD PRIMARY KEY (`id`),
  ADD KEY `deals_owner_id_foreign` (`owner_id`),
  ADD KEY `deals_ground_id_foreign` (`ground_id`);
--
-- Indexes for table `events`
--
ALTER TABLE `events`
ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `events_slug_unique` (`slug`),
  ADD KEY `events_organizer_id_foreign` (`organizer_id`),
  ADD KEY `events_booking_id_foreign` (`booking_id`);
--
-- Indexes for table `event_participants`
--
ALTER TABLE `event_participants`
ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `event_participants_event_id_user_id_unique` (`event_id`, `user_id`),
  ADD KEY `event_participants_user_id_foreign` (`user_id`);
--
-- Indexes for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`);
--
-- Indexes for table `favorites`
--
ALTER TABLE `favorites`
ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `favorites_user_id_ground_id_unique` (`user_id`, `ground_id`),
  ADD KEY `favorites_ground_id_foreign` (`ground_id`);
--
-- Indexes for table `grounds`
--
ALTER TABLE `grounds`
ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `grounds_slug_unique` (`slug`),
  ADD KEY `grounds_complex_id_foreign` (`complex_id`);
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
-- Indexes for table `media`
--
ALTER TABLE `media`
ADD PRIMARY KEY (`id`),
  ADD KEY `media_model_type_model_id_index` (`model_type`, `model_id`);
--
-- Indexes for table `migrations`
--
ALTER TABLE `migrations`
ADD PRIMARY KEY (`id`);
--
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
ADD PRIMARY KEY (`id`),
  ADD KEY `notifications_notifiable_type_notifiable_id_index` (`notifiable_type`, `notifiable_id`);
--
-- Indexes for table `password_reset_tokens`
--
ALTER TABLE `password_reset_tokens`
ADD PRIMARY KEY (`email`);
--
-- Indexes for table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  ADD KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`, `tokenable_id`),
  ADD KEY `personal_access_tokens_expires_at_index` (`expires_at`);
--
-- Indexes for table `reviews`
--
ALTER TABLE `reviews`
ADD PRIMARY KEY (`id`),
  ADD KEY `reviews_ground_id_foreign` (`ground_id`),
  ADD KEY `reviews_user_id_foreign` (`user_id`);
--
-- Indexes for table `sessions`
--
ALTER TABLE `sessions`
ADD PRIMARY KEY (`id`),
  ADD KEY `sessions_user_id_index` (`user_id`),
  ADD KEY `sessions_last_activity_index` (`last_activity`);
--
-- Indexes for table `teams`
--
ALTER TABLE `teams`
ADD PRIMARY KEY (`id`),
  ADD KEY `teams_owner_id_foreign` (`owner_id`);
--
-- Indexes for table `team_members`
--
ALTER TABLE `team_members`
ADD PRIMARY KEY (`id`),
  ADD KEY `team_members_team_id_foreign` (`team_id`),
  ADD KEY `team_members_user_id_foreign` (`user_id`);
--
-- Indexes for table `transactions`
--
ALTER TABLE `transactions`
ADD PRIMARY KEY (`id`),
  ADD KEY `transactions_user_id_foreign` (`user_id`);
--
-- Indexes for table `users`
--
ALTER TABLE `users`
ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `users_email_unique` (`email`),
  ADD UNIQUE KEY `users_google_id_unique` (`google_id`),
  ADD UNIQUE KEY `users_apple_id_unique` (`apple_id`);
--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `bookings`
--
ALTER TABLE `bookings`
MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  AUTO_INCREMENT = 43;
--
-- AUTO_INCREMENT for table `complexes`
--
ALTER TABLE `complexes`
MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  AUTO_INCREMENT = 12;
--
-- AUTO_INCREMENT for table `deals`
--
ALTER TABLE `deals`
MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  AUTO_INCREMENT = 5;
--
-- AUTO_INCREMENT for table `events`
--
ALTER TABLE `events`
MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  AUTO_INCREMENT = 12;
--
-- AUTO_INCREMENT for table `event_participants`
--
ALTER TABLE `event_participants`
MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `favorites`
--
ALTER TABLE `favorites`
MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  AUTO_INCREMENT = 2;
--
-- AUTO_INCREMENT for table `grounds`
--
ALTER TABLE `grounds`
MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  AUTO_INCREMENT = 8;
--
-- AUTO_INCREMENT for table `jobs`
--
ALTER TABLE `jobs`
MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `media`
--
ALTER TABLE `media`
MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  AUTO_INCREMENT = 3;
--
-- AUTO_INCREMENT for table `migrations`
--
ALTER TABLE `migrations`
MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  AUTO_INCREMENT = 45;
--
-- AUTO_INCREMENT for table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  AUTO_INCREMENT = 103;
--
-- AUTO_INCREMENT for table `reviews`
--
ALTER TABLE `reviews`
MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  AUTO_INCREMENT = 4;
--
-- AUTO_INCREMENT for table `teams`
--
ALTER TABLE `teams`
MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  AUTO_INCREMENT = 2;
--
-- AUTO_INCREMENT for table `team_members`
--
ALTER TABLE `team_members`
MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  AUTO_INCREMENT = 2;
--
-- AUTO_INCREMENT for table `transactions`
--
ALTER TABLE `transactions`
MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  AUTO_INCREMENT = 5;
--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  AUTO_INCREMENT = 28;
--
-- Constraints for dumped tables
--

--
-- Constraints for table `bookings`
--
ALTER TABLE `bookings`
ADD CONSTRAINT `bookings_ground_id_foreign` FOREIGN KEY (`ground_id`) REFERENCES `grounds` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `bookings_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
--
-- Constraints for table `complexes`
--
ALTER TABLE `complexes`
ADD CONSTRAINT `complexes_owner_id_foreign` FOREIGN KEY (`owner_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
--
-- Constraints for table `deals`
--
ALTER TABLE `deals`
ADD CONSTRAINT `deals_ground_id_foreign` FOREIGN KEY (`ground_id`) REFERENCES `grounds` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `deals_owner_id_foreign` FOREIGN KEY (`owner_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
--
-- Constraints for table `events`
--
ALTER TABLE `events`
ADD CONSTRAINT `events_booking_id_foreign` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`) ON DELETE
SET NULL,
  ADD CONSTRAINT `events_organizer_id_foreign` FOREIGN KEY (`organizer_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
--
-- Constraints for table `event_participants`
--
ALTER TABLE `event_participants`
ADD CONSTRAINT `event_participants_event_id_foreign` FOREIGN KEY (`event_id`) REFERENCES `events` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `event_participants_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
--
-- Constraints for table `favorites`
--
ALTER TABLE `favorites`
ADD CONSTRAINT `favorites_ground_id_foreign` FOREIGN KEY (`ground_id`) REFERENCES `grounds` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `favorites_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
--
-- Constraints for table `grounds`
--
ALTER TABLE `grounds`
ADD CONSTRAINT `grounds_complex_id_foreign` FOREIGN KEY (`complex_id`) REFERENCES `complexes` (`id`) ON DELETE CASCADE;
--
-- Constraints for table `reviews`
--
ALTER TABLE `reviews`
ADD CONSTRAINT `reviews_ground_id_foreign` FOREIGN KEY (`ground_id`) REFERENCES `grounds` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `reviews_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE
SET NULL;
--
-- Constraints for table `teams`
--
ALTER TABLE `teams`
ADD CONSTRAINT `teams_owner_id_foreign` FOREIGN KEY (`owner_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
--
-- Constraints for table `team_members`
--
ALTER TABLE `team_members`
ADD CONSTRAINT `team_members_team_id_foreign` FOREIGN KEY (`team_id`) REFERENCES `teams` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `team_members_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
--
-- Constraints for table `transactions`
--
ALTER TABLE `transactions`
ADD CONSTRAINT `transactions_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
COMMIT;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */
;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */
;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */
;