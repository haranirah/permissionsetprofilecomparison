public with sharing class StatelessVerifyOTP {

    public class VerifyInput {
        @InvocableVariable
        public String generatedOtp;

        @InvocableVariable
        public String userEnteredOtp;
    }

    public class VerifyOutput {
        @InvocableVariable
        public Boolean isVerified;
    }

    @InvocableMethod(label='Verify OTP')
    public static List<VerifyOutput> verifyOtp(List<VerifyInput> requests) {
        List<VerifyOutput> responses = new List<VerifyOutput>();

        for(VerifyInput req : requests) {
            VerifyOutput res = new VerifyOutput();
            res.isVerified = req.generatedOtp == req.userEnteredOtp;
            responses.add(res);
        }
        return responses;
    }
}