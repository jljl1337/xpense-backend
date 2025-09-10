package route

import (
	"net/http"

	"github.com/jljl1337/xpense-backend/internal/server/handler"
)

// RegisterHealthRoutes registers health check routes
func RegisterHealthRoutes(mux *http.ServeMux) {
	mux.HandleFunc("GET /health", handler.HealthCheckHandler)
}
