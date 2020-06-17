-- Курсовой проект курса "Базы данных" от 6 мая 2020г. (Geekbrains Univercity)
# DML-part
# DML формируется нащим бэкендом, например языком PHP, поэтому здесь я буду симулировать что эти запросы (в т.ч. и транзакционные)
# отправляет бэкенд на сервер MySQL
USE `course_project`;
INSERT INTO `users` (`uid`,`username`,`email`,`password_hash`,`password_hash2`, `is_administrator`, `is_moderator`) VALUES ('1', 'willparry', 'admin@site.ru', SHA(1), MD5(1), 1, 1);
UPDATE `user_profiles` SET `phone`=79040459833,`preferences`='{"strawberryMode":"1"}',`firstname`='Will',`lastname`='Parry',`sex`='M',`birthday`='1987-04-12' WHERE `user_id` = 1;
INSERT INTO `users` (`username`,`email`,`password_hash`,`password_hash2`) VALUES ('johnsnow', 'johnsnow@winterfell.gt', SHA(2), MD5(2)),('billsmith', 'billsmith@yahoo.ru', SHA(3), MD5(3)),('superuser', 'superuser@yandex.ru', SHA(4), MD5(4)), ('noname', 'noname@aiwillhackyourmom.gfys', SHA(5), MD5(5)),('ali.baba', 'ali.baba@express.ru', SHA(6), MD5(6)),('mikestein', 'mikestein@gmain.com', SHA(7), MD5(7)),('onizuka', 'onizuka@sensei.jp', SHA(8), MD5(8)),('geralt', 'geralt@gwynbleydd.rv', SHA(9), MD5(9)),('zireael', 'cirilla@riannon.cintra', SHA(10), MD5(10));
INSERT INTO `subscribers` (`initiator_user_id`, `target_user_id`) VALUES (2,1), (3,1), (4,1), (5,1), (6,1), (7,1), (8,1), (9,1), (10,1),(3,2),(5,2),(8,2),(9,2),(2,3),(10,3),(2,5),(3,5),(4,5),(6,5),(7,5),(10,5),(1,6),(2,6),(3,6),(4,6),(5,6),(8,7),(7,8),(5,9),(1,10),(9,10),(10,9);
DELETE FROM `subscribers` WHERE `initiator_user_id` = 5 AND `target_user_id` = 2;
INSERT INTO `communities` (`administrator_id`, `community_name`) VALUES (1,'Support Tech'),(1, 'Advertisement Department'),(1, 'Moderation'),(2, 'The Game of Thrones'),(4, 'Automobiles'),(4, 'Motocycles'),(7, 'Blizzard Games'),(7, 'Overwatch'),(9,'The Witcher'),(10, 'Cintra');
INSERT INTO `communities_users` (`community_id`,`member_id`) VALUES (1,2),(1,3),(1,4),(1,5),(1,6),(1,7),(1,8),(1,9),(1,10),(2,2),(2,3),(2,4),(2,5),(2,6),(2,7),(2,8),(2,9),(2,10),(3,2),(3,3),(3,4),(3,5),(3,6),(3,7),(3,8),(3,9),(3,10),(4,1),(4,3),(4,6),(4,7),(4,8),(5,2),(5,9),(5,10),(6,1),(6,9),(6,10),(6,5),(6,7),(7,3),(7,2),(7,5),(8,1),(8,2),(8,3),(8,4),(8,5),(8,6),(8,8),(8,9),(8,10),(9,1),(10,1);
DELETE FROM `communities_users` WHERE `community_id`= 8 AND `member_id`= 2;
INSERT INTO `users_notes` (`author_user_id`,`target_user_id`,`body`) VALUES (2,1,'admin'),(9,1,'our admin'),(10,1,'administrator'),(1,2,'fanart GOT'),(9,10,'ciri'),(10,9,'geralt'),(3,4,'kiddyboy'),(5,4,'little'),(6,4,'dont argue with him'),(7,4,'such a stupid one!!');
INSERT INTO `achievements`(`name`) VALUES ('Post of the week'),('Post of the month'),('Active reader'),('You know nothing'),('Top Five in karma'),('Top writer'),('Five years user'),('Ten years user'),('Comment of the week');
INSERT INTO `users_achievements`(`user_id`,`achievement_id`,`description`) VALUES (2,1,'31 Week of 2019'),(2,1,'32 Week of 2019'),(7,1,'33 Week of 2019'),(3,2,'Igritt says'),(9,5,'Second place'),(10,5,'First place'),(4,6,'At the end of 2019'),(4,6,'At the end of 2018'),(1,7,''), (1,8,'');
INSERT INTO `ignore_lists`(`initiator_user_id`,`target_user_id`) VALUES (4,1),(4,6),(4,8),(8,2),(6,5),(7,2),(3,9),(10,4),(9,4),(7,8),(2,4),(2,5),(2,7),(9,5),(10,5);
# INSERT INTO `tags` (`name`) VALUES ('auto'),('moto'),('support'),('cat'),('dog'),('witcher'),('thewitcher'),('withcher3'),('adv'),('helpme'),('got'),('game of thrones'),('targariens'),('buy n sell'),('schematechnic'),('text'),('video'),('youtube'),('strawberry'),('18+');
########################################################
START TRANSACTION;
	SET @author_id = (SELECT `uid` FROM `users` WHERE `username` = 'willparry');
    SET @community_id = (SELECT `cid` FROM `communities` WHERE `community_name` = 'Support Tech');
	INSERT INTO `posts` (`header`,`author_id`, `assembly_code`, `community_id`) VALUES 
		('How to create a post', @author_id, 'TPTP', @community_id);
	SET @last_inserted_id = LAST_INSERT_ID();
	INSERT INTO `content` (`post_id`, `content_type`, `assembly_number`, `metadata`, `body`, `filename`) VALUES 
		(@last_inserted_id, 'T', 1, '{}', 'First text block of the post', NULL),
		(@last_inserted_id, 'P', 1, '{"size":"600x600"}', NULL, 'opening_picture.jpg'),
		(@last_inserted_id, 'T', 2, '{}', 'Second text block of the post', NULL),
		(@last_inserted_id, 'P', 2, '{"size":"600x600"}', NULL, 'ending_picture.jpg');
	# Бэкенд получает массив тэгов, с которым ассоциирован пост и передаёт их в хранимую процедуру по одному
	SET @tag_id = (SELECT `add_tag` ('helpdesk'));
	INSERT INTO `tagsets` (`tag_id`,`post_id`,`assembly_number`) VALUES (@tag_id, @last_inserted_id, 1);
    
	SET @tag_id = (SELECT `add_tag` ('support'));
	INSERT INTO `tagsets` (`tag_id`,`post_id`,`assembly_number`) VALUES (@tag_id, @last_inserted_id, 2);
    
	SET @tag_id = (SELECT `add_tag` ('supptech'));
	INSERT INTO `tagsets` (`tag_id`,`post_id`,`assembly_number`) VALUES (@tag_id, @last_inserted_id, 3);    
