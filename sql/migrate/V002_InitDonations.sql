/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


CREATE DATABASE IF NOT EXISTS `donations` /*!40100 DEFAULT CHARACTER SET utf8 */;
USE `donations`;

-- Дамп структуры для таблица council_suggestions
CREATE TABLE IF NOT EXISTS `council_suggestions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(150) DEFAULT NULL,
  `body` text DEFAULT NULL,
  `create_dt` datetime DEFAULT NULL,
  `resolve_dt` datetime DEFAULT NULL,
  `status` int(11) DEFAULT NULL,
  `channel` varchar(50) DEFAULT NULL,
  `init_message` varchar(50) DEFAULT NULL,
  `discuss_message` varchar(50) DEFAULT NULL,
  `voting_message` varchar(50) DEFAULT NULL,
  `result_message` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_council_suggestions_council_suggestion_statuses` (`status`),
  CONSTRAINT `FK_council_suggestions_council_suggestion_statuses` FOREIGN KEY (`status`) REFERENCES `council_suggestion_statuses` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8;

-- Экспортируемые данные не выделены.

-- Дамп структуры для таблица council_suggestion_statuses
CREATE TABLE IF NOT EXISTS `council_suggestion_statuses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;

-- Экспортируемые данные не выделены.

-- Дамп структуры для таблица council_suggestion_votes
CREATE TABLE IF NOT EXISTS `council_suggestion_votes` (
  `suggestion` int(11) NOT NULL,
  `discord_user` varchar(50) NOT NULL,
  `value` int(11) NOT NULL,
  `comment` text DEFAULT NULL,
  `datetime` datetime NOT NULL,
  PRIMARY KEY (`suggestion`,`discord_user`),
  KEY `FK_council_suggestion_votes_discord_users` (`discord_user`),
  CONSTRAINT `FK_council_suggestion_votes_council_suggestions` FOREIGN KEY (`suggestion`) REFERENCES `council_suggestions` (`id`),
  CONSTRAINT `FK_council_suggestion_votes_discord_users` FOREIGN KEY (`discord_user`) REFERENCES `discord_users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Экспортируемые данные не выделены.

