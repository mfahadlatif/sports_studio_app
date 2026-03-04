-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Mar 04, 2026 at 05:57 PM
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
-- Database: `cricket_oasis`
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
  `total_price` decimal(8,2) NOT NULL,
  `players` int(11) NOT NULL DEFAULT 1,
  `status` varchar(255) NOT NULL DEFAULT 'pending',
  `rejection_reason` text DEFAULT NULL,
  `payment_status` varchar(255) NOT NULL DEFAULT 'pending',
  `payment_expires_at` timestamp NULL DEFAULT NULL,
  `payment_method` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `bookings`
--

INSERT INTO `bookings` (`id`, `user_id`, `customer_name`, `customer_phone`, `customer_email`, `ground_id`, `start_time`, `end_time`, `total_price`, `players`, `status`, `rejection_reason`, `payment_status`, `payment_expires_at`, `payment_method`, `created_at`, `updated_at`) VALUES
(1, 7, NULL, NULL, NULL, 4, '2026-02-26 10:00:20', '2026-02-26 12:00:20', 1600.00, 1, 'confirmed', NULL, 'paid', NULL, NULL, '2026-02-24 13:38:20', '2026-02-24 13:38:20'),
(2, 7, NULL, NULL, NULL, 5, '2026-02-27 18:00:20', '2026-02-27 20:00:20', 3600.00, 1, 'confirmed', NULL, 'paid', NULL, NULL, '2026-02-24 13:38:20', '2026-02-24 13:38:20');

-- --------------------------------------------------------

--
-- Table structure for table `cache`
--

CREATE TABLE `cache` (
  `key` varchar(255) NOT NULL,
  `value` mediumtext NOT NULL,
  `expiration` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `cache`
--

INSERT INTO `cache` (`key`, `value`, `expiration`) VALUES
('sports-studio-cache-17ba0791499db908433b80f37c5fbc89b870084b', 'i:3;', 1772625113),
('sports-studio-cache-17ba0791499db908433b80f37c5fbc89b870084b:timer', 'i:1772625113;', 1772625113),
('sports-studio-cache-424f74a6a7ed4d4ed4761507ebcd209a6ef0937b', 'i:2;', 1772625115),
('sports-studio-cache-424f74a6a7ed4d4ed4761507ebcd209a6ef0937b:timer', 'i:1772625115;', 1772625115),
('sports-studio-cache-b1d5781111d84f7b3fe45a0852e59758cd7a87e5', 'i:2;', 1772625115),
('sports-studio-cache-b1d5781111d84f7b3fe45a0852e59758cd7a87e5:timer', 'i:1772625115;', 1772625115);

-- --------------------------------------------------------

--
-- Table structure for table `cache_locks`
--

CREATE TABLE `cache_locks` (
  `key` varchar(255) NOT NULL,
  `owner` varchar(255) NOT NULL,
  `expiration` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
  `latitude` decimal(10,8) DEFAULT NULL,
  `longitude` decimal(11,8) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `rating` decimal(3,2) NOT NULL DEFAULT 0.00,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `images` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`images`)),
  `amenities` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`amenities`)),
  `status` varchar(255) NOT NULL DEFAULT 'active'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `complexes`
--

INSERT INTO `complexes` (`id`, `owner_id`, `name`, `slug`, `address`, `latitude`, `longitude`, `description`, `rating`, `created_at`, `updated_at`, `images`, `amenities`, `status`) VALUES
(1, 6, 'Victory Sports Arena', NULL, '123 Stadium Road, Downtown', NULL, NULL, 'Premier indoor sports facility with state-of-the-art turf.', 0.00, '2026-02-24 13:38:19', '2026-02-24 13:38:19', '[\"https:\\/\\/images.unsplash.com\\/photo-1577223625816-7546f13dfbb5?w=800\"]', NULL, 'active'),
(2, 6, 'Elite Cricket Zone', NULL, '45 Green Park, Westside', NULL, NULL, 'Dedicated box cricket arenas for professionals.', 0.00, '2026-02-24 13:38:19', '2026-02-24 13:38:19', '[\"https:\\/\\/images.unsplash.com\\/photo-1531415074968-036ba1b575da?w=800\"]', NULL, 'active');

