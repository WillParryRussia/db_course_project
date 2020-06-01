-- Курсовой проект курса "Базы данных" от 6 мая 2020г. (Geekbrains Univercity)
# DDL-part
DROP DATABASE IF EXISTS `course_project`;
CREATE DATABASE `course_project` DEFAULT CHARACTER SET 'UTF8MB4' COLLATE 'UTF8MB4_bin';
USE `course_project`;
#DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
	`uid` VARCHAR(16) NOT NULL COMMENT 'Уникальный идентификатор пользователя на сайте (никнейм)',
    `email` VARCHAR(128) NOT NULL COMMENT 'Почтовый адрес пользователя',
    `phone` BIGINT UNSIGNED NOT NULL COMMENT 'Номер мобильного телефона пользователя',
    `preferences` JSON COMMENT 'Личные настройки пользователя',
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
#DROP TABLE IF EXISTS `profiles`;
CREATE TABLE `profiles` (
	`user_id` VARCHAR(16) NOT NULL COMMENT 'Внешний ключ на идентификатор пользователя, отношение таблиц 1 х 1',
    `firstname` VARCHAR(32) DEFAULT NULL COMMENT 'Имя пользователя (при желании)',
    `lastname` VARCHAR(32) DEFAULT NULL COMMENT 'Фамилия пользователя (при желании)',
    `sex` ENUM('M','F') DEFAULT NULL COMMENT 'Пол пользователя (при желании). Не гендер!',
    `birthday` DATE DEFAULT NULL COMMENT 'Дата рождения пользователя (при желании)',
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
#DROP TABLE IF EXISTS `subscribers`;
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
#DROP TABLE IF EXISTS `communities`;
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
    `moderator_id` VARCHAR(16) DEFAULT NULL COMMENT 'Идентификатор пользователя-модератора сообщества, отношение 1 х М',
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
#DROP TABLE IF EXISTS `communities_users`;
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
#DROP TABLE IF EXISTS `achievements`;
CREATE TABLE `achievements` (
	`aid` SERIAL COMMENT 'Числовой идентификатор ачивки',
    `name` VARCHAR(128) NOT NULL COMMENT 'Название ачивки',
    PRIMARY KEY (`aid`),
    UNIQUE INDEX (`name`)
);
#DROP TABLE IF EXISTS `users_achievements`;
CREATE TABLE `users_achievements` (
	`uaid` SERIAL COMMENT 'Идентификатор таблицы, не могу использовать составной ключ так как таблица М х М',
    `user_id` VARCHAR(16) NOT NULL COMMENT 'Внешний ключ на пользователей',
    `achievement_id` BIGINT UNSIGNED NOT NULL COMMENT 'Внешний ключ на справочник ачивок',
    `description` VARCHAR(128) NOT NULL COMMENT 'Описание конкретной ачивки, за что, когда и ссылка',
    `reached_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP() COMMENT 'Временной штамп достижения',
    PRIMARY KEY (`uaid`),
    INDEX (`user_id`),
    CONSTRAINT
		FOREIGN KEY (`user_id`) REFERENCES `users`(`uid`)
			ON UPDATE CASCADE
            ON DELETE NO ACTION,
        FOREIGN KEY (`achievement_id`) REFERENCES `achievements`(`aid`)
			ON UPDATE CASCADE
            ON DELETE NO ACTION
);
#DROP TABLE IF EXISTS `users_notes`;
CREATE TABLE `users_notes` (
	`author_user_id` VARCHAR(16) NOT NULL COMMENT 'Пользователь-автор заметки',
    `target_user_id` VARCHAR(16) NOT NULL COMMENT 'Целевой пользователь заметки',
    `body` VARCHAR(128) COMMENT 'Тело заметки',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP() COMMENT 'Когда создана',
    `updated_at` DATETIME ON UPDATE CURRENT_TIMESTAMP() COMMENT 'Когда изменена',
    PRIMARY KEY (`author_user_id`, `target_user_id`),
    CONSTRAINT
		FOREIGN KEY (`author_user_id`) REFERENCES `users`(`uid`)
			ON UPDATE CASCADE
            ON DELETE NO ACTION,
        FOREIGN KEY (`target_user_id`) REFERENCES `users`(`uid`)
			ON UPDATE CASCADE
            ON DELETE NO ACTION    
);
#DROP TABLE IF EXISTS `ignore_lists`;
CREATE TABLE `ignore_lists` (
	`initiator_user_id` VARCHAR(16) NOT NULL COMMENT '',
    `target_user_id` VARCHAR(16) NOT NULL COMMENT '',
    PRIMARY KEY (`initiator_user_id`, `target_user_id`),
    CONSTRAINT
		FOREIGN KEY (`initiator_user_id`) REFERENCES `users`(`uid`)
			ON UPDATE CASCADE
            ON DELETE NO ACTION,
        FOREIGN KEY (`target_user_id`) REFERENCES `users`(`uid`)
			ON UPDATE CASCADE
            ON DELETE NO ACTION    
);
#DROP TABLE IF EXISTS `posts`;
CREATE TABLE `posts` (
	`pid` SERIAL COMMENT 'Идентификатор контента',
    `header` VARCHAR(128) NOT NULL COMMENT 'Заголовок поста',
    `author_id` VARCHAR(16) NOT NULL COMMENT 'Автор поста',
    `assembly_code` VARCHAR(128) NOT NULL DEFAULT 'T1' COMMENT 'Код сборки поста из таблицы контента',
    `community_id` VARCHAR(32) DEFAULT NULL COMMENT 'Относится ли к сообществу',
    `rating` BIGINT NOT NULL DEFAULT 0 COMMENT 'Рейтинг поста. ТРИГГЕР, когда ставят оценки',
    `is_deleted` BIT(1) DEFAULT 0 COMMENT 'Удалён ли пост',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP() COMMENT 'Когда создан',
    `updated_at` DATETIME ON UPDATE CURRENT_TIMESTAMP() COMMENT 'Когда изменен',
    PRIMARY KEY (`pid`),
    INDEX (`header`, `author_id`, `rating`, `community_id`),
    CONSTRAINT
		FOREIGN KEY (`author_id`) REFERENCES `users`(`uid`)
			ON UPDATE CASCADE
            ON DELETE NO ACTION,
		FOREIGN KEY (`community_id`) REFERENCES `communities`(`cid`)
			ON UPDATE CASCADE
            ON DELETE NO ACTION
);
#DROP TABLE IF EXISTS `tags`;
CREATE TABLE `tags` (
	`tid` SERIAL COMMENT 'Идентификатор тэга',
    `name` VARCHAR(16) NOT NULL COMMENT 'Текст тэга',
    PRIMARY KEY (`tid`),
    UNIQUE INDEX (`name`)
);
#DROP TABLE IF EXISTS `tagsets`;
CREATE TABLE `tagsets` (
	`tag_id` BIGINT UNSIGNED NOT NULL COMMENT 'Идентификатор тэга из справочника',
    `post_id` BIGINT UNSIGNED NOT NULL COMMENT 'Идентификатор поста, кому принадлежат тэги',
    `assembly_number` SMALLINT NOT NULL DEFAULT 1 COMMENT 'Порядок следования тэгов поста',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP() COMMENT 'Когда создан, чтобы отслеживать популярность тэгов',
    PRIMARY KEY (`tag_id`, `post_id`),
    CONSTRAINT
		FOREIGN KEY (`tag_id`) REFERENCES `tags`(`tid`)
			ON UPDATE CASCADE
            ON DELETE CASCADE,
		FOREIGN KEY (`post_id`) REFERENCES `posts`(`pid`)
			ON UPDATE CASCADE
            ON DELETE CASCADE
);
#DROP TABLE IF EXISTS `comments`;
CREATE TABLE `comments` (
	`cuid` SERIAL COMMENT 'Идентификатор коммента',
    `post_id` BIGINT UNSIGNED NOT NULL COMMENT 'Пост, в котором находится коммент',
    `user_id` VARCHAR(16) NOT NULL COMMENT 'Пользователь написавший коммент',
    `assembly_code` VARCHAR(32) NOT NULL DEFAULT 'T1' COMMENT 'Код сборки коммент',
    `rating` BIGINT NOT NULL DEFAULT 0 COMMENT 'Рейтинг коммента',
    `parent_cuid` BIGINT UNSIGNED DEFAULT NULL COMMENT 'Идентификатор родительского коммента',
    `parent_uid` VARCHAR(16) DEFAULT NULL COMMENT 'Идентификатор автора родительского коммента',
    `is_banned` BIT(1) NOT NULL DEFAULT 0 COMMENT 'Является ли коммент забаненым',
    `is_read` BIT(1) NOT NULL DEFAULT 0 COMMENT 'Прочитан ли коммент тем, кому он написан',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP() COMMENT 'Когда создан',
    `updated_at` DATETIME ON UPDATE CURRENT_TIMESTAMP() COMMENT 'Когда изменён',
    PRIMARY KEY (`cuid`),
    INDEX (`post_id`, `user_id`),
    CONSTRAINT
		FOREIGN KEY (`post_id`) REFERENCES `posts`(`pid`)
			ON UPDATE CASCADE
            ON DELETE CASCADE,
		FOREIGN KEY (`user_id`) REFERENCES `users`(`uid`)
			ON UPDATE CASCADE
            ON DELETE NO ACTION,
		FOREIGN KEY (`parent_uid`) REFERENCES `users`(`uid`)
			ON UPDATE CASCADE
            ON DELETE NO ACTION
);
#DROP TABLE IF EXISTS `saves`;
CREATE TABLE `saves` (
	`user_id` VARCHAR(16) NOT NULL COMMENT 'Пользователь, сохранивший пост или коммент',
	`post_id` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Сохранённый пост (0 если не пост сохранён)',
    `comment_id` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Сохранённый коммент (0 если не коммент сохранён)',
    `target_type` ENUM('P', 'C') NOT NULL COMMENT 'Тип сохранённого контента, пост или коммент',
    PRIMARY KEY (`user_id`, `post_id`, `comment_id`),
    CONSTRAINT
		FOREIGN KEY (`post_id`) REFERENCES `posts`(`pid`)
			ON UPDATE CASCADE
            ON DELETE CASCADE,
		FOREIGN KEY (`user_id`) REFERENCES `users`(`uid`)
			ON UPDATE CASCADE
            ON DELETE CASCADE,
		FOREIGN KEY (`comment_id`) REFERENCES `comments`(`cuid`)
			ON UPDATE CASCADE
            ON DELETE CASCADE
);
#DROP TABLE IF EXISTS `content`;
CREATE TABLE `content` (
	`coid` SERIAL COMMENT 'Идентификатор контекста',
    `post_id` BIGINT UNSIGNED DEFAULT NULL COMMENT 'Идентификатор поста, если этот контент относится к посту',
    `comment_id` BIGINT UNSIGNED DEFAULT NULL COMMENT 'Идентификатор коммента, если этот контент относится к комменту',
    `content_type` ENUM('T','P','V') NOT NULL COMMENT 'Тип контента, T - текст, P - пикча, V - видео',
    `assembly_number` SMALLINT NOT NULL COMMENT 'Сборочный номер, чтобы расположить контент в верном порядке',
    `metadata` JSON NOT NULL COMMENT 'Разные метаданные для файла',
    `body` VARCHAR(5000) DEFAULT NULL COMMENT 'Содержимое контента, если тип Т',
    `filename` VARCHAR(128) DEFAULT NULL COMMENT 'Ссылка на внешний источник или имя медифайла',
    PRIMARY KEY (`coid`),
    INDEX (`post_id`, `comment_id`),
    CONSTRAINT
		FOREIGN KEY (`post_id`) REFERENCES `posts`(`pid`)
			ON UPDATE NO ACTION
            ON DELETE NO ACTION,
		FOREIGN KEY (`comment_id`) REFERENCES `comments`(`cuid`)
			ON UPDATE NO ACTION
            ON DELETE NO ACTION
);
#DROP TABLE IF EXISTS `assessments`;
CREATE TABLE `assessments` (
	`asid` SERIAL COMMENT 'Идентификатор оценки',
	`user_id` VARCHAR(16) NOT NULL COMMENT 'Кто поставил оценку',
    `post_id` BIGINT UNSIGNED DEFAULT NULL COMMENT 'Какому посту (если посту)',
    `comment_id` BIGINT UNSIGNED DEFAULT NULL COMMENT 'Какому комменту (если комменту)',
    `assessment_type` ENUM('+','-') NOT NULL COMMENT 'Тип оценки',
    PRIMARY KEY (`asid`),
    CONSTRAINT
		FOREIGN KEY (`user_id`) REFERENCES `users`(`uid`)
			ON UPDATE CASCADE
            ON DELETE NO ACTION,
		FOREIGN KEY (`post_id`) REFERENCES `posts`(`pid`)
			ON UPDATE CASCADE
            ON DELETE CASCADE,
		FOREIGN KEY (`comment_id`) REFERENCES `comments`(`cuid`)
			ON UPDATE CASCADE
            ON DELETE CASCADE
)
##########################
DELIMITER |
CREATE TRIGGER `insert_profiles` AFTER INSERT ON `users`
	FOR EACH ROW
		BEGIN
			INSERT INTO `profiles` (`user_id`) VALUES (NEW.uid);
		END;
CREATE TRIGGER `update_profiles1` AFTER INSERT ON `subscribers`
	FOR EACH ROW
		BEGIN
			UPDATE `profiles`
				SET `subscribers` = `subscribers` + 1 
                WHERE `user_id` = NEW.`target_user_id`;
		END;
CREATE TRIGGER `update_profiles2` BEFORE DELETE ON `subscribers`
	FOR EACH ROW
		BEGIN
			UPDATE `profiles`
				SET `subscribers` = `subscribers` - 1 
                WHERE `user_id` = OLD.`target_user_id`;
        END;
CREATE TRIGGER `update_communities` AFTER INSERT ON `communities_users`
	FOR EACH ROW
		BEGIN
			UPDATE `communities` 
				SET `amount_members` = `amount_members` + 1 WHERE `cid` = NEW.`community_id`;
		END;
| DELIMITER ;

-- tests
USE `course_project`;
INSERT INTO `users` (`uid`,`email`,`phone`,`password_hash`,`password_hash2`) VALUES
	('willparry', 'lordgeralt@mail.ru', 79040459833, '123@@@AS3', '123@@#DDD'),
    ('nickname1', 'nickname1@mail.ru', 79040459834, '123@@@AS3', '123@@#DDD'),
    ('nickname2', 'nickname2@mail.ru', 79040459835, '123@@@AS3', '123@@#DDD'),
    ('nickname3', 'nickname3@mail.ru', 79040459836, '123@@@AS3', '123@@#DDD'),
    ('nickname4', 'nickname4@mail.ru', 79040459837, '123@@@AS3', '123@@#DDD');
SELECT * FROM `users`;
SELECT `user_id`, `subscribers` FROM `profiles`;

INSERT INTO `subscribers` (`initiator_user_id`, `target_user_id`) VALUES
	('nickname1', 'willparry'),
    ('nickname2', 'willparry'),
    ('nickname1', 'nickname3'),
    ('nickname2', 'nickname4');
# wp : 2
# n1 : 0
# n2 : 0
# n3 : 1
# n4 : 1

DELETE FROM `subscribers` 
	WHERE `initiator_user_id` = 'nickname1' AND `target_user_id` = 'nickname3';

INSERT INTO `users` (`uid`,`email`,`phone`,`password_hash`,`password_hash2`) VALUES
	('willparry', 'email', '777', '123', '123');
INSERT INTO `communities` (`administrator_id`, `cid`) VALUES
	('willparry', 'community');
INSERT INTO `posts` (`header`, `author_id`) VALUES
	('New post', 'willparry');
INSERT INTO `comments` (`post_id`, `user_id`) VALUES
	(1, 'willparry');
INSERT INTO `content` (`post_id`, `assembly_number`, `content_type`, `metadata`, `filename`) VALUES
    (1, 1, 'P', '{}', 'cat.jpg');
INSERT INTO `content` (`comment_id`, `assembly_number`, `content_type`, `metadata`, `body`) VALUES
    (1, 1, 'T', '{}', 'Ipsum dolor si amet');
    
SELECT * FROM users;
SELECT * FROM profiles;
SELECT * FROM communities;
SELECT * FROM posts;
SELECT * FROM comments;
SELECT * FROM content;


# DML-part
























-- TRIGGERS !!!
#DROP TABLE IF EXISTS `p`;
#DROP TABLE IF EXISTS `u`;
#CREATE TABLE `u` (`uid` SERIAL, `name` VARCHAR(128) NOT NULL, `karma` INT DEFAULT 0, PRIMARY KEY (`uid`));
#CREATE TABLE `p` (`pid` SERIAL, `author_uid` BIGINT UNSIGNED NOT NULL, `rating` INT NOT NULL, PRIMARY KEY (`pid`), CONSTRAINT FOREIGN KEY (`author_uid`) REFERENCES `u`(`uid`));
#DELIMITER |
#CREATE TRIGGER `update_karma` BEFORE INSERT ON `p`
#	FOR EACH ROW
#		BEGIN
#			UPDATE `u` SET `karma` = `karma` + NEW.`rating` WHERE `uid` = NEW.`author_uid`;
#		END;
#| DELIMITER ;
#INSERT IGNORE INTO `u` (`name`) VALUES ('John'), ('Peter'), ('Sophie');
#INSERT IGNORE INTO `p` (`author_uid`, `rating`) VALUES
#	(1, 100),
#	(1, 200),
#   (2, -100),
#   (2, -300);
    
# 300  - 1
# -400 - 2
# 0    - 3
#SELECT * FROM `u`;