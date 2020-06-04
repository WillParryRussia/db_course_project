-- Курсовой проект курса "Базы данных" от 6 мая 2020г. (Geekbrains Univercity)
# DML-part
USE `course_project`;
INSERT INTO `users` (`uid`,`username`,`email`,`password_hash`,`password_hash2`, `is_administrator`, `is_moderator`) VALUES ('1', 'administrator', 'admin@site.ru', SHA(1), MD5(1), 1, 1);
UPDATE `profiles` SET `phone`=79040459833,`preferences`='{"strawberryMode":"1"}',`firstname`='Will',`lastname`='Parry',`sex`='M',`birthday`='1987-04-12' WHERE `user_id` = 1;
INSERT INTO `users` (`username`,`email`,`password_hash`,`password_hash2`) VALUES ('johnsnow', 'johnsnow@winterfell.gt', SHA(2), MD5(2)),('billsmith', 'billsmith@yahoo.ru', SHA(3), MD5(3)),('superuser', 'superuser@yandex.ru', SHA(4), MD5(4)), ('noname', 'noname@attratata.ru', SHA(5), MD5(5)),('ali.baba', 'ali.baba@express.ru', SHA(6), MD5(6)),('mikestein', 'mikestein@gmain.com', SHA(7), MD5(7));
INSERT INTO `subscribers` (`initiator_user_id`, `target_user_id`) VALUES (2,1), (3,1), (2,5), (4,1), (4,2), (3,2), (2,3);
DELETE FROM `subscribers` WHERE `initiator_user_id` = 4 AND `target_user_id` = 2;
START TRANSACTION;
	SET @new_community_name = 'The Game of Thrones';
    SET @admin_id = (SELECT `uid` FROM `users` WHERE `username` = 'johnsnow');
	INSERT INTO `communities` (`administrator_id`, `community_name`) VALUES (@admin_id, @new_community_name);
    SET @comm_id = (SELECT `cid` FROM `communities` WHERE `community_name` = @new_community_name);
	INSERT INTO `communities_users` (`community_id`, `member_id`) VALUES (@comm_id, @admin_id);
COMMIT;

INSERT INTO `achievements` (`name`) VALUES ('Weekly Post'), ('The most important'), ('Readable'), ('You know nothing');
INSERT INTO `users_achievements` (`user_id`, `achievement_id`, `description`) VALUES 
	(2, 1, '31 Week of 2019'),(2, 1, '32 Week of 2019'),(7, 1, '33 Week of 2019'),(3, 3, 'More than 1kk of readers');

INSERT INTO `posts` (`header`,`author_id`, `community_id`) VALUES ('1ST POST', 1, 1),('2ND POST', 2, 1),('4TH',1,1);
INSERT INTO `posts` (`header`,`author_id`) VALUES ('3RD POST', 3);
INSERT INTO `comments` (`post_id`,`user_id`) VALUES (1, 2), (2, 3), (3, 1);
INSERT INTO `assessments` (`user_id`,`post_id`,`assessment_type`) VALUES (1, 1, '+'),(2, 1, '+'),(3, 1, '-'),(4, 1, '-'),(5, 1, '+'),(6, 1, '+'),(7, 1, '+');
INSERT INTO `assessments` (`user_id`,`comment_id`,`assessment_type`) VALUES (5, 1, '+'),(6, 1, '+'),(5, 1, '+'),(5, 1, '+'),(5, 1, '+');
