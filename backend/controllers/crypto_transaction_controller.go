package controllers

// TODO read this. https://www.coinpayments.net/apidoc-create-transaction
// TODO check this https://www.coinpayments.net/supported-coins-all
// func CreateTransactions() {
// 	config := &coinpayments.Config{PublicKey: configs.CoinWalletPublicKey, PrivateKey: configs.CoinWalletPrivateKey}
// 	client, err := coinpayments.NewClient(config, &http.Client{Timeout: 10 * time.Second})
// 	if err != nil {
// 		fmt.Println(err)
// 	}
// 	transactionResult, err := client.CallCreateTransaction(&coinpayments.TransactionRequest{Amount: "1", Currency1: "TRX", Currency2: "TRX", BuyerEmail: "hamidkhajeh77@gmail.com", Invoice: "temp"})
// 	if err != nil {
// 		fmt.Println(err)
// 	}
// 	fmt.Println(transactionResult.CheckoutURL)
// }
