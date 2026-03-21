public with sharing class HotelBookingCreator {

    public class HotelBookingInput {
        @InvocableVariable(label='Check-In Date')
        public Date checkInDate;

        @InvocableVariable(label='Check-Out Date')
        public Date checkOutDate;

        @InvocableVariable(label='Customer Email')
        public String customerEmail;   // Instead of Contact Id

        @InvocableVariable(label='Hotel Name')
        public String hotelName;       // Instead of Hotel Id

        @InvocableVariable(label='Number of Guests')
        public Integer numberOfGuests;

        @InvocableVariable(label='Room Type')
        public String roomType;        // Picklist
    }

    public class HotelBookingOutput {
        @InvocableVariable(label='Reservation ID')
        public String reservationId;

        @InvocableVariable(label='Message')
        public String message;
    }

    @InvocableMethod(label='Create Hotel Booking by Names')
    public static List<HotelBookingOutput> createBooking(List<HotelBookingInput> bookingInputs) {
        List<HotelBookingOutput> responses = new List<HotelBookingOutput>();

        for (HotelBookingInput input : bookingInputs) {
            try {
                Customer_Contact__c customer = [
                    SELECT Id, Name FROM Customer_Contact__c 
                    WHERE Email__c = :input.customerEmail 
                    LIMIT 1
                ];

                Hotel__c hotel = [
                    SELECT Id, Name FROM Hotel__c 
                    WHERE Name = :input.hotelName 
                    LIMIT 1
                ];

                Hotel_Booking__c booking = new Hotel_Booking__c(
                    Check_In_Date__c = input.checkInDate,
                    Check_Out_Date__c = input.checkOutDate,
                    Customer_Contact__c = customer.Id,
                    Hotel__c = hotel.Id,
                    No_of_Guest__c = input.numberOfGuests,
                    Room_Type__c = input.roomType
                );

                insert booking;

                // Generate Reservation ID
                String namePart = (customer.Name != null && customer.Name.length() >=3) ? customer.Name.substring(0,3).toUpperCase() : 'CUS';
                String datePart = Date.today().format().replaceAll('-',''); // Format: yyyyMMdd
                Integer randomNum = Math.mod(Math.abs(Crypto.getRandomInteger()), 10000);
                String randomPart = String.valueOf(randomNum).leftPad(4,'0');

                booking.Reservation_ID__c = namePart + datePart + randomPart;
                update booking;

                HotelBookingOutput output = new HotelBookingOutput();
                output.reservationId = booking.Reservation_ID__c;
                output.message = 'Hotel booking created successfully with Reservation ID: ' + booking.Reservation_ID__c;
                responses.add(output);

            } catch(Exception e) {
                HotelBookingOutput output = new HotelBookingOutput();
                output.message = 'Booking Failed: ' + e.getMessage();
                responses.add(output);
            }
        }

        return responses;
    }
}