-- MySQL dump 10.11
--
-- Host: localhost    Database: intern_diary_skozawa
-- ------------------------------------------------------
-- Server version	5.0.95

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `category`
--

DROP TABLE IF EXISTS `category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `category` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `name` varbinary(255) NOT NULL,
  `created_on` datetime NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=MyISAM AUTO_INCREMENT=12 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `category`
--

LOCK TABLES `category` WRITE;
/*!40000 ALTER TABLE `category` DISABLE KEYS */;
INSERT INTO `category` VALUES (1,'テスト','2012-02-24 02:22:16'),(2,'天気','2012-02-24 02:22:29'),(3,'MoCo','2012-02-24 02:22:54'),(4,'Hatena','2012-02-24 02:23:17'),(5,'Perl','2012-02-24 02:23:17'),(6,'冬','2012-02-24 02:24:15'),(7,'Ridge','2012-02-27 04:26:25'),(8,'MVC','2012-02-27 04:28:08'),(9,'OAuth','2012-02-27 09:22:09'),(10,'Feed','2012-02-28 05:00:55'),(11,'WAF','2012-02-28 06:22:05');
/*!40000 ALTER TABLE `category` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `comment`
--

DROP TABLE IF EXISTS `comment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `comment` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `user_id` int(10) unsigned NOT NULL,
  `entry_id` int(10) unsigned NOT NULL,
  `content` blob NOT NULL,
  `created_on` datetime NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `user_id` (`user_id`,`entry_id`,`created_on`)
) ENGINE=MyISAM AUTO_INCREMENT=12 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `comment`
--

LOCK TABLES `comment` WRITE;
/*!40000 ALTER TABLE `comment` DISABLE KEYS */;
INSERT INTO `comment` VALUES (1,1,2,'確かに寒かったですね','2012-02-24 02:24:52'),(5,2,6,'テストコメントです','2012-02-27 04:54:36'),(4,1,5,'MoCoを利用中','2012-02-24 02:25:23'),(7,2,2,'今週は寒いみたいですよ。','2012-02-27 06:58:03'),(8,4,15,'Ridge','2012-02-28 06:22:19'),(9,2,15,'Catalyst','2012-02-28 06:26:06'),(10,2,15,'Symfony','2012-02-28 06:28:03'),(11,4,15,'Smarty','2012-02-28 06:29:05');
/*!40000 ALTER TABLE `comment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `entry`
--

DROP TABLE IF EXISTS `entry`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `entry` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `user_id` int(10) unsigned NOT NULL,
  `title` varbinary(255) NOT NULL,
  `body` blob NOT NULL,
  `created_on` datetime NOT NULL,
  `updated_on` datetime NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `user_id` (`user_id`)
) ENGINE=MyISAM AUTO_INCREMENT=16 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `entry`
--

LOCK TABLES `entry` WRITE;
/*!40000 ALTER TABLE `entry` DISABLE KEYS */;
INSERT INTO `entry` VALUES (1,1,'テスト','これはテストです','2012-02-24 02:22:16','2012-02-24 02:22:16'),(2,1,'天気','今日は寒かったです','2012-02-24 02:22:29','2012-02-24 02:24:15'),(3,1,'test','これもテストです','2012-02-24 02:22:42','2012-02-24 02:22:42'),(6,2,'skozawaのテスト','テストです。\r\n日記を書いてみよう。\r\n','2012-02-27 04:04:24','2012-02-27 04:04:24'),(5,1,'課題','課題に取組中','2012-02-24 02:23:17','2012-02-24 02:23:17'),(7,2,'Ridge','Ridgeを使って課題に取り組んでいます。\r\n','2012-02-27 04:26:25','2012-02-27 04:26:25'),(8,2,'MVCによるウェブアプリケーション','Catalystを勉強してたから、\r\nRidgeも理解しやすかった。','2012-02-27 04:28:08','2012-02-27 04:44:03'),(10,4,'TwitterOAuth','TwitterでのOAuth認証ができた','2012-02-27 09:22:09','2012-02-27 09:22:09'),(11,4,'テスト','日記のテストをします。','2012-02-28 04:55:59','2012-02-28 04:55:59'),(12,4,'MVC','モデルとビューとコントローラです。','2012-02-28 04:57:10','2012-02-28 04:57:10'),(13,4,'MoCo','はてなで使っているORマッパー','2012-02-28 04:58:35','2012-02-28 04:58:35'),(14,4,'フィード','フィード（RSS, Atom）を作った。\r\n','2012-02-28 05:00:55','2012-02-28 05:00:55'),(15,4,'Webアプリケーションフレームワーク','Webアプリケーションフレームワークにはどんなのがある？','2012-02-28 06:22:05','2012-02-28 06:22:05');
/*!40000 ALTER TABLE `entry` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rel_entry_category`
--

DROP TABLE IF EXISTS `rel_entry_category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rel_entry_category` (
  `entry_id` int(10) unsigned NOT NULL,
  `category_id` int(10) unsigned NOT NULL,
  PRIMARY KEY  (`entry_id`,`category_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rel_entry_category`
--

LOCK TABLES `rel_entry_category` WRITE;
/*!40000 ALTER TABLE `rel_entry_category` DISABLE KEYS */;
INSERT INTO `rel_entry_category` VALUES (1,1),(2,2),(2,6),(3,1),(5,3),(5,4),(5,5),(6,1),(7,5),(7,7),(8,7),(8,8),(10,9),(11,1),(12,8),(13,3),(14,10),(15,11);
/*!40000 ALTER TABLE `rel_entry_category` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `name` varbinary(32) NOT NULL,
  `created_on` datetime NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=MyISAM AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user`
--

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
INSERT INTO `user` VALUES (1,'kozawa','2012-02-24 02:19:48'),(2,'skozawa','2012-02-27 03:54:29'),(4,'5kozawa','2012-02-27 09:14:17');
/*!40000 ALTER TABLE `user` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2012-02-29 11:05:22
