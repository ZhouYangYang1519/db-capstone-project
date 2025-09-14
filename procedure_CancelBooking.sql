DROP PROCEDURE IF EXISTS CancelBooking;
DELIMITER //
CREATE PROCEDURE CancelBooking(
    IN pBookingID INT
)
BEGIN
    DECLARE vExists INT;

    -- Check if the booking exists
    SELECT COUNT(*) INTO vExists
    FROM little_lemon.bookings
    WHERE BookingID = pBookingID;

    IF vExists > 0 THEN
    
		UPDATE little_lemon.orders
		SET BookingID = NULL
		WHERE BookingID = pBookingID;
        
        -- Delete the booking
        DELETE FROM little_lemon.bookings
        WHERE BookingID = pBookingID;

        -- Confirmation message
        SELECT CONCAT('Booking ', pBookingID, ' cancelled successfully') AS Message;
    ELSE
        -- If no booking found
        SELECT CONCAT('Booking ', pBookingID, ' not found') AS Message;
    END IF;
END //
DELIMITER ;

-- Cancel an existing booking (e.g., BookingID = 2015)
CALL CancelBooking(345);


