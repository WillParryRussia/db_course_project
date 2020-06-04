-- Курсовой проект курса "Базы данных" от 6 мая 2020г. (Geekbrains Univercity)
# Trigger-part
USE `course_project`;
DELIMITER |
-- Добавляем профиль пользователя после создания пользователя
CREATE TRIGGER `add_profile_to_user` 
	AFTER INSERT ON `users` 
	FOR EACH ROW 
	BEGIN
		INSERT INTO `profiles` (`user_id`) VALUES (NEW.uid);
	END;

#-- Триггер, который запретит вставку в таблицу profiles
#CREATE TRIGGER `no_humaninsert_to_profiles_allowed`
#	BEFORE INSERT ON `profiles`
#	FOR EACH ROW
#	BEGIN
#		SET @user_id = (SELECT `uid` FROM `users` WHERE NEW.`user_id` = `uid`);
#		IF(@user_id IS NOT NULL) THEN
#			INSERT INTO `profiles` ВОТ НА ЭТОМ МЕСТЕ Я ВСПОМНИЛ ЧТО ДЛЯ ЭТОГО ЕСТЬ ОГРАНИЧЕНИЕ ВНЕШНЕГО КЛЮЧА
#	END;

CREATE TRIGGER `change_rating`
	AFTER INSERT ON	`assessments` #AND NEW.`assessment_type` = '+'
	FOR EACH ROW
	BEGIN
		SET @content_author = (SELECT `uid` FROM `users` WHERE IF(NEW.`post_id` IS NOT NULL, ));
    
    
		UPDATE `profiles`
			SET `karma` = 
            IF
            (
				NEW.`assessment_type` = '+',
					IF(NEW.`post_id` IS NOT NULL, `karma` + 1, `karma` + 0.5),
					IF(NEW.`post_id` IS NOT NULL, `karma` - 1, `karma` - 0.5)
			) WHERE `profiles`.`user_id` = NEW.`user_id`; //Неправильно, сначала надо выяснить автора поста/коммента
            а оценках хранится кто поставил, что поставил и какому типу контента
#		UPDATE `posts`
#			SET `rating` =

#		UPDATE `comments`
#			SET `rating` =

#		UPDATE `communities`
#			SET `rating` = 
	END;
/*
1. Пользователь ставить оценку посту:
	а) Рейтинг поста +1 или -1
	б) Рейтинг автора поста +1 или -1
    в) Рейтинг сообщества +1 или -1
2. Пользователь ставит оценку комменту:
	а) Рейтинг коммент +1 или -1
    б) Рейтинг автора коммента +0.5 или -0.5 

Четыре кейса в профайлах
Два кейса в постах
Два кейса в сообществах
Два кейса в комментах
Отработать 10 кейсов инсерта в таблицу оценок

*/
-- Увеличиваем счётчик подписчиков пользователя после подписки на пользователя
CREATE TRIGGER `add_subscribers` 
	AFTER INSERT ON `subscribers` 
	FOR EACH ROW 
	BEGIN 
		UPDATE `profiles`
			SET `subscribers` = `subscribers` + 1 
			WHERE `user_id` = NEW.`target_user_id`;
	END;

-- Уменьшаем счётчик подписчиков пользователя после отписки от пользователя
CREATE TRIGGER `delete_subscribers` BEFORE DELETE ON `subscribers` FOR EACH ROW BEGIN
			UPDATE `profiles`
				SET `subscribers` = `subscribers` - 1 
                WHERE `user_id` = OLD.`target_user_id`;
        END;
-- Увеличиваем счётчик членов сообщества после подписки на сообщество
CREATE TRIGGER `add_community_member` AFTER INSERT ON `communities_users` FOR EACH ROW BEGIN
	UPDATE `communities`
		SET `amount_members` = `amount_members` + 1 
		WHERE `cid` = NEW.`community_id`;
END;
-- Уменьшаем счётчик членов сообщества после отписки от сообщества
CREATE TRIGGER `delete_community_members` AFTER DELETE ON `communities_users` FOR EACH ROW BEGIN
			UPDATE `communities`
				SET `amount_members` = `amount_members` - 1
                WHERE `cid` = OLD.`community_id`;
        END;    
-- Увеличиваем счётчик постов в сообществе после создания поста
-- При этом логическое условие, что увеличиваем только если автор поста указал к какому сообществу относится пост
CREATE TRIGGER `add_community_post` AFTER INSERT ON `posts` FOR EACH ROW BEGIN
			UPDATE `communities`
				SET `amount_posts` = IF(NEW.`community_id` IS NOT NULL, `amount_posts` + 1, `amount_posts`)
                WHERE `cid` = NEW.`community_id`;
		END;
-- Уменьшаем счётчик постов в сообществе после удаления поста
-- При этом надо помнить, что фактически мы не удаляем посты, а ставим флаг is_deleted
CREATE TRIGGER `delete_community_post` AFTER UPDATE ON `posts` FOR EACH ROW BEGIN
			UPDATE `communities`
				SET `amount_posts` = IF(NEW.`is_deleted` = 1, `amount_posts` - 1, `amount_posts`)
                WHERE `cid` = NEW.`community_id`;
        END;
        
| DELIMITER ;