-- Курсовой проект курса "Базы данных" от 6 мая 2020г. (Geekbrains Univercity)
# DDL-part
DROP DATABASE IF EXISTS `course_project`;
CREATE DATABASE `course_project` DEFAULT CHARACTER SET 'UTF8MB4' COLLATE 'UTF8MB4_bin';
USE `course_project`;
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
	`uid` VARCHAR(16) NOT NULL COMMENT 'Уникальный идентификатор пользователя на сайте (никнейм)',
    `email` VARCHAR(128) NOT NULL COMMENT 'Почтовый адрес пользователя',
    `phone` BIGINT UNSIGNED NOT NULL COMMENT 'Номер мобильного телефона пользователя',
    `preferences` JSON NOT NULL COMMENT 'Личные настройки пользователя',
    `password_hash` VARCHAR(256) NOT NULL COMMENT 'Основной хэш пароля',
    `password_hash2` VARCHAR(256) NOT NULL COMMENT 'Дополнительный хэш пароля (для смены пароля)',
    `is_banned` BIT(1) NOT NULL DEFAULT 0 COMMENT 'Является ли пользователь забанненым на сайте',
    `is_moderator` BIT(1) NOT NULL DEFAULT 0 COMMENT 'Есть ли у пользователя полномочия чтобы модерировать сайт',
    `is_administrator` BIT(1) NOT NULL DEFAULT 0 COMMENT 'Есть ли у пользователя полномочия чтобы администрировать сайт',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP() COMMENT 'Временной штамп создания аккаунта',
    PRIMARY KEY (`uid`),
    UNIQUE INDEX (`email`),
    UNIQUE INDEX (`phone`)
);
DROP TABLE IF EXISTS `profiles`;
CREATE TABLE `profiles` (
	`user_id` VARCHAR(16) NOT NULL COMMENT 'Внешний ключ на идентификатор пользователя, отношение таблиц 1 х 1',
    `firstname` VARCHAR(32) DEFAULT NULL COMMENT 'Имя пользователя (при желании)',
    `lastname` VARCHAR(32) DEFAULT NULL COMMENT 'Фамилия пользователя (при желании)',
    `sex` ENUM('M','F') DEFAULT NULL COMMENT 'Пол пользователя (при желании). Не гендер!',
    `burthday` DATE DEFAULT NULL COMMENT 'Дата рождения пользователя (при желании)',
    `subscribers` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Количество подписчиков. ТРИГГЕР из таблицы subscribers',
    `avatar` VARCHAR(128) NOT NULL DEFAULT 'empty_user_avatar' COMMENT 'Аватарка пользователя',
    `cover` VARCHAR(128) NOT NULL DEFAULT 'empty_user_cover' COMMENT 'Фон для страницы профиля пользователя',
    `slogan` VARCHAR(256) DEFAULT NULL COMMENT 'Информация о себе',
    `karma` BIGINT NOT NULL DEFAULT 0 COMMENT 'Рейтинг пользователя на сайте (+/-). ТРИГГЕР из таблицы assessments',
    `amount_posts` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Количество постов пользователя. ТРИГГЕР из таблицы posts',
    PRIMARY KEY (`user_id`),
    CONSTRAINT
		FOREIGN KEY (`user_id`) REFERENCES `users`(`uid`)
			ON UPDATE CASCADE
            ON DELETE NO ACTION
);
DROP TABLE IF EXISTS `subscribers`;
CREATE TABLE `subscribers` (
	`initiator_user_id` VARCHAR(16) NOT NULL COMMENT 'Внешний ключ на таблицу users',
    `target_user_id` VARCHAR(16) NOT NULL COMMENT 'Внешний ключ на таблицу users',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP() COMMENT 'Временной штамп подписки',
    PRIMARY KEY (`initiator_user_id`, `target_user_id`),
    CONSTRAINT
		FOREIGN KEY (`initiator_user_id`) REFERENCES `users`(`uid`)
			ON UPDATE CASCADE
            ON DELETE NO ACTION,
		FOREIGN KEY (`target_user_id`) REFERENCES `users`(`uid`)
			ON UPDATE CASCADE
            ON DELETE NO ACTION
);
DELIMITER 
|
CREATE TRIGGER `update_users` BEFORE INSERT ON `subscribers`
	FOR EACH ROW
		BEGIN
			UPDATE `users` 
				SET `subscribers` = `subscribers` + 1 WHERE `uid` = NEW.`target_user_id`;
		END;
|
DELIMITER ;
DROP TABLE IF EXISTS `communities`;
CREATE TABLE `communities` (
	`cid` VARCHAR(32) NOT NULL COMMENT 'Уникальный число-цифровой идентификатор сообщества',
    `rating` BIGINT NOT NULL DEFAULT 0 COMMENT 'Рейтинг сообщества, который складывается из рейтинга всех его постов. ТРИГГЕР из таблицы assessments',
    `avatar` VARCHAR(128) NOT NULL DEFAULT 'empty_comm_avatar' COMMENT 'Аватар сообщества',
    `cover` VARCHAR(128) NOT NULL DEFAULT 'empty_comm_cover' COMMENT 'Обложка профиля сообщества',
    `slogan` VARCHAR(256) DEFAULT NULL COMMENT 'Небольшое текстовое описание',
    `amount_posts` BIGINT NOT NULL DEFAULT 0 COMMENT 'Количество постов в сообществе. ТРИГГЕР из таблицы posts',
    `amount_members` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Количество членов. ТРИГГЕР из таблицы subscribers',
    `description` VARCHAR(1000) NOT NULL DEFAULT 'Community Description Area' COMMENT 'Полнотекстовое описание сообщества',
    `administrator_id` VARCHAR(16) NOT NULL COMMENT 'Идентификатор пользователя-администратора сообщества, отношение 1 х М',
    `moderator_id` VARCHAR(16) NOT NULL COMMENT 'Идентификатор пользователя-модератора сообщества, отношение 1 х М',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP() COMMENT 'Временной штамп создания сообщества',
    PRIMARY KEY (`cid`),
    INDEX (`rating`),
    CONSTRAINT
		FOREIGN KEY (`administrator_id`) REFERENCES `users`(`uid`)
			ON UPDATE CASCADE
            ON DELETE NO ACTION,
		FOREIGN KEY (`moderator_id`) REFERENCES `users`(`uid`)
			ON UPDATE CASCADE
            ON DELETE NO ACTION
);
DROP TABLE IF EXISTS `communities_users`;
CREATE TABLE `communities_users` (
	`community_id` VARCHAR(32) NOT NULL COMMENT 'Внешний ключ на таблицу communities, отношение М х М',
    `member_id` VARCHAR(16) NOT NULL COMMENT 'Внешний ключ на таблицу users, отношение М х М',
    PRIMARY KEY (`community_id`,`member_id`),
    CONSTRAINT
		FOREIGN KEY (`community_id`) REFERENCES `communities`(`cid`)
			ON UPDATE CASCADE
            ON DELETE CASCADE,
		FOREIGN KEY (`member_id`) REFERENCES `users`(`uid`)
			ON UPDATE CASCADE
            ON DELETE CASCADE
);
DELIMITER 
|
CREATE TRIGGER `update_communities` BEFORE INSERT ON `communities_users`
	FOR EACH ROW
		BEGIN
			UPDATE `communities` 
				SET `amount_members` = `amount_members` + 1 WHERE `cid` = NEW.`community_id`;
		END;
|
DELIMITER ;

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