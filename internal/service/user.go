package service

import (
	"context"
	"database/sql"
	"errors"

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

func (s *UserService) UserExistsByEmail(email string) (bool, error) {
	ctx := context.Background()
	_, err := s.queries.GetUserByEmail(ctx, email)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return false, nil
		}
		return false, err
	}
	return true, nil
}