COMMIT;
START TRANSACTION;
	SET @author_id = (SELECT `uid` FROM `users` WHERE `username` = 'willparry');
    SET @community_id = (SELECT `cid` FROM `communities` WHERE `community_name` = 'Support Tech');
	INSERT INTO `posts` (`header`,`author_id`, `assembly_code`, `community_id`) VALUES 
		('How not to get banned', @author_id, 'TPV', @community_id);
	SET @last_inserted_id = LAST_INSERT_ID();
	INSERT INTO `content` (`post_id`, `content_type`, `assembly_number`, `metadata`, `body`, `filename`,`filelink`) VALUES 
		(@last_inserted_id, 'T', 1, '{}', 'Blah-bla-blah', NULL, NULL),
		(@last_inserted_id, 'P', 1, '{"size":"600x600"}', NULL, 'opening_picture.jpg', NULL),
		(@last_inserted_id, 'V', 1, '{}', NULL, NULL, 'youtube.com/......');
	SET @tag_id = (SELECT `add_tag` ('helpdesk'));
	INSERT INTO `tagsets` (`tag_id`,`post_id`,`assembly_number`) VALUES (@tag_id, @last_inserted_id, 1);
    
	SET @tag_id = (SELECT `add_tag` ('support'));
	INSERT INTO `tagsets` (`tag_id`,`post_id`,`assembly_number`) VALUES (@tag_id, @last_inserted_id, 2);
    
	SET @tag_id = (SELECT `add_tag` ('supptech'));
	INSERT INTO `tagsets` (`tag_id`,`post_id`,`assembly_number`) VALUES (@tag_id, @last_inserted_id, 3);
    
    SET @tag_id = (SELECT `add_tag` ('youtube'));
	INSERT INTO `tagsets` (`tag_id`,`post_id`,`assembly_number`) VALUES (@tag_id, @last_inserted_id, 4);
    
    SET @tag_id = (SELECT `add_tag` ('banhammer'));
	INSERT INTO `tagsets` (`tag_id`,`post_id`,`assembly_number`) VALUES (@tag_id, @last_inserted_id, 5);
