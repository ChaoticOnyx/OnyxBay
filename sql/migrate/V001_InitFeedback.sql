/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

CREATE DATABASE IF NOT EXISTS `feedback` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `feedback`;

-- Дамп структуры для таблица blacklist_ip
CREATE TABLE IF NOT EXISTS `blacklist_ip` (
  `ip` int NOT NULL,
  PRIMARY KEY (`ip`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Экспортируемые данные не выделены.

-- Дамп структуры для таблица ckey_computerid
CREATE TABLE IF NOT EXISTS `ckey_computerid` (
  `id` int NOT NULL AUTO_INCREMENT,
  `ckey` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `computerid` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ckey` (`ckey`),
  KEY `computerid` (`computerid`)
) ENGINE=InnoDB AUTO_INCREMENT=276106 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Экспортируемые данные не выделены.

-- Дамп структуры для таблица ckey_ip
CREATE TABLE IF NOT EXISTS `ckey_ip` (
  `id` int NOT NULL AUTO_INCREMENT,
  `ckey` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `ip` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `ckey` (`ckey`) USING BTREE,
  KEY `computerid` (`ip`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=276106 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- Экспортируемые данные не выделены.

-- Дамп структуры для таблица connection
CREATE TABLE IF NOT EXISTS `connection` (
  `id` int NOT NULL AUTO_INCREMENT,
  `datetime` datetime DEFAULT NULL,
  `ckey` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `ip` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `computerid` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=102190 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Экспортируемые данные не выделены.

-- Дамп структуры для таблица eams_ban_provider
CREATE TABLE IF NOT EXISTS `eams_ban_provider` (
  `ip_as` varchar(255) NOT NULL,
  `ip_isp` varchar(255) NOT NULL,
  `ip_org` varchar(255) NOT NULL,
  `ip_country` varchar(255) NOT NULL,
  `ip_countryCode` varchar(255) NOT NULL,
  `ip_region` varchar(255) NOT NULL,
  `ip_regionCode` varchar(255) NOT NULL,
  `ip_city` varchar(255) NOT NULL,
  `ip_lat` float(7,2) NOT NULL,
  `ip_lon` float(7,2) NOT NULL,
  `ip_timezone` varchar(255) NOT NULL,
  `ip_zip` varchar(255) NOT NULL,
  `ip_reverse` varchar(255) NOT NULL,
  `ip_mobile` bit(1) NOT NULL,
  `ip_proxy` bit(1) NOT NULL,
  `type` bit(1) NOT NULL,
  `priority` bit(1) NOT NULL,
  `ckey` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='1';

-- Экспортируемые данные не выделены.

-- Дамп структуры для таблица eams_cache
CREATE TABLE IF NOT EXISTS `eams_cache` (
  `ip` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `response` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  PRIMARY KEY (`ip`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Экспортируемые данные не выделены.

-- Дамп структуры для таблица erro_admin
CREATE TABLE IF NOT EXISTS `erro_admin` (
  `id` int NOT NULL AUTO_INCREMENT,
  `ckey` varchar(32) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `rank` varchar(32) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT 'Administrator',
  `flags` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `UNIQUE` (`ckey`)
) ENGINE=InnoDB AUTO_INCREMENT=440 DEFAULT CHARSET=utf8mb3;

-- Экспортируемые данные не выделены.

-- Дамп структуры для таблица erro_ban
CREATE TABLE IF NOT EXISTS `erro_ban` (
  `id` int NOT NULL AUTO_INCREMENT,
  `bantime` datetime NOT NULL,
  `serverip` varchar(32) NOT NULL,
  `bantype` varchar(32) NOT NULL,
  `reason` text NOT NULL,
  `job` varchar(32) DEFAULT NULL,
  `duration` int NOT NULL,
  `rounds` int DEFAULT NULL,
  `expiration_time` datetime NOT NULL,
  `ckey` varchar(32) NOT NULL,
  `computerid` varchar(32) NOT NULL,
  `ip` varchar(32) NOT NULL,
  `a_ckey` varchar(32) NOT NULL,
  `a_computerid` varchar(32) NOT NULL,
  `a_ip` varchar(32) NOT NULL,
  `who` text NOT NULL,
  `adminwho` text NOT NULL,
  `edits` text,
  `unbanned` tinyint(1) DEFAULT NULL,
  `unbanned_datetime` datetime DEFAULT NULL,
  `unbanned_reason` text,
  `unbanned_ckey` varchar(32) DEFAULT NULL,
  `unbanned_computerid` varchar(32) DEFAULT NULL,
  `unbanned_ip` varchar(32) DEFAULT NULL,
  `server_id` varchar(32) NOT NULL,
  PRIMARY KEY (`id`,`server_id`)
) ENGINE=InnoDB AUTO_INCREMENT=91043 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=COMPACT;

-- Экспортируемые данные не выделены.

-- Дамп структуры для таблица erro_ban_latin1
CREATE TABLE IF NOT EXISTS `erro_ban_latin1` (
  `id` int NOT NULL AUTO_INCREMENT,
  `bantime` datetime NOT NULL,
  `serverip` varchar(32) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `bantype` varchar(32) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `reason` text CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `job` varchar(32) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `duration` int NOT NULL,
  `rounds` int DEFAULT NULL,
  `expiration_time` datetime NOT NULL,
  `ckey` varchar(32) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `computerid` varchar(32) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `ip` varchar(32) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `a_ckey` varchar(32) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `a_computerid` varchar(32) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `a_ip` varchar(32) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `who` text CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `adminwho` text CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `edits` text CHARACTER SET latin1 COLLATE latin1_swedish_ci,
  `unbanned` tinyint(1) DEFAULT NULL,
  `unbanned_datetime` datetime DEFAULT NULL,
  `unbanned_reason` text,
  `unbanned_ckey` varchar(32) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `unbanned_computerid` varchar(32) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `unbanned_ip` varchar(32) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `server_id` varchar(32) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  PRIMARY KEY (`id`,`server_id`)
) ENGINE=InnoDB AUTO_INCREMENT=82227 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=COMPACT;

-- Экспортируемые данные не выделены.

-- Дамп структуры для таблица erro_iaa_approved
CREATE TABLE IF NOT EXISTS `erro_iaa_approved` (
  `ckey` varchar(32) NOT NULL,
  `approvals` int DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Экспортируемые данные не выделены.

-- Дамп структуры для таблица erro_iaa_jobban
CREATE TABLE IF NOT EXISTS `erro_iaa_jobban` (
  `id` int NOT NULL AUTO_INCREMENT,
  `fakeid` varchar(6) NOT NULL,
  `ckey` varchar(32) NOT NULL,
  `iaa_ckey` varchar(32) NOT NULL,
  `other_ckeys` text NOT NULL,
  `reason` text NOT NULL,
  `job` varchar(32) NOT NULL,
  `creation_time` datetime NOT NULL,
  `resolve_time` datetime DEFAULT NULL,
  `resolve_comment` text,
  `resolve_ckey` varchar(32) DEFAULT NULL,
  `cancel_time` datetime DEFAULT NULL,
  `cancel_comment` text,
  `cancel_ckey` varchar(32) DEFAULT NULL,
  `status` varchar(32) NOT NULL,
  `expiration_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb3;

-- Экспортируемые данные не выделены.

-- Дамп структуры для таблица erro_player
CREATE TABLE IF NOT EXISTS `erro_player` (
  `id` int NOT NULL AUTO_INCREMENT,
  `ckey` varchar(32) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `firstseen` datetime NOT NULL,
  `lastseen` datetime NOT NULL,
  `ip` varchar(18) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `computerid` varchar(32) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `lastadminrank` varchar(32) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT 'Player',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ckey` (`ckey`)
) ENGINE=InnoDB AUTO_INCREMENT=40322 DEFAULT CHARSET=utf8mb3;

-- Экспортируемые данные не выделены.

-- Дамп структуры для таблица erro_watch
CREATE TABLE IF NOT EXISTS `erro_watch` (
  `ckey` varchar(32) NOT NULL,
  `reason` text NOT NULL,
  `adminckey` varchar(32) NOT NULL,
  `timestamp` datetime NOT NULL,
  `last_editor` varchar(32) DEFAULT NULL,
  `edits` text,
  PRIMARY KEY (`ckey`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=COMPACT;

-- Экспортируемые данные не выделены.

-- Дамп структуры для таблица erro_watch_latin1
CREATE TABLE IF NOT EXISTS `erro_watch_latin1` (
  `ckey` varchar(32) NOT NULL,
  `reason` text NOT NULL,
  `adminckey` varchar(32) NOT NULL,
  `timestamp` datetime NOT NULL,
  `last_editor` varchar(32) DEFAULT NULL,
  `edits` text,
  PRIMARY KEY (`ckey`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ROW_FORMAT=COMPACT;

-- Экспортируемые данные не выделены.

-- Дамп структуры для таблица ip2nation
CREATE TABLE IF NOT EXISTS `ip2nation` (
  `ip` int unsigned NOT NULL DEFAULT '0',
  `country` char(2) NOT NULL DEFAULT '',
  KEY `ip` (`ip`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Экспортируемые данные не выделены.

-- Дамп структуры для таблица ip2nationCountries
CREATE TABLE IF NOT EXISTS `ip2nationCountries` (
  `code` varchar(4) NOT NULL DEFAULT '',
  `iso_code_2` varchar(2) NOT NULL DEFAULT '',
  `iso_code_3` varchar(3) DEFAULT '',
  `iso_country` varchar(255) NOT NULL DEFAULT '',
  `country` varchar(255) NOT NULL DEFAULT '',
  `lat` float NOT NULL DEFAULT '0',
  `lon` float NOT NULL DEFAULT '0',
  PRIMARY KEY (`code`),
  KEY `code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Экспортируемые данные не выделены.

-- Дамп структуры для таблица library
CREATE TABLE IF NOT EXISTS `library` (
  `id` int NOT NULL AUTO_INCREMENT,
  `author` text NOT NULL,
  `title` text NOT NULL,
  `content` text NOT NULL,
  `category` text NOT NULL,
  `deleted` int DEFAULT NULL,
  `author_ckey` text CHARACTER SET latin1 COLLATE latin1_swedish_ci,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=912 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=COMPACT;

-- Экспортируемые данные не выделены.

-- Дамп структуры для таблица library_latin1
CREATE TABLE IF NOT EXISTS `library_latin1` (
  `id` int NOT NULL AUTO_INCREMENT,
  `author` text CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `title` text CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `content` text CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `category` text CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `deleted` int DEFAULT NULL,
  `author_ckey` text CHARACTER SET latin1 COLLATE latin1_swedish_ci,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=623 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=COMPACT;

-- Экспортируемые данные не выделены.

-- Дамп структуры для таблица old_erro_ban
CREATE TABLE IF NOT EXISTS `old_erro_ban` (
  `id` int NOT NULL AUTO_INCREMENT,
  `bantime` datetime NOT NULL,
  `serverip` varchar(32) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `bantype` varchar(32) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `reason` text CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `job` varchar(32) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `duration` int NOT NULL,
  `rounds` int DEFAULT NULL,
  `expiration_time` datetime NOT NULL,
  `ckey` varchar(32) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `computerid` varchar(32) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `ip` varchar(32) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `a_ckey` varchar(32) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `a_computerid` varchar(32) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `a_ip` varchar(32) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `who` text CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `adminwho` text CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `edits` text CHARACTER SET latin1 COLLATE latin1_swedish_ci,
  `unbanned` tinyint(1) DEFAULT NULL,
  `unbanned_datetime` datetime DEFAULT NULL,
  `unbanned_reason` text,
  `unbanned_ckey` varchar(32) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `unbanned_computerid` varchar(32) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `unbanned_ip` varchar(32) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=14581 DEFAULT CHARSET=utf8mb3;

-- Экспортируемые данные не выделены.

-- Дамп структуры для таблица serverids
CREATE TABLE IF NOT EXISTS `serverids` (
  `server_id` varchar(32) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  PRIMARY KEY (`server_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Экспортируемые данные не выделены.

-- Дамп структуры для таблица whitelist
CREATE TABLE IF NOT EXISTS `whitelist` (
  `id` int NOT NULL AUTO_INCREMENT,
  `ckey` text NOT NULL,
  `race` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Экспортируемые данные не выделены.

-- Дамп структуры для таблица whitelist_ckey
CREATE TABLE IF NOT EXISTS `whitelist_ckey` (
  `ckey` varchar(50) NOT NULL,
  PRIMARY KEY (`ckey`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Экспортируемые данные не выделены.

-- Дамп структуры для таблица Z_buys
CREATE TABLE IF NOT EXISTS `Z_buys` (
  `_id` int NOT NULL AUTO_INCREMENT,
  `byond` varchar(32) NOT NULL,
  `type` varchar(100) NOT NULL,
  PRIMARY KEY (`_id`)
) ENGINE=InnoDB AUTO_INCREMENT=733 DEFAULT CHARSET=utf8mb3;

-- Экспортируемые данные не выделены.

-- Дамп структуры для таблица Z_donators
CREATE TABLE IF NOT EXISTS `Z_donators` (
  `byond` varchar(32) NOT NULL DEFAULT '',
  `sum` float(7,2) NOT NULL DEFAULT '0.00',
  `current` float(7,2) NOT NULL DEFAULT '0.00',
  PRIMARY KEY (`byond`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Экспортируемые данные не выделены.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
