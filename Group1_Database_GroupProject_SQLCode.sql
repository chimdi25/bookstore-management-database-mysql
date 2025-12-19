-----------------------------------------------------------------------------------
-- TASK 1: DATABASE SETUP
-----------------------------------------------------------------------------------
-- 1. Create and select the database
CREATE DATABASE IF NOT EXISTS bookstore_db;



USE bookstore_db;

-----------------------------------------------------------------------------------
-- TASK 2: BASE TABLE CREATION 
-----------------------------------------------------------------------------------
-- 1. Authors Table (Look-up Table)
CREATE TABLE Authors (
    author_id INT AUTO_INCREMENT PRIMARY KEY, -- PK
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    bio TEXT,
    -- Combined index for fast searches by name
    INDEX idx_author_name (last_name, first_name)
);

-- 2. Categories Table (Look-up Table)
CREATE TABLE Categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY, -- PK
    category_name VARCHAR(100) UNIQUE NOT NULL
);

-- 3. Books Table (Core Entity)
CREATE TABLE Books (
    book_id INT AUTO_INCREMENT PRIMARY KEY, -- PK
    title VARCHAR(255) NOT NULL,
    isbn VARCHAR(13) UNIQUE NOT NULL,
    publication_year YEAR,
    unit_price DECIMAL(10, 2) NOT NULL,
    stock_quantity INT NOT NULL DEFAULT 0,
    author_id INT, -- FK
    category_id INT, -- FK
    
    -- Foreign Keys
    FOREIGN KEY (author_id) REFERENCES Authors(author_id),
    FOREIGN KEY (category_id) REFERENCES Categories(category_id),
    
    -- Constraint to ensure stock and price are non-negative
    CHECK (unit_price >= 0),
    CHECK (stock_quantity >= 0)
);

-- 4. Customers Table (User/Membership Information)
CREATE TABLE Customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY, -- PK
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL, 
    phone VARCHAR(20),
    -- Membership status will be used by the UDF 
    membership_level ENUM('Standard', 'Silver', 'Gold') DEFAULT 'Standard', 
    date_joined DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 5. Orders Table (Transaction Header)
CREATE TABLE Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY, -- PK
    customer_id INT NOT NULL, -- FK to link to customer
    order_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10, 2) DEFAULT 0.00,
    -- Status is important for the Event to auto-remove unpaid orders
    order_status ENUM('Pending', 'Paid', 'Shipped', 'Completed', 'Cancelled', 'Unpaid') DEFAULT 'Unpaid',
    
    -- Foreign Key
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

-- 6. OrderDetails Table (Transaction Line Items)
CREATE TABLE OrderDetails (
    order_detail_id INT AUTO_INCREMENT PRIMARY KEY, -- PK
    order_id INT NOT NULL, -- FK to Orders table
    book_id INT NOT NULL, -- FK to Books table
    quantity INT NOT NULL,
    price_at_order DECIMAL(10, 2) NOT NULL, -- Price at the time of purchase
    
    -- Unique constraint ensures one book per order line 
    UNIQUE KEY uk_order_book (order_id, book_id),
    
    -- Foreign Keys
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (book_id) REFERENCES Books(book_id),
    
    CHECK (quantity > 0)
);

-- 7. Payments Table (Transaction Finalization)
CREATE TABLE Payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY, -- PK
    order_id INT UNIQUE NOT NULL, -- FK, UNIQUE constraint ensures one payment per order
    payment_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    payment_method VARCHAR(50),
    amount_paid DECIMAL(10, 2) NOT NULL,
    
    -- Foreign Key
    FOREIGN KEY (order_id) REFERENCES Orders(order_id)
);


---------------------------------------------------------------
-- TASK 3: INSERT INITIAL DATA (DML)
---------------------------------------------------------------

-- 1. Insert data into Authors (10 total)
INSERT INTO Authors (first_name, last_name, bio) VALUES
('Jane', 'Austen', 'Classic English novelist.'),        
('George', 'Orwell', 'Dystopian and political writer.'),  
('Haruki', 'Murakami', 'Contemporary Japanese writer, often surreal.'), 
('Brandon', 'Sanderson', 'Prolific fantasy and science fiction writer.'), 
('Toni', 'Morrison', 'Nobel Prize winner, focused on the Black American experience.'),
('Neil', 'Gaiman', 'Fantasy author and graphic novelist.'),
('J.R.R.', 'Tolkien', 'Author of The Lord of the Rings.'),
('Octavia', 'Butler', 'Visionary science fiction writer.'),
('Gabriel', 'Garcia Marquez', 'Master of magical realism.'),
('Margaret', 'Atwood', 'Canadian poet, novelist, and essayist.');