COMMIT;
# Создаём пост без указания сообщества
START TRANSACTION;
	SET @author_id = (SELECT `uid` FROM `users` WHERE `username` = 'zireael');
    SET @community_id = NULL;
	INSERT INTO `posts` (`header`,`author_id`, `assembly_code`) VALUES 
		('Live as Witcher', @author_id, 'TP');
	SET @last_inserted_id = LAST_INSERT_ID();
	INSERT INTO `content` (`post_id`, `content_type`, `assembly_number`, `metadata`, `body`, `filename`,`filelink`) VALUES 
		(@last_inserted_id, 'T', 1, '{}', 'If u want to live like ...', NULL, NULL),
		(@last_inserted_id, 'P', 1, '{"size":"1600x1600"}', NULL, 'sword.jpg', NULL);
	SET @tag_id = (SELECT `add_tag` ('thewitcher'));
	INSERT INTO `tagsets` (`tag_id`,`post_id`,`assembly_number`) VALUES (@tag_id, @last_inserted_id, 1);
    
	SET @tag_id = (SELECT `add_tag` ('guide'));
	INSERT INTO `tagsets` (`tag_id`,`post_id`,`assembly_number`) VALUES (@tag_id, @last_inserted_id, 2);
    
	SET @tag_id = (SELECT `add_tag` ('fanart'));
	INSERT INTO `tagsets` (`tag_id`,`post_id`,`assembly_number`) VALUES (@tag_id, @last_inserted_id, 3);
COMMIT;
# Потом решаем внести его в сообщество
UPDATE `posts` SET `community_id` = 10 WHERE `pid` = 3;
# А потом переносим в другое
UPDATE `posts` SET `community_id` = 9 WHERE `pid` = 3;
# А потом вообще выносим из сообщества
UPDATE `posts` SET `community_id` = NULL WHERE `pid` = 3;

START TRANSACTION;
	SET @author_id = (SELECT `uid` FROM `users` WHERE `username` = 'billsmith');
    SET @community_id = NULL;
	INSERT INTO `posts` (`header`,`author_id`, `assembly_code`) VALUES 
		('Stories about WW2', @author_id, 'TPTPTP');
	SET @last_inserted_id = LAST_INSERT_ID();
	INSERT INTO `content` (`post_id`, `content_type`, `assembly_number`, `metadata`, `body`, `filename`) VALUES 
		(@last_inserted_id, 'T', 1, '{}', 'Blah-bla-blah', NULL),
		(@last_inserted_id, 'P', 1, '{"size":"600x600"}', NULL, 'soldier1.jpg'),
		(@last_inserted_id, 'T', 2, '{}', 'Blah-bla-blah', NULL),
		(@last_inserted_id, 'P', 2, '{"size":"600x600"}', NULL, 'soldier2.jpg'),
        (@last_inserted_id, 'T', 3, '{}', 'Blah-bla-blah', NULL),
		(@last_inserted_id, 'P', 3, '{"size":"600x600"}', NULL, 'soldier3.jpg');
	SET @tag_id = (SELECT `add_tag` ('ww2'));
	INSERT INTO `tagsets` (`tag_id`,`post_id`,`assembly_number`) VALUES (@tag_id, @last_inserted_id, 1);
    
	SET @tag_id = (SELECT `add_tag` ('soldiers'));
	INSERT INTO `tagsets` (`tag_id`,`post_id`,`assembly_number`) VALUES (@tag_id, @last_inserted_id, 2);
    
	SET @tag_id = (SELECT `add_tag` ('war'));
	INSERT INTO `tagsets` (`tag_id`,`post_id`,`assembly_number`) VALUES (@tag_id, @last_inserted_id, 3);
    
    SET @tag_id = (SELECT `add_tag` ('history'));
	INSERT INTO `tagsets` (`tag_id`,`post_id`,`assembly_number`) VALUES (@tag_id, @last_inserted_id, 4);
COMMIT;
START TRANSACTION;
	SET @author_id = (SELECT `uid` FROM `users` WHERE `username` = 'johnsnow');
    SET @community_id = (SELECT `cid` FROM `communities` WHERE `community_name` = 'The Game of Thrones');
	INSERT INTO `posts` (`header`,`author_id`, `assembly_code`, `community_id`) VALUES 
		('Daenerys', @author_id, 'P', @community_id);
	SET @last_inserted_id = LAST_INSERT_ID();
	INSERT INTO `content` (`post_id`, `content_type`, `assembly_number`, `metadata`, `body`, `filename`,`filelink`) VALUES 
		(@last_inserted_id, 'P', 1, '{"size":"600x600"}', NULL, 'Daenerys_and_John.jpg', NULL);
	SET @tag_id = (SELECT `add_tag` ('GOT'));
	INSERT INTO `tagsets` (`tag_id`,`post_id`,`assembly_number`) VALUES (@tag_id, @last_inserted_id, 1);
    
	SET @tag_id = (SELECT `add_tag` ('fanart'));
	INSERT INTO `tagsets` (`tag_id`,`post_id`,`assembly_number`) VALUES (@tag_id, @last_inserted_id, 2);
    
	SET @tag_id = (SELECT `add_tag` ('queen'));
	INSERT INTO `tagsets` (`tag_id`,`post_id`,`assembly_number`) VALUES (@tag_id, @last_inserted_id, 3);
