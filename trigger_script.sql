-- Курсовой проект курса "Базы данных" от 6 мая 2020г. (Geekbrains Univercity)
# Trigger-part
USE `course_project`;
DELIMITER |
-- Добавляем профиль пользователя после создания пользователя
CREATE TRIGGER `insert_profiles` AFTER INSERT ON `users` FOR EACH ROW BEGIN
			INSERT INTO `profiles` (`user_id`) VALUES (NEW.uid);
		END;
-- Увеличиваем счётчик подписчиков пользователя после подписки на пользователя
CREATE TRIGGER `add_subscribers` AFTER INSERT ON `subscribers` FOR EACH ROW BEGIN 
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