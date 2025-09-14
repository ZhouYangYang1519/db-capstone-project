DROP PROCEDURE IF EXISTS UpdateBooking;
DELIMITER //
CREATE PROCEDURE UpdateBooking(
    IN pBookingID INT,
    IN pNewBookingDate DATE,
    IN pNewNumberOfGuest INT
)
BEGIN
    -- Update the booking with the given ID
    UPDATE little_lemon.bookings
    SET BookingDate   = pNewBookingDate,
        NumberOfGuest = pNewNumberOfGuest
    WHERE BookingID   = pBookingID;

    -- Return the updated booking (if it exists)
    SELECT BookingID, BookingDate, NumberOfGuest
    FROM little_lemon.bookings
    WHERE BookingID = pBookingID;
END //
DELIMITER ;

-- Update booking with ID = 1
CALL UpdateBooking(1, '2025-11-01', 4);
