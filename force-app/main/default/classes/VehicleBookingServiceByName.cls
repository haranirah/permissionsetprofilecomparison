public with sharing class VehicleBookingServiceByName {

    public class BookingInput {
        @InvocableVariable(required=true)
        public String customerEmail;

        @InvocableVariable(required=true)
        public String vehicleName;

        @InvocableVariable(required=true)
        public Date startDate;

        @InvocableVariable(required=true)
        public Date endDate;

        @InvocableVariable(required=true)
        public String pickupLocationName;

        @InvocableVariable(required=true)
        public String destinationCityName;

        @InvocableVariable(required=true)
        public Boolean withDriver;
    }

    public class BookingOutput {
        @InvocableVariable
        public String message;
    }

    @InvocableMethod(label='Create Vehicle Booking by Name')
    public static List<BookingOutput> createVehicleBooking(List<BookingInput> inputs) {
        List<BookingOutput> outputs = new List<BookingOutput>();

        for(BookingInput input : inputs) {
            try {
                Customer_Contact__c customer = [SELECT Id FROM Customer_Contact__c WHERE Email__c = :input.customerEmail LIMIT 1];

                Vehicle__c vehicle = [SELECT Id, Name, Daily_Price__c FROM Vehicle__c WHERE Name = :input.vehicleName LIMIT 1];

                Location_DriveNServe__c pickupLocation = [SELECT Id FROM Location_DriveNServe__c WHERE Name = :input.pickupLocationName LIMIT 1];

                Location_DriveNServe__c destinationCity = [SELECT Id FROM Location_DriveNServe__c WHERE Name = :input.destinationCityName LIMIT 1];

                Integer days = input.endDate.daysBetween(input.startDate) + 1;

                Vehicle_Booking__c booking = new Vehicle_Booking__c(
                    Booking_Status__c = 'Confirmed',
                    Customer_Contact__c = customer.Id,
                    Vehicle__c = vehicle.Id,
                    Start_Date__c = input.startDate,
                    End_Date__c = input.endDate,
                    Pickup_Location__c = pickupLocation.Id,
                    Destination_City__c = destinationCity.Id,
                    With_Driver__c = input.withDriver
                );

                insert booking;

                // Query back to get Booking Number (Name) and Total_Amount__c
                booking = [SELECT Name, Total_Amount__c FROM Vehicle_Booking__c WHERE Id = :booking.Id];

                BookingOutput output = new BookingOutput();
                output.message = 'Booking Confirmed!' +
                                 '\nBooking Number: ' + booking.Name +
                                 '\nVehicle: ' + vehicle.Name +
                                 '\nTotal Days: ' + days +
                                 '\nTotal Amount: ₹' + booking.Total_Amount__c +
                                 '\nWith Driver: ' + input.withDriver +
                                 '\nBooking Id: ' + booking.Id;
                outputs.add(output);

            } catch(Exception e) {
                BookingOutput output = new BookingOutput();
                output.message = 'Booking Failed: ' + e.getMessage();
                outputs.add(output);
            }
        }

        return outputs;
    }
}