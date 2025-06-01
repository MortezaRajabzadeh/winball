package utils

import (
	"encoding/json"
	"net/http"

	"github.com/khodehamid/winball_go_back/logger"
)

// AppError ساختار خطای برنامه
type AppError struct {
	Code        int
	UserMessage string
	DevMessage  string
	Err         error
}

// HandleAPIError مدیریت خطاهای API
func HandleAPIError(w http.ResponseWriter, module string, appErr AppError) {
	// ثبت خطا در لاگ
	logger.Error(module, appErr.DevMessage, appErr.Err)
	
	// پاسخ به کاربر
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(appErr.Code)
	
	response := map[string]string{
		"error": appErr.UserMessage,
	}
	
	json.NewEncoder(w).Encode(response)
}

// WithError تبدیل یک خطای ساده به AppError
func WithError(err error, code int, userMessage, devMessage string) AppError {
	return AppError{
		Code:        code,
		UserMessage: userMessage,
		DevMessage:  devMessage,
		Err:         err,
	}
}

// ارائه خطاهای متداول برای سهولت استفاده

// NotFoundError خطای عدم وجود منبع
func NotFoundError(devMessage string, err error) AppError {
	return AppError{
		Code:        http.StatusNotFound,
		UserMessage: "منبع درخواستی یافت نشد",
		DevMessage:  devMessage,
		Err:         err,
	}
}

// BadRequestError خطای درخواست نامعتبر
func BadRequestError(devMessage string, err error) AppError {
	return AppError{
		Code:        http.StatusBadRequest,
		UserMessage: "درخواست نامعتبر است",
		DevMessage:  devMessage,
		Err:         err,
	}
}

// ServerError خطای سرور
func ServerError(devMessage string, err error) AppError {
	return AppError{
		Code:        http.StatusInternalServerError,
		UserMessage: "خطای داخلی سرور رخ داده است",
		DevMessage:  devMessage,
		Err:         err,
	}
}

// UnauthorizedError خطای عدم احراز هویت
func UnauthorizedError(devMessage string, err error) AppError {
	return AppError{
		Code:        http.StatusUnauthorized,
		UserMessage: "دسترسی شما تأیید نشد",
		DevMessage:  devMessage,
		Err:         err,
	}
}

// ForbiddenError خطای عدم دسترسی
func ForbiddenError(devMessage string, err error) AppError {
	return AppError{
		Code:        http.StatusForbidden,
		UserMessage: "شما اجازه دسترسی به این منبع را ندارید",
		DevMessage:  devMessage,
		Err:         err,
	}
} 