-- Самые рейтинговые пользователи
SELECT `username`,`karma` FROM `users` JOIN `profiles` ON `user_id` = `uid` ORDER BY `karma` DESC;

-- Количество созданных пользователями постов
SELECT COUNT(*) AS `Amount of posts`, `username` FROM `posts` JOIN `users` ON `uid` = `author_id` GROUP BY(`uid`) ORDER BY(`Amount of posts`) DESC;

-- 