-- phpMyAdmin SQL Dump
-- version 2.11.11.1
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Aug 02, 2011 at 06:04 PM
-- Server version: 5.0.77
-- PHP Version: 5.1.6

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

--
-- Database: `bay12`
--


-- --------------------------------------------------------

--
-- Table structure for table `admins`
--

CREATE TABLE IF NOT EXISTS `admins` (
  `ckey` varchar(255) NOT NULL,
  `rank` int(1) NOT NULL,
  PRIMARY KEY  (`ckey`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `backpack`
--

CREATE TABLE IF NOT EXISTS `backpack` (
  `ckey` varchar(255) NOT NULL,
  `type` varchar(255) NOT NULL,
  UNIQUE KEY `NODUPE` (`ckey`,`type`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `bans`
--

CREATE TABLE IF NOT EXISTS `bans` (
  `ckey` varchar(255) NOT NULL,
  `computerid` text NOT NULL,
  `ips` varchar(255) NOT NULL,
  `reason` text NOT NULL,
  `bannedby` varchar(255) NOT NULL,
  `temp` int(1) NOT NULL COMMENT '0 = perma ban / minutes banned',
  `minute` int(255) NOT NULL default '0',
  `timebanned` timestamp NOT NULL default CURRENT_TIMESTAMP,
  PRIMARY KEY  (`ckey`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `booklog`
--

CREATE TABLE IF NOT EXISTS `booklog` (
  `ckey` varchar(255) NOT NULL,
  `type` varchar(255) NOT NULL default 'INSERT',
  `title` text NOT NULL,
  `author` varchar(256) NOT NULL,
  `text` longtext NOT NULL,
  `cat` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `books`
--

CREATE TABLE IF NOT EXISTS `books` (
  `id` int(11) NOT NULL auto_increment,
  `title` varchar(255) NOT NULL,
  `author` varchar(255) NOT NULL,
  `text` longtext NOT NULL,
  `cat` int(2) NOT NULL default '1',
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=138 ;

-- --------------------------------------------------------

--
-- Table structure for table `changelog`
--

CREATE TABLE IF NOT EXISTS `changelog` (
  `id` int(11) NOT NULL auto_increment,
  `bywho` varchar(255) NOT NULL,
  `changes` text NOT NULL,
  `date` timestamp NOT NULL default CURRENT_TIMESTAMP,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=33 ;

-- --------------------------------------------------------

--
-- Table structure for table `config`
--

CREATE TABLE IF NOT EXISTS `config` (
  `motd` text NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `crban`
--

CREATE TABLE IF NOT EXISTS `crban` (
  `ckey` varchar(255) NOT NULL,
  `ips` varchar(255) NOT NULL,
  `reason` text NOT NULL COMMENT 'Why the ban was placed',
  `bannedby` varchar(255) NOT NULL COMMENT 'Who set the ban',
  `time` datetime NOT NULL COMMENT 'When the ban was placed',
  `unban_time` datetime default NULL COMMENT 'When the loser should be Unbanned',
  PRIMARY KEY  (`ckey`),
  KEY `bannedby` (`bannedby`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `crban_past`
--

CREATE TABLE IF NOT EXISTS `crban_past` (
  `CKey` varchar(255) NOT NULL COMMENT 'Who was banned',
  `Banner` varchar(255) NOT NULL COMMENT 'Who banned them',
  `BanReason` text NOT NULL COMMENT 'Why they were banned',
  `BanTime` datetime NOT NULL COMMENT 'When the ban was placed',
  `UnbanTime` datetime default NULL COMMENT 'When the ban was supposed to be lifted',
  `Unbanned` datetime default NULL COMMENT 'If not null, when the ban was lifted early',
  `Unbanner` varchar(255) default NULL COMMENT 'Who unbanned them early',
  KEY `CKey` (`CKey`),
  KEY `Banner` (`Banner`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='Record of all the past bans';

-- --------------------------------------------------------

--
-- Table structure for table `currentplayers`
--

CREATE TABLE IF NOT EXISTS `currentplayers` (
  `name` varchar(255) NOT NULL,
  `playing` int(11) NOT NULL default '1',
  PRIMARY KEY  (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `deathlog`
--

CREATE TABLE IF NOT EXISTS `deathlog` (
  `ckey` varchar(255) NOT NULL,
  `location` text NOT NULL,
  `lastattacker` text NOT NULL,
  `ToD` text NOT NULL,
  `health` text NOT NULL,
  `lasthit` text NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `invites`
--

CREATE TABLE IF NOT EXISTS `invites` (
  `ckey` varchar(255) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `jobban`
--

CREATE TABLE IF NOT EXISTS `jobban` (
  `ckey` varchar(255) NOT NULL,
  `rank` varchar(255) NOT NULL,
  UNIQUE KEY `NODUPES` (`ckey`(100),`rank`(100))
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `jobbanlog`
--

CREATE TABLE IF NOT EXISTS `jobbanlog` (
  `ckey` varchar(255) NOT NULL COMMENT 'By who',
  `targetckey` varchar(255) NOT NULL COMMENT 'Target',
  `rank` varchar(255) NOT NULL COMMENT 'rank',
  `when` timestamp NOT NULL default CURRENT_TIMESTAMP COMMENT 'when',
  `why` varchar(355) NOT NULL,
  UNIQUE KEY `targetckey` (`targetckey`(100),`rank`(100))
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `medals`
--

CREATE TABLE IF NOT EXISTS `medals` (
  `ckey` varchar(255) NOT NULL,
  `medal` text NOT NULL,
  `medaldesc` text NOT NULL,
  `medaldiff` text NOT NULL,
  UNIQUE KEY `NODUPES` (`ckey`,`medal`(8))
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `players`
--

CREATE TABLE IF NOT EXISTS `players` (
  `ckey` varchar(255) NOT NULL,
  `slot` int(2) NOT NULL default '1',
  `slotname` varchar(255) NOT NULL default 'Default',
  `real_name` varchar(255) NOT NULL,
  `gender` varchar(255) NOT NULL,
  `occupation1` varchar(255) NOT NULL,
  `occupation2` varchar(255) NOT NULL,
  `occupation3` varchar(255) NOT NULL,
  `hair_red` int(3) NOT NULL,
  `hair_green` int(3) NOT NULL,
  `hair_blue` int(3) NOT NULL,
  `ages` int(3) NOT NULL,
  `facial_red` int(3) NOT NULL,
  `facial_green` int(3) NOT NULL,
  `facial_blue` int(3) NOT NULL,
  `skin_tone` int(3) NOT NULL,
  `hair_style_name` varchar(255) NOT NULL,
  `facial_style_name` varchar(255) NOT NULL,
  `eyes_red` int(3) NOT NULL,
  `eyes_green` int(3) NOT NULL,
  `eyes_blue` int(3) NOT NULL,
  `blood_type` varchar(3) NOT NULL,
  `be_syndicate` int(3) NOT NULL,
  `underwear` int(3) NOT NULL,
  `name_is_always_random` int(3) NOT NULL,
  `bios` longtext NOT NULL,
  `show` int(1) NOT NULL default '1',
  `be_nuke_agent` tinyint(1) NOT NULL,
  `be_takeover_agent` tinyint(1) NOT NULL,
  UNIQUE KEY `ckey` (`ckey`,`slot`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `ranks`
--

CREATE TABLE IF NOT EXISTS `ranks` (
  `Rank` int(11) NOT NULL COMMENT 'What Numeric Rank',
  `Desc` text NOT NULL COMMENT 'What is a person with this rank?',
  PRIMARY KEY  (`Rank`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `roundsjoined`
--

CREATE TABLE IF NOT EXISTS `roundsjoined` (
  `ckey` varchar(255) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `roundsurvived`
--

CREATE TABLE IF NOT EXISTS `roundsurvived` (
  `ckey` varchar(255) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `stats`
--

CREATE TABLE IF NOT EXISTS `stats` (
  `ckey` varchar(255) NOT NULL COMMENT 'ckey',
  `deaths` int(10) NOT NULL default '0' COMMENT 'player deaths',
  `roundsplayed` int(10) NOT NULL default '0' COMMENT 'rounds played',
  `suicides` int(10) NOT NULL default '0' COMMENT 'suicides',
  `traitorwin` int(10) NOT NULL default '0' COMMENT 'traitor wins',
  PRIMARY KEY  (`ckey`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `suggest`
--

CREATE TABLE IF NOT EXISTS `suggest` (
  `id` int(11) NOT NULL auto_increment,
  `userid` int(11) NOT NULL,
  `username` varchar(255) NOT NULL,
  `title` varchar(255) NOT NULL,
  `desc` text NOT NULL,
  `link` varchar(255) NOT NULL,
  `votes` int(11) NOT NULL default '0',
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=29 ;

-- --------------------------------------------------------

--
-- Table structure for table `traitorbuy`
--

CREATE TABLE IF NOT EXISTS `traitorbuy` (
  `type` varchar(255) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `traitorlogs`
--

CREATE TABLE IF NOT EXISTS `traitorlogs` (
  `CKey` varchar(128) NOT NULL,
  `Objective` text NOT NULL,
  `Succeeded` tinyint(4) NOT NULL,
  `Spawned` text NOT NULL,
  `Occupation` varchar(128) NOT NULL,
  `PlayerCount` int(11) NOT NULL,
  KEY `CKey` (`CKey`),
  KEY `Succeeded` (`Succeeded`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `unbans`
--

CREATE TABLE IF NOT EXISTS `unbans` (
  `ckey` varchar(255) NOT NULL,
  `computerid` text NOT NULL,
  `ips` varchar(255) NOT NULL,
  `reason` text NOT NULL,
  `bannedby` varchar(255) NOT NULL,
  `temp` int(255) NOT NULL COMMENT '0 = perma ban / minutes banned',
  `minutes` int(255) NOT NULL,
  `timebanned` timestamp NOT NULL default CURRENT_TIMESTAMP
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `voters`
--

CREATE TABLE IF NOT EXISTS `voters` (
  `username` varchar(255) NOT NULL,
  `votes` int(11) NOT NULL,
  UNIQUE KEY `username` (`username`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `web_log`
--

CREATE TABLE IF NOT EXISTS `web_log` (
  `type` varchar(255) NOT NULL,
  `message` varchar(255) NOT NULL,
  `bywho` varchar(255) NOT NULL,
  `time` datetime NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
