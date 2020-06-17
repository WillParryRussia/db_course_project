-- Курсовой проект курса "Базы данных" от 6 мая 2020г. (Geekbrains Univercity)
# Procedures/functions-part
DELIMITER ||
###############################################################
# DROP FUNCTION IF EXISTS `add_tag`||
CREATE FUNCTION `add_tag` (`tagname` VARCHAR(16))
	RETURNS INT
	DETERMINISTIC
BEGIN
	SET @tag_id = (SELECT `tid` FROM `tags` WHERE `name` = `tagname`);
    IF(@tag_id IS NULL) THEN
		INSERT INTO `tags`(`name`) VALUES (`tagname`);
        SET @tag_id = (SELECT `tid` FROM `tags` WHERE `name` = `tagname`);
    END IF;
    RETURN @tag_id;
END||
###############################################################
DELIMITER ;