-- 2. Insert data into Categories (10 total)
INSERT INTO Categories (category_name) VALUES
('Fiction'),         
('Classics'),        
('Sci-Fi/Fantasy'),  
('Dystopian'),       
('Young Adult'),     
('Historical Fiction'),
('Biography'),
('Poetry'),
('Self-Help'),
('Fantasy'); 


-- 3. Insert data into Books (20 total)
INSERT INTO Books (title, isbn, publication_year, unit_price, stock_quantity, author_id, category_id) VALUES
('Pride and Prejudice', '9780141439518', 2025, 15.50, 50, 1, 2), 
('Emma', '9780141439519', 1915, 14.99, 25, 1, 2), 
('1984', '9780451524935', 1949, 12.00, 30, 2, 4), 
('Animal Farm', '9780451526342', 1945, 9.99, 45, 2, 4), 
('Kafka on the Shore', '9780099458279', 2002, 22.99, 15, 3, 1), 
('The Way of Kings', '9780765326355', 2010, 25.99, 10, 4, 3),
('Mistborn: The Final Empire', '9780765311788', 2006, 18.75, 22, 4, 3), 
('Beloved', '9780307274020', 1987, 13.50, 28, 5, 6), 
('Song of Solomon', '9780452261543', 1977, 11.25, 35, 5, 1), 
('Elantris', '9780765313935', 2005, 16.50, 40, 4, 5),
('Neverwhere', '9780060535345', 1996, 14.50, 30, 6, 10), 
('The Hobbit', '9780618260300', 1937, 17.99, 55, 7, 3), 
('Parable of the Sower', '9780446675501', 1993, 11.99, 20, 8, 4), 
('One Hundred Years of Solitude', '9780060883287', 1967, 15.75, 25, 9, 1), 
('The Handmaids Tale', '9780385490818', 1985, 10.99, 40, 10, 4), 
('The Hero of Ages', '9780765316882', 2008, 19.99, 18, 4, 3), 
('Coraline', '9780380807345', 2002, 8.50, 60, 6, 5), 
('Silmarillion', '9780618391119', 1977, 21.50, 12, 7, 3), 
('The Stand', '9780385121682', 1978, 16.99, 28, 7, 3), 
('The Ocean at the End of the Lane', '9780062450521', 2013, 13.00, 33, 6, 1); 


-- 4. Insert data into Customers (10 total)
INSERT INTO Customers (first_name, last_name, email, membership_level) VALUES
('Alice', 'Smith', 'alice.s@example.com', 'Gold'),   
('Bob', 'Jones', 'bob.j@example.com', 'Silver'),   
('Charlie', 'Brown', 'charlie.b@example.com', 'Standard'), 
('David', 'Lee', 'david.l@example.com', 'Gold'),    
('Eve', 'Green', 'eve.g@example.com', 'Standard'),   
('Frank', 'White', 'frank.w@example.com', 'Silver'),   
('Grace', 'Hall', 'grace.h@example.com', 'Standard'),
('Hannah', 'King', 'hannah.k@example.com', 'Gold'),
('Ian', 'Miller', 'ian.m@example.com', 'Standard'),
('Jenny', 'Clark', 'jenny.c@example.com', 'Silver');


-- 5. Insert data into Orders (10 total)
INSERT INTO Orders (customer_id, order_date, total_amount, order_status) VALUES
(1, NOW() - INTERVAL 10 DAY, 48.49, 'Completed'), 
(2, NOW() - INTERVAL 50 HOUR, 12.00, 'Unpaid'),    
(3, NOW() - INTERVAL 5 MINUTE, 9.99, 'Pending'),   
(4, NOW() - INTERVAL 3 DAY, 42.49, 'Completed'),  
(5, NOW(), 18.75, 'Pending'),                     
(6, NOW() - INTERVAL 1 DAY, 30.00, 'Unpaid'),     
(7, NOW() - INTERVAL 2 HOUR, 25.99, 'Pending'),  
(1, NOW() - INTERVAL 1 WEEK, 15.50, 'Completed'),
(8, NOW() - INTERVAL 1 DAY, 25.49, 'Completed'), -- Total based on OrderDetails below (14.50 + 10.99)
(9, NOW() - INTERVAL 3 HOUR, 37.98, 'Pending'); -- Total based on OrderDetails below (17.99 + 19.99)


