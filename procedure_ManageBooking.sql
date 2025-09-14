DROP PROCEDURE IF EXISTS ManageBooking;
DELIMITER //
CREATE PROCEDURE ManageBooking(
    IN pBookingID INT
)
BEGIN
    -- Return the booking details if the BookingID exists
    SELECT BookingID, BookingDate, NumberOfGuest
    FROM little_lemon.bookings
    WHERE BookingID = pBookingID;
END //
DELIMITER ;

-- Look up booking with ID = 1
CALL ManageBooking(1);
