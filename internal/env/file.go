package env

import "github.com/joho/godotenv"

func LoadEnvFile() {
	if err := godotenv.Load(); err != nil {
		// It's okay if the .env file doesn't exist, we can proceed with existing env vars
	}
}
