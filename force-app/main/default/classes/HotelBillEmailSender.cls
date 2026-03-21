public with sharing class HotelBillEmailSender {

    public class InputWrapper {
        @InvocableVariable(required=true)
        public String reservationId;
    }

    public class OutputWrapper {
        @InvocableVariable
        public String message;
    }

    @InvocableMethod(label='Send Hotel Checkout Email')
    public static List<OutputWrapper> sendCheckoutEmail(List<InputWrapper> inputs) {
        List<OutputWrapper> results = new List<OutputWrapper>();

        for (InputWrapper input : inputs) {
            OutputWrapper result = new OutputWrapper();

            try {
                List<Hotel_Booking__c> bookings = [
                    SELECT Reservation_ID__c, Check_In_Date__c, Check_Out_Date__c, No_of_Guest__c,
                           Room_Type__c, Total_Amount__c, Additional_Charges__c, Services_Availed__c,
                           Hotel__r.Name, Customer_Contact__r.Name, Customer_Contact__r.Email__c
                    FROM Hotel_Booking__c
                    WHERE Reservation_ID__c = :input.reservationId
                    LIMIT 1
                ];

                if (!bookings.isEmpty()) {
                    Hotel_Booking__c booking = bookings[0];

                    Decimal baseAmount = booking.Total_Amount__c != null ? booking.Total_Amount__c : 0;
                    Decimal additional = booking.Additional_Charges__c != null ? booking.Additional_Charges__c : 0;
                    Decimal finalAmount = baseAmount + additional;

                    String emailBody = 'Dear ' + booking.Customer_Contact__r.Name + ',\n\n' +
                        'Thank you for choosing ' + booking.Hotel__r.Name + '. Your checkout is successful. Below is your bill summary:\n\n' +
                        'Reservation ID: ' + booking.Reservation_ID__c + '\n' +
                        'Check-In Date: ' + String.valueOf(booking.Check_In_Date__c) + '\n' +
                        'Check-Out Date: ' + String.valueOf(booking.Check_Out_Date__c) + '\n' +
                        'Room Type: ' + booking.Room_Type__c + '\n' +
                        'No. of Guests: ' + booking.No_of_Guest__c + '\n\n' +
                        'Base Amount: ₹' + baseAmount + '\n' +
                        'Additional Charges: ₹' + additional + '\n' +
                        'Final Amount: ₹' + finalAmount + '\n\n';

                    if (String.isNotBlank(booking.Services_Availed__c)) {
                        emailBody += 'Services Availed:\n' + booking.Services_Availed__c + '\n\n';
                    }

                    emailBody += 'We hope you had a pleasant stay!\nLooking forward to seeing you again.\n\n' +
                                 'Warm regards,\n' + booking.Hotel__r.Name + ' Management';

                    // Send Email
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setToAddresses(new String[] { booking.Customer_Contact__r.Email__c });
                    email.setSubject('Your Checkout Summary - ' + booking.Hotel__r.Name);
                    email.setPlainTextBody(emailBody);
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });

                    result.message = 'Email sent successfully to ' + booking.Customer_Contact__r.Email__c;
                } else {
                    result.message = 'No booking found for Reservation ID: ' + input.reservationId;
                }
            } catch (Exception e) {
                result.message = 'Error sending email for Reservation ID ' + input.reservationId + ': ' + e.getMessage();
            }

            results.add(result);
        }

        return results;
    }
}