-- 6. Insert data into OrderDetails (20 total)
-- Note: Totals in Orders (above) have been adjusted to reflect the final quantity * price_at_order here.
INSERT INTO OrderDetails (order_id, book_id, quantity, price_at_order) VALUES
(1, 1, 1, 15.50), 
(1, 5, 1, 22.99),
(2, 3, 1, 12.00),
(3, 4, 1, 9.99),
(4, 2, 1, 14.99), 
(4, 8, 2, 13.50),
(5, 7, 1, 18.75),
(6, 9, 2, 11.25), 
(6, 10, 1, 16.50),
(7, 6, 1, 25.99),
(8, 1, 1, 15.50),
(9, 11, 1, 14.50), 
(9, 15, 1, 10.99),
(10, 12, 1, 17.99), 
(10, 16, 1, 19.99),
(1, 17, 1, 8.50), 
(4, 13, 1, 11.99), 
(5, 14, 1, 15.75), 
(7, 18, 1, 21.50), 
(2, 19, 1, 16.99); 


-- 7. Insert data into Payments (10 total)
-- Payments recorded for Orders that are now finalized or completed.
INSERT INTO Payments (order_id, payment_method, amount_paid) VALUES
(1, 'Credit Card', 48.49),  
(4, 'Debit Card', 42.49),   
(8, 'E-Transfer', 15.50),  
(2, 'Credit Card', 28.99),   -- Total for Order 2 (12.00 + 16.99)
(6, 'Debit Card', 30.00),    -- Total for Order 6
(9, 'Credit Card', 25.49),   -- Total for Order 9
(10, 'E-Transfer', 37.98),   -- Total for Order 10
(3, 'Debit Card', 9.99),     -- Total for Order 3
(5, 'Credit Card', 34.50),   -- Total for Order 5 (18.75 + 15.75)
(7, 'E-Transfer', 47.49);    -- Total for Order 7 (25.99 + 21.50)

----------------------------------------------------------------------------------------
----------------- TASK 4: USER ROLES AND PERMISSIONS -----------------------------------
----------------------------------------------------------------------------------------

-- Define the host to be used by all users 
SET @HOST_NAME = 'localhost';


-- A. ADMIN ROLE (All Access)
-- Drop the user if it exists to ensure a clean run
DROP USER IF EXISTS 'admin_user'@'localhost';

-- 1. Create Admin User
CREATE USER 'admin_user'@'localhost' IDENTIFIED BY 'Admin_Secure_2024';

-- 2. Grant All Privileges on the entire database
GRANT ALL PRIVILEGES ON bookstore_db.* TO 'admin_user'@'localhost';

-- B. SELLER ROLE
-- Permissions: Read only for all DB + EXECUTE on Stored Procedures
-- ---------------------------------

-- Grant the EXECUTE permission here assuming that as a name.
DROP USER IF EXISTS 'seller_user'@'localhost';

-- 1. Create Seller User
CREATE USER 'seller_user'@'localhost' IDENTIFIED BY 'Seller_Data_2024!';

-- 2. Grant SELECT (read-only) on all tables in the database
GRANT SELECT ON bookstore_db.* TO 'seller_user'@'localhost';

