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
DROP TRIGGER IF EXISTS `increase_amount_posts`||
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
		INSERT INTO `users_achievements` (`user_id`,`achievement_id`,`description`) VALUES (NEW.`user_id`, 100, `U get rare Golden Mystery Sign`);
   END IF;
END||
###############################################################
# Сохранение поста и удаление из сохранений
DROP TRIGGER IF EXISTS `increase_counter_saves`||
CREATE TRIGGER `increase_counter_saves` AFTER INSERT ON `saves` FOR EACH ROW
BEGIN
	IF(NEW.`post_id`IS NOT NULL) THEN
		UPDATE `posts` SET `saved` = `saved` + 1 WHERE `pid` = NEW.`post_id`;
   END IF;
END||
###############################################################
DROP TRIGGER IF EXISTS `decrease_counter_saves`||
CREATE TRIGGER `decrease_counter_saves` AFTER DELETE ON `saves` FOR EACH ROW
BEGIN
	IF(OLD.`post_id`IS NOT NULL) THEN
		UPDATE `posts` SET `saved` = `saved` - 1 WHERE `pid` = OLD.`post_id`;
   END IF;
END||
###############################################################
DELIMITER ;

#DROP TABLE IF EXISTS `logs`;
#CREATE TEMPORARY TABLE `logs` (`old` VARCHAR(128), `new` VARCHAR(128));

















/*
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
*/