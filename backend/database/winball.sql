CREATE TABLE `announcements` (
  `id` int UNIQUE PRIMARY KEY AUTO_INCREMENT,
  `title` text NOT NULL,
  `details` text NOT NULL,
  `creator_id` int NOT NULL,
  `created_at` datetime DEFAULT (now()),
  `updated_at` datetime DEFAULT (now())
);

CREATE TABLE `activities` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `banner_url` varchar(255) NOT NULL,
  `details` text NOT NULL COMMENT 'must be html format',
  `creator_id` int,
  `created_at` datetime DEFAULT (now()),
  `updated_at` datetime DEFAULT (now())
);

CREATE TABLE `help` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `subsection` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `creator_id` int,
  `created_at` datetime DEFAULT (now()),
  `updated_at` datetime DEFAULT (now())
);

CREATE TABLE `support` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `message_value` text NOT NULL,
  `message_type` ENUM ('normal', 'music', 'video', 'picture') DEFAULT 'normal',
  `creator_id` int,
  `room_id` varchar(255) NOT NULL,
  `created_at` datetime DEFAULT (now()),
  `updated_at` datetime DEFAULT (now())
);

CREATE TABLE `invitations` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `invitor_id` int,
  `invited_id` text NOT NULL,
  `invitation_code` varchar(255) NOT NULL,
  `created_at` datetime DEFAULT (now()),
  `updated_at` datetime DEFAULT (now())
);

CREATE TABLE `users` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `invitation_code` varchar(255) NOT NULL,
  `username` varchar(255),
  `password` varchar(255),
  `firstname` varchar(255),
  `lastname` varchar(255),
  `user_unique_number` varchar(255) NOT NULL,
  `is_demo_account` varchar(255) DEFAULT '0',
  `ton_inventory` varchar(255) DEFAULT '0',
  `stars_inventory` varchar(255) DEFAULT '0',
  `usdt_inventory` varchar(255) DEFAULT '0',
  `btc_inventory` varchar(255) DEFAULT '0',
  `cusd_inventory` varchar(255) DEFAULT '0',
  `user_profile` varchar(255),
  `total_wagered` varchar(255) DEFAULT '0' COMMENT 'shows whole bets amount',
  `total_bets` varchar(255) DEFAULT '0' COMMENT 'count of bets',
  `total_wins` varchar(255) DEFAULT '0' COMMENT 'count of game bets that end_game_result is positive',
  `level_id` int,
  `experience` varchar(255) DEFAULT '0',
  `user_type` ENUM ('normal', 'admin', 'support', 'blocked') DEFAULT 'normal',
  `token` varchar(255),
  `created_at` datetime DEFAULT (now()),
  `updated_at` datetime DEFAULT (now())
);

CREATE TABLE `levels` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `level_tag` varchar(255) NOT NULL,
  `exp_to_upgrade` varchar(255) NOT NULL,
  `created_at` datetime DEFAULT (now()),
  `updated_at` datetime DEFAULT (now())
);

CREATE TABLE `transactions` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `coin_type` ENUM ('ton', 'stars', 'usdt', 'btc', 'cusd') NOT NULL DEFAULT 'ton',
  `transaction_type` ENUM ('deposit', 'withdraw') NOT NULL,
  `amount` varchar(255) NOT NULL,
  `status` ENUM ('pending', 'success', 'faild') DEFAULT 'pending',
  `transaction_id` varchar(255) NOT NULL,
  `more_info` text,
  `creator_id` int,
  `created_at` datetime DEFAULT (now()),
  `updated_at` datetime DEFAULT (now())
);

CREATE TABLE `withdraws` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `amount` varchar(255) NOT NULL,
  `wallet_address` varchar(255) NOT NULL,
  `coin_type` ENUM ('ton', 'stars', 'usdt', 'btc', 'cusd') NOT NULL,
  `status` ENUM ('pending', 'success', 'faild') DEFAULT 'pending',
  `creator_id` int,
  `transaction_id` varchar(255) NOT NULL,
  `created_at` datetime DEFAULT (now()),
  `updated_at` datetime DEFAULT (now())
);

CREATE TABLE `site_settings` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `loading_picture` varchar(255) NOT NULL,
  `referal_percent` int NOT NULL,
  `min_withdraw_amount` varchar(255) NOT NULL,
  `min_deposit_amount` varchar(255) NOT NULL,
  `creator_id` int,
  `created_at` datetime DEFAULT (now()),
  `updated_at` datetime DEFAULT (now())
);

CREATE TABLE `one_min_game` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `game_type` ENUM ('one_min_game', 'three_min_game', 'five_min_game') NOT NULL DEFAULT 'one_min_game',
  `game_hash` varchar(255) NOT NULL,
  `game_result` ENUM ('redPurple0', 'green1', 'red2', 'green3', 'red4', 'greenPurple5', 'red6', 'green7', 'red8', 'green9', 'red', 'purple', 'green'),
  `each_game_unique_number` int NOT NULL,
  `created_at` datetime DEFAULT (now()),
  `updated_at` datetime DEFAULT (now())
);

CREATE TABLE `user_bets` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `game_id` int,
  `user_choices` varchar(255) NOT NULL COMMENT 'list of game result',
  `end_game_result` varchar(255) COMMENT 'save the positive values for users to show profit or lose money like:+2.1$ if user loses the amount will be 0',
  `bet_status` ENUM ('open', 'closed') DEFAULT 'open',
  `creator_id` int,
  `amount` varchar(255) NOT NULL,
  `coin_type` ENUM ('ton', 'stars', 'usdt', 'btc', 'cusd') NOT NULL DEFAULT 'ton',
  `created_at` datetime DEFAULT (now()),
  `updated_at` datetime DEFAULT (now())
);

CREATE TABLE `slider` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `image_path` varchar(255) NOT NULL,
  `button_title` varchar(255),
  `button_link` varchar(255),
  `created_at` datetime DEFAULT (now()),
  `updated_at` datetime DEFAULT (now())
);

ALTER TABLE `announcements` ADD FOREIGN KEY (`creator_id`) REFERENCES `users` (`id`);

ALTER TABLE `activities` ADD FOREIGN KEY (`creator_id`) REFERENCES `users` (`id`);

ALTER TABLE `help` ADD FOREIGN KEY (`creator_id`) REFERENCES `users` (`id`);

ALTER TABLE `support` ADD FOREIGN KEY (`creator_id`) REFERENCES `users` (`id`);

ALTER TABLE `invitations` ADD FOREIGN KEY (`invitor_id`) REFERENCES `users` (`id`);

ALTER TABLE `users` ADD FOREIGN KEY (`level_id`) REFERENCES `levels` (`id`);

ALTER TABLE `transactions` ADD FOREIGN KEY (`creator_id`) REFERENCES `users` (`id`);

ALTER TABLE `withdraws` ADD FOREIGN KEY (`creator_id`) REFERENCES `users` (`id`);

ALTER TABLE `site_settings` ADD FOREIGN KEY (`creator_id`) REFERENCES `users` (`id`);

ALTER TABLE `user_bets` ADD FOREIGN KEY (`game_id`) REFERENCES `one_min_game` (`id`);

ALTER TABLE `user_bets` ADD FOREIGN KEY (`creator_id`) REFERENCES `users` (`id`);
