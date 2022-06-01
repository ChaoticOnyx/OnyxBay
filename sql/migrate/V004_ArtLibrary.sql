-- Дамп структуры для таблица art_library
CREATE TABLE IF NOT EXISTS `art_library` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ckey` text NOT NULL,
  `title` text NOT NULL,
  `data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`data`)),
  `deleted` int(11) DEFAULT NULL,
  `type` text DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=929 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=COMPACT;
