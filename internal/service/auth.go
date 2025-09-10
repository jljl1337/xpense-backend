package service

import (
	"context"
	"database/sql"
	"errors"
	"time"

	"github.com/jljl1337/xpense-backend/internal/crypto"
	"github.com/jljl1337/xpense-backend/internal/generator"
	"github.com/jljl1337/xpense-backend/internal/repository"
)

type AuthService struct {
	queries *repository.Queries
}

func NewAuthService(queries *repository.Queries) *AuthService {
	return &AuthService{
		queries: queries,
	}
}

func (a *AuthService) SignUp(email, password string) error {
	passwordHash, err := crypto.HashPassword(password)
	if err != nil {
		return err
	}

	ctx := context.Background()
	currentTime := time.Now().UnixMilli()

	return a.queries.CreateUser(ctx, repository.CreateUserParams{
		ID:           generator.NewKSUID(),
		Email:        email,
		PasswordHash: passwordHash,
		CreatedAt:    currentTime,
		UpdatedAt:    currentTime,
	})
}

// Login authenticates a user and creates a new session.
// It returns non-empty session token and CSRF token if the credentials are valid.
//
// If the credentials are invalid, it returns empty strings and no error.
//
// If an error occurs during the process, it returns the error.
func (a *AuthService) Login(email, password string) (string, string, error) {
	ctx := context.Background()

	user, err := a.queries.GetUserByEmail(ctx, email)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return "", "", nil
		}
		return "", "", err
	}

	if !crypto.CheckPasswordHash(password, user.PasswordHash) {
		return "", "", nil
	}

	sessionID := generator.NewKSUID()
	sessionToken := generator.NewToken(16)
	CSRFToken := generator.NewToken(16)
	currentTime := time.Now().UnixMilli()
	expiresAt := time.Now().Add(24 * time.Hour).UnixMilli()

	if _, err := a.queries.CreateSession(ctx, repository.CreateSessionParams{
		ID:        sessionID,
		UserID:    user.ID,
		Token:     sessionToken,
		CsrfToken: CSRFToken,
		ExpiresAt: expiresAt,
		CreatedAt: currentTime,
		UpdatedAt: currentTime,
	}); err != nil {
		return "", "", err
	}

	return sessionToken, CSRFToken, nil
}

// GetSessionUserIDAndRefreshSession validates the session token and CSRF token,
// refreshes the session expiration, and returns the associated user ID.
//
// If the session is invalid or expired, it returns an empty string and no error.
//
// If an error occurs during the process, it returns the error.
func (a *AuthService) GetSessionUserIDAndRefreshSession(sessionToken, CSRFToken string) (string, error) {
	ctx := context.Background()

	session, err := a.queries.GetSessionByToken(ctx, sessionToken)

	// No session with the given token
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return "", nil
		}
	}

	// CSRF token does not match
	if CSRFToken != "" && session.CsrfToken != CSRFToken {
		return "", nil
	}

	// Session expired
	now := time.Now()
	nowMillis := now.UnixMilli()
	if session.ExpiresAt < nowMillis {
		return "", nil
	}

	// Refresh the session expiration
	newExpiresAt := now.Add(24 * time.Hour).UnixMilli()
	if err := a.queries.UpdateSession(ctx, repository.UpdateSessionParams{
		ID:        session.ID,
		ExpiresAt: newExpiresAt,
		UpdatedAt: nowMillis,
	}); err != nil {
		return "", err
	}

	return session.UserID, nil
}
