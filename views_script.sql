-- Курсовой проект курса "Базы данных" от 6 мая 2020г. (Geekbrains Univercity)
# Views-part
-- Самые рейтинговые пользователи
# DROP VIEW IF EXISTS `The Top Five in KARMA`;
CREATE VIEW `The Top Five in KARMA` AS
	SELECT `username`,`karma` FROM `users` JOIN `user_profiles` ON `user_id` = `uid` ORDER BY `karma` DESC LIMIT 5;

-- Количество созданных пользователями постов
# DROP VIEW IF EXISTS `The best contentmakers`;
CREATE VIEW `The best contentmakers` AS
	SELECT COUNT(*) AS `Amount of posts`, `username` FROM `posts` JOIN `users` ON `uid` = `author_id` GROUP BY(`uid`) ORDER BY(`Amount of posts`) DESC;

-- Представление-тест того, что триггер увеличения количества подписчиков работает верно
# DROP VIEW IF EXISTS `test_subscribers`;
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
# DROP VIEW IF EXISTS `test_comm_members`;
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

# Хорошо бы сделать представление для тестирования постов в сообществах
-- Также надо ещё хранимых процедур и функций
-- И можно будет сдавать на проверку

