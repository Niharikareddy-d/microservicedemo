-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: localhost    Database: tenantcrm
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `attendance`
--

DROP TABLE IF EXISTS `attendance`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `attendance` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `break2end` time(6) DEFAULT NULL,
  `break2start` time(6) DEFAULT NULL,
  `break_end` time(6) DEFAULT NULL,
  `break_start` time(6) DEFAULT NULL,
  `check_in` time(6) DEFAULT NULL,
  `check_out` time(6) DEFAULT NULL,
  `date` date NOT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'present',
  `tenant_segment` varchar(255) NOT NULL,
  `user_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FKjcaqd29v2qy723owsdah2t8vx` (`user_id`),
  CONSTRAINT `FKjcaqd29v2qy723owsdah2t8vx` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attendance`
--

LOCK TABLES `attendance` WRITE;
/*!40000 ALTER TABLE `attendance` DISABLE KEYS */;
/*!40000 ALTER TABLE `attendance` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `domain_categories`
--

DROP TABLE IF EXISTS `domain_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `domain_categories` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `tenant_segment` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `domain_categories`
--

LOCK TABLES `domain_categories` WRITE;
/*!40000 ALTER TABLE `domain_categories` DISABLE KEYS */;
/*!40000 ALTER TABLE `domain_categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `holiday`
--

DROP TABLE IF EXISTS `holiday`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `holiday` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `date` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `tenant_segment` varchar(255) NOT NULL,
  `type` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `holiday`
--

LOCK TABLES `holiday` WRITE;
/*!40000 ALTER TABLE `holiday` DISABLE KEYS */;
/*!40000 ALTER TABLE `holiday` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `leave_requests`
--

DROP TABLE IF EXISTS `leave_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `leave_requests` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `attachment_content_type` varchar(255) DEFAULT NULL,
  `attachment_data` longblob,
  `attachment_name` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `employee_name` varchar(255) NOT NULL,
  `from_date` date NOT NULL,
  `reason` varchar(1000) NOT NULL,
  `rejection_message` varchar(1000) DEFAULT NULL,
  `reviewed_at` datetime(6) DEFAULT NULL,
  `reviewed_by` varchar(255) DEFAULT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'Pending',
  `tenant_segment` varchar(255) NOT NULL,
  `to_date` date NOT NULL,
  `type` varchar(255) NOT NULL,
  `employee_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FKsqls5en3a5v8l9md81umuu87c` (`employee_id`),
  CONSTRAINT `FKsqls5en3a5v8l9md81umuu87c` FOREIGN KEY (`employee_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `leave_requests`
--

LOCK TABLES `leave_requests` WRITE;
/*!40000 ALTER TABLE `leave_requests` DISABLE KEYS */;
/*!40000 ALTER TABLE `leave_requests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `meetings`
--

DROP TABLE IF EXISTS `meetings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `meetings` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `agenda` varchar(255) DEFAULT NULL,
  `duration` int NOT NULL,
  `location` varchar(255) DEFAULT NULL,
  `meeting_date` date NOT NULL,
  `meeting_time` time(6) NOT NULL,
  `meeting_type` varchar(255) NOT NULL,
  `participants` varchar(255) NOT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `send_notification` bit(1) NOT NULL,
  `tenant_segment` varchar(255) DEFAULT NULL,
  `title` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `meetings_chk_1` CHECK (((`duration` >= 1) and (`duration` <= 1440)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `meetings`
--

LOCK TABLES `meetings` WRITE;
/*!40000 ALTER TABLE `meetings` DISABLE KEYS */;
/*!40000 ALTER TABLE `meetings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notifications` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `created_at` datetime(6) NOT NULL,
  `link` varchar(500) DEFAULT NULL,
  `message` varchar(1000) NOT NULL,
  `is_read` bit(1) NOT NULL,
  `title` varchar(255) NOT NULL,
  `type` varchar(30) DEFAULT NULL,
  `user_id` bigint NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
/*!40000 ALTER TABLE `notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `password_reset_token`
--

DROP TABLE IF EXISTS `password_reset_token`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `password_reset_token` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `expiry_time` datetime(6) DEFAULT NULL,
  `token` varchar(255) DEFAULT NULL,
  `user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UKf90ivichjaokvmovxpnlm5nin` (`user_id`),
  CONSTRAINT `FK83nsrttkwkb6ym0anu051mtxn` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `password_reset_token`
--

LOCK TABLES `password_reset_token` WRITE;
/*!40000 ALTER TABLE `password_reset_token` DISABLE KEYS */;
/*!40000 ALTER TABLE `password_reset_token` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payroll_template`
--

DROP TABLE IF EXISTS `payroll_template`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payroll_template` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `bank_account` varchar(255) DEFAULT NULL,
  `basic_salary` decimal(12,2) DEFAULT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `department` varchar(255) DEFAULT NULL,
  `designation` varchar(255) DEFAULT NULL,
  `hra` decimal(12,2) DEFAULT NULL,
  `other_allowance` decimal(12,2) DEFAULT NULL,
  `other_deduction` decimal(12,2) DEFAULT NULL,
  `payment_month` int DEFAULT NULL,
  `payment_year` int DEFAULT NULL,
  `pf_deduction` decimal(12,2) DEFAULT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'active',
  `tax_deduction` decimal(12,2) DEFAULT NULL,
  `tenant_segment` varchar(255) NOT NULL,
  `transport_allowance` decimal(12,2) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `employee_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK60w94bksmiq7cfvfsbky1cwdt` (`employee_id`),
  CONSTRAINT `FK60w94bksmiq7cfvfsbky1cwdt` FOREIGN KEY (`employee_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payroll_template`
--

LOCK TABLES `payroll_template` WRITE;
/*!40000 ALTER TABLE `payroll_template` DISABLE KEYS */;
/*!40000 ALTER TABLE `payroll_template` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payslips`
--

DROP TABLE IF EXISTS `payslips`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payslips` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `bank_account` varchar(255) DEFAULT NULL,
  `basic_salary` decimal(12,2) DEFAULT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `department` varchar(255) DEFAULT NULL,
  `designation` varchar(255) DEFAULT NULL,
  `gross_salary` decimal(12,2) DEFAULT NULL,
  `hra` decimal(12,2) DEFAULT NULL,
  `leave_deduction` decimal(12,2) DEFAULT NULL,
  `net_salary` decimal(12,2) DEFAULT NULL,
  `other_allowance` decimal(12,2) DEFAULT NULL,
  `other_deduction` decimal(12,2) DEFAULT NULL,
  `payment_month` int NOT NULL,
  `payment_year` int NOT NULL,
  `pf_deduction` decimal(12,2) DEFAULT NULL,
  `tax_deduction` decimal(12,2) DEFAULT NULL,
  `tenant_segment` varchar(255) NOT NULL,
  `transport_allowance` decimal(12,2) DEFAULT NULL,
  `employee_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK3u2q4cfpg7d9feubiw2p8dhig` (`employee_id`),
  CONSTRAINT `FK3u2q4cfpg7d9feubiw2p8dhig` FOREIGN KEY (`employee_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payslips`
--

LOCK TABLES `payslips` WRITE;
/*!40000 ALTER TABLE `payslips` DISABLE KEYS */;
/*!40000 ALTER TABLE `payslips` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `performance_reviews`
--

DROP TABLE IF EXISTS `performance_reviews`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `performance_reviews` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `rating` int NOT NULL,
  `remarks` varchar(1000) DEFAULT NULL,
  `review_month` varchar(7) NOT NULL,
  `reviewed_at` bigint DEFAULT NULL,
  `reviewed_by` varchar(255) NOT NULL,
  `tenant_segment` varchar(255) NOT NULL,
  `employee_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_perf_emp_month_tenant` (`employee_id`,`review_month`,`tenant_segment`),
  CONSTRAINT `FKq4qi55u4hd0rkoehawb5x5toi` FOREIGN KEY (`employee_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `performance_reviews`
--

LOCK TABLES `performance_reviews` WRITE;
/*!40000 ALTER TABLE `performance_reviews` DISABLE KEYS */;
/*!40000 ALTER TABLE `performance_reviews` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `projects`
--

DROP TABLE IF EXISTS `projects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `projects` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `description` varchar(1000) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'active',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `projects`
--

LOCK TABLES `projects` WRITE;
/*!40000 ALTER TABLE `projects` DISABLE KEYS */;
/*!40000 ALTER TABLE `projects` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `report_attachments`
--

DROP TABLE IF EXISTS `report_attachments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `report_attachments` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `content_type` varchar(255) DEFAULT NULL,
  `file_data` longblob,
  `original_filename` varchar(255) DEFAULT NULL,
  `uploaded_at` bigint DEFAULT NULL,
  `report_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_report_attachment_report` (`report_id`),
  CONSTRAINT `fk_report_attachment_report` FOREIGN KEY (`report_id`) REFERENCES `reports` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `report_attachments`
--

LOCK TABLES `report_attachments` WRITE;
/*!40000 ALTER TABLE `report_attachments` DISABLE KEYS */;
/*!40000 ALTER TABLE `report_attachments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reports`
--

DROP TABLE IF EXISTS `reports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reports` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `absent_days` int DEFAULT NULL,
  `attendance_score` int DEFAULT NULL,
  `done_tasks` int DEFAULT NULL,
  `grade` varchar(255) DEFAULT NULL,
  `late_days` int DEFAULT NULL,
  `leave_days` int DEFAULT NULL,
  `message` text,
  `overall_score` int DEFAULT NULL,
  `overdue_tasks` int DEFAULT NULL,
  `pending_tasks` int DEFAULT NULL,
  `present_days` int DEFAULT NULL,
  `recipient_ids` varchar(2000) DEFAULT NULL,
  `recipient_names` varchar(2000) DEFAULT NULL,
  `sent_at` bigint DEFAULT NULL,
  `sent_by` varchar(255) DEFAULT NULL,
  `task_score` int DEFAULT NULL,
  `tenant_segment` varchar(255) DEFAULT NULL,
  `title` varchar(200) NOT NULL,
  `total_tasks` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reports`
--

LOCK TABLES `reports` WRITE;
/*!40000 ALTER TABLE `reports` DISABLE KEYS */;
/*!40000 ALTER TABLE `reports` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `task_attachments`
--

DROP TABLE IF EXISTS `task_attachments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `task_attachments` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `content_type` varchar(255) DEFAULT NULL,
  `file_data` longblob,
  `original_filename` varchar(255) DEFAULT NULL,
  `uploaded_at` bigint DEFAULT NULL,
  `uploaded_by` varchar(255) DEFAULT NULL,
  `task_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_attachment_task` (`task_id`),
  CONSTRAINT `fk_attachment_task` FOREIGN KEY (`task_id`) REFERENCES `tasks` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `task_attachments`
--

LOCK TABLES `task_attachments` WRITE;
/*!40000 ALTER TABLE `task_attachments` DISABLE KEYS */;
/*!40000 ALTER TABLE `task_attachments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tasks`
--

DROP TABLE IF EXISTS `tasks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tasks` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `assigned_to` varchar(255) DEFAULT NULL,
  `assigned_to_id` bigint DEFAULT NULL,
  `attachment_paths` varchar(2000) DEFAULT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `description` varchar(1000) DEFAULT NULL,
  `due_date` varchar(255) DEFAULT NULL,
  `last_verified_at` varchar(255) DEFAULT NULL,
  `last_verified_by` varchar(255) DEFAULT NULL,
  `priority` varchar(10) NOT NULL DEFAULT 'Medium',
  `start_date` varchar(255) DEFAULT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'pending',
  `tenant_segment` varchar(255) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `verification_reason` varchar(500) DEFAULT NULL,
  `verification_status` varchar(20) NOT NULL DEFAULT 'pending',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tasks`
--

LOCK TABLES `tasks` WRITE;
/*!40000 ALTER TABLE `tasks` DISABLE KEYS */;
/*!40000 ALTER TABLE `tasks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `team_members`
--

DROP TABLE IF EXISTS `team_members`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `team_members` (
  `team_id` bigint NOT NULL,
  `user_id` bigint NOT NULL,
  KEY `FKee8x7x5026imwmma9kndkxs36` (`user_id`),
  KEY `FKtgca08el3ofisywcf11f0f76t` (`team_id`),
  CONSTRAINT `FKee8x7x5026imwmma9kndkxs36` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `FKtgca08el3ofisywcf11f0f76t` FOREIGN KEY (`team_id`) REFERENCES `teams` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `team_members`
--

LOCK TABLES `team_members` WRITE;
/*!40000 ALTER TABLE `team_members` DISABLE KEYS */;
/*!40000 ALTER TABLE `team_members` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `teams`
--

DROP TABLE IF EXISTS `teams`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `teams` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `tenant_segment` varchar(255) NOT NULL,
  `manager_id` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK957exwbsdbxyv2kir751ejid7` (`manager_id`),
  CONSTRAINT `FK957exwbsdbxyv2kir751ejid7` FOREIGN KEY (`manager_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `teams`
--

LOCK TABLES `teams` WRITE;
/*!40000 ALTER TABLE `teams` DISABLE KEYS */;
/*!40000 ALTER TABLE `teams` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `domain` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `employee_limit` int NOT NULL DEFAULT '10',
  `joining_date` date DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `role` varchar(255) DEFAULT NULL,
  `status` varchar(10) NOT NULL DEFAULT 'active',
  `username` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,NULL,'superadmin@crm.com',10,NULL,'$2a$10$Ts/KaZPmIRsngPKZ8bx0QeuC1G/ro6MYEBUDuCX7dVo57KiDnnWWy','SUPER_ADMIN','active','superadmin');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-07-03 16:02:59
