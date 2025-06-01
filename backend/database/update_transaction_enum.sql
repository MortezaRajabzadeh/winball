-- Update the existing transaction_type enum to include 'referral_bonus'
ALTER TABLE `transactions` MODIFY `transaction_type` ENUM ('deposit', 'withdraw', 'referral_bonus') NOT NULL; 