-- --------------------------------------------------------

--
-- Table structure for table `deals`
--

CREATE TABLE `deals` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `code` varchar(255) DEFAULT NULL,
  `discount_percentage` decimal(5,2) NOT NULL,
  `valid_until` datetime NOT NULL,
  `applicable_sports` varchar(255) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `color_theme` varchar(255) NOT NULL DEFAULT 'from-primary to-primary/80',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `owner_id` bigint(20) UNSIGNED DEFAULT NULL,
  `ground_id` bigint(20) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `deals`
--

INSERT INTO `deals` (`id`, `title`, `description`, `code`, `discount_percentage`, `valid_until`, `applicable_sports`, `is_active`, `color_theme`, `created_at`, `updated_at`, `owner_id`, `ground_id`) VALUES
(1, 'Morning Bird Special', 'Book any ground between 6 AM - 9 AM and get 30% off', 'MORNING30', 30.00, '2026-02-26 18:38:20', 'All Sports', 1, 'from-primary to-primary/80', '2026-02-24 13:38:20', '2026-02-24 13:38:20', NULL, NULL),
(2, 'Weekend Warrior', 'Flat 25% off on all weekend bookings. Play more, pay less!', 'WEEKEND25', 25.00, '2026-03-01 18:38:20', 'Cricket & Football', 1, 'from-accent to-accent/80', '2026-02-24 13:38:20', '2026-02-24 13:38:20', NULL, NULL),
(3, 'Group Booking Bonus', 'Book 3+ hours and get 1 hour free. Perfect for tournaments!', 'GROUP20', 20.00, '2026-03-03 18:38:20', 'All Sports', 1, 'from-secondary to-secondary/80', '2026-02-24 13:38:20', '2026-02-24 13:38:20', NULL, NULL);

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
  `registration_fee` decimal(8,2) NOT NULL DEFAULT 0.00,
  `max_participants` int(11) DEFAULT NULL,
  `status` varchar(255) NOT NULL DEFAULT 'upcoming',
  `event_type` varchar(255) NOT NULL DEFAULT 'public',
  `is_vip` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `image` varchar(255) DEFAULT NULL,
  `images` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`images`)),
  `location` varchar(255) DEFAULT NULL,
  `latitude` decimal(10,8) DEFAULT NULL,
  `longitude` decimal(11,8) DEFAULT NULL,
  `rules` text DEFAULT NULL,
  `safety_policy` text DEFAULT NULL,
  `schedule` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`schedule`))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `events`
--

INSERT INTO `events` (`id`, `organizer_id`, `booking_id`, `name`, `slug`, `description`, `start_time`, `end_time`, `registration_fee`, `max_participants`, `status`, `event_type`, `is_vip`, `created_at`, `updated_at`, `image`, `images`, `location`, `latitude`, `longitude`, `rules`, `safety_policy`, `schedule`) VALUES
(2, 8, NULL, 'Winter Cricket Bash 2026', NULL, 'Join the biggest amateur cricket tournament of the season!', '2026-03-06 09:00:19', '2026-03-06 18:00:19', 500.00, 16, 'published', 'public', 0, '2026-02-24 13:38:19', '2026-02-24 13:38:19', 'https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?w=800', NULL, 'Victory Sports Arena', NULL, NULL, NULL, NULL, NULL),
(3, 8, NULL, 'Sunday Football League', NULL, '5-a-side football league. Every Sunday.', '2026-03-01 16:00:19', '2026-03-01 20:00:19', 200.00, 8, 'published', 'public', 0, '2026-02-24 13:38:19', '2026-02-24 13:38:19', 'https://images.unsplash.com/photo-1579952363873-27f3bade9f55?w=800', NULL, 'Victory Sports Arena', NULL, NULL, NULL, NULL, NULL),
(4, 8, NULL, 'Corporate Box Cricket Cup', NULL, 'Team building event for local companies.', '2026-03-11 10:00:19', '2026-03-11 17:00:19', 3000.00, 12, 'published', 'public', 0, '2026-02-24 13:38:19', '2026-02-24 13:38:19', 'https://images.unsplash.com/photo-1531415074968-036ba1b575da?w=800', NULL, 'Elite Cricket Zone', NULL, NULL, NULL, NULL, NULL),
(5, 8, NULL, 'Badminton Pro League', NULL, 'Singles and Doubles tournament.', '2026-03-16 09:00:19', '2026-03-16 16:00:19', 1000.00, 32, 'published', 'public', 0, '2026-02-24 13:38:19', '2026-02-24 13:38:19', 'https://images.unsplash.com/photo-1622279457486-640fc202970a?w=800', NULL, 'Victory Sports Arena', NULL, NULL, NULL, NULL, NULL),
(6, 8, NULL, '3v3 Street Basketball', NULL, 'Fast-paced half-court basketball tournament.', '2026-03-21 17:00:19', '2026-03-21 22:00:19', 1500.00, 24, 'published', 'private', 0, '2026-02-24 13:38:19', '2026-02-24 13:38:19', 'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=800', NULL, 'Elite Cricket Zone', NULL, NULL, NULL, NULL, NULL);

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `event_participants`
--

