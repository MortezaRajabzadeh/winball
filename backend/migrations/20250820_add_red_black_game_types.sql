ALTER TABLE `one_min_game`
MODIFY COLUMN `game_type` ENUM (
  'one_min_game',
  'three_min_game',
  'five_min_game',
  'red_black_30s',
  'red_black_3m',
  'red_black_5m'
) NOT NULL DEFAULT 'one_min_game'; 