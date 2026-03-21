global with sharing class GenerateOTPHandler {

    global class Request {
        @InvocableVariable(label='Email Address')
        public String email;
    }

    global class Response {
        @InvocableVariable(label='OTP')
        public String otp;
        @InvocableVariable(label='Message')
        public String message;
    }

    @InvocableMethod(label='Generate OTP for Email')
    global static List<Response> generateOTP(List<Request> requests) {
        List<Response> responses = new List<Response>();

        for(Request req : requests) {
            Response res = new Response();
            try {
                List<Contact> contacts = [SELECT Id, FirstName, Email FROM Contact WHERE Email = :req.email LIMIT 1];
                
                if (!contacts.isEmpty()) {
                    String otp = String.valueOf(Math.mod(Crypto.getRandomInteger(), 10000)).leftPad(4, '0');
                    
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setToAddresses(new String[] { req.email });
                    email.setSubject('Your OTP Code');
                    email.setPlainTextBody('Hello ' + contacts[0].FirstName + ',\n\nYour OTP code is: ' + otp);

                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });

                    res.otp = otp;
                    res.message = 'OTP sent successfully';
                } else {
                    res.otp = '';
                    res.message = 'No contact found for this email';
                }
            } catch(Exception ex) {
                res.otp = '';
                res.message = 'Error: ' + ex.getMessage();
            }

            responses.add(res);
        }
        return responses;
    }
}
//22