-- Дамп структуры для таблица discord_roles
CREATE TABLE IF NOT EXISTS `discord_roles` (
  `id` varchar(50) NOT NULL,
  `title` varchar(50) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Экспортируемые данные не выделены.

-- Дамп структуры для таблица discord_users
CREATE TABLE IF NOT EXISTS `discord_users` (
  `id` varchar(50) NOT NULL,
  `nickname` varchar(50) CHARACTER SET utf8mb4 DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Экспортируемые данные не выделены.

-- Дамп структуры для таблица discord_user_roles
CREATE TABLE IF NOT EXISTS `discord_user_roles` (
  `id` varchar(50) NOT NULL,
  `user` varchar(50) CHARACTER SET utf8 NOT NULL,
  `role` varchar(50) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_discord_user_roles_discord_users` (`user`),
  KEY `FK_discord_user_roles_discord_roles` (`role`),
  CONSTRAINT `FK_discord_user_roles_discord_roles` FOREIGN KEY (`role`) REFERENCES `discord_roles` (`id`),
  CONSTRAINT `FK_discord_user_roles_discord_users` FOREIGN KEY (`user`) REFERENCES `discord_users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Экспортируемые данные не выделены.

-- Дамп структуры для таблица donations_types
CREATE TABLE IF NOT EXISTS `donations_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(32) DEFAULT NULL,
  KEY `Primary Key` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

-- Экспортируемые данные не выделены.

-- Дамп структуры для таблица issues
CREATE TABLE IF NOT EXISTS `issues` (
  `id` int(11) NOT NULL,
  `votes` int(11) DEFAULT NULL,
  `points` float DEFAULT NULL,
  `close_votes` int(11) DEFAULT NULL,
  `bounty` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Экспортируемые данные не выделены.

-- Дамп структуры для таблица issues_design_approves
CREATE TABLE IF NOT EXISTS `issues_design_approves` (
  `issue` int(11) NOT NULL,
  `discord_user` varchar(50) NOT NULL,
  `value` int(11) NOT NULL,
  `date` datetime NOT NULL,
  `suspended` int(11) DEFAULT NULL,
  PRIMARY KEY (`issue`,`discord_user`) USING BTREE,
  KEY `FK_issues_votes_discord_users` (`discord_user`) USING BTREE,
  CONSTRAINT `issues_design_approves_ibfk_1` FOREIGN KEY (`discord_user`) REFERENCES `discord_users` (`id`),
  CONSTRAINT `issues_design_approves_ibfk_2` FOREIGN KEY (`issue`) REFERENCES `issues` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

-- Экспортируемые данные не выделены.

-- Дамп структуры для таблица issues_points
CREATE TABLE IF NOT EXISTS `issues_points` (
  `issue` int(11) NOT NULL,
  `discord_user` varchar(50) NOT NULL,
  `points` float NOT NULL,
  `datetime` datetime NOT NULL,
  `transaction` int(11) NOT NULL,
  PRIMARY KEY (`issue`,`discord_user`),
  KEY `FK_issues_points_discord_users` (`discord_user`),
  KEY `FK_issues_points_points_transactions` (`transaction`),
  CONSTRAINT `FK_issues_points_discord_users` FOREIGN KEY (`discord_user`) REFERENCES `discord_users` (`id`),
  CONSTRAINT `FK_issues_points_issues` FOREIGN KEY (`issue`) REFERENCES `issues` (`id`),
  CONSTRAINT `FK_issues_points_points_transactions` FOREIGN KEY (`transaction`) REFERENCES `points_transactions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Экспортируемые данные не выделены.

-- Дамп структуры для таблица issues_votes
CREATE TABLE IF NOT EXISTS `issues_votes` (
  `issue` int(11) NOT NULL,
  `discord_user` varchar(50) NOT NULL,
  `value` int(11) NOT NULL,
  `date` datetime NOT NULL,
  `suspended` int(11) DEFAULT NULL,
  PRIMARY KEY (`issue`,`discord_user`),
  KEY `FK_issues_votes_discord_users` (`discord_user`),
  CONSTRAINT `FK_issues_votes_discord_users` FOREIGN KEY (`discord_user`) REFERENCES `discord_users` (`id`),
  CONSTRAINT `FK_issues_votes_issues` FOREIGN KEY (`issue`) REFERENCES `issues` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Экспортируемые данные не выделены.

-- Дамп структуры для таблица karma
CREATE TABLE IF NOT EXISTS `karma` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `to` int(11) NOT NULL,
  `from` int(11) NOT NULL,
  `change` int(11) NOT NULL,
  `datetime` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_karma_players` (`to`),
  KEY `FK_karma_players_2` (`from`),
  CONSTRAINT `FK_karma_players` FOREIGN KEY (`to`) REFERENCES `players` (`id`),
  CONSTRAINT `FK_karma_players_2` FOREIGN KEY (`from`) REFERENCES `players` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=83 DEFAULT CHARSET=utf8;

-- Экспортируемые данные не выделены.

-- Дамп структуры для таблица message_to_issue
CREATE TABLE IF NOT EXISTS `message_to_issue` (
  `message_id` varchar(50) NOT NULL DEFAULT '',
  `issue_id` int(11) NOT NULL,
  PRIMARY KEY (`message_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Экспортируемые данные не выделены.

-- Дамп структуры для таблица money_currencies
CREATE TABLE IF NOT EXISTS `money_currencies` (
  `id` int(11) NOT NULL,
  `name` varchar(50) NOT NULL,
  `division` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Экспортируемые данные не выделены.

-- Дамп структуры для таблица money_transactions
CREATE TABLE IF NOT EXISTS `money_transactions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `datetime` datetime NOT NULL,
  `currency` int(11) NOT NULL,
  `change` int(11) NOT NULL DEFAULT 0,
  `reason` text NOT NULL DEFAULT '',
  `player` int(11) DEFAULT NULL,
  `donation_type` int(11) DEFAULT NULL,
  `issue` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK__money_currencies` (`currency`),
  KEY `FK_money_transactions_issues` (`issue`),
  KEY `FK_money_transactions_players` (`player`),
  KEY `FK_money_transactions_donations_types` (`donation_type`),
  CONSTRAINT `FK__money_currencies` FOREIGN KEY (`currency`) REFERENCES `money_currencies` (`id`),
  CONSTRAINT `FK_money_transactions_donations_types` FOREIGN KEY (`donation_type`) REFERENCES `donations_types` (`id`),
  CONSTRAINT `FK_money_transactions_issues` FOREIGN KEY (`issue`) REFERENCES `issues` (`id`),
  CONSTRAINT `FK_money_transactions_players` FOREIGN KEY (`player`) REFERENCES `players` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=769 DEFAULT CHARSET=utf8mb4;

-- Экспортируемые данные не выделены.

-- Дамп структуры для таблица patron_types
CREATE TABLE IF NOT EXISTS `patron_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(32) NOT NULL,
  KEY `Primary Key` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8;

-- Экспортируемые данные не выделены.

-- Дамп структуры для таблица players
CREATE TABLE IF NOT EXISTS `players` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ckey` varchar(50) NOT NULL,
  `discord` varchar(50) DEFAULT NULL,
  `points` float DEFAULT 0,
  `patron_type` int(11) DEFAULT 0,
  `overall_donation` float DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `Индекс 4` (`ckey`),
  KEY `FK_players_discord_users` (`discord`),
  KEY `FK_players_patron_types` (`patron_type`),
  CONSTRAINT `FK_players_discord_users` FOREIGN KEY (`discord`) REFERENCES `discord_users` (`id`),
  CONSTRAINT `FK_players_patron_types` FOREIGN KEY (`patron_type`) REFERENCES `patron_types` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=805150 DEFAULT CHARSET=utf8;

-- Экспортируемые данные не выделены.

-- Дамп структуры для таблица points_transactions
CREATE TABLE IF NOT EXISTS `points_transactions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `player` int(11) NOT NULL,
  `type` int(11) NOT NULL,
  `datetime` datetime NOT NULL,
  `change` float NOT NULL,
  `comment` text DEFAULT NULL,
  KEY `Primary Key` (`id`),
  KEY `FK_points_transactions_players` (`player`),
  KEY `FK_points_transactions_points_transactions_types` (`type`),
  CONSTRAINT `FK_points_transactions_players` FOREIGN KEY (`player`) REFERENCES `players` (`id`),
  CONSTRAINT `FK_points_transactions_points_transactions_types` FOREIGN KEY (`type`) REFERENCES `points_transactions_types` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1778 DEFAULT CHARSET=utf8;

-- Экспортируемые данные не выделены.

-- Дамп структуры для таблица points_transactions_types
CREATE TABLE IF NOT EXISTS `points_transactions_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(32) DEFAULT NULL,
  KEY `Primary Key` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

-- Экспортируемые данные не выделены.

-- Дамп структуры для таблица runtimes
CREATE TABLE IF NOT EXISTS `runtimes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `date` datetime NOT NULL,
  `game_id` varchar(50) NOT NULL,
  `build_version` varchar(50) NOT NULL,
  `file` varchar(50) NOT NULL,
  `line` int(11) NOT NULL,
  `body` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=584431 DEFAULT CHARSET=utf8mb4;

-- Экспортируемые данные не выделены.

-- Дамп структуры для таблица store_players_items
CREATE TABLE IF NOT EXISTS `store_players_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `player` int(11) NOT NULL,
  `transaction` int(11) DEFAULT NULL,
  `obtaining_date` datetime DEFAULT NULL,
  `item_path` varchar(200) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_store_players_items_players` (`player`),
  KEY `FK_store_players_items_points_transactions` (`transaction`),
  CONSTRAINT `FK_store_players_items_players` FOREIGN KEY (`player`) REFERENCES `players` (`id`),
  CONSTRAINT `FK_store_players_items_points_transactions` FOREIGN KEY (`transaction`) REFERENCES `points_transactions` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=772 DEFAULT CHARSET=utf8mb4;

-- Экспортируемые данные не выделены.

-- Дамп структуры для таблица tokens
CREATE TABLE IF NOT EXISTS `tokens` (
  `token` varchar(50) NOT NULL,
  `discord` varchar(50) NOT NULL,
  PRIMARY KEY (`token`),
  KEY `FK_tokens_discord_users` (`discord`),
  CONSTRAINT `FK_tokens_discord_users` FOREIGN KEY (`discord`) REFERENCES `discord_users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Экспортируемые данные не выделены.

-- Дамп структуры для таблица _ARCHIVED_donations
CREATE TABLE IF NOT EXISTS `_ARCHIVED_donations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `player` int(11) NOT NULL,
  `type` int(11) NOT NULL,
  `datetime` datetime NOT NULL,
  `donation` float NOT NULL DEFAULT 0,
  `money_transaction` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_donations_donations_types` (`type`),
  KEY `FK_donations_players` (`player`),
  KEY `FK_donations_money_transactions` (`money_transaction`),
  CONSTRAINT `FK_donations_donations_types` FOREIGN KEY (`type`) REFERENCES `donations_types` (`id`),
  CONSTRAINT `FK_donations_money_transactions` FOREIGN KEY (`money_transaction`) REFERENCES `money_transactions` (`id`),
  CONSTRAINT `FK_donations_players` FOREIGN KEY (`player`) REFERENCES `players` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=109 DEFAULT CHARSET=utf8;

-- Экспортируемые данные не выделены.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
