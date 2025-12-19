# Bookstore Management Database (MySQL)

This project is a fully functional **relational database** for a fictional bookstore built using **MySQL**.  
It demonstrates real-world database design, transactional logic, automation, and security concepts commonly used in business and retail systems.

---

## 📌 Project Overview

The database supports key bookstore operations, including:

- Book and inventory management  
- Customer and membership tracking  
- Order processing and payments  
- Automated cleanup and archiving using MySQL events  
- Role-based access control for different user types  

This project was developed as part of an academic database management course and structured to mirror production-style database logic.

---

## 🧱 Database Schema

Core tables included in the design:

- **Authors** – book author reference data  
- **Categories** – book genres and classifications  
- **Books** – book catalog and inventory levels  
- **Customers** – customer records and membership tiers  
- **Orders** – order headers (date, status, total)  
- **OrderDetails** – line items for each order  
- **Payments** – payment records linked to orders  

The schema enforces:
- Primary and foreign key relationships  
- Unique constraints (e.g., one payment per order)  
- Check constraints to prevent invalid data  
- Indexes for improved query performance  

---

## ⚙️ Stored Procedures

### `place_order`
Handles the full order workflow:
- Validates available stock
- Creates a new order
- Inserts order line items
- Updates inventory
- Calculates and updates order totals

### `UpdateInventory`
Safely adjusts inventory levels while preventing negative stock quantities.

---

## 🧮 User-Defined Function

### `udf_membership_discount`
Applies pricing discounts based on customer membership level:
- **Gold:** 15%
- **Silver:** 10%
- **Standard:** 0%

This function can be used during checkout or pricing analysis.

---

## 📑 Views

To simplify reporting and querying:
- **View_BookList** – basic book catalog view
- **View_BooksWithCategory** – joins books with category names

These views are suitable for dashboards or BI tools.

---

## 🔐 User Roles & Permissions

Three database users model real-world access control:

- **Admin**
  - Full access to the database

- **Seller**
  - Read-only access
  - Execute permission on stored procedures

- **Customer**
  - Limited read-only access to book and category data

This demonstrates role-based access control (RBAC) at the database level.

---

## ⏱️ Automation with MySQL Events

Scheduled events automate routine maintenance tasks:

- **RemoveUnpaidOrders**
  - Deletes unpaid orders older than 48 hours

- **ArchiveCompletedOrders**
  - Archives completed orders older than 30 days

- **LowStockAlert**
  - Flags books with inventory below a defined threshold

> Note: These events assume supporting archive/alert tables.

---

## ▶️ How to Run the Project

1. Open MySQL Workbench or another MySQL client  
2. Run the SQL script:
