package configs


const GameCreatedCommand = "GAME_CREATED"
const GameUpdatedCommand = "GAME_UPDATED"
const StartGameDtails = "START_GAME_DETAILS"

// When User Deposit from his bank account to our casino account.
const DepositMessage = "INTERNAL"

// When Casino send money to user
const WithdrawMessage = "EXTERNAL_IN"

var GameResultPossibilities map[string]float32 = map[string]float32{"redPurple0": 9.75, "green1": 9.75, "red2": 9.75, "green3": 9.75, "red4": 9.75, "greenPurple5": 9.75, "red6": 9.75, "green7": 9.75, "red8": 9.75, "green9": 9.75, "red": 1.95, "purple": 4.49, "green": 1.95}
var GameResultColorsPossibilities []string = []string{"red", "green", "purple"}

// v5r1
// test money wallet
// const TestWalletAddress string = "adjust host leaf tube merge permit save body drastic keen helmet sort corn fetch tomorrow ready cloth whale stand shed divorce knee electric tooth"
// const CasinoWallet = "copper myth lemon border oyster fold crazy wood invite wool excuse cluster twin session top poverty system all debris fresh easily good summer saddle"
// const CoinWalletPrivateKey = "0ec86e80B8d613AD145c5629c784299f8378c65c7540A0dAEe26A2FaeF7C257C"
// const CoinWalletPublicKey = "a17296c7f4e134fba04dbcca798fa154207c786c324ef08d2471d4fcb8cc9160"

const CasinoWallet = "keen shift picnic jazz nation vendor forget figure glue much cable couch damage fossil believe north angle canvas shift occur day scan amazing upper"
const TonBaseFactor = 1000000000
const CoinValuesUrl = "https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest"
const CoinMarketCapApi = "5a29f1b6-8929-41a6-850b-0c00b33e1416"
const TonToStarsCount = 1000
const WITHDRAWABLE_LESS_THAN = 0.01
const WIN_RATE = 40
const COLOR_WIN_RATE = 30

const FORCE_WIN  = false
const FORCE_LOSE = false

// 👇 حداقل مبلغی که شرط‌بندی‌های سنگین حساب میشه  
const HEAVY_BET_AMOUNT = 10.0 // مثلا هر کی بالای ۵۰۰ شرط ببنده، ریسک باختش بیشتره

// 🗓️ تنظیمات دوره زمانی اقتصاد
const ECONOMY_PERIOD_DAYS = 7 // چند روز گذشته را برای محاسبه اقتصاد در نظر بگیریم (1=روزانه، 7=هفتگی، 30=ماهانه)

// تنظیمات لاگینگ - برای جلوگیری از تکرار، به فایل logger_config.go مراجعه کنید
const LOG_LEVEL = "info"
const TELEGRAM_BOT_TOKEN = ""
const TELEGRAM_CHAT_ID = ""
