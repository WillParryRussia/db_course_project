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
# Процедура, которая забьёт таблицу saves (DML) для тестирования
DROP PROCEDURE IF EXISTS `generate_DML4saves`||
CREATE PROCEDURE `generate_DML4saves` (`type` ENUM('p','c'))
BEGIN
	SET @user_id = (SELECT `uid` FROM `users` ORDER BY RAND() LIMIT 1);
	IF (`type` = 'p') THEN
		SET @content_id = (SELECT `pid` FROM `posts` ORDER BY RAND() LIMIT 1);
		INSERT INTO `saves` (`user_id`, `post_id`) VALUES (@user_id, @content_id);
	ELSEIF (`type` = 'c') THEN
		SET @content_id = (SELECT `cuid` FROM `comments` ORDER BY RAND() LIMIT 1);
		INSERT INTO `saves` (`user_id`, `comment_id`) VALUES (@user_id, @content_id);
	END IF;

END||
###############################################################
# Процедура, которая забьёт таблицу assessments (DML) для тестирования
DROP PROCEDURE IF EXISTS `generate_DML4assessments`||
CREATE PROCEDURE `generate_DML4assessments` (`type` ENUM('p','c'), `count` INT)
BEGIN
	SET @counter = 0;
	WHILE (@counter < `count`) DO
        SET @user_id = (SELECT `uid` FROM `users` ORDER BY RAND() LIMIT 1);
		SET @math_sign = IF (FLOOR(RAND()*10) <= 5, '+', '-');
        SELECT @math_sign;
        IF (`type` = 'p') THEN
            SET @content_id = (SELECT `pid` FROM `posts` ORDER BY RAND() LIMIT 1);
			INSERT INTO `assessments` (`user_id`, `post_id`, `assessment_type`) VALUES (@user_id, @content_id, @math_sign);
		ELSEIF (`type` = 'c') THEN
            SET @content_id = (SELECT `cuid` FROM `comments` ORDER BY RAND() LIMIT 1);
			INSERT INTO `assessments` (`user_id`, `comment_id`, `assessment_type`) VALUES (@user_id, @content_id, @math_sign);
		END IF;
		SET @counter = @counter + 1;
	END WHILE;
END||
DELIMITER ;