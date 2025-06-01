package controllers

import (
	"fmt"
	"io/fs"
	"os"
	"time"

	"github.com/khodehamid/winball_go_back/models"
	"github.com/khodehamid/winball_go_back/utils"
)

// this take 4 parameters
// first uint8list of bytes of images.
// second is user that upload this image . and third is file type that can be only image video documents.
// last is fileExtension that can be png , doc , docx and so on.
func UploadFile(fileBytes []byte, user *models.User, fileType, fileExtension string) (string, error) {
	var maxFileSize int
	switch fileType {
	case "image":
		{
			maxFileSize = 5
		}
	case "video":
		{
			maxFileSize = 15
		}
	case "document":
		{
			maxFileSize = 5
		}
	case "music":
		{
			maxFileSize = 10
		}
	default:
		{
			maxFileSize = 5
		}
	}
	var fileTypeDirectory = fmt.Sprintf("%ss/", fileType)
	var storageFile string = "storage/"
	var fileTypeString = fmt.Sprintf("%s%s", storageFile, fileTypeDirectory)
	var userStoragePath string = fmt.Sprintf("%s%d/", fileTypeString, user.Id)
	permission := 0755
	if _, err := os.Stat(storageFile); os.IsNotExist(err) {
		os.Mkdir(storageFile, fs.FileMode(permission))
	}
	if _, err := os.Stat(fileTypeString); os.IsNotExist(err) {
		os.Mkdir(fileTypeString, fs.FileMode(permission))
	}
	if _, err := os.Stat(userStoragePath); os.IsNotExist(err) {
		os.Mkdir(userStoragePath, fs.FileMode(permission))
	}
	var sizeOfByte int = len(fileBytes)
	var howMuchMBIsSize int = sizeOfByte / (1024 * 1024)
	if howMuchMBIsSize > maxFileSize {
		return "", fmt.Errorf("حجم فایل انتخاب شده بسیار بیشتر از %d مگابایت می باشد . لطفا فایل کم حجم تری انتخاب نمایید", maxFileSize)
	} else {
		tempFileName := time.Now().UnixMicro()
		var filePath string = fmt.Sprintf("%s%s_%d.%s", userStoragePath, fileType, tempFileName, fileExtension)
		return utils.FilterImageStringPath(filePath), os.WriteFile(filePath, fileBytes, fs.FileMode(permission))
	}
}
func DeleteFile(filePath string) error {
	return os.Remove(utils.FilterImageStringPath(filePath))
}
