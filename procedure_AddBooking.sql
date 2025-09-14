DROP PROCEDURE IF EXISTS AddBooking;
DELIMITER //
CREATE PROCEDURE AddBooking(
    IN pCustomerID VARCHAR(20),
    IN pBookingDate DATE,
    IN pNumberOfGuest INT
)
proc: BEGIN
    -- Basic validation
    IF pCustomerID IS NULL OR pBookingDate IS NULL OR pNumberOfGuest IS NULL OR pNumberOfGuest <= 0 THEN
        SELECT 'Invalid parameters' AS Error;
        LEAVE proc;
    END IF;

    -- FK check: customer must exist
    IF NOT EXISTS (SELECT 1 FROM little_lemon.customers WHERE CustomerID = pCustomerID) THEN
        SELECT 'CustomerID not found in customers' AS Error, pCustomerID AS CustomerID;
        LEAVE proc;
    END IF;

    -- Insert the new booking
    INSERT INTO little_lemon.bookings(CustomerID, BookingDate, NumberOfGuest)
    VALUES (pCustomerID, pBookingDate, pNumberOfGuest);

    -- Return the row just inserted
    SELECT BookingID, CustomerID, BookingDate, NumberOfGuest
    FROM little_lemon.bookings
    WHERE BookingID = LAST_INSERT_ID();
END//
DELIMITER ;

-- (Primero mira un CustomerID válido de la tabla customers)
-- SELECT CustomerID FROM little_lemon.customers LIMIT 10;

CALL AddBooking('07-158-6611', '2025-11-10', 3);
