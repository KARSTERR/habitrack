// filepath: c:\Users\KARSTERR\Projects\habitrack\backend\cmd\migrate\main.go
package main

import (
	"database/sql"
	"fmt"
	"log"
	"os"

	_ "github.com/lib/pq"
	"github.com/joho/godotenv"
	"gitlab.com/KARSTERRR/habitrack/internal/migration"
)

func main() {
	// Load environment variables
	if err := godotenv.Load("../../.env"); err != nil {
		log.Printf("Warning: Error loading .env file: %v", err)
	}

	// Get database connection parameters from environment variables
	dbHost := os.Getenv("DB_HOST")
	dbPort := os.Getenv("DB_PORT")
	dbUser := os.Getenv("DB_USER")
	dbPassword := os.Getenv("DB_PASSWORD")
	dbName := os.Getenv("DB_NAME")
	
	if dbHost == "" {
		dbHost = "localhost"
	}
	if dbPort == "" {
		dbPort = "5432"
	}
	if dbUser == "" {
		dbUser = "postgres"
	}
	if dbName == "" {
		dbName = "habitrack"
	}
	
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
	err = migration.RunMigrations(db)
	if err != nil {
		log.Fatalf("Error running migrations: %v", err)
	}

	log.Println("Migrations completed successfully")
}
