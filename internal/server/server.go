package server

import (
	"database/sql"
	"log/slog"
	"net/http"

	"github.com/jljl1337/xpense-backend/internal/repository"
	"github.com/jljl1337/xpense-backend/internal/server/handler"
	"github.com/jljl1337/xpense-backend/internal/server/middleware"
	"github.com/jljl1337/xpense-backend/internal/service"
)

type Server struct {
	queries    *repository.Queries
	httpServer *http.Server
}

func NewServer(db *sql.DB) *Server {
	queries := repository.New(db)
	mux := http.NewServeMux()

	authService := service.NewAuthService(queries)
	userService := service.NewUserService(queries)

	healthHandler := handler.NewHealthHandler()
	authHandler := handler.NewAuthHandler(authService)
	userHandler := handler.NewUserHandler(userService)

	healthHandler.RegisterRoutes(mux)
	authHandler.RegisterRoutes(mux)
	userHandler.RegisterRoutes(mux)

	middlewareProvider := middleware.NewMiddlewareProvider(authService)

	stack := middleware.CreateStack(
		middlewareProvider.CORS(),
		middlewareProvider.Logging(),
		middlewareProvider.Auth(),
	)

	return &Server{
		queries: queries,
		httpServer: &http.Server{
			Addr:    ":8080",
			Handler: stack(mux),
		},
	}
}

func (s *Server) Start() error {
	slog.Info("Starting server")
	return s.httpServer.ListenAndServe()
}
