package database

import (
	"fmt"
	"github.com/riipandi/lisacp/cmd/app/config"
	"github.com/riipandi/lisacp/cmd/app/models"
	"gorm.io/driver/mysql"
	"gorm.io/gorm"
	"log"
)

var (
	err error
	DBConn *gorm.DB
)

func InitializeConnection() {
	dsn :=  fmt.Sprintf("%s:%v@tcp(%s:%v)/%s?charset=utf8mb4&parseTime=True&loc=Local",
		config.DBUser, config.DBPass, config.DBHost, config.DBPort, config.DBName)

	DBConn, err = gorm.Open(mysql.New(mysql.Config{
		DSN: dsn, // data source name
		DefaultStringSize: 255, // default size for string fields
		DisableDatetimePrecision: true, // disable datetime precision, which not supported before MySQL 5.6
		DontSupportRenameIndex: true, // drop & create when rename index, rename index not supported before MySQL 5.7, MariaDB
		DontSupportRenameColumn: true, // `change` when rename column, rename column not supported before MySQL 8, MariaDB
		SkipInitializeWithVersion: false, // auto configure based on currently MySQL version
	}), &gorm.Config{})

	if err != nil {
		log.Fatal(err)
	}

	DBConn.AutoMigrate(&models.User{})
}

func CloseConnection() {
	// return DBConn.Close()
}