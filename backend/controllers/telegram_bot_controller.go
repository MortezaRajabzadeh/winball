package controllers

import (
	"fmt"
	"log"

	"github.com/nickname76/telegrambot"
)

func StartTelegramBot() {
	api, me, err := telegrambot.NewAPI("7750565862:AAH5jwXb9L_c2HdNzxHVq5mWqGBYf0M6GfU")
	if err != nil {
		log.Fatalf("Error: %v", err)
	}

	stop := telegrambot.StartReceivingUpdates(api, func(update *telegrambot.Update, err error) {
		if err != nil {
			log.Printf("Error: %v", err)
			return
		}

		msg := update.Message
		if msg == nil {
			return
		}
		if msg.Text == "/pay" {
			var prices []*telegrambot.LabeledPrice = []*telegrambot.LabeledPrice{{Label: "Star Payment", Amount: 200}}
			api.CreateInvoiceLink(&telegrambot.CreateInvoiceLinkParams{Currency: "XTR", Title: "Pay Stars", Description: "Test payment", Prices: prices})
		}
		if msg.Text == "pre_checkout_query" {
			api.AnswerPreCheckoutQuery(&telegrambot.AnswerPreCheckoutQueryParams{})
		}
		_, err = api.SendMessage(&telegrambot.SendMessageParams{
			ChatID: msg.Chat.ID,
			Text:   fmt.Sprintf("Hello %v, I am %v", msg.From.FirstName, me.FirstName),
			ReplyMarkup: &telegrambot.ReplyKeyboardMarkup{
				Keyboard: [][]*telegrambot.KeyboardButton{{
					{
						Text: "Hello",
					},
				}},
				ResizeKeyboard:  true,
				OneTimeKeyboard: true,
			},
		})

		if err != nil {
			log.Printf("Error: %v", err)
			return
		}
	})
	stop()
}
