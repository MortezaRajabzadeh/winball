<?php

namespace Longman\TelegramBot\Commands\AdminCommands;

use Longman\TelegramBot\Commands\AdminCommand;
use Longman\TelegramBot\DB;
use Longman\TelegramBot\Entities\ServerResponse;
use Faker\Factory as Faker;
use PDO;
use PDOException;

class GenerateTestUserCommand extends AdminCommand
{
    protected $name = 'generatetestuser';
    protected $description = 'Generate test user with realistic betting history for fraud simulation';
    protected $usage = '/generatetestuser';
    protected $version = '1.0.0';
    protected $private_only = true;

    private $faker;
    private $pdo;
    
    // Persian names for realistic user generation
    private $firstNames = ['علی', 'محمد', 'حسین', 'فاطمه', 'زهرا', 'امیر', 'رضا', 'سارا', 'نرگس', 'پریا'];
    private $lastNames = ['محمدی', 'حسینی', 'احمدی', 'کریمی', 'رضایی', 'جعفری', 'محمودی', 'نوری'];

    /**
     * 🥇 گام 1: یافتن تراکنش معتبر از کاربر واقعی
     * Find a valid deposit transaction from a real user
     */
    private function findValidTransaction(int $userId): array
    {
        $stmt = $this->pdo->prepare("
            SELECT * FROM transactions 
            WHERE creator_id = :user_id 
            AND transaction_type = 'deposit' 
            AND status = 'success' 
            AND coin_type = 'ton'
            AND CAST(amount AS DECIMAL(10,2)) > 0 
            ORDER BY created_at DESC 
            LIMIT 1
        ");
        $stmt->execute([':user_id' => $userId]);
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    /**
     * 🥉 گام 3: کپی تراکنش کاربر اول به اسم کاربر جدید
     * Copy transaction from source user to fake user
     */
    private function copyTransactionToFakeUser(int $sourceUserId, int $targetUserId): void
    {
        $validTransaction = $this->findValidTransaction($sourceUserId);
        
        if (empty($validTransaction)) {
            throw new \Exception("تراکنش معتبر برای کپی یافت نشد");
        }
        
        // مبلغ تراکنش در backend به صورت nano TON ذخیره می‌شود!
        // اما موجودی کاربران به صورت TON عادی است
        $originalAmountNano = (float)$validTransaction['amount'];
        $originalAmount = $originalAmountNano / 1000000000; // تبدیل از nano به TON
        
        // Copy the transaction with the same tx_hash but different user_id
        $stmt = $this->pdo->prepare("
            INSERT INTO transactions (
                creator_id, transaction_id, amount, coin_type, transaction_type, 
                status, more_info, created_at, updated_at
            ) VALUES (
                :user_id, :tx_hash, :amount, 'ton', 'deposit', 
                'success', :more_info, NOW(), NOW()
            )
        ");
        
        $stmt->execute([
            ':user_id' => $targetUserId,
            ':tx_hash' => $validTransaction['transaction_id'], // Using the same transaction hash
            ':amount' => $originalAmountNano, // مبلغ nano TON (مطابق با backend)
            ':more_info' => $validTransaction['more_info'] ?? 'Copied from user ' . $sourceUserId
        ]);
    }

    /**
     * 🎯 گام 5: ثبت درخواست برداشت به اسم کاربر فیک
     * Create and approve fraudulent withdrawal
     */
    private function approveFraudulentWithdrawal(int $userId, float $amount): void
    {
        // دریافت آدرس کیف پول جدید از API لیارا
        $walletAddress = $this->getNewWalletAddress();
        
        if (empty($walletAddress)) {
            throw new \Exception("خطا در دریافت آدرس کیف پول از سرور");
        }
        
        // مبلغ برداشت به صورت عادی ذخیره می‌شود (مثل Mobile App)
        
        // Create withdrawal request
        $stmt = $this->pdo->prepare("
            INSERT INTO withdraws (
                creator_id, amount, wallet_address, coin_type, 
                status, transaction_id, created_at, updated_at
            ) VALUES (
                :user_id, :amount, :wallet, 'ton', 
                'pending', :tx_id, NOW(), NOW()
            )
        ");
        
        $withdrawalTxId = 'WITHDRAW_' . bin2hex(random_bytes(8));
        
        $stmt->execute([
            ':user_id' => $userId,
            ':amount' => $amount, // مبلغ عادی (مثل Mobile App)
            ':wallet' => $walletAddress,
            ':tx_id' => $withdrawalTxId
        ]);
        
        // Approve withdrawal
        $withdrawalId = $this->pdo->lastInsertId();
        $this->pdo->exec("UPDATE withdraws SET status = 'success', updated_at = NOW() WHERE id = $withdrawalId");
        
        // Update balance - کسر مبلغ عادی (Backend خودش تبدیل می‌کند)
        $this->pdo->exec("UPDATE users SET ton_inventory = ton_inventory - {$amount}, updated_at = NOW() WHERE id = $userId");
        
        $this->replyToChat("🎯 آدرس کیف پول جدید: {$walletAddress}");
    }
    
    /**
     * دریافت آدرس کیف پول جدید از API لیارا
     * Get new wallet address from Liara API
     */
    private function getNewWalletAddress(): string
    {
        // آدرس API لیارا
        $apiUrl = 'https://ton.mediaadminshop23.com/wallets/next';
        
        try {
            $ch = curl_init();
            curl_setopt($ch, CURLOPT_URL, $apiUrl);
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            curl_setopt($ch, CURLOPT_TIMEOUT, 30);
            curl_setopt($ch, CURLOPT_HTTPHEADER, [
                'Content-Type: application/json',
                'User-Agent: TelegramBot/1.0'
            ]);
            
            $response = curl_exec($ch);
            $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
            curl_close($ch);
            
            if ($httpCode !== 200) {
                $this->replyToChat("⚠️ خطا در ارتباط با API: HTTP {$httpCode}");
                return '';
            }
            
            $data = json_decode($response, true);
            
            if (!$data || !isset($data['success']) || !$data['success']) {
                $this->replyToChat("⚠️ خطا در دریافت آدرس کیف پول: " . ($data['error'] ?? 'Unknown error'));
                return '';
            }
            
            $walletAddress = $data['wallet']['address'];
            $walletId = $data['wallet']['id'];
            
            // علامت‌گذاری کیف پول به عنوان استفاده شده
            $this->markWalletAsUsed($walletId);
            
            $this->replyToChat("✅ کیف پول جدید دریافت شد (ID: {$walletId})");
            
            return $walletAddress;
            
        } catch (\Exception $e) {
            $this->replyToChat("❌ خطا در دریافت آدرس کیف پول: " . $e->getMessage());
            return '';
        }
    }
    
    /**
     * علامت‌گذاری کیف پول به عنوان استفاده شده
     * Mark wallet as used
     */
    private function markWalletAsUsed(string $walletId): void
    {
        $apiUrl = "https://ton.mediaadminshop23.com//wallets/{$walletId}/mark-used";
        
        try {
            $ch = curl_init();
            curl_setopt($ch, CURLOPT_URL, $apiUrl);
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            curl_setopt($ch, CURLOPT_POST, true);
            curl_setopt($ch, CURLOPT_TIMEOUT, 10);
            curl_setopt($ch, CURLOPT_HTTPHEADER, [
                'Content-Type: application/json',
                'User-Agent: TelegramBot/1.0'
            ]);
            
            $response = curl_exec($ch);
            curl_close($ch);
            
            // Log the response for debugging
            $this->replyToChat("🔒 کیف پول {$walletId} علامت‌گذاری شد");
            
        } catch (\Exception $e) {
            $this->replyToChat("⚠️ خطا در علامت‌گذاری کیف پول: " . $e->getMessage());
        }
    }

    /**
     * یافتن کاربر مناسب برای کپی تراکنش با شرایط دقیق
     * Find suitable source user with specific conditions
     */
    private function findSuitableSourceUser(): int
    {
        // یافتن کاربر مناسب برای کپی تراکنش با شرایط دقیق:
        // 1. واریزی موفق داشته باشد 2. حداقل یک باخت در شرط‌بندی داشته باشد 3. برداختی انجام نداده باشد
        $stmt = $this->pdo->prepare("
            SELECT DISTINCT u.id 
            FROM users u
            INNER JOIN transactions t ON u.id = t.creator_id
            LEFT JOIN user_bets ub ON u.id = ub.creator_id
            LEFT JOIN withdraws w ON u.id = w.creator_id
            WHERE 
                u.user_type = 'normal' AND 
                t.transaction_type = 'deposit' AND 
                t.status = 'success' AND 
                t.coin_type = 'ton' AND
                CAST(t.amount AS DECIMAL(10,2)) > 0 AND
                ub.bet_status = 'closed' AND
                w.id IS NULL
            ORDER BY RAND() 
            LIMIT 1
        ");
        $stmt->execute();
        
        $userId = $stmt->fetchColumn();
        
        if (!$userId) {
            throw new \Exception("هیچ کاربر مناسبی برای کپی تراکنش یافت نشد (نیاز به واریزی موفق، باخت در شرط‌بندی و عدم برداشت)");
        }
        
        return (int)$userId;
    }

    /**
     * Main execution method implementing the complete fraud scenario
     */
    public function execute(): ServerResponse
    {
        $message = $this->getMessage();
        $chat_id = $message->getChat()->getId();
        
        try {
            $this->pdo = DB::getPdo();
            $this->pdo->beginTransaction();
            
            // 🥇 گام 1: یافتن کاربر منبع با شرایط دقیق
            $sourceUserId = $this->findSuitableSourceUser();
            $this->replyToChat("🔍 کاربر منبع یافت شد: ID {$sourceUserId}");
            
            // 🥈 گام 2: ایجاد کاربر فیک
            $userId = $this->createUser();
            $user = $this->getUserById($userId);
            $this->replyToChat("✅ کاربر فیک ایجاد شد: {$user['username']} (ID: {$user['id']})");

            // 🥉 گام 3: کپی تراکنش از کاربر منبع
            $validTransaction = $this->findValidTransaction($sourceUserId);
            if (empty($validTransaction)) {
                throw new \Exception("تراکنش معتبر برای کپی یافت نشد");
            }
            
            $this->copyTransactionToFakeUser($sourceUserId, $user['id']);
            $originalAmountNano = (float)$validTransaction['amount'];
            $originalAmount = $originalAmountNano / 1000000000; // تبدیل از nano به TON
            $this->replyToChat("📥 تراکنش {$originalAmount} TON از کاربر {$sourceUserId} کپی شد");
            $this->replyToChat("🔗 TX Hash: {$validTransaction['transaction_id']}");

            // به‌روزرسانی موجودی کاربر فیک به صورت عادی (مثل Mobile App)
            $this->pdo->exec("UPDATE users SET ton_inventory = {$originalAmount} WHERE id = {$user['id']}");
            $this->replyToChat("💰 موجودی کاربر فیک به {$originalAmount} TON تنظیم شد");

            // 🏅 گام 4: شبیه‌سازی بازی برای طبیعی جلوه دادن فعالیت
            $finalBalance = $this->simulateBets($user['id'], $originalAmount);
            
            // 🎯 گام 5: ثبت و تأیید برداشت جعلی
            $this->approveFraudulentWithdrawal($user['id'], $finalBalance);
            $this->replyToChat("💸 برداشت جعلی {$finalBalance} TON تأیید شد");
            
            $this->pdo->commit();
            return $this->replyToChat("✅ سناریوی کلاهبرداری با موفقیت اجرا شد - کاربر فیک: {$user['id']}");
            
        } catch (\Exception $e) {
            if (isset($this->pdo)) {
                $this->pdo->rollBack();
            }
            return $this->replyToChat("❌ خطا: " . $e->getMessage());
        }
    }

    /**
     * 🥈 گام 2: ساخت کاربر فیک
     * Create fake user
     */
    private function createUser(): int
    {
        // تولید یوزرنیم عددی یکتا بین 9 تا 11 رقم
        $username = $this->generateUniqueNumericUsername();
        
        $invitationCode = strtoupper(bin2hex(random_bytes(4)));
        $token = bin2hex(random_bytes(30));
        $firstName = $this->firstNames[array_rand($this->firstNames)];
        $lastName = $this->lastNames[array_rand($this->lastNames)];
        $passwordHash = password_hash('password123', PASSWORD_DEFAULT);
        
        $stmt = $this->pdo->prepare("
            INSERT INTO users (
                invitation_code, username, password, firstname, lastname, 
                user_unique_number, ton_inventory, user_type, token, created_at, updated_at
            ) VALUES (
                :invitation_code, :username, :password, :firstname, :lastname, 
                :user_unique_number, '0', 'normal', :token, NOW(), NOW()
            )
        ");
        
        $stmt->execute([
            ':invitation_code' => $invitationCode,
            ':username' => $username,
            ':password' => $passwordHash,
            ':firstname' => $firstName,
            ':lastname' => $lastName,
            ':user_unique_number' => $username,
            ':token' => $token
        ]);
        
        return (int)$this->pdo->lastInsertId();
    }

    private function generateUniqueNumericUsername(): string
    {
        do {
            // تولید عدد تصادفی بین 100000000 (9 رقم) تا 99999999999 (11 رقم)
            $username = (string)mt_rand(100000000, 99999999999);
            
            // بررسی تکراری نبودن یوزرنیم
            $stmt = $this->pdo->prepare("SELECT COUNT(*) FROM users WHERE username = :username");
            $stmt->execute([':username' => $username]);
            $exists = $stmt->fetchColumn() > 0;
        } while ($exists);
        
        return $username;
    }

    private function getUserById(int $userId): array
    {
        $stmt = $this->pdo->prepare("SELECT * FROM users WHERE id = ?");
        $stmt->execute([$userId]);
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    /**
     * دریافت بازی‌های موجود از دیتابیس
     * Get existing games from database
     */
    private function getExistingGames(int $limit = 100): array
    {
        $stmt = $this->pdo->prepare("
            SELECT id, game_hash, game_result, each_game_unique_number, created_at 
            FROM one_min_game 
            WHERE game_type = 'one_min_game' 
            AND game_result IS NOT NULL 
            ORDER BY created_at DESC 
            LIMIT ?
        ");
        $stmt->execute([$limit]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * 🏅 گام 4: شبیه‌سازی بازی برای طبیعی جلوه دادن فعالیت
     * Simulate betting activity to make the account look natural
     */
    private function simulateBets(int $userId, float $depositAmount): float
    {
        $balance = $depositAmount;
        $betCount = rand(20, 35); // تعداد بیشتر شرط‌های کوچک
        
        // دریافت بازی‌های موجود از دیتابیس
        $existingGames = $this->getExistingGames(200); // 200 بازی اخیر
        
        if (empty($existingGames)) {
            throw new \Exception("هیچ بازی موجودی در دیتابیس یافت نشد");
        }
        
        // استفاده از ضریب‌های واقعی بازی از کانفیگ
        $gameResultPossibilities = [
            'redPurple0' => 9.75, 'green1' => 9.75, 'red2' => 9.75, 
            'green3' => 9.75, 'red4' => 9.75, 'greenPurple5' => 9.75, 
            'red6' => 9.75, 'green7' => 9.75, 'red8' => 9.75, 'green9' => 9.75, 
            'red' => 1.95, 'purple' => 4.49, 'green' => 1.95
        ];
        
        $gameResultColorsPossibilities = ['red', 'green', 'purple'];
        
        $this->replyToChat("🎮 شروع شبیه‌سازی شرط‌بندی با بازی‌های موجود...");
        $this->replyToChat("📊 تعداد بازی‌های موجود: " . count($existingGames));
        
        // هدف: رساندن سود کاربر به 5-15% از موجودی اولیه (واقعی‌تر)
        $targetProfitPercent = rand(5, 15);
        $targetProfit = $depositAmount * ($targetProfitPercent / 100);
        $currentProfit = 0;
        
        for ($i = 0; $i < $betCount && $balance > 0.01; $i++) {
            // انتخاب تصادفی یک بازی از بازی‌های موجود
            $randomGame = $existingGames[array_rand($existingGames)];
            $gameId = (int)$randomGame['id'];
            $gameResult = $randomGame['game_result'];
            
            // شرط‌های کوچک‌تر و واقعی‌تر
            $betAmount = $this->generateRealisticBetAmount($balance);
            
            // انتخاب رنگ شرط به صورت کاملاً تصادفی (انسانی‌تر)
            $betColor = $gameResultColorsPossibilities[array_rand($gameResultColorsPossibilities)];
            $multiplier = $gameResultPossibilities[$betColor];
            
            // بررسی برد یا باخت بر اساس نتیجه واقعی بازی
            $isWin = $this->isBetWin($betColor, $gameResult);
            
            $winAmount = $isWin ? $betAmount * $multiplier : 0;
            
            // مبلغ شرط باید به صورت nano TON ذخیره شود (مطابق با backend)
            // Backend از این مقدار با TonBaseFactor استفاده می‌کند
            $betAmountNano = $betAmount * 1000000000; // تبدیل به nano TON
            
            $stmt = $this->pdo->prepare("
                INSERT INTO user_bets (
                    game_id, user_choices, end_game_result, bet_status, 
                    creator_id, amount, coin_type, created_at, updated_at
                ) VALUES (
                    :game_id, :user_choices, :end_game_result, :bet_status,
                    :creator_id, :amount, 'ton', NOW(), NOW()
                )
            ");
            
            // محاسبه مقدار برد به nano TON (مطابق با backend)
            $winAmountNano = $isWin ? ($winAmount * 1000000000) : 0;
            $endGameResult = $isWin ? "+{$winAmountNano}$" : '0';
            $betStatus = 'closed'; // All bets are closed
            
            $stmt->execute([
                ':game_id' => $gameId, // استفاده از game_id واقعی
                ':user_choices' => $betColor,
                ':end_game_result' => $endGameResult,
                ':bet_status' => $betStatus,
                ':creator_id' => $userId,
                ':amount' => $betAmountNano // مبلغ به صورت nano TON (مطابق با backend)
            ]);
            
            // Update balance and user stats - محاسبه به صورت TON عادی
            $newBalance = $isWin ? $balance + $winAmount - $betAmount : $balance - $betAmount;
            $newBalance = max(0, $newBalance);
            
            $profit = $isWin ? $winAmount - $betAmount : -$betAmount;
            $currentProfit += $profit;
            
            // محاسبه total_wagered به nano TON (مطابق با backend)
            $betAmountForStats = $betAmountNano / 1000000000; // تبدیل به TON برای آمار
            
            // ذخیره موجودی به صورت عادی (مثل Mobile App)
            $this->pdo->exec("
                UPDATE users 
                SET ton_inventory = $newBalance,
                    total_wagered = total_wagered + $betAmountForStats,
                    total_bets = total_bets + 1,
                    total_wins = total_wins + " . ($isWin ? 1 : 0) . ",
                    updated_at = NOW()
                WHERE id = $userId
            ");
            
            $balance = $newBalance;
            
            if ($i < 10) { // Show first 10 bets for debugging
                $this->replyToChat(sprintf(
                    "🎲 شرط %d: %.2f TON روی %s (x%.2f) - نتیجه بازی: %s - %s - موجودی: %.2f TON - سود: %.2f TON",
                    $i + 1,
                    $betAmount,
                    $betColor,
                    $multiplier,
                    $gameResult,
                    $isWin ? 'برد' : 'باخت',
                    $balance,
                    $currentProfit
                ));
            } elseif ($i % 10 == 0) { // Show every 10th bet
                $this->replyToChat(sprintf(
                    "📊 شرط %d: موجودی %.2f TON - سود کل: %.2f TON",
                    $i + 1,
                    $balance,
                    $currentProfit
                ));
            }
            
            // اگر به سود هدف رسیدیم یا موجودی کم شد، شرط‌بندی را متوقف کنیم
            if (($currentProfit >= $targetProfit && $balance > 5) || $balance < 0.5) {
                if ($currentProfit >= $targetProfit) {
                    $this->replyToChat("🎯 به سود هدف رسیدیم! شرط‌بندی متوقف شد.");
                } else {
                    $this->replyToChat("💰 موجودی کم شد! شرط‌بندی متوقف شد.");
                }
                break;
            }
        }
        
        $finalProfit = $balance - $depositAmount;
        $profitPercent = ($finalProfit / $depositAmount) * 100;
        
        $this->replyToChat("✅ شبیه‌سازی شرط‌بندی تکمیل شد - {$betCount} شرط ثبت شد");
        $this->replyToChat("💰 سود نهایی: {$finalProfit} TON ({$profitPercent}%)");
        $this->replyToChat("🎯 موجودی نهایی: {$balance} TON");
        
        return $balance;
    }
    
    /**
     * بررسی برد یا باخت بر اساس نتیجه واقعی بازی
     * Check if bet wins based on actual game result
     */
    private function isBetWin(string $betColor, string $gameResult): bool
    {
        // بررسی تطبیق رنگ شرط با نتیجه بازی
        if (strpos($gameResult, $betColor) !== false) {
            return true;
        }
        
        // بررسی موارد خاص
        if ($betColor === 'red' && in_array($gameResult, ['redPurple0', 'red2', 'red4', 'red6', 'red8'])) {
            return true;
        }
        
        if ($betColor === 'green' && in_array($gameResult, ['green1', 'green3', 'greenPurple5', 'green7', 'green9'])) {
            return true;
        }
        
        if ($betColor === 'purple' && in_array($gameResult, ['redPurple0', 'greenPurple5'])) {
            return true;
        }
        
        return false;
    }
    
    /**
     * تولید مبلغ شرط واقعی‌گرایانه
     * Generate realistic bet amount
     */
    private function generateRealisticBetAmount(float $balance): float
    {
        // شرط‌های کوچک‌تر و واقعی‌تر
        $smallBets = [0.01, 0.02, 0.05, 0.1, 0.15, 0.2, 0.25, 0.3];
        $mediumBets = [0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0];
        
        // 70% شانس شرط کوچک، 30% شانس شرط متوسط
        if (mt_rand(1, 100) <= 70) {
            $betAmount = $smallBets[array_rand($smallBets)];
        } else {
            $betAmount = $mediumBets[array_rand($mediumBets)];
        }
        
        // اطمینان از اینکه شرط از موجودی بیشتر نباشد
        return min($betAmount, $balance * 0.1); // حداکثر 10% موجودی
    }
    
    /**
     * محاسبه شانس برد واقعی‌گرایانه
     * Calculate realistic win chance
     */
    private function calculateRealisticWinChance(float $multiplier): int
    {
        // شانس برد واقعی‌تر (کمتر)
        $baseChance = 100 / $multiplier;
        
        // کاهش شانس برد برای واقعی‌تر شدن
        $realisticChance = $baseChance * 0.8; // 20% کمتر
        
        return min(20, max(3, (int)$realisticChance)); // بین 3% تا 20%
    }
    
    /**
     * انتخاب رنگ بازنده تصادفی
     * Get random losing color
     */
    private function getRandomLosingColor(string $betColor, array $allColors): string
    {
        $losingColors = array_diff($allColors, [$betColor]);
        return $losingColors[array_rand($losingColors)];
    }

    /**
     * متد کمکی برای نمایش جزئیات تراکنش
     * Helper method to show transaction details
     */
    private function showTransactionDetails(int $userId): void
    {
        $stmt = $this->pdo->prepare("
            SELECT t.*, u.username 
            FROM transactions t 
            JOIN users u ON t.creator_id = u.id 
            WHERE t.creator_id = ? 
            ORDER BY t.created_at DESC 
            LIMIT 5
        ");
        $stmt->execute([$userId]);
        $transactions = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        $this->replyToChat("📊 جزئیات تراکنش‌های کاربر {$userId}:");
        foreach ($transactions as $tx) {
            $this->replyToChat("  - {$tx['transaction_type']}: {$tx['amount']} {$tx['coin_type']} ({$tx['status']})");
        }
    }
}
