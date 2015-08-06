CREATE TABLE user (
    `user_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `name` VARBINARY(32) NOT NULL,
    `created` TIMESTAMP NOT NULL,
    PRIMARY KEY (user_id),
    UNIQUE KEY (name),
    KEY (created)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE entry (
    `entry_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `url` VARBINARY(512) NOT NULL,
    `title` VARCHAR(512) NOT NULL,
    `created` TIMESTAMP NOT NULL,
    `updated` TIMESTAMP NOT NULL,
    PRIMARY KEY (entry_id),
    UNIQUE KEY (url(191))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE bookmark (
    `bookmark_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `user_id` BIGINT UNSIGNED NOT NULL,
    `entry_id` BIGINT UNSIGNED NOT NULL,
    `comment` VARCHAR(256) NOT NULL,
    `created` TIMESTAMP NOT NULL,
    `updated` TIMESTAMP NOT NULL,
    PRIMARY KEY (bookmark_id),
    UNIQUE KEY (user_id, entry_id),
    KEY (user_id, created)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
