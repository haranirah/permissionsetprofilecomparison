public with sharing class HotelBookingDetailsFetcher {

    public class BookingDetailsInput {
        @InvocableVariable(label='Reservation ID')
        public String reservationId;
    }

    public class BookingDetailsOutput {
        @InvocableVariable(label='Message')
        public String message;
    }

    @InvocableMethod(label='Get Hotel Booking Details')
    public static List<BookingDetailsOutput> getBookingDetails(List<BookingDetailsInput> inputs) {
        List<BookingDetailsOutput> outputs = new List<BookingDetailsOutput>();

        for (BookingDetailsInput input : inputs) {
            try {
                Hotel_Booking__c booking = [
                    SELECT Name, Reservation_ID__c, Check_In_Date__c, Check_Out_Date__c, No_of_Guest__c, Room_Type__c,
                           Hotel__r.Name, Customer_Contact__r.Name
                    FROM Hotel_Booking__c
                    WHERE Reservation_ID__c = :input.reservationId
                    LIMIT 1
                ];

                String details = 'Booking Details:' +
                    '\nReservation ID: ' + booking.Reservation_ID__c +
                    '\nHotel Name: ' + booking.Hotel__r.Name +
                    '\nCustomer: ' + booking.Customer_Contact__r.Name +
                    '\nCheck-In Date: ' + booking.Check_In_Date__c +
                    '\nCheck-Out Date: ' + booking.Check_Out_Date__c +
                    '\nNumber of Guests: ' + booking.No_of_Guest__c +
                    '\nRoom Type: ' + booking.Room_Type__c;

                BookingDetailsOutput output = new BookingDetailsOutput();
                output.message = details;
                outputs.add(output);
            } catch (Exception e) {
                BookingDetailsOutput output = new BookingDetailsOutput();
                output.message = 'Failed to retrieve booking details: ' + e.getMessage();
                outputs.add(output);
            }
        }

        return outputs;
    }
}