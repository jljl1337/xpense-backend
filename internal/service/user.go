package service

import (
	"context"
	"time"

	"github.com/jljl1337/xpense-backend/internal/generator"
	"github.com/jljl1337/xpense-backend/internal/repository"
)

type UserService struct {
	queries *repository.Queries
}

func NewUserService(queries *repository.Queries) *UserService {
	return &UserService{
		queries: queries,
	}
}

func (s *UserService) CreateUser(ctx context.Context, email, passwordHash string) error {
	return s.queries.CreateUser(ctx, repository.CreateUserParams{
		ID:           generator.NewKSUID(),
		Email:        email,
		PasswordHash: passwordHash,
		CreatedAt:    time.Now().UnixMilli(),
		UpdatedAt:    time.Now().UnixMilli(),
	})
}