COMMIT;
START TRANSACTION;
	SET @author_id = (SELECT `uid` FROM `users` WHERE `username` = 'johnsnow');
    SET @community_id = (SELECT `cid` FROM `communities` WHERE `community_name` = 'The Game of Thrones');
	INSERT INTO `posts` (`header`,`author_id`, `assembly_code`, `community_id`) VALUES 
		('Littlefinger', @author_id, 'P', @community_id);
	SET @last_inserted_id = LAST_INSERT_ID();
	INSERT INTO `content` (`post_id`, `content_type`, `assembly_number`, `metadata`, `body`, `filename`) VALUES 
		(@last_inserted_id, 'P', 1, '{"size":"1280x720"}', NULL, 'Littlefinger_trying_to_spy.jpg');
	SET @tag_id = (SELECT `add_tag` ('GOT'));
	INSERT INTO `tagsets` (`tag_id`,`post_id`,`assembly_number`) VALUES (@tag_id, @last_inserted_id, 1);
    
	SET @tag_id = (SELECT `add_tag` ('videomoment'));
	INSERT INTO `tagsets` (`tag_id`,`post_id`,`assembly_number`) VALUES (@tag_id, @last_inserted_id, 2);
    
	SET @tag_id = (SELECT `add_tag` ('spy'));
	INSERT INTO `tagsets` (`tag_id`,`post_id`,`assembly_number`) VALUES (@tag_id, @last_inserted_id, 3);
COMMIT;
START TRANSACTION;
	SET @author_id = (SELECT `uid` FROM `users` WHERE `username` = 'johnsnow');
    SET @community_id = (SELECT `cid` FROM `communities` WHERE `community_name` = 'The Game of Thrones');
	INSERT INTO `posts` (`header`,`author_id`, `assembly_code`, `community_id`) VALUES 
		('Map of GOT', @author_id, 'PP', @community_id);
	SET @last_inserted_id = LAST_INSERT_ID();
	INSERT INTO `content` (`post_id`, `content_type`, `assembly_number`, `metadata`, `body`, `filename`) VALUES 
		(@last_inserted_id, 'P', 1, '{"size":"1280x720"}', NULL, 'Westeros.jpg'),
		(@last_inserted_id, 'P', 2, '{"size":"1280x720"}', NULL, 'Essos.jpg');
	SET @tag_id = (SELECT `add_tag` ('GOT'));
	INSERT INTO `tagsets` (`tag_id`,`post_id`,`assembly_number`) VALUES (@tag_id, @last_inserted_id, 1);
    
	SET @tag_id = (SELECT `add_tag` ('map'));
	INSERT INTO `tagsets` (`tag_id`,`post_id`,`assembly_number`) VALUES (@tag_id, @last_inserted_id, 2);
    
	SET @tag_id = (SELECT `add_tag` ('westeros'));
	INSERT INTO `tagsets` (`tag_id`,`post_id`,`assembly_number`) VALUES (@tag_id, @last_inserted_id, 3);
    
    SET @tag_id = (SELECT `add_tag` ('essos'));
	INSERT INTO `tagsets` (`tag_id`,`post_id`,`assembly_number`) VALUES (@tag_id, @last_inserted_id, 4);
COMMIT;
START TRANSACTION;
	SET @author_id = (SELECT `uid` FROM `users` WHERE `username` = 'noname');
    SET @community_id = NULL;
	INSERT INTO `posts` (`header`,`author_id`, `assembly_code`) VALUES 
		('Brainhacking', @author_id, 'TP');
	SET @last_inserted_id = LAST_INSERT_ID();
	INSERT INTO `content` (`post_id`, `content_type`, `assembly_number`, `metadata`, `body`, `filename`,`filelink`) VALUES 
		(@last_inserted_id, 'T', 1, '{}', 'Blah blah blah', NULL, NULL),
        (@last_inserted_id, 'P', 1, '{"size":"1280x720"}', NULL, 'brain.jpg', NULL);
	SET @tag_id = (SELECT `add_tag` ('hacking'));
	INSERT INTO `tagsets` (`tag_id`,`post_id`,`assembly_number`) VALUES (@tag_id, @last_inserted_id, 1);
    
	SET @tag_id = (SELECT `add_tag` ('brain'));
	INSERT INTO `tagsets` (`tag_id`,`post_id`,`assembly_number`) VALUES (@tag_id, @last_inserted_id, 2);
