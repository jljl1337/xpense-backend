package generator

import (
	"crypto/rand"
)

const charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

func MustNewToken(length int) string {
	src := make([]byte, length)
	if _, err := rand.Read(src); err != nil {
		panic(err)
	}

	for i := range length {
		src[i] = charset[int(src[i])%len(charset)]
	}

	return string(src)
}
