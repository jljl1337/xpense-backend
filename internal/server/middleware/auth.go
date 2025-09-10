package middleware

import (
	"context"
	"log/slog"
	"net/http"
)

type contextKey string

const UserIDKey contextKey = "user_id"

func (m *MiddlewareProvider) Auth() Middleware {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			// Skip for public routes
			if r.URL.Path == "/auth/sign-up" || r.URL.Path == "/auth/login" || r.URL.Path == "/health" {
				next.ServeHTTP(w, r)
				return
			}

			// Get session token from cookie
			cookie, err := r.Cookie("session_token")
			if err != nil {
				// err is not nil only if the cookie is not present
				http.Error(w, "Unauthorized", http.StatusUnauthorized)
				return
			}

			// Get CSRF token from header
			CSRFToken := r.Header.Get("X-CSRF-Token")

			if CSRFToken == "" && (r.Method == http.MethodPost || r.Method == http.MethodPut || r.Method == http.MethodDelete) {
				http.Error(w, "CSRF token is required", http.StatusUnauthorized)
				return
			}

			// Validate session token (and CSRF token)
			userID, err := m.authService.GetSessionUserIDAndRefreshSession(cookie.Value, CSRFToken)
			if err != nil {
				slog.Error("Failed to check session: " + err.Error())
				return
			}

			if userID == "" {
				http.Error(w, "Unauthorized", http.StatusUnauthorized)
				return
			}

			// Add user ID to context
			ctx := context.WithValue(r.Context(), UserIDKey, userID)
			next.ServeHTTP(w, r.WithContext(ctx))
		})
	}
}

func GetUserIDFromContext(ctx context.Context) (string, bool) {
	userID, ok := ctx.Value(UserIDKey).(string)
	return userID, ok
}