INSERT INTO `event_participants` (`id`, `event_id`, `user_id`, `name`, `email`, `is_manual`, `status`, `payment_expires_at`, `payment_status`, `payment_method`, `rejection_reason`, `message`, `created_at`, `updated_at`) VALUES
(1, 2, 7, NULL, NULL, 0, 'accepted', NULL, 'unpaid', NULL, NULL, 'Joining this event!', '2026-02-24 13:38:20', '2026-02-24 13:38:20'),
(2, 3, 7, NULL, NULL, 0, 'accepted', NULL, 'unpaid', NULL, NULL, 'Joining this event!', '2026-02-24 13:38:20', '2026-02-24 13:38:20'),
(3, 4, 7, NULL, NULL, 0, 'accepted', NULL, 'unpaid', NULL, NULL, 'Joining this event!', '2026-02-24 13:38:20', '2026-02-24 13:38:20'),
(4, 5, 7, NULL, NULL, 0, 'accepted', NULL, 'unpaid', NULL, NULL, 'Joining this event!', '2026-02-24 13:38:20', '2026-02-24 13:38:20'),
(5, 6, 7, NULL, NULL, 0, 'accepted', NULL, 'unpaid', NULL, NULL, 'Joining this event!', '2026-02-24 13:38:20', '2026-02-24 13:38:20');

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
  `price_per_hour` decimal(8,2) NOT NULL,
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `grounds`
--

INSERT INTO `grounds` (`id`, `complex_id`, `name`, `slug`, `description`, `price_per_hour`, `opening_time`, `closing_time`, `dimensions`, `type`, `created_at`, `updated_at`, `images`, `amenities`, `lighting`, `status`) VALUES
(1, 1, 'Main Cricket Turf', 'main-cricket-turf-2zefI', 'International standard size turf.', 1500.00, '08:00:00', '22:00:00', NULL, 'Cricket', '2026-02-24 13:38:19', '2026-02-24 15:16:58', '[\"https:\\/\\/images.unsplash.com\\/photo-1624880357913-a8539238245b?w=800\"]', NULL, 1, 'active'),
(2, 1, '5-a-side Football', '5-a-side-football-AYUiJ', 'High quality astro-turf for football.', 1200.00, '08:00:00', '22:00:00', NULL, 'Football', '2026-02-24 13:38:19', '2026-02-24 15:16:58', '[\"https:\\/\\/images.unsplash.com\\/photo-1575361204480-aadea25e6e68?w=800\"]', NULL, 1, 'active'),
(3, 2, 'Box Cricket A', 'box-cricket-a-IYhfx', 'Perfect for corporate tournaments.', 1000.00, '08:00:00', '22:00:00', NULL, 'Cricket', '2026-02-24 13:38:19', '2026-02-24 15:16:58', '[\"https:\\/\\/images.unsplash.com\\/photo-1593341646261-079c5285647f?w=800\"]', NULL, 1, 'active'),
(4, 1, 'Badminton Court 1', 'badminton-court-1-OWB5N', 'Wooden court with professional lighting.', 800.00, '08:00:00', '22:00:00', NULL, 'Badminton', '2026-02-24 13:38:19', '2026-02-24 15:16:58', '[\"https:\\/\\/images.unsplash.com\\/photo-1622279457486-640fc202970a?w=800\"]', NULL, 1, 'active'),
(5, 2, 'Basketball Full Court', 'basketball-full-court-3f5cL', 'FIBA standard full court.', 1800.00, '08:00:00', '22:00:00', NULL, 'Basketball', '2026-02-24 13:38:19', '2026-02-24 15:16:58', '[\"https:\\/\\/images.unsplash.com\\/photo-1546519638-68e109498ffc?w=800\"]', NULL, 1, 'active');

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `jobs`
--

