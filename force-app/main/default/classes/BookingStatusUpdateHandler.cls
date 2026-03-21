public with sharing class BookingStatusUpdateHandler {

    public class BookingActionInput {
        @InvocableVariable(required=true)
        public String bookingNumber;  // Assuming this is a unique identifier

        @InvocableVariable(required=true)
        public String action;  // Expected: 'confirm', 'complete', 'cancel'
    }

    public class BookingActionOutput {
        @InvocableVariable
        public String message;
    }

    @InvocableMethod(label='Update Booking Status')
    public static List<BookingActionOutput> updateBookingStatus(List<BookingActionInput> inputList) {
        List<BookingActionOutput> results = new List<BookingActionOutput>();

        for (BookingActionInput input : inputList) {
            BookingActionOutput output = new BookingActionOutput();
            try {
                Vehicle_Booking__c booking = [SELECT Id, Booking_Status__c 
                                              FROM Vehicle_Booking__c 
                                              WHERE Name = :input.bookingNumber
                                              LIMIT 1];

                String newStatus;
                if (input.action.toLowerCase() == 'confirm') {
                    newStatus = 'Confirmed';
                } else if (input.action.toLowerCase() == 'complete') {
                    newStatus = 'Completed';
                } else if (input.action.toLowerCase() == 'cancel') {
                    newStatus = 'Cancelled';
                } else {
                    output.message = 'Invalid action provided. Use confirm, complete, or cancel.';
                    results.add(output);
                    continue;
                }

                booking.Booking_Status__c = newStatus;
                update booking;

                output.message = 'Booking ' + input.bookingNumber + ' has been updated to ' + newStatus;
            } catch(QueryException qe) {
                output.message = 'Booking number ' + input.bookingNumber + ' not found.';
            } catch(Exception e) {
                output.message = 'Error updating booking: ' + e.getMessage();
            }
            results.add(output);
        }

        return results;
    }
}