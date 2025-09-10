package main

import (
	"context"
	"database/sql"
	"fmt"
	"log/slog"

	"github.com/segmentio/ksuid"

	"github.com/jljl1337/xpense-backend/internal/db"
	"github.com/jljl1337/xpense-backend/internal/env"
	"github.com/jljl1337/xpense-backend/internal/log"
	"github.com/jljl1337/xpense-backend/internal/repository"
)

func main() {
	env.LoadEnvFile()

	log.SetCustomLogger()

	slog.Debug(ksuid.New().String())
	slog.Info(ksuid.New().String())
	slog.Warn(ksuid.New().String())
	slog.Error(ksuid.New().String())

	// Migrate the database
	dbInstance, err := db.NewDB()
	if err != nil {
		slog.Error("Failed to connect to database: " + err.Error())
		return
	}

	if err := db.Migrate(dbInstance); err != nil {
		slog.Error("Failed to migrate database: " + err.Error())
	}

	queries := db.NewRepositoryQueries(dbInstance)
	ctx := context.Background()
	queries.CreateUser(ctx, repository.CreateUserParams{
		ID:           ksuid.New().String(),
		Email:        "user@example.com",
		PasswordHash: "hashed_password",
		CreatedAt:    1234567890,
		UpdatedAt:    1234567890,
	})
	queries.CreateUser(ctx, repository.CreateUserParams{
		ID:           ksuid.New().String(),
		Email:        "user@example.com",
		PasswordHash: "hashed_password",
		CreatedAt:    1234567890,
		UpdatedAt:    1234567890,
	})
	user, err := queries.GetUser(ctx, "some_user_id")
	// user, err := queries.GetUser(ctx)
	if err != nil {
		if err == sql.ErrNoRows {
			slog.Info("No user found")
			return
		}
		slog.Error("Failed to get user: " + err.Error())
		return
	}

	slog.Info(fmt.Sprintf("User: %s", user.ID))
	_ = user
}
