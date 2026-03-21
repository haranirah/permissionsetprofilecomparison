public with sharing class StatelessGenerateOTP {
    
    @InvocableMethod(label='Generate OTP and Send Email')
    public static List<String> generateOtpAndSendEmail(List<String> emails) {
        List<String> otpList = new List<String>();
        
        for(String email : emails){
            String otp = String.valueOf(Math.mod(Crypto.getRandomInteger(), 9000) + 1000);
            otpList.add(otp);
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new List<String>{email});
            mail.setSubject('Your OTP Verification Code');
            mail.setHtmlBody('Your OTP is: <b>' + otp + '</b>');
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
        }
        return otpList;
    }
}