INSERT INTO `jobs` (`id`, `queue`, `payload`, `attempts`, `reserved_at`, `available_at`, `created_at`) VALUES
(1, 'default', '{\"uuid\":\"9ec59583-b5e5-4307-83ca-cbc21e53a049\",\"displayName\":\"App\\\\Notifications\\\\WelcomeNotification\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"Illuminate\\\\Notifications\\\\SendQueuedNotifications\",\"command\":\"O:48:\\\"Illuminate\\\\Notifications\\\\SendQueuedNotifications\\\":3:{s:11:\\\"notifiables\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:15:\\\"App\\\\Models\\\\User\\\";s:2:\\\"id\\\";a:1:{i:0;i:9;}s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:12:\\\"notification\\\";O:37:\\\"App\\\\Notifications\\\\WelcomeNotification\\\":1:{s:2:\\\"id\\\";s:36:\\\"b3dc8450-2f82-49c4-bf67-e68ca1e99400\\\";}s:8:\\\"channels\\\";a:1:{i:0;s:8:\\\"database\\\";}}\"},\"createdAt\":1771958349,\"delay\":null}', 0, NULL, 1771958349, 1771958349),
(2, 'default', '{\"uuid\":\"fc1d9bf0-c1ef-46ec-8188-c44c6117d136\",\"displayName\":\"App\\\\Notifications\\\\WelcomeNotification\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"Illuminate\\\\Notifications\\\\SendQueuedNotifications\",\"command\":\"O:48:\\\"Illuminate\\\\Notifications\\\\SendQueuedNotifications\\\":3:{s:11:\\\"notifiables\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:15:\\\"App\\\\Models\\\\User\\\";s:2:\\\"id\\\";a:1:{i:0;i:9;}s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:12:\\\"notification\\\";O:37:\\\"App\\\\Notifications\\\\WelcomeNotification\\\":1:{s:2:\\\"id\\\";s:36:\\\"b3dc8450-2f82-49c4-bf67-e68ca1e99400\\\";}s:8:\\\"channels\\\";a:1:{i:0;s:4:\\\"mail\\\";}}\"},\"createdAt\":1771958349,\"delay\":null}', 0, NULL, 1771958349, 1771958349),
(3, 'default', '{\"uuid\":\"7cd024ba-814e-4050-9581-31fbeb41952a\",\"displayName\":\"App\\\\Notifications\\\\WelcomeNotification\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"Illuminate\\\\Notifications\\\\SendQueuedNotifications\",\"command\":\"O:48:\\\"Illuminate\\\\Notifications\\\\SendQueuedNotifications\\\":3:{s:11:\\\"notifiables\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:15:\\\"App\\\\Models\\\\User\\\";s:2:\\\"id\\\";a:1:{i:0;i:10;}s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:12:\\\"notification\\\";O:37:\\\"App\\\\Notifications\\\\WelcomeNotification\\\":1:{s:2:\\\"id\\\";s:36:\\\"b3cdd897-8f6f-4f08-a4c6-68b8a2862fe1\\\";}s:8:\\\"channels\\\";a:1:{i:0;s:8:\\\"database\\\";}}\"},\"createdAt\":1771979036,\"delay\":null}', 0, NULL, 1771979036, 1771979036),
(4, 'default', '{\"uuid\":\"5997ccba-d02d-4def-a17a-62194cf8a2aa\",\"displayName\":\"App\\\\Notifications\\\\WelcomeNotification\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"Illuminate\\\\Notifications\\\\SendQueuedNotifications\",\"command\":\"O:48:\\\"Illuminate\\\\Notifications\\\\SendQueuedNotifications\\\":3:{s:11:\\\"notifiables\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:15:\\\"App\\\\Models\\\\User\\\";s:2:\\\"id\\\";a:1:{i:0;i:10;}s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:12:\\\"notification\\\";O:37:\\\"App\\\\Notifications\\\\WelcomeNotification\\\":1:{s:2:\\\"id\\\";s:36:\\\"b3cdd897-8f6f-4f08-a4c6-68b8a2862fe1\\\";}s:8:\\\"channels\\\";a:1:{i:0;s:4:\\\"mail\\\";}}\"},\"createdAt\":1771979036,\"delay\":null}', 0, NULL, 1771979036, 1771979036),
(5, 'default', '{\"uuid\":\"f1ec3cb2-c377-4dfa-83b7-9c3182c0e278\",\"displayName\":\"App\\\\Notifications\\\\WelcomeNotification\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"Illuminate\\\\Notifications\\\\SendQueuedNotifications\",\"command\":\"O:48:\\\"Illuminate\\\\Notifications\\\\SendQueuedNotifications\\\":3:{s:11:\\\"notifiables\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:15:\\\"App\\\\Models\\\\User\\\";s:2:\\\"id\\\";a:1:{i:0;i:11;}s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:12:\\\"notification\\\";O:37:\\\"App\\\\Notifications\\\\WelcomeNotification\\\":1:{s:2:\\\"id\\\";s:36:\\\"51e9328e-2edc-4e8c-952e-7567c8e30eaf\\\";}s:8:\\\"channels\\\";a:1:{i:0;s:8:\\\"database\\\";}}\"},\"createdAt\":1772619797,\"delay\":null}', 0, NULL, 1772619797, 1772619797),
(6, 'default', '{\"uuid\":\"e695a0cb-85bf-4436-9b09-efb62d5489d7\",\"displayName\":\"App\\\\Notifications\\\\WelcomeNotification\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"Illuminate\\\\Notifications\\\\SendQueuedNotifications\",\"command\":\"O:48:\\\"Illuminate\\\\Notifications\\\\SendQueuedNotifications\\\":3:{s:11:\\\"notifiables\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:15:\\\"App\\\\Models\\\\User\\\";s:2:\\\"id\\\";a:1:{i:0;i:11;}s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:12:\\\"notification\\\";O:37:\\\"App\\\\Notifications\\\\WelcomeNotification\\\":1:{s:2:\\\"id\\\";s:36:\\\"51e9328e-2edc-4e8c-952e-7567c8e30eaf\\\";}s:8:\\\"channels\\\";a:1:{i:0;s:4:\\\"mail\\\";}}\"},\"createdAt\":1772619798,\"delay\":null}', 0, NULL, 1772619798, 1772619798);

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `migrations`
--