COMMIT;
START TRANSACTION;
	SET @author_id = (SELECT `uid` FROM `users` WHERE `username` = 'noname');
    SET @community_id = NULL;
	INSERT INTO `posts` (`header`,`author_id`, `assembly_code`) VALUES 
		('How to get money easily', @author_id, 'T');
	SET @last_inserted_id = LAST_INSERT_ID();
	INSERT INTO `content` (`post_id`, `content_type`, `assembly_number`, `metadata`, `body`, `filename`,`filelink`) VALUES 
		(@last_inserted_id, 'T', 1, '{}', 'No way, dude -)', NULL, NULL);
	SET @tag_id = (SELECT `add_tag` ('hacking'));
	INSERT INTO `tagsets` (`tag_id`,`post_id`,`assembly_number`) VALUES (@tag_id, @last_inserted_id, 1);
	SET @tag_id = (SELECT `add_tag` ('money'));
	INSERT INTO `tagsets` (`tag_id`,`post_id`,`assembly_number`) VALUES (@tag_id, @last_inserted_id, 2);
COMMIT;
START TRANSACTION;
	SET @author_id = (SELECT `uid` FROM `users` WHERE `username` = 'onizuka');
    SET @community_id = (SELECT `cid` FROM `communities` WHERE `community_name` = 'Overwatch');
	INSERT INTO `posts` (`header`,`author_id`, `assembly_code`, `community_id`) VALUES 
		('How to play with Gendzi', @author_id, 'PTPTV', @community_id);
	SET @last_inserted_id = LAST_INSERT_ID();
	INSERT INTO `content` (`post_id`, `content_type`, `assembly_number`, `metadata`, `body`, `filename`,`filelink`) VALUES 
		(@last_inserted_id, 'P', 1, '{"size":"1280x720"}', NULL, 'gendzi.jpg', NULL),
        (@last_inserted_id, 'T', 1, '{}', 'text text text', NULL, NULL),
        (@last_inserted_id, 'P', 2, '{"size":"1280x720"}', NULL, 'hanzo.jpg', NULL),
        (@last_inserted_id, 'T', 2, '{}', 'text text text', NULL, NULL),
        (@last_inserted_id, 'V', 1, '{}', NULL, NULL, 'youtube.com/6489');
	SET @tag_id = (SELECT `add_tag` ('overwatch'));
	INSERT INTO `tagsets` (`tag_id`,`post_id`,`assembly_number`) VALUES (@tag_id, @last_inserted_id, 1);
    
	SET @tag_id = (SELECT `add_tag` ('gaming'));
	INSERT INTO `tagsets` (`tag_id`,`post_id`,`assembly_number`) VALUES (@tag_id, @last_inserted_id, 2);
    
	SET @tag_id = (SELECT `add_tag` ('gendzi'));
	INSERT INTO `tagsets` (`tag_id`,`post_id`,`assembly_number`) VALUES (@tag_id, @last_inserted_id, 3);
    
    SET @tag_id = (SELECT `add_tag` ('cybersport'));
	INSERT INTO `tagsets` (`tag_id`,`post_id`,`assembly_number`) VALUES (@tag_id, @last_inserted_id, 4);
    
    SET @tag_id = (SELECT `add_tag` ('youtube'));
	INSERT INTO `tagsets` (`tag_id`,`post_id`,`assembly_number`) VALUES (@tag_id, @last_inserted_id, 5);
COMMIT;


# ASSESSMENTS / COMMENTS / SAVES


#SELECT * FROM posts;
#SELECT * FROM community_profiles;
#SELECT * FROM content;
#SELECT * FROM tags;
#SELECT * FROM tagsets;



#INSERT INTO `comments` (`post_id`,`user_id`) VALUES (1, 2), (2, 3), (3, 1);
#INSERT INTO `assessments` (`user_id`,`post_id`,`assessment_type`) VALUES (1, 1, '+'),(2, 1, '+'),(3, 1, '-'),(4, 1, '-'),(5, 1, '+'),(6, 1, '+'),(7, 1, '+');
#INSERT INTO `assessments` (`user_id`,`comment_id`,`assessment_type`) VALUES (5, 1, '+'),(6, 1, '+'),(5, 1, '+'),(5, 1, '+'),(5, 1, '+');