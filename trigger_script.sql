-- Курсовой проект курса "Базы данных" от 6 мая 2020г. (Geekbrains Univercity)
# Triggers-part
USE `course_project`;
DELIMITER ||
###############################################################
# Добавляем профиль пользователя после создания пользователя
DROP TRIGGER IF EXISTS `add_user_profile`||
CREATE TRIGGER `add_user_profile` AFTER INSERT ON `users` FOR EACH ROW
BEGIN
	INSERT INTO `user_profiles` (`user_id`) VALUES (NEW.uid);
END||
###############################################################
# Добавляем профиль сообщества после создания сообщества и заодно добавим запись в таблицу users_communities
DROP TRIGGER IF EXISTS `add_community_profile`||
CREATE TRIGGER `add_community_profile` AFTER INSERT ON `communities` FOR EACH ROW
BEGIN
	INSERT INTO `community_profiles` (`community_id`) VALUES (NEW.cid);
    INSERT INTO `communities_users` (`community_id`,`member_id`) VALUES (NEW.cid, NEW.`administrator_id`);
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
	UPDATE `user_profiles` SET `subscribers` = `subscribers` + 1 WHERE `user_id` = NEW.`target_user_id`;
END||
###############################################################
# Уменьшаем счётчик подписчиков пользователя после отписки от пользователя
DROP TRIGGER IF EXISTS `delete_subscribers`||
CREATE TRIGGER `delete_subscribers` BEFORE DELETE ON `subscribers` FOR EACH ROW
BEGIN
	UPDATE `user_profiles` SET `subscribers` = `subscribers` - 1 WHERE `user_id` = OLD.`target_user_id`;
END||
###############################################################
# После подписки человека на сообщество, надо увеличить счётчик количества членов сообщества в таблице community_profiles
DROP TRIGGER IF EXISTS `increase_comm_members`||
CREATE TRIGGER `increase_comm_members` AFTER INSERT ON `communities_users` FOR EACH ROW
BEGIN
	UPDATE `community_profiles` SET `amount_members` = `amount_members` + 1 WHERE `community_id` = NEW.`community_id`;
END||
###############################################################
# После отписки человека от сообщества, надо уменьшить счётчик количества членов сообщества в таблице community_profiles
DROP TRIGGER IF EXISTS `decrease_comm_members`||
CREATE TRIGGER `decrease_comm_members` BEFORE DELETE ON `communities_users` FOR EACH ROW
BEGIN
	UPDATE `community_profiles` SET `amount_members` = `amount_members` - 1 WHERE `community_id` = OLD.`community_id`;
END||
###############################################################
# После того, как мы создаём пост и явно указываем сообщество, у сообщества должен прирасти счётчик
# А тажке, после того, как мы создаём пост у пользователя должен вырасти счётчик постов
DROP TRIGGER IF EXISTS `increase_amount_posts`||
CREATE TRIGGER `increase_amount_posts` AFTER INSERT ON `posts` FOR EACH ROW
BEGIN
	IF(NEW.`community_id` IS NOT NULL) THEN
		UPDATE `community_profiles` SET `amount_posts` = `amount_posts` + 1 WHERE `community_profiles`.`community_id` = NEW.`community_id`;
    END IF;
	UPDATE `user_profiles` SET `amount_posts` = `amount_posts` + 1 WHERE `user_id` = NEW.`author_id`;
END||
###############################################################
# Мы можем добавить пост в сообщество не только после создания поста, но и позже, равно как и удалить
DROP TRIGGER IF EXISTS `increase_amount_comm_posts`||
CREATE TRIGGER `increase_amount_comm_posts` AFTER UPDATE ON `posts` FOR EACH ROW
BEGIN
	IF((NEW.`community_id` <> OLD.`community_id`) OR 
		(NEW.`community_id` IS NULL AND OLD.`community_id` IS NOT NULL) OR
		(NEW.`community_id` IS NOT NULL AND OLD.`community_id` IS NULL)) 
		THEN
			IF (NEW.`community_id` IS NOT NULL) THEN
				UPDATE `community_profiles` SET `amount_posts` = `amount_posts` + 1 WHERE `community_id` = NEW.`community_id`;
			END IF;
			UPDATE `community_profiles` SET `amount_posts` = `amount_posts` - 1 WHERE `community_id` = OLD.`community_id`;
	END IF;
END||
###############################################################
# Таинственный золотой знак (определённая и крайне редкая награда. Когда ID коммента совпадёт с ID поста)
DROP TRIGGER IF EXISTS `get_mystery_golden_sign`||
CREATE TRIGGER `get_mystery_golden_sign` AFTER INSERT ON `comments` FOR EACH ROW
BEGIN
	IF(NEW.`cuid` = NEW.`post_id`) THEN
		INSERT INTO `users_achievements` (`user_id`,`achievement_id`,`description`) VALUES (NEW.`user_id`, 100, 'U get rare Golden Mystery Sign');
   END IF;