CREATE TABLE `migrations` (
  `id` int(10) UNSIGNED NOT NULL,
  `migration` varchar(255) NOT NULL,
  `batch` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(16, '2026_01_27_085522_create_deals_table', 1),
(17, '2026_01_27_100221_add_images_to_tables', 1),
(18, '2026_01_28_063424_add_slug_to_grounds_table', 1),
(19, '2026_01_28_071839_add_extra_fields_to_grounds_and_events_tables', 1),
(20, '2026_01_28_112158_add_players_to_bookings_table', 1),
(21, '2026_01_28_114710_create_notifications_table', 1),
(22, '2026_02_03_143000_add_details_to_complexes_table', 1),
(23, '2026_02_04_114430_create_favorites_table', 1),
(24, '2026_02_06_031153_add_images_to_events_table', 1),
(25, '2026_02_06_033250_create_event_participants_table', 1),
(26, '2026_02_06_093202_add_lat_lng_to_complexes_and_events', 1),
(27, '2026_02_06_095531_add_google_id_to_users_table', 1),
(28, '2026_02_06_100812_add_rejection_reason_to_bookings_table', 1),
(29, '2026_02_06_101201_add_rejection_reason_to_event_participants_table', 1),
(30, '2026_02_06_102043_add_payment_method_to_bookings_and_participants', 1),
(31, '2026_02_06_105117_add_slug_to_complexes_table', 1),
(32, '2026_02_06_112926_create_reviews_table', 1),
(33, '2026_02_06_130330_add_operating_hours_to_grounds_table', 1),
(34, '2026_02_06_185000_add_payment_status_to_event_participants', 1),
(35, '2026_02_09_052341_add_fcm_token_to_users_table', 1),
(36, '2026_02_09_120020_add_phone_verified_at_to_users_table', 1),
(37, '2026_02_09_132105_add_event_type_to_events_table', 1),
(38, '2026_02_10_091653_add_payment_expires_at_to_bookings_and_participants_table', 1),
(39, '2026_02_10_121643_create_teams_table', 1),
(40, '2026_02_10_121644_create_team_members_table', 1),
(41, '2026_02_10_135713_make_user_id_nullable_on_bookings_table', 1),
(42, '2026_02_11_094001_add_customer_email_to_bookings_table', 1),
(43, '2026_02_11_105635_add_status_to_grounds_table', 1),
(44, '2026_02_11_115311_add_owner_and_ground_to_deals_table', 1),
(45, '2026_02_11_115558_add_business_name_to_users_table', 1),
(46, '2026_02_12_114500_add_apple_id_to_users_table', 1);

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `password_reset_tokens`
--

CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) NOT NULL,
  `token` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `personal_access_tokens`
