-- Курсовой проект курса "Базы данных" от 6 мая 2020г. (Geekbrains Univercity)
# Views-part
-- Самые рейтинговые пользователи
DROP VIEW IF EXISTS `The Top Five in KARMA`;
CREATE VIEW `The Top Five in KARMA` AS
	SELECT `username`,`rating` FROM `users` JOIN `user_profiles` ON `user_id` = `uid` ORDER BY `rating` DESC LIMIT 5;

-- Количество созданных пользователями постов
DROP VIEW IF EXISTS `The best contentmakers`;
CREATE VIEW `The best contentmakers` AS
	SELECT COUNT(*) AS `Amount of posts`, `username` FROM `posts` JOIN `users` ON `uid` = `author_id` GROUP BY(`uid`) ORDER BY(`Amount of posts`) DESC;

-- Представление-тест того, что триггер увеличения количества подписчиков работает верно
DROP VIEW IF EXISTS `test_subscribers`;
CREATE VIEW `test_subscribers` AS
	SELECT 
		`user_id` AS 'Идентификатор пользователя',
		`subscribers` AS 'Количество подписчиков #1',
		COUNT(`target_user_id`) AS 'Количество подписчиков #2',
        IF(`subscribers` = COUNT(`target_user_id`), 'SUCCESS', 'ERROR') AS 'CHECK_MESSAGE'
		FROM `user_profiles`
		RIGHT JOIN `subscribers`
			ON `target_user_id` = `user_id`
		GROUP BY `target_user_id`;

-- Представление-тест того, что триггер увеличения количества членов сообщества работает верно
DROP VIEW IF EXISTS `test_comm_members`;
CREATE VIEW `test_comm_members` AS
	SELECT 
		`cp`.`community_id` AS 'Идентификатор сообщества',
		`amount_members` AS 'Количество членов сообщества #1',
		COUNT(`cu`.`community_id`) AS 'Количество членов сообщества #2',
		IF(`amount_members` = COUNT(`cu`.`community_id`), 'SUCCESS', 'ERROR') AS 'CHECK_MESSAGE'
		FROM `community_profiles` AS `cp`
		RIGHT JOIN `communities_users` AS `cu`
			ON `cp`.`community_id` = `cu`.`community_id`
		GROUP BY `cu`.`community_id`;

-- Выборка-тест того, что триггер увеличения рейтинга поста работает верно
SELECT `pid`,
	(SELECT @incr := (SELECT COUNT(`assessment_type`) FROM `assessments_posts` WHERE `assessment_type` = '+' AND `post_id` = `pid` GROUP BY (`post_id`))) AS 'tmp1',
	(SELECT @decr := (SELECT COUNT(`assessment_type`) FROM `assessments_posts` WHERE `assessment_type` = '-' AND `post_id` = `pid` GROUP BY (`post_id`))) AS 'tmp2',
	(SELECT @incr := IF(@incr IS NULL, 0, @incr)) AS 'Positive',
	(SELECT @decr := IF(@decr IS NULL, 0, @decr)) AS 'Negative',
	(SELECT @summ := @incr - @decr) AS `Math Calculated`,
	`rating` AS `rating from posts`,
	IF(`rating` = @incr - @decr, 'SUCCESS', 'ERROR') AS 'CHECK_MESSAGE'
	FROM `posts`;

-- Выборка-тест того, что триггер увеличения рейтинга коммента работает верно
SELECT `cuid`,
	(SELECT @incr := (SELECT COUNT(`assessment_type`) FROM `assessments_comments` WHERE `assessment_type` = '+' AND `comment_id` = `cuid` GROUP BY (`comment_id`))) AS 'tmp1',
	(SELECT @decr := (SELECT COUNT(`assessment_type`) FROM `assessments_comments` WHERE `assessment_type` = '-' AND `comment_id` = `cuid` GROUP BY (`comment_id`))) AS 'tmp2',
	(SELECT @incr := IF(@incr IS NULL, 0, @incr)) AS 'Positive',
	(SELECT @decr := IF(@decr IS NULL, 0, @decr)) AS 'Negative',
	(SELECT @summ := @incr - @decr) AS `Math Calculated`,
	`rating` AS `rating from posts`,
	IF(`rating` = @incr - @decr, 'SUCCESS', 'ERROR') AS 'CHECK_MESSAGE'
	FROM `comments`;

-- Представление-тест того, что триггеры увеличения рейтинга пользователя работают верно и рейтинг автора изменяется в соответствии с оценками пользователей
DROP VIEW IF EXISTS `test_user_rating`;
CREATE VIEW `test_user_rating` AS
SELECT 
	`author_id` AS `Content Author ID`, 
	SUM(`All posts rating`) AS `All Content Rating`, 
    ANY_VALUE(`Union Table`.`User rating`) AS `user rating`,
    IF(SUM(`All posts rating`) = ANY_VALUE(`User rating`), 'SUCCESS', 'ERROR') AS 'CHECK_MESSAGE'
    FROM
		(SELECT `author_id`, SUM(P.`rating`) AS `All posts rating`, U.`rating` AS `User rating`
			FROM `posts` P
			JOIN `user_profiles` U ON P.`author_id` = U.`user_id`
			GROUP BY (`author_id`)
		UNION
		SELECT C.`user_id`, SUM(C.`rating`) / 2 AS `All comments rating`, U.`rating` AS `User rating`
			FROM `comments` C
			JOIN `user_profiles` U ON C.`user_id` = U.`user_id`
			GROUP BY (C.`user_id`)
		) AS `Union Table`
	GROUP BY (`Content Author ID`);