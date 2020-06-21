-- Курсовой проект курса "Базы данных" от 6 мая 2020г. (Geekbrains Univercity)
# Procedures/functions-part
DELIMITER ||
###############################################################
# Функция, которая добавляет запись в таблицу тэгов при необходимости, либо возвращает идентификатор существующего тэга
DROP FUNCTION IF EXISTS `add_tag`||
CREATE FUNCTION `add_tag` (`tagname` VARCHAR(16))
	RETURNS INT
    DETERMINISTIC
	MODIFIES SQL DATA
BEGIN
	SET @tag_id = (SELECT `tid` FROM `tags` WHERE `name` = `tagname`);
    IF(@tag_id IS NULL) THEN
		INSERT INTO `tags`(`name`) VALUES (`tagname`);
        SET @tag_id = (SELECT `tid` FROM `tags` WHERE `name` = `tagname`);
    END IF;
    RETURN @tag_id;
END||
###############################################################
# Функция, которая будет генерировать случайное десятизнаковое число
DROP FUNCTION IF EXISTS `generate_id`||
CREATE FUNCTION `generate_id` ()
	RETURNS BIGINT
	READS SQL DATA
BEGIN
	SET @random_number = FLOOR(RAND()*(99999999999 - 1)*1);
	RETURN @random_number;
END||
###############################################################
# Процедура, которая забьёт таблицу saved_posts (DML) для тестирования
DROP PROCEDURE IF EXISTS `generate_DML4saved_posts`||
CREATE PROCEDURE `generate_DML4saved_posts` (`count` INT)
BEGIN
	SET @counter = 0;
	WHILE (@counter < `count`) DO
		SET @user_id = (SELECT `uid` FROM `users` ORDER BY RAND() LIMIT 1);
		SET @content_id = (SELECT `pid` FROM `posts` ORDER BY RAND() LIMIT 1);
		INSERT IGNORE INTO `saved_posts` (`user_id`, `post_id`) VALUES (@user_id, @content_id);
	SET @counter = @counter + 1;
    END WHILE;
END||
###############################################################
# Процедура, которая забьёт таблицу saved_comments (DML) для тестирования
DROP PROCEDURE IF EXISTS `generate_DML4saved_comments`||
CREATE PROCEDURE `generate_DML4saved_comments` (`count` INT)
BEGIN
	SET @counter = 0;
	WHILE (@counter < `count`) DO
		SET @user_id = (SELECT `uid` FROM `users` ORDER BY RAND() LIMIT 1);
		SET @content_id = (SELECT `cuid` FROM `comments` ORDER BY RAND() LIMIT 1);
		INSERT IGNORE INTO `saved_comments` (`user_id`, `comment_id`) VALUES (@user_id, @content_id);
	SET @counter = @counter + 1;
    END WHILE;
END||
###############################################################
# Процедура, которая будет вставлять оценки постов в таблицу оценок постов (или обновлять)
DROP PROCEDURE IF EXISTS `insert-update_assessments_posts`||
CREATE PROCEDURE `insert-update_assessments_posts`(`uid` INT, `pid` BIGINT, `type` ENUM('+','-'))
checking: BEGIN
	SET @assessment = (SELECT `assessment_type` FROM `assessments_posts` WHERE `user_id` = `uid` AND `post_id` = `pid`);
    IF (@assessment IS NOT NULL AND @assessment = `type`) THEN
		LEAVE checking;
	ELSEIF (@assessment IS NOT NULL) THEN
		DELETE FROM `assessments_posts` WHERE `user_id` = `uid` AND `post_id` = `pid`;
		LEAVE checking;
    END IF;
	INSERT IGNORE INTO `assessments_posts` (`user_id`,`post_id`,`assessment_type`) VALUES (`uid`,`pid`,`type`);
    # Проблема данного подхода в том, что у нас не будет варианта убрать оценку у поста, либо плюс, либо минус
	#INSERT INTO `assessments_posts` (`user_id`,`post_id`,`assessment_type`)
	#VALUES (`uid`,`pid`,`type`)
    #ON DUPLICATE KEY UPDATE `assessment_type` = `type`;
END||
###############################################################
# Процедура, которая будет вставлять оценки комментов в таблицу оценок комментов (или обновлять)
DROP PROCEDURE IF EXISTS `insert-update_assessments_comments`||
CREATE PROCEDURE `insert-update_assessments_comments`(`uid` INT, `cuid` BIGINT, `type` ENUM('+','-'))
checking: BEGIN
	SET @assessment = (SELECT `assessment_type` FROM `assessments_comments` WHERE `user_id` = `uid` AND `comment_id` = `cuid`);
    IF (@assessment IS NOT NULL AND @assessment = `type`) THEN
		LEAVE checking;
	ELSEIF (@assessment IS NOT NULL) THEN
		DELETE FROM `assessments_comments` WHERE `user_id` = `uid` AND `comment_id` = `cuid`;
		LEAVE checking;
    END IF;
    INSERT IGNORE INTO `assessments_comments` (`user_id`,`comment_id`,`assessment_type`) VALUES (`uid`,`cuid`,`type`);
	#INSERT INTO `assessments_comments` (`user_id`,`comment_id`,`assessment_type`)
	#VALUES (`uid`,`cuid`,`type`)
    #ON DUPLICATE KEY UPDATE `assessment_type` = `type`;
END||
###############################################################
DROP PROCEDURE IF EXISTS `generate_DML4assessments_posts`||
CREATE PROCEDURE `generate_DML4assessments_posts`(`count` INT)
BEGIN
	SET @counter = 0;
	WHILE (@counter < `count`) DO
		SET @random_user_id = (SELECT `uid` FROM `users` ORDER BY RAND() LIMIT 1);
		SET @random_post_id = (SELECT `pid` FROM `posts` ORDER BY RAND() LIMIT 1);
		SET @random_math_sign = IF((SELECT FLOOR(RAND() * 10) <= 5), '+', '-');
		CALL `insert-update_assessments_posts`(@random_user_id, @random_post_id, @random_math_sign);
		SET @counter = @counter + 1;
	END WHILE;
END||
###############################################################
DROP PROCEDURE IF EXISTS `generate_DML4assessments_comments`||
CREATE PROCEDURE `generate_DML4assessments_comments`(`count` INT)
BEGIN
SET @counter = 0;
	WHILE (@counter < `count`) DO
		SET @random_user_id = (SELECT `uid` FROM `users` ORDER BY RAND() LIMIT 1);
		SET @random_comment_id = (SELECT `cuid` FROM `comments` ORDER BY RAND() LIMIT 1);
		SET @random_math_sign = IF((SELECT FLOOR(RAND() * 10) <= 5), '+', '-');
		CALL `insert-update_assessments_comments`(@random_user_id, @random_comment_id, @random_math_sign);
		SET @counter = @counter + 1;
	END WHILE;
END||
###############################################################
DELIMITER ;