END||
###############################################################
# Сохранение поста
DROP TRIGGER IF EXISTS `increase_counter_savedposts`||
CREATE TRIGGER `increase_counter_savedposts` AFTER INSERT ON `saved_posts` FOR EACH ROW
BEGIN
	UPDATE `posts` SET `saved` = `saved` + 1 WHERE `pid` = NEW.`post_id`;
END||
###############################################################
# Удаление поста из сохранений
DROP TRIGGER IF EXISTS `decrease_counter_savedposts`||
CREATE TRIGGER `decrease_counter_savedposts` AFTER DELETE ON `saved_posts` FOR EACH ROW
BEGIN
	UPDATE `posts` SET `saved` = `saved` - 1 WHERE `pid` = OLD.`post_id`;
END||
###############################################################
# После вставки в таблицу assessments_posts
DROP TRIGGER IF EXISTS `insert_to_assessments_posts`||
CREATE TRIGGER `insert_to_assessments_posts` AFTER INSERT ON `assessments_posts` FOR EACH ROW
BEGIN
	SELECT `author_id`, `community_id` INTO @author_id, @community_id FROM `posts` WHERE `pid` = NEW.`post_id`;
	IF (NEW.`assessment_type` = '+') THEN
		UPDATE `posts` SET `rating` = `rating` + 1 WHERE `pid` = NEW.`post_id`;
		UPDATE `community_profiles` SET `rating` = `rating` + 1 WHERE `community_id` = @community_id;
		UPDATE `user_profiles` SET `rating` = `rating` + 1 WHERE `user_id` = @author_id;
	ELSE
		UPDATE `posts` SET `rating` = `rating` - 1 WHERE `pid` = NEW.`post_id`;
		UPDATE `community_profiles` SET `rating` = `rating` - 1 WHERE `community_id` = @community_id;
		UPDATE `user_profiles` SET `rating` = `rating` - 1 WHERE `user_id` = @author_id;
	END IF;
END||
###############################################################
# После удаления из таблицы assessments_posts
DROP TRIGGER IF EXISTS `delete_from_assessments_posts`||
CREATE TRIGGER `delete_from_assessments_posts` AFTER DELETE ON `assessments_posts` FOR EACH ROW
BEGIN
	SELECT `author_id`, `community_id` INTO @author_id, @community_id FROM `posts` WHERE `pid` = OLD.`post_id`;
	IF (OLD.`assessment_type` = '+') THEN
		UPDATE `posts` SET `rating` = `rating` - 1 WHERE `pid` = OLD.`post_id`;
		UPDATE `community_profiles` SET `rating` = `rating` - 1 WHERE `community_id` = @community_id;
		UPDATE `user_profiles` SET `rating` = `rating` - 1 WHERE `user_id` = @author_id;
	ELSE
		UPDATE `posts` SET `rating` = `rating` + 1 WHERE `pid` = OLD.`post_id`;
		UPDATE `community_profiles` SET `rating` = `rating` + 1 WHERE `community_id` = @community_id;
		UPDATE `user_profiles` SET `rating` = `rating` + 1 WHERE `user_id` = @author_id;
	END IF;
END||
###############################################################
# После вставки в таблицу assessments_comments
DROP TRIGGER IF EXISTS `insert_to_assessments_comments`||
CREATE TRIGGER `insert_to_assessments_comments` AFTER INSERT ON `assessments_comments` FOR EACH ROW
BEGIN
	SELECT `user_id` INTO @author_id FROM `comments` WHERE `cuid` = NEW.`comment_id`;
	IF (NEW.`assessment_type` = '+') THEN
		UPDATE `comments` SET `rating` = `rating` + 1 WHERE `cuid` = NEW.`comment_id`;
		UPDATE `user_profiles` SET `rating` = `rating` + 0.5 WHERE `user_id` = @author_id;
	ELSE
		UPDATE `comments` SET `rating` = `rating` - 1 WHERE `cuid` = NEW.`comment_id`;
		UPDATE `user_profiles` SET `rating` = `rating` - 0.5 WHERE `user_id` = @author_id;
	END IF;
END||
###############################################################
# После удаления из таблицы assessments_comments
DROP TRIGGER IF EXISTS `delete_from_assessments_comments`||
CREATE TRIGGER `delete_from_assessments_comments` AFTER DELETE ON `assessments_comments` FOR EACH ROW
BEGIN
	SELECT `user_id` INTO @author_id FROM `comments` WHERE `cuid` = OLD.`comment_id`;
	IF (OLD.`assessment_type` = '+') THEN
		UPDATE `comments` SET `rating` = `rating` - 1 WHERE `cuid` = OLD.`comment_id`;
		UPDATE `user_profiles` SET `rating` = `rating` - 0.5 WHERE `user_id` = @author_id;
	ELSE
		UPDATE `comments` SET `rating` = `rating` + 1 WHERE `cuid` = OLD.`comment_id`;
		UPDATE `user_profiles` SET `rating` = `rating` + 0.5 WHERE `user_id` = @author_id;
	END IF;
END||
###############################################################
DELIMITER ;