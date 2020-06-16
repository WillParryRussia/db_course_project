-- Самые рейтинговые пользователи
DROP VIEW IF EXISTS `The Top Five in KARMA`;
CREATE VIEW `The Top Five in KARMA` AS
	SELECT `username`,`karma` FROM `users` JOIN `profiles` ON `user_id` = `uid` ORDER BY `karma` DESC LIMIT 5;

-- Количество созданных пользователями постов
DROP VIEW IF EXISTS `The best contentmakers`;
CREATE VIEW `The best contentmakers` AS
	SELECT COUNT(*) AS `Amount of posts`, `username` FROM `posts` JOIN `users` ON `uid` = `author_id` GROUP BY(`uid`) ORDER BY(`Amount of posts`) DESC;

-- Представление-проверка того, что триггер увеличения количества подписчиков работает верно
DROP VIEW IF EXISTS `subscribers_test`;
CREATE VIEW `subscribers_test` AS
	SELECT 
		`user_id` AS 'Идентификатор пользователя',
		`subscribers` AS 'Количество подписчиков #1',
		COUNT(`target_user_id`) AS 'Количество подписчиков #2',
        IF(`subscribers` = COUNT(`target_user_id`), 'SUCCESS', 'ERROR') AS 'CHECK_MESSAGE'
		FROM `profiles`
		RIGHT JOIN `subscribers`
			ON `target_user_id` = `user_id`
		GROUP BY `target_user_id`;
