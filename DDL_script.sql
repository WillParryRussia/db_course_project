# Курсовой проект
DROP DATABASE IF EXISTS `course_project`;
CREATE DATABASE `course_project` DEFAULT CHARACTER SET 'utf8' COLLATE 'utf8_bin';
USE `course_project`;

# DDL-part

# DML-part

-- TRIGGERS !!!
DROP TABLE IF EXISTS `p`;
DROP TABLE IF EXISTS `u`;
CREATE TABLE `u` (`uid` SERIAL, `name` VARCHAR(128) NOT NULL, `karma` INT DEFAULT 0, PRIMARY KEY (`uid`));
CREATE TABLE `p` (`pid` SERIAL, `author_uid` BIGINT UNSIGNED NOT NULL, `rating` INT NOT NULL, PRIMARY KEY (`pid`), CONSTRAINT FOREIGN KEY (`author_uid`) REFERENCES `u`(`uid`));
DELIMITER |
CREATE TRIGGER `update_karma` BEFORE INSERT ON `p`
	FOR EACH ROW
		BEGIN
			UPDATE `u` SET `karma` = `karma` + NEW.`rating` WHERE `uid` = NEW.`author_uid`;
		END;
| DELIMITER ;
INSERT IGNORE INTO `u` (`name`) VALUES ('John'), ('Peter'), ('Sophie');
INSERT IGNORE INTO `p` (`author_uid`, `rating`) VALUES
	(1, 100),
    (1, 200),
    (2, -100),
    (2, -300);
    
# 300  - 1
# -400 - 2
# 0    - 3
SELECT * FROM `u`;