global with sharing class VerifyOTPHandler {

    global class Request {
        @InvocableVariable(label='Generated OTP')
        public String generatedOtp;

        @InvocableVariable(label='User Input OTP')
        public String userInputOtp;
    }

    global class Response {
        @InvocableVariable(label='Is Valid')
        public Boolean isValid;
    }

    @InvocableMethod(label='Verify OTP')
    global static List<Response> verifyOTP(List<Request> requests) {
        List<Response> responses = new List<Response>();

        for(Request req : requests) {
            Response res = new Response();
            res.isValid = (req.generatedOtp == req.userInputOtp);
            responses.add(res);
        }

        return responses;
    }
}