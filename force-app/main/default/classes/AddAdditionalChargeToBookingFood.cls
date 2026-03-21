public with sharing class AddAdditionalChargeToBookingFood {

    public class ChargeInput {
        @InvocableVariable(label='Reservation ID' required=true)
        public String reservationId;

        @InvocableVariable(label='Charge Amount' required=true)
        public Decimal amount;
    }

    public class ChargeOutput {
        @InvocableVariable(label='Message')
        public String message;
    }

    @InvocableMethod(label='Add Additional Charge to Booking Food')
    public static List<ChargeOutput> addCharge(List<ChargeInput> inputs) {
        List<ChargeOutput> outputs = new List<ChargeOutput>();

        for (ChargeInput input : inputs) {
            ChargeOutput output = new ChargeOutput();

            try {
                Hotel_Booking__c booking = [
                    SELECT Id, Reservation_ID__c, Additional_Charges__c
                    FROM Hotel_Booking__c
                    WHERE Reservation_ID__c = :input.reservationId
                    LIMIT 1
                ];

                if (booking != null) {
                    // Add the new amount to existing additional charges
                    Decimal existingCharges = booking.Additional_Charges__c != null ? booking.Additional_Charges__c : 0;
                    booking.Additional_Charges__c = existingCharges + input.amount;

                    update booking;

                    output.message = 'Added ₹' + input.amount + ' to booking. New total: ₹' + booking.Additional_Charges__c;
                } else {
                    output.message = 'Booking not found for Reservation ID: ' + input.reservationId;
                }

            } catch (Exception e) {
                output.message = 'Error while adding charge: ' + e.getMessage();
            }

            outputs.add(output);
        }

        return outputs;
    }
}