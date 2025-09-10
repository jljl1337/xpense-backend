package route

import (
	"net/http"
)

// RegisterRoutes registers all application routes
func RegisterRoutes(mux *http.ServeMux) {
	RegisterHealthRoutes(mux)
}