--

INSERT INTO `personal_access_tokens` (`id`, `tokenable_type`, `tokenable_id`, `name`, `token`, `abilities`, `last_used_at`, `expires_at`, `created_at`, `updated_at`) VALUES
(5, 'App\\Models\\User', 9, 'auth_token', '1a7af8639165f405035d6be74e1e438f40b9f548b6599b4a535b30911a8d1638', '[\"*\"]', '2026-02-24 14:07:42', NULL, '2026-02-24 13:39:09', '2026-02-24 14:07:42'),
(7, 'App\\Models\\User', 9, 'auth_token', '2bf845fecacb47e18058fe12c399ca9684691ca04428223681a6476efcdaec41', '[\"*\"]', '2026-02-24 19:18:16', NULL, '2026-02-24 15:05:36', '2026-02-24 19:18:16'),
(8, 'App\\Models\\User', 10, 'auth_token', 'a2d61f442b4b248fb65c9be447b4c8cd47a3c8712ca03fded4493a41da6020f9', '[\"*\"]', '2026-02-24 19:31:52', NULL, '2026-02-24 19:23:56', '2026-02-24 19:31:52'),
(9, 'App\\Models\\User', 10, 'auth_token', '1b5723391b6abe5891c7b5215d7500936eb54036cc45dfecc90365c8d3075a76', '[\"*\"]', '2026-02-24 19:54:24', NULL, '2026-02-24 19:50:27', '2026-02-24 19:54:24'),
(10, 'App\\Models\\User', 10, 'auth_token', '7378de5d799ecaac4d68604592952e0b5fe151645ebde669a9ac99ea17ae6af4', '[\"*\"]', '2026-02-24 19:56:31', NULL, '2026-02-24 19:54:34', '2026-02-24 19:56:31'),
(11, 'App\\Models\\User', 10, 'auth_token', 'a223464aa7300930ce3129a9b8fc8b6e98b1e1d101cdfc4aa8f3a7cc750de297', '[\"*\"]', '2026-02-25 00:45:07', NULL, '2026-02-25 00:39:12', '2026-02-25 00:45:07'),
(12, 'App\\Models\\User', 10, 'auth_token', 'f5365df898bb1d7132d22c94c4afb616ed399b3496e6f51dcf8bcc6529ee867a', '[\"*\"]', '2026-03-04 11:50:56', NULL, '2026-02-25 00:45:16', '2026-03-04 11:50:56'),
(13, 'App\\Models\\User', 11, 'auth_token', '6a7d30a2305777e2b702a64db9207f410dfa730c450e2ae34298bea76b03d196', '[\"*\"]', '2026-03-04 11:50:55', NULL, '2026-03-04 10:23:18', '2026-03-04 11:50:55');

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `transactions`
--

