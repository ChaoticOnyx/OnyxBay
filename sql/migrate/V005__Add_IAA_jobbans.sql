CREATE TABLE IF NOT EXISTS `erro_iaa_jobban` (
  `id` int(11) AUTO_INCREMENT PRIMARY KEY,
  `fakeid` int(11) NOT NULL,
  `ckey` varchar(32) NOT NULL,
  `iaa_ckey` varchar(32) NOT NULL,
  `other_ckeys` text NOT NULL,
  `reason` text NOT NULL,
  `job` varchar(32) NOT NULL,
  `creation_time` datetime NOT NULL,
  `resolve_time` datetime DEFAULT NULL,
  `resolve_comment` text DEFAULT NULL,
  `resolve_ckey` varchar(32) DEFAULT NULL,
  `cancel_time` datetime DEFAULT NULL,
  `cancel_comment` text DEFAULT NULL,
  `cancel_ckey` varchar(32) DEFAULT NULL,
  `status` varchar(32) NOT NULL,
  `expiration_time` datetime DEFAULT NULL,
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `erro_iaa_approved` {
  `ckey` varchar(32) NOT NULL,
  `approvals` int(11) DEFAULT 1
} ENGINE=InnoDB DEFAULT CHARSET=latin1;