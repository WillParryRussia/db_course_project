-- Курсовой проект курса "Базы данных" от 6 мая 2020г. (Geekbrains Univercity)
# Trigger-part
USE `course_project`;
DELIMITER ||
###############################################################
# Добавляем профиль пользователя после создания пользователя
DROP TRIGGER IF EXISTS `add_profile_to_user`;
CREATE TRIGGER `add_profile_to_user` AFTER INSERT ON `users` FOR EACH ROW
BEGIN
	INSERT INTO `profiles` (`user_id`) VALUES (NEW.uid);
END||
###############################################################
# Нельзя подписаться на самого себя
DROP TRIGGER IF EXISTS `no_selfsubcribing_allowed`||
CREATE TRIGGER `no_selfsubcribing_allowed` BEFORE INSERT ON `subscribers` FOR EACH ROW
BEGIN
	IF NEW.`initiator_user_id` = NEW.`target_user_id`
		THEN SIGNAL SQLSTATE '45000';
	END IF;
END||
###############################################################
# Увеличиваем счётчик подписчиков пользователя после подписки на пользователя
DROP TRIGGER IF EXISTS `add_subscribers`||
CREATE TRIGGER `add_subscribers` AFTER INSERT ON `subscribers` FOR EACH ROW
BEGIN
	UPDATE `profiles`
		SET `subscribers` = `subscribers` + 1 
		WHERE `user_id` = NEW.`target_user_id`;
END||
###############################################################
# Уменьшаем счётчик подписчиков пользователя после отписки от пользователя
CREATE TRIGGER `delete_subscribers` BEFORE DELETE ON `subscribers` FOR EACH ROW
BEGIN
	UPDATE `profiles`
		SET `subscribers` = `subscribers` - 1 
		WHERE `user_id` = OLD.`target_user_id`;
END||
###############################################################
# После создания сообщества, нужно добавить увеличить счётчик членов сообщества на 1 и добавить запись в таблицу users_communities


# Сложный триггер, где в зависимости от опций отрабатывают 10 кейсов
# Если пост или коммент получают положительную оценку, то рейтинг пользователя, поста(коммента) и
# сообщество (если пост в сообществе) увеличивается на единицу (если коммент, то на 0.5) и наоборот
CREATE TRIGGER `change_rating` AFTER INSERT ON	`assessments` FOR EACH ROW
BEGIN
	SET @content_author = IF(
		NEW.`post_id` IS NOT NULL,
		(SELECT `author_id` FROM `posts` WHERE `pid` = NEW.`post_id`),
		(SELECT `user_id` FROM `comments` WHERE `cuid` = NEW.`comment_id`)
	);
    
	SET @post_community_id = (SELECT `community_id` FROM `posts` WHERE `pid` = NEW.`post_id`);
    
	UPDATE `profiles`
		SET `karma` = IF(
			NEW.`assessment_type` = '+',
				IF(NEW.`post_id` IS NULL, `karma` + 0.5, `karma` + 1),
				IF(NEW.`post_id` IS NULL, `karma` - 0.5, `karma` - 1)
		) WHERE `profiles`.`user_id` = @content_author;
	UPDATE `posts`
		SET `rating` = IF(
			NEW.`assessment_type` = '+',
				`rating` + 1,
				`rating` - 1
		) WHERE `posts`.`pid` = NEW.`post_id`;
	UPDATE `comments`
		SET `rating` = IF(
			NEW.`assessment_type` = '+',
				`rating` + 1,
				`rating` - 1
		) WHERE `comments`.`cuid` = NEW.`comment_id`;
	UPDATE `communities`
		SET `rating` = IF(
			NEW.`assessment_type` = '+',
				`rating` + 1,
				`rating` - 1
		) WHERE `communities`.`cid` = @post_community_id;
END||





-- Увеличиваем счётчик членов сообщества после подписки на сообщество
CREATE TRIGGER `add_community_member`
	AFTER INSERT ON `communities_users`
	FOR EACH ROW
	BEGIN
		UPDATE `communities`
			SET `amount_members` = `amount_members` + 1 
			WHERE `cid` = NEW.`community_id`;
	END;

-- Уменьшаем счётчик членов сообщества после отписки от сообщества
CREATE TRIGGER `delete_community_members`
	AFTER DELETE ON `communities_users`
	FOR EACH ROW
	BEGIN
		UPDATE `communities`
			SET `amount_members` = `amount_members` - 1
			WHERE `cid` = OLD.`community_id`;
	END;

-- Увеличиваем счётчик постов в сообществе после создания поста
-- При этом логическое условие, что увеличиваем только если автор поста указал к какому сообществу относится пост
CREATE TRIGGER `add_community_post`
	AFTER INSERT ON `posts`
	FOR EACH ROW
	BEGIN
		UPDATE `communities`
			SET `amount_posts` = IF(NEW.`community_id` IS NOT NULL, `amount_posts` + 1, `amount_posts`)
			WHERE `cid` = NEW.`community_id`;
	END;

-- Уменьшаем счётчик постов в сообществе после удаления поста
-- При этом надо помнить, что фактически мы не удаляем посты, а ставим флаг is_deleted
CREATE TRIGGER `delete_community_post`
	AFTER UPDATE ON `posts`
	FOR EACH ROW
	BEGIN
		UPDATE `communities`
			SET `amount_posts` = IF(NEW.`is_deleted` = 1, `amount_posts` - 1, `amount_posts`)
			WHERE `cid` = NEW.`community_id`;
	END;

| DELIMITER ;