CREATE TABLE `transactions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(255) NOT NULL,
  `category` varchar(255) DEFAULT NULL,
  `amount` decimal(10,2) NOT NULL,
  `type` varchar(255) NOT NULL,
  `date` date NOT NULL,
  `description` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `google_id`, `apple_id`, `email_verified_at`, `password`, `remember_token`, `created_at`, `updated_at`, `phone`, `business_name`, `notification_preferences`, `fcm_token`, `phone_verified_at`, `role`, `is_active`, `avatar`) VALUES
(5, 'Super Admin', 'admin@example.com', NULL, NULL, NULL, '$2y$12$frlXtqRz5QA.zJgzxVHNQ.HmLVmnDgMsyQeVGhlKigVbDvu1geQrq', NULL, '2026-02-24 13:38:18', '2026-02-24 13:38:18', '1234567890', NULL, NULL, NULL, NULL, 'admin', 1, NULL),
(6, 'Venue Owner', 'owner@example.com', NULL, NULL, NULL, '$2y$12$kCDuC6WY/339ZfAMJjuSKuD3mnZb9P2jaX60bAZJUP7LIoLhdbsCO', NULL, '2026-02-24 13:38:18', '2026-02-24 13:38:18', '0987654321', NULL, NULL, NULL, NULL, 'owner', 1, NULL),
(7, 'John Doe', 'user@example.com', NULL, NULL, NULL, '$2y$12$fzdccaiDa4z7RRIc.b.wtesyKRNojyZginbbDHQjiPsCrajelubz.', NULL, '2026-02-24 13:38:18', '2026-02-24 13:38:18', '1122334455', NULL, NULL, NULL, NULL, 'user', 1, NULL),
(8, 'Event Organizer', 'organizer@example.com', NULL, NULL, NULL, '$2y$12$Ms9qDHTalZ1o9btgLV0R8.FkCeOTSGFp54B.yJ8me.zWD7AN2cnsy', NULL, '2026-02-24 13:38:19', '2026-02-24 13:38:19', '5544332211', NULL, NULL, NULL, NULL, 'organizer', 1, NULL),
(10, 'Fahad Latif', 'fahadlatif752@gmail.com', '102653151814827717029', NULL, NULL, '$2y$12$LY.ed5AM6.V4WMQZE75P4.VT/7QxBFRuKii.XgOGWEHUE3lSXKacK', NULL, '2026-02-24 19:23:55', '2026-02-25 00:45:32', '+923421316906', NULL, NULL, NULL, NULL, 'user', 1, 'https://lh3.googleusercontent.com/a/ACg8ocI8nwxE7Y01r2gFafPVP4yaVy4kiXUzS-IJ-oB-wtE9oDwnIg=s96-c'),
(11, 'Ahsan Ali', 'coxjordon38@gmail.com', '115549205437875917104', NULL, NULL, '$2y$12$lhVrLAorgm1v3fxAa/h9U./9d.GFA/XnIVIqsDO/OMAPmlgMpchq6', NULL, '2026-03-04 10:23:17', '2026-03-04 10:23:55', NULL, NULL, NULL, NULL, NULL, 'user', 1, 'uploads/avatars/1772619835_11.png');

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
  ADD UNIQUE KEY `event_participants_event_id_user_id_unique` (`event_id`,`user_id`),
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
  ADD UNIQUE KEY `favorites_user_id_ground_id_unique` (`user_id`,`ground_id`),
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
  ADD KEY `media_model_type_model_id_index` (`model_type`,`model_id`);

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
  ADD KEY `notifications_notifiable_type_notifiable_id_index` (`notifiable_type`,`notifiable_id`);

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
  ADD KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`),
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
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `complexes`
--
ALTER TABLE `complexes`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `deals`
--
ALTER TABLE `deals`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `events`
--
ALTER TABLE `events`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `event_participants`
--
ALTER TABLE `event_participants`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `favorites`
--
ALTER TABLE `favorites`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `grounds`
--
ALTER TABLE `grounds`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `jobs`
--
ALTER TABLE `jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `media`
--
ALTER TABLE `media`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=47;

--
-- AUTO_INCREMENT for table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `reviews`
--
ALTER TABLE `reviews`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `teams`
--
ALTER TABLE `teams`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `team_members`
--
ALTER TABLE `team_members`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `transactions`
--
ALTER TABLE `transactions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

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
  ADD CONSTRAINT `events_booking_id_foreign` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`) ON DELETE SET NULL,
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
  ADD CONSTRAINT `reviews_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

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

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
