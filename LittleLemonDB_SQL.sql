-- LittleLemonDB

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

CREATE SCHEMA IF NOT EXISTS `little_lemon` DEFAULT CHARACTER SET utf8mb4;
USE `little_lemon`;

-- =========================
-- 1) CUSTOMERS
-- =========================
CREATE TABLE IF NOT EXISTS Customers (
  CustomerID   VARCHAR(20)  NOT NULL,
  CustomerName VARCHAR(500) NOT NULL,
  PRIMARY KEY (CustomerID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================
-- 2) BOOKINGS
-- =========================
CREATE TABLE IF NOT EXISTS Bookings (
  BookingID     INT NOT NULL AUTO_INCREMENT,
  CustomerID    VARCHAR(20) NOT NULL,
  BookingDate   DATE NOT NULL,
  NumberOfGuest INT  NOT NULL,
  PRIMARY KEY (BookingID),
  KEY idx_bookings_customer (CustomerID),
  CONSTRAINT fk_bookings_customer
    FOREIGN KEY (CustomerID)
    REFERENCES Customers(CustomerID)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================
-- 3) DELIVERY
-- =========================
CREATE TABLE IF NOT EXISTS Delivery (
  DeliveryID   INT NOT NULL AUTO_INCREMENT,
  DeliveryDate DATE NULL,
  CountryCode  VARCHAR(10) NOT NULL,
  Country      VARCHAR(45) NOT NULL,
  City         VARCHAR(45) NOT NULL,
  PostalCode   VARCHAR(20) NOT NULL,
  DeliveryCost DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (DeliveryID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================
-- 4) MENU ITEMS 
-- =========================
CREATE TABLE IF NOT EXISTS MenuItems (
  MenuItemsID INT NOT NULL AUTO_INCREMENT,
  StarterName VARCHAR(45) NOT NULL,
  CourseName  VARCHAR(45) NOT NULL,
  DessertName VARCHAR(45) NOT NULL,
  Drink       VARCHAR(45) NOT NULL,
  Sides       VARCHAR(45) NOT NULL,
  PRIMARY KEY (MenuItemsID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================
-- 5) MENUS 
-- =========================
CREATE TABLE IF NOT EXISTS Menus (
  MenuID      INT NOT NULL AUTO_INCREMENT,
  CuisineName VARCHAR(45) NOT NULL,
  PRIMARY KEY (MenuID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================
-- 6) MENU DETAILS 
-- =========================
CREATE TABLE IF NOT EXISTS MenuDetails (
  MenuID      INT NOT NULL,
  MenuItemsID INT NOT NULL,
  PRIMARY KEY (MenuID, MenuItemsID),
  CONSTRAINT fk_menudetails_menu
    FOREIGN KEY (MenuID)
    REFERENCES Menus(MenuID)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  CONSTRAINT fk_menudetails_item
    FOREIGN KEY (MenuItemsID)
    REFERENCES MenuItems(MenuItemsID)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================
-- 7) ORDERS
-- =========================
CREATE TABLE IF NOT EXISTS Orders (
  OrderID    VARCHAR(20) NOT NULL,      
  CustomerID VARCHAR(20) NOT NULL,
  OrderDate  DATE NULL,
  DeliveryID INT  NOT NULL,
  Cost       DECIMAL(10,2) NOT NULL,
  Sales      DECIMAL(10,2) NOT NULL,
  Quantity   INT NOT NULL,
  Discount   DECIMAL(10,2) NOT NULL,
  BookingID  INT ,
  MenuID     INT NOT NULL,
  PRIMARY KEY (OrderID),

  KEY idx_orders_customer (CustomerID),
  KEY idx_orders_delivery (DeliveryID),
  KEY idx_orders_booking  (BookingID),
  KEY idx_orders_menu     (MenuID),

  CONSTRAINT fk_orders_customer
    FOREIGN KEY (CustomerID)
    REFERENCES Customers(CustomerID)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,

  CONSTRAINT fk_orders_delivery
    FOREIGN KEY (DeliveryID)
    REFERENCES Delivery(DeliveryID)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,

  CONSTRAINT fk_orders_booking
    FOREIGN KEY (BookingID)
    REFERENCES Bookings(BookingID)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,

  CONSTRAINT fk_orders_menu
    FOREIGN KEY (MenuID)
    REFERENCES Menus(MenuID)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;


CREATE TABLE IF NOT EXISTS raw_littlelemon (
  RowNumber    VARCHAR(20),
  OrderID      VARCHAR(50),
  OrderDate    VARCHAR(50),
  DeliveryDate VARCHAR(50),
  CustomerID   VARCHAR(50),
  CustomerName TEXT,
  City         TEXT,
  Country      TEXT,
  PostalCode   VARCHAR(50),
  CountryCode  VARCHAR(10),
  Cost         VARCHAR(50),
  Sales        VARCHAR(50),
  Quantity     VARCHAR(50),
  Discount     VARCHAR(50),
  DeliveryCost VARCHAR(50),
  CourseName   TEXT,
  CuisineName  TEXT,
  StarterName  TEXT,
  DessertName  TEXT,
  Drink        TEXT,
  Sides        TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;



LOAD DATA LOCAL INFILE 'C:\\Users\\Wei Zhou\\Desktop\\Yang\\coursera\\db-capstone-project\\short_little_lemon.csv'
INTO TABLE little_lemon.raw_littlelemon
CHARACTER SET utf8
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;


INSERT IGNORE INTO customers (CustomerID, CustomerName)
SELECT DISTINCT
  TRIM(CustomerID),
  TRIM(CustomerName)
FROM raw_littlelemon
WHERE CustomerID IS NOT NULL AND CustomerID <> '';


INSERT INTO delivery (DeliveryDate, CountryCode, Country, City, PostalCode, DeliveryCost)
SELECT DISTINCT
  STR_TO_DATE(NULLIF(DeliveryDate,''), '%Y/%m/%d'),
  CountryCode,
  Country,
  City,
  PostalCode,
  CAST(REPLACE(DeliveryCost, ',', '.') AS DECIMAL(10,2))
FROM raw_littlelemon;


INSERT INTO bookings (CustomerID, BookingDate, NumberOfGuest)
SELECT DISTINCT
  r.CustomerID,
  STR_TO_DATE(NULLIF(r.OrderDate,''), '%Y/%m/%d'),
  1   -- o ajusta con la columna correcta si tienes "guests"
FROM raw_littlelemon r
WHERE r.CustomerID IS NOT NULL;


-- Insertar menú según CuisineName
INSERT IGNORE INTO menus (CuisineName)
SELECT DISTINCT CuisineName
FROM raw_littlelemon
WHERE CuisineName IS NOT NULL AND CuisineName <> '';

-- Insertar items
INSERT IGNORE INTO menuitems (StarterName, CourseName, DessertName, Drink, Sides)
SELECT DISTINCT StarterName, CourseName, DessertName, Drink, Sides
FROM raw_littlelemon;

-- Relacionar menú con items
INSERT IGNORE INTO menudetails (MenuID, MenuItemsID)
SELECT DISTINCT m.MenuID, i.MenuItemsID
FROM raw_littlelemon r
JOIN menus m ON r.CuisineName = m.CuisineName
JOIN menuitems i 
  ON r.StarterName = i.StarterName
 AND r.CourseName  = i.CourseName
 AND r.DessertName = i.DessertName
 AND r.Drink       = i.Drink
 AND r.Sides       = i.Sides;


INSERT INTO orders
(OrderID, CustomerID, OrderDate, DeliveryID, Cost, Sales, Quantity, Discount, BookingID, MenuID)
SELECT
  r.OrderID,
  r.CustomerID,
  STR_TO_DATE(NULLIF(r.OrderDate,''), '%Y/%m/%d'),
  d.DeliveryID,
  CAST(REPLACE(r.Cost, ',', '.') AS DECIMAL(10,2)),
  CAST(REPLACE(r.Sales, ',', '.') AS DECIMAL(10,2)),
  CAST(r.Quantity AS UNSIGNED),
  CAST(REPLACE(r.Discount, ',', '.') AS DECIMAL(10,2)),
  b.BookingID,
  m.MenuID
FROM raw_littlelemon r
LEFT JOIN delivery d
  ON d.DeliveryDate = STR_TO_DATE(NULLIF(r.DeliveryDate,''), '%Y/%m/%d')
 AND d.PostalCode   = r.PostalCode
LEFT JOIN bookings b
  ON b.CustomerID  = r.CustomerID
 AND b.BookingDate = STR_TO_DATE(NULLIF(r.OrderDate,''), '%Y/%m/%d')
LEFT JOIN menus m
  ON m.CuisineName = r.CuisineName;


