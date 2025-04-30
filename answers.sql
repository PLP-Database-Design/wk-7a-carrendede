-- QUESTION 1
USE salesdb;

CREATE TABLE ProductDetail (
    OrderID INT,
    CustomerName VARCHAR(100),
    Products VARCHAR(255)
);

INSERT INTO ProductDetail (OrderID, CustomerName, Products) VALUES
(101, 'John Doe', 'Laptop, Mouse'),
(102, 'Jane Smith', 'Tablet, Keyboard, Mouse'),
(103, 'Emily Clark', 'Phone');

-- Create a new normalized table
CREATE TABLE ProductDetail_1NF (
    OrderID INT,
    CustomerName VARCHAR(100),
    Product VARCHAR(100)
);

-- Temporarily increase recursion depth
SET SESSION cte_max_recursion_depth = 5000;

-- Then run your recursive CTE
INSERT INTO ProductDetail_1NF (OrderID, CustomerName, Product)
WITH RECURSIVE split_products AS (
    SELECT 
        OrderID,
        CustomerName,
        Products,
        TRIM(SUBSTRING_INDEX(Products, ',', 1)) AS Product,
        SUBSTRING(Products, LOCATE(',', Products) + 1) AS remaining_products
    FROM ProductDetail
    
    UNION ALL
    
    SELECT 
        OrderID,
        CustomerName,
        Products,
        TRIM(SUBSTRING_INDEX(remaining_products, ',', 1)) AS Product,
        CASE 
            WHEN LOCATE(',', remaining_products) > 0 
            THEN SUBSTRING(remaining_products, LOCATE(',', remaining_products) + 1)
            ELSE ''
        END AS remaining_products
    FROM split_products
    WHERE remaining_products != ''
)
SELECT OrderID, CustomerName, Product
FROM split_products
WHERE Product != '';

-- For SQL implementations without STRING_SPLIT (like MySQL), you might use:
INSERT INTO ProductDetail_1NF (OrderID, CustomerName, Product) VALUES
(101, 'John Doe', 'Laptop'),
(101, 'John Doe', 'Mouse'),
(102, 'Jane Smith', 'Tablet'),
(102, 'Jane Smith', 'Keyboard'),
(102, 'Jane Smith', 'Mouse'),
(103, 'Emily Clark', 'Phone');


-- QUESTION 2
USE salesdb;

-- drop existing table
DROP TABLE OrderDetails;

-- create a new table
CREATE TABLE OrderDetails (
    OrderID INT,
    CustomerName VARCHAR(100),
    Product VARCHAR(50),
    Quantity INT,
    PRIMARY KEY (OrderID, Product)
);

-- Insert sample data
INSERT INTO OrderDetails (OrderID, CustomerName, Product, Quantity) VALUES
(101, 'John Doe', 'Laptop', 2),
(101, 'John Doe', 'Mouse', 1),
(102, 'Jane Smith', 'Tablet', 3),
(102, 'Jane Smith', 'Keyboard', 1),
(102, 'Jane Smith', 'Mouse', 2),
(103, 'Emily Clark', 'Phone', 1);


DROP TABLE Orders;
-- Create Orders table (contains order-level information)
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerName VARCHAR(100) NOT NULL
);

-- Create OrderItems table (contains product-level information)
CREATE TABLE OrderItems (
    OrderItemID INT AUTO_INCREMENT PRIMARY KEY,
    OrderID INT NOT NULL,
    Product VARCHAR(50) NOT NULL,
    Quantity INT NOT NULL,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);

-- First insert into Orders table
INSERT INTO Orders (OrderID, CustomerName)
SELECT DISTINCT OrderID, CustomerName
FROM OrderDetails;

-- Then insert into OrderItems table
INSERT INTO OrderItems (OrderID, Product, Quantity)
SELECT OrderID, Product, Quantity
FROM OrderDetails;

-- Verify Orders table
SELECT * FROM Orders;

-- Verify OrderItems table
SELECT * FROM OrderItems;

-- Reconstruct original data with a join
SELECT o.OrderID, o.CustomerName, oi.Product, oi.Quantity
FROM Orders o
JOIN OrderItems oi ON o.OrderID = oi.OrderID
ORDER BY o.OrderID, oi.Product;

