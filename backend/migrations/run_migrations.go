// filepath: c:\Users\KARSTERR\Projects\habitrack\backend\migrations\run_migrations.go
package main

import (
	"database/sql"
	"fmt"
	"log"
	"os"

	"github.com/joho/godotenv"
	_ "github.com/lib/pq"
)

func main() {
	// Load environment variables
	err := godotenv.Load("../.env")
	if err != nil {
		log.Fatalf("Error loading .env file: %v", err)
	}

	// Get database connection parameters from environment variables
	dbHost := os.Getenv("DB_HOST")
	dbPort := os.Getenv("DB_PORT")
	dbUser := os.Getenv("DB_USER")
	dbPassword := os.Getenv("DB_PASSWORD")
	dbName := os.Getenv("DB_NAME")
	
	// Construct connection string
	connStr := fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=disable",
		dbHost, dbPort, dbUser, dbPassword, dbName)

	// Connect to the database
	db, err := sql.Open("postgres", connStr)
	if err != nil {
		log.Fatalf("Could not connect to database: %v", err)
	}
	defer db.Close()

	// Test the connection
	err = db.Ping()
	if err != nil {
		log.Fatalf("Could not ping database: %v", err)
	}

	log.Println("Successfully connected to database")

	// Run migrations
	err = RunMigrations(db)
	if err != nil {
		log.Fatalf("Error running migrations: %v", err)
	}

	log.Println("Migrations completed successfully")
}

// RunMigrations runs database migrations
func RunMigrations(db *sql.DB) error {
	log.Println("Running migrations...")
	
	// Get migration files
	upFile := "000001_init_schema.up.sql"
	
	// Read migration file content
	content, err := os.ReadFile(upFile)
	if err != nil {
		return fmt.Errorf("could not read migration file: %w", err)
	}
	
	// Execute SQL statements
	_, err = db.Exec(string(content))
	if err != nil {
		return fmt.Errorf("could not execute migration: %w", err)
	}
	
	return nil
}
