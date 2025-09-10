package db

import (
	"database/sql"
	"os"
	"path/filepath"

	"github.com/jljl1337/xpense-backend/internal/env"
)

func NewDB() (*sql.DB, error) {
	dbPath := env.MustGetString("DB_PATH", "data/live/db/data.db")
	// Create parent directories if they don't exist

	_ = os.MkdirAll(filepath.Dir(dbPath), 0755)

	return sql.Open("sqlite3", "file:"+dbPath+"?_journal=WAL&_foreign_keys=true")
}
