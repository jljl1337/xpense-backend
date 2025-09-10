package service

import (
	"github.com/jljl1337/xpense-backend/internal/crypto"
)

type AuthService struct {
	userService *UserService
}

func NewAuthService(userService *UserService) *AuthService {
	return &AuthService{
		userService: userService,
	}
}

func (a *AuthService) Register(email, password string) error {
	passwordHash, err := crypto.HashPassword(password)
	if err != nil {
		return err
	}

	return a.userService.CreateUser(
		email,
		passwordHash,
	)
}
