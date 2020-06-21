-- Курсовой проект курса "Базы данных" от 6 мая 2020г. (Geekbrains Univercity)
# DDL-part
DROP DATABASE IF EXISTS `course_project`;
CREATE DATABASE `course_project` DEFAULT CHARACTER SET 'UTF8MB4' COLLATE 'UTF8MB4_bin';
USE `course_project`;
#DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
	`uid` SERIAL COMMENT 'Уникальный числовой идентификатор пользователя',
	`username` VARCHAR(16) NOT NULL COMMENT 'Имя пользователя на сайте',
	`email` VARCHAR(128) NOT NULL COMMENT 'Почтовый адрес пользователя',
	`password_hash` VARCHAR(64) NOT NULL COMMENT 'Основной хэш пароля',
	`password_hash2` VARCHAR(64) NOT NULL COMMENT 'Дополнительный хэш пароля (для смены пароля)',
	`is_banned` BIT(1) NOT NULL DEFAULT 0 COMMENT 'Является ли пользователь забанненым на сайте',
	`is_moderator` BIT(1) NOT NULL DEFAULT 0 COMMENT 'Есть ли у пользователя полномочия чтобы модерировать сайт',
	`is_administrator` BIT(1) NOT NULL DEFAULT 0 COMMENT 'Есть ли у пользователя полномочия чтобы администрировать сайт',
	`created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP() COMMENT 'Временной штамп создания аккаунта',
	PRIMARY KEY (`uid`),
	UNIQUE INDEX (`username`),
	UNIQUE INDEX (`email`)
);
#DROP TABLE IF EXISTS `profiles`;
CREATE TABLE `user_profiles` (
	`user_id` BIGINT UNSIGNED NOT NULL COMMENT 'Внешний ключ на идентификатор пользователя, отношение таблиц 1 х 1',
    `phone` BIGINT UNSIGNED DEFAULT NULL COMMENT 'Номер мобильного телефона пользователя при желании',
	`preferences` JSON COMMENT 'Личные настройки пользователя',
	`firstname` VARCHAR(32) DEFAULT NULL COMMENT 'Имя пользователя (при желании)',
	`lastname` VARCHAR(32) DEFAULT NULL COMMENT 'Фамилия пользователя (при желании)',
	`sex` ENUM('M','F') DEFAULT NULL COMMENT 'Пол пользователя (при желании). Не гендер!',
	`birthday` DATE DEFAULT NULL COMMENT 'Дата рождения пользователя (при желании)',
	`subscribers` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Количество подписчиков',
	`avatar` VARCHAR(128) NOT NULL DEFAULT 'empty_user_avatar' COMMENT 'Аватарка пользователя',
	`cover` VARCHAR(128) NOT NULL DEFAULT 'empty_user_cover' COMMENT 'Фон для страницы профиля пользователя',
	`slogan` VARCHAR(256) DEFAULT NULL COMMENT 'Информация о себе',
	`rating` DECIMAL(65,1) NOT NULL DEFAULT 0 COMMENT 'Рейтинг пользователя на сайте (+/-)',
	`amount_posts` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Количество постов пользователя. ТРИГГЕР из таблицы posts',
	PRIMARY KEY (`user_id`),
    UNIQUE INDEX (`phone`),
	CONSTRAINT
		FOREIGN KEY (`user_id`) REFERENCES `users`(`uid`)
			ON UPDATE CASCADE
			ON DELETE NO ACTION
);
#DROP TABLE IF EXISTS `subscribers`;
CREATE TABLE `subscribers` (
	`initiator_user_id` BIGINT UNSIGNED NOT NULL COMMENT 'Внешний ключ на таблицу users',
	`target_user_id` BIGINT UNSIGNED NOT NULL COMMENT 'Внешний ключ на таблицу users',
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
	`cid` SERIAL COMMENT 'Уникальный цифровой идентификатор сообщества',
	`community_name` VARCHAR(32) NOT NULL COMMENT 'Название сообщества',
	`administrator_id` BIGINT UNSIGNED NOT NULL COMMENT 'Идентификатор пользователя-администратора сообщества, отношение 1 х М',
	`moderator_id` BIGINT UNSIGNED DEFAULT NULL COMMENT 'Идентификатор пользователя-модератора сообщества, отношение 1 х М',
	`created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP() COMMENT 'Временной штамп создания сообщества',
	PRIMARY KEY (`cid`),
	UNIQUE INDEX (`community_name`),
	CONSTRAINT
		FOREIGN KEY (`administrator_id`) REFERENCES `users`(`uid`)
			ON UPDATE CASCADE
			ON DELETE NO ACTION,
		FOREIGN KEY (`moderator_id`) REFERENCES `users`(`uid`)
			ON UPDATE CASCADE
			ON DELETE NO ACTION
);
#DROP TABLE IF EXISTS `community_profiles`;
CREATE TABLE `community_profiles` (
	`community_id` SERIAL COMMENT 'Внешний ключ на идентификатор  сообщества, отношение таблиц 1 х 1',
	`rating` BIGINT NOT NULL DEFAULT 0 COMMENT 'Рейтинг сообщества, который складывается из рейтинга всех его постов',
	`avatar` VARCHAR(128) NOT NULL DEFAULT 'empty_comm_avatar' COMMENT 'Аватар сообщества',
	`cover` VARCHAR(128) NOT NULL DEFAULT 'empty_comm_cover' COMMENT 'Обложка профиля сообщества',
	`slogan` VARCHAR(256) DEFAULT NULL COMMENT 'Небольшое текстовое описание',
	`amount_posts` BIGINT NOT NULL DEFAULT 0 COMMENT 'Количество постов в сообществе',
	`amount_members` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Количество членов',
	`description` VARCHAR(1000) NOT NULL DEFAULT 'Community Description Area' COMMENT 'Полнотекстовое описание сообщества',
	PRIMARY KEY (`community_id`),
	INDEX (`rating`),
	CONSTRAINT
		FOREIGN KEY (`community_id`) REFERENCES `communities`(`cid`)
			ON UPDATE CASCADE
			ON DELETE NO ACTION
);
#DROP TABLE IF EXISTS `communities_users`;
CREATE TABLE `communities_users` (
	`community_id` BIGINT UNSIGNED NOT NULL COMMENT 'Внешний ключ на таблицу communities, отношение М х М',
	`member_id` BIGINT UNSIGNED NOT NULL COMMENT 'Внешний ключ на таблицу users, отношение М х М',
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
	`user_id` BIGINT UNSIGNED NOT NULL COMMENT 'Внешний ключ на пользователей',
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
	`author_user_id` BIGINT UNSIGNED NOT NULL COMMENT 'Пользователь-автор заметки',
	`target_user_id` BIGINT UNSIGNED NOT NULL COMMENT 'Целевой пользователь заметки',
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
	`initiator_user_id` BIGINT UNSIGNED NOT NULL COMMENT 'Кто заблокировал',
	`target_user_id` BIGINT UNSIGNED NOT NULL COMMENT 'Кого заблокировали',
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
	`author_id` BIGINT UNSIGNED NOT NULL COMMENT 'Автор поста',
	`assembly_code` VARCHAR(128) NOT NULL DEFAULT 'T' COMMENT 'Код сборки поста из таблицы контента',
	`community_id` BIGINT UNSIGNED DEFAULT NULL COMMENT 'Относится ли к сообществу',
	`rating` BIGINT NOT NULL DEFAULT 0 COMMENT 'Рейтинг поста. ТРИГГЕР, когда ставят оценки',
    `saved` BIGINT NOT NULL DEFAULT 0 COMMENT 'Сколько раз сохранён пост',
	`is_deleted` BIT(1) DEFAULT 0 COMMENT 'Удалён ли пост',
	`created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP() COMMENT 'Когда создан',
	`updated_at` DATETIME ON UPDATE CURRENT_TIMESTAMP() COMMENT 'Когда изменен',
	PRIMARY KEY (`pid`),
	INDEX (`header`),
	INDEX (`author_id`), 
	INDEX (`rating`),
	INDEX (`community_id`),
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
	`user_id` BIGINT UNSIGNED NOT NULL COMMENT 'Пользователь написавший коммент',
	`assembly_code` VARCHAR(32) NOT NULL DEFAULT 'T' COMMENT 'Код сборки коммент',
	`rating` BIGINT NOT NULL DEFAULT 0 COMMENT 'Рейтинг коммента',
	`parent_cuid` BIGINT UNSIGNED DEFAULT NULL COMMENT 'Идентификатор родительского коммента',
	`parent_uid` BIGINT UNSIGNED DEFAULT NULL COMMENT 'Идентификатор автора родительского коммента',
	# Тут стоит отдельно заметить, что если идентификатор родительского коммента NULL
    # то это значит что он в корне иерархии комментов поста. То-есть коммент непосредственно к посту
	`is_banned` BIT(1) NOT NULL DEFAULT 0 COMMENT 'Является ли коммент забаненым',
	`is_read` BIT(1) NOT NULL DEFAULT 0 COMMENT 'Прочитан ли коммент тем, кому он написан',
	`created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP() COMMENT 'Когда создан',
	`updated_at` DATETIME ON UPDATE CURRENT_TIMESTAMP() COMMENT 'Когда изменён',
	PRIMARY KEY (`cuid`),
	INDEX (`post_id`),
	INDEX (`user_id`),
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
#DROP TABLE IF EXISTS `content`;
CREATE TABLE `content` (
	`coid` SERIAL COMMENT 'Идентификатор контекста',
	`post_id` BIGINT UNSIGNED DEFAULT NULL COMMENT 'Идентификатор поста, если этот контент относится к посту',
	`comment_id` BIGINT UNSIGNED DEFAULT NULL COMMENT 'Идентификатор коммента, если этот контент относится к комменту',
	`content_type` ENUM('T','V','P') NOT NULL COMMENT 'Тип контента, T - текст, P - пикча, V - видео',
	`assembly_number` SMALLINT NOT NULL COMMENT 'Сборочный номер, чтобы расположить контент в верном порядке',
	`metadata` JSON NOT NULL COMMENT 'Разные метаданные для файла',
	`body` VARCHAR(5000) DEFAULT NULL COMMENT 'Содержимое контента, если тип Т',
	`filename` VARCHAR(128) DEFAULT NULL COMMENT 'Ссылка на имя медифайла',
    `filelink` VARCHAR(256) DEFAULT NULL COMMENT 'Ссылка на имя внешний источник',
	PRIMARY KEY (`coid`),
	INDEX (`post_id`),
	INDEX (`comment_id`),
	CONSTRAINT
		FOREIGN KEY (`post_id`) REFERENCES `posts`(`pid`)
			ON UPDATE NO ACTION
			ON DELETE NO ACTION,
		FOREIGN KEY (`comment_id`) REFERENCES `comments`(`cuid`)
			ON UPDATE NO ACTION
			ON DELETE NO ACTION
);

#DROP TABLE IF EXISTS `saved_comments`;
CREATE TABLE `saved_comments` (
	`user_id` BIGINT UNSIGNED NOT NULL COMMENT 'Пользователь, сохранивший коммент',
	`comment_id` BIGINT UNSIGNED NOT NULL COMMENT 'Сохранённый коммент',
	PRIMARY KEY (`user_id`,`comment_id`),
	CONSTRAINT
		FOREIGN KEY (`user_id`) REFERENCES `users`(`uid`)
			ON UPDATE CASCADE
			ON DELETE CASCADE,
		FOREIGN KEY (`comment_id`) REFERENCES `comments`(`cuid`)
			ON UPDATE CASCADE
			ON DELETE CASCADE
);
#DROP TABLE IF EXISTS `saved_posts`;
CREATE TABLE `saved_posts` (
	`user_id` BIGINT UNSIGNED NOT NULL COMMENT 'Пользователь, сохранивший пост',
	`post_id` BIGINT UNSIGNED NOT NULL COMMENT 'Сохранённый пост',
	PRIMARY KEY (`user_id`,`post_id`),
	CONSTRAINT
		FOREIGN KEY (`user_id`) REFERENCES `users`(`uid`)
			ON UPDATE CASCADE
			ON DELETE CASCADE,
		FOREIGN KEY (`post_id`) REFERENCES `posts`(`pid`)
			ON UPDATE CASCADE
			ON DELETE CASCADE
);
#DROP TABLE IF EXISTS `assessments_posts`;
# Я думаю при загрузке страницы поста нужно уже передавать через POST поставил ли пользователь оценку и какую.
CREATE TABLE `assessments_posts` (
	`user_id` BIGINT UNSIGNED NOT NULL COMMENT 'Кто поставил оценку',
	`post_id` BIGINT UNSIGNED NOT NULL COMMENT 'Какому посту',
	`assessment_type` ENUM('+','-') NOT NULL COMMENT 'Тип оценки',
	PRIMARY KEY (`user_id`, `post_id`),
	CONSTRAINT
		FOREIGN KEY (`user_id`) REFERENCES `users`(`uid`)
			ON UPDATE CASCADE
			ON DELETE NO ACTION,
		FOREIGN KEY (`post_id`) REFERENCES `posts`(`pid`)
			ON UPDATE CASCADE
			ON DELETE CASCADE
);
#DROP TABLE IF EXISTS `assessments_comments`;
CREATE TABLE `assessments_comments` (
	`user_id` BIGINT UNSIGNED NOT NULL COMMENT 'Кто поставил оценку',
	`comment_id` BIGINT UNSIGNED NOT NULL COMMENT 'Какому комменту',
	`assessment_type` ENUM('+','-') NOT NULL COMMENT 'Тип оценки',
	PRIMARY KEY (`user_id`, `comment_id`),
	CONSTRAINT
		FOREIGN KEY (`user_id`) REFERENCES `users`(`uid`)
			ON UPDATE CASCADE
			ON DELETE NO ACTION,
		FOREIGN KEY (`comment_id`) REFERENCES `comments`(`cuid`)
			ON UPDATE CASCADE
			ON DELETE CASCADE
);
###############################################################################3