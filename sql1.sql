USE shoppingdb;
DELIMITER //

CREATE PROCEDURE PlaceOrder (
    IN p_CustomerID INT,
    IN p_ProductID INT,
    IN p_Quantity INT
)
BEGIN
    DECLARE v_Price DECIMAL(10,2);
    DECLARE v_Stock INT;
    DECLARE v_Subtotal DECIMAL(10,2);

    -- Get product price and stock
    SELECT Price, Stock_Quantity INTO v_Price, v_Stock
    FROM Product
    WHERE Product_ID = p_ProductID;

    -- Check if enough stock
    IF v_Stock >= p_Quantity THEN
        SET v_Subtotal = v_Price * p_Quantity;

        -- Create a new order
        INSERT INTO Orders (Customer_ID, Order_Date, Total_Amount)
        VALUES (p_CustomerID, CURDATE(), v_Subtotal);

        -- Get the last inserted Order_ID
        SET @OrderID = LAST_INSERT_ID();

        -- Insert into OrderDetails
        INSERT INTO OrderDetails (Order_ID, Product_ID, Quantity, Subtotal)
        VALUES (@OrderID, p_ProductID, p_Quantity, v_Subtotal);

        -- Update product stock
        UPDATE Product
        SET Stock_Quantity = Stock_Quantity - p_Quantity
        WHERE Product_ID = p_ProductID;

    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Insufficient stock!';
    END IF;
END //

DELIMITER ;

ALTER TABLE Orders
MODIFY Order_ID INT AUTO_INCREMENT PRIMARY KEY;



ALTER TABLE orders
MODIFY COLUMN Order_ID INT NOT NULL AUTO_INCREMENT;

ALTER TABLE orderdetails
DROP FOREIGN KEY orderdetails_ibfk_1;

ALTER TABLE orderdetails
ADD CONSTRAINT orderdetails_ibfk_1
FOREIGN KEY (Order_ID) REFERENCES orders(Order_ID);

CALL PlaceOrder(101, 1, 2);
DESC orders;
ALTER TABLE orderdetails
MODIFY COLUMN OrderDetail_ID INT NOT NULL AUTO_INCREMENT;
CALL PlaceOrder(101, 1, 2);

SELECT * FROM orders;
SELECT * FROM orderdetails;

CALL PlaceOrder(102, 2, 1);
CALL PlaceOrder(103, 3, 4);