-- 3. Grant EXECUTE on the SP (P3's task)
-- The Seller must be able to place orders.
GRANT EXECUTE ON bookstore_db.* TO 'seller_user'@'localhost';

-- C. CUSTOMER ROLE
-- Permissions: Read only to see available books and their unit price
DROP USER IF EXISTS 'cust_user'@'localhost';

-- 1. Create Customer User
CREATE USER 'cust_user'@'localhost' IDENTIFIED BY 'Cust_ReadOnly_2024!';

-- 2. Grant SELECT only on the specific columns of the Books table
-- This limits what the customer can see for security and privacy.
GRANT SELECT (book_id, title, unit_price, stock_quantity) 
ON bookstore_db.Books TO 'cust_user'@'localhost';

-- Grant SELECT access on Categories table so they can filter books 
GRANT SELECT ON bookstore_db.Categories TO 'cust_user'@'localhost';


-- Apply all changes made to the grants
FLUSH PRIVILEGES;

-- TASK 5: VERIFICATION (OPTIONAL)

-- Verify Table Creation
SHOW TABLES;

-- Verify Data Insertion (10 Books and 7 Customers)
SELECT COUNT(*) FROM Books;
SELECT COUNT(*) FROM Customers;

-- Verify User Creation and Permissions 
SELECT user, host FROM mysql.user WHERE user IN ('admin_user', 'seller_user', 'cust_user');

-------------------------------------------------------------------------------------------------------
-------------------------------- TASK 5: STORED PROCEDURES---------------------------------------------
-------------------------------------------------------------------------------------------------------

-- STORED PROCEDURE 1 : Place_Order
DELIMITER //

CREATE PROCEDURE place_order (
    IN p_customer_id INT,
    IN p_book_id INT,
    IN p_quantity INT
)
BEGIN
    DECLARE v_price DECIMAL(10,2);
    DECLARE v_stock INT;
    DECLARE v_order_id INT;

    SELECT unit_price, stock_quantity
    INTO v_price, v_stock
    FROM Books
    WHERE book_id = p_book_id;

    IF v_stock < p_quantity THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Not enough stock to fulfill the order';
    END IF;

    INSERT INTO Orders (customer_id, order_status)
    VALUES (p_customer_id, 'Pending');

    SET v_order_id = LAST_INSERT_ID();

    INSERT INTO OrderDetails (order_id, book_id, quantity, price_at_order)
    VALUES (v_order_id, p_book_id, p_quantity, v_price);

    UPDATE Books
    SET stock_quantity = stock_quantity - p_quantity
    WHERE book_id = p_book_id;

    UPDATE Orders
    SET total_amount = (
        SELECT SUM(quantity * price_at_order)
        FROM OrderDetails
        WHERE order_id = v_order_id
    )
    WHERE order_id = v_order_id;

END//

DELIMITER ;


-- STORED PROCEDURE 2 : UpdateInventory
DELIMITER $$

CREATE PROCEDURE UpdateInventory(
    IN p_book_id INT,
    IN p_quantity INT
)
BEGIN
    DECLARE v_stock INT;

    -- Get current stock
    SELECT stock_quantity INTO v_stock
    FROM Books
    WHERE book_id = p_book_id;

    -- Check if new stock will be negative
    IF v_stock - p_quantity < 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cannot reduce stock below zero';
    END IF;

    -- Update stock
    UPDATE Books
    SET stock_quantity = stock_quantity - p_quantity
    WHERE book_id = p_book_id;
END $$

DELIMITER ;

--------------------------------------------------------------------------------------------
---------------------------- Task 6 CREATING VIEWS -----------------------------------------
---------------------------------------------------------------------------------------------

-- Book List
CREATE VIEW View_BookList AS

SELECT book_id, title, unit_price, stock_quantity
FROM Books;

SELECT * FROM View_BookList;

-- Books With Categories

CREATE VIEW View_BooksWithCategory AS

	SELECT 
	    b.book_id,
	    b.title,
	    c.category_name,
	    b.unit_price,
	    b.stock_quantity
	FROM Books b
	JOIN Categories c ON b.category_id = c.category_id;
	
SELECT * FROM View_BooksWithCategory;


-- Membership Discount Function
CREATE FUNCTION udf_membership_discount(
    price DECIMAL(10,2),
    membership_level VARCHAR(20)
)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE discount_rate DECIMAL(4,2);

    IF membership_level = 'Gold' THEN
        SET discount_rate = 0.15;
    ELSEIF membership_level = 'Silver' THEN
        SET discount_rate = 0.10;
    ELSE
        SET discount_rate = 0.00;
    END IF;

    RETURN price - (price * discount_rate);
END;

SELECT 
    20 AS original_price,
    udf_membership_discount(20, 'Gold') AS gold_price,
    udf_membership_discount(20, 'Silver') AS silver_price,
    udf_membership_discount(20, 'Standard') AS standard_price;

SHOW CREATE FUNCTION udf_membership_discount;


----------------------------------------------------------------------------------------
--------------------------- TASK 7 EVENTS AND CODE COMPILATION -------------------------
----------------------------------------------------------------------------------------

-- Auto-Remove Unpaid Orders after 48 hour --

CREATE EVENT RemoveUnpaidOrders
ON SCHEDULE EVERY 1 HOUR 
DO
	DELETE FROM Orders 
	WHERE Status = 'Unpaid'
	AND order_date < NOW() - INTERVAL 48 HOUR;

-- Archive Orders that have been Completed --

CREATE EVENT ArchiveCompletedOrders
ON schedule EVERY 1 DAY
DO
	INSERT INTO OrdersArchive
	SELECT * FROM Orders
	WHERE order_status = 'Completed'
	AND Order_Date < NOW() - INTERVAL 30 DAY;
	DELETE FROM Orders
	WHERE order_status = 'Completed'
	AND order_date < NOW() - INTERVAL 30 DAY;

-- Inventory Restock Alert--

CREATE Event LowStockAlert
ON SCHEDULE EVERY 1 DAY 
DO
	INSERT INTO StockAlerts (book_id, alert_date, message)
	SELECT book_id, NOW(), 'Stock Below Threshold'
	FROM books 
	WHERE quantity < 15;

SELECT EVENT_NAME, STATUS, LAST_EXECUTED, SQL_MODE, EVENT_DEFINITION
FROM INFORMATION_SCHEMA.EVENTS
WHERE EVENT_SCHEMA = 'bookstore_db';