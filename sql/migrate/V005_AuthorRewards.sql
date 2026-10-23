USE `donations`;

INSERT INTO `points_transactions_types` (`type`)
SELECT 'donation_store_reward'
FROM DUAL
WHERE NOT EXISTS (
  SELECT 1
  FROM `points_transactions_types`
  WHERE `type` = 'donation_store_reward'
);
