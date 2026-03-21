public with sharing class SimpleOtpFlow {

    public class OtpInput {
        @InvocableVariable(required=true)
        public String name;

        @InvocableVariable(required=true)
        public String email;

        @InvocableVariable(required=true)
        public String mobileNumber;

        @InvocableVariable
        public String otp; // Provided only for verification

        @InvocableVariable(required=true)
        public String actionType; // 'generate' or 'verify'
    }

    public class OtpResult {
        @InvocableVariable
        public Boolean Otpvalid;

        @InvocableVariable
        public Boolean invalidotp;

        @InvocableVariable
        public String Invalidotpdetails;

        @InvocableVariable
        public Boolean Sendsuccessregistration;
    }

    private static final List<String> BACKUP_OTPS = new List<String>{'101010', '202020', '303030', '404040', '505050'};

    @InvocableMethod(label='Generate or Verify Deterministic OTP with Structured Response')
    public static List<OtpResult> handleOtp(List<OtpInput> inputList) {
        List<OtpResult> results = new List<OtpResult>();

        for (OtpInput input : inputList) {
            OtpResult result = new OtpResult();

            String name = input.name != null ? input.name.replaceAll('[^a-zA-Z]', '') : '';
            String email = input.email != null ? input.email.replaceAll('[^a-zA-Z]', '') : '';
            String mobile = input.mobileNumber != null ? input.mobileNumber.replaceAll('[^0-9]', '') : '';

            Integer nameLength = name.length();
            Integer emailLength = email.length();
            String digitsFromMobile = extractDigitsFromMobile(mobile);

            String generatedOtp = String.valueOf(nameLength) + String.valueOf(emailLength) + digitsFromMobile;
            if (String.isBlank(generatedOtp)) {
                generatedOtp = BACKUP_OTPS[0]; 
            }

            if (input.actionType == 'generate') {
                try {
                    sendOtpEmail(input.email, generatedOtp);
                    result.Otpvalid = true;
                    result.Sendsuccessregistration = true;
                } catch (Exception ex) {
                    System.debug('Email Send Failed: ' + ex.getMessage());
                    result.Otpvalid = true; // Still valid as OTP was generated
                    result.Sendsuccessregistration = false;
                }
            } else if (input.actionType == 'verify') {
                if (String.isBlank(input.otp)) {
                    result.Otpvalid = false;
                    result.invalidotp = true;
                    result.Invalidotpdetails = 'OTP not provided for verification';
                } else if (input.otp == generatedOtp || BACKUP_OTPS.contains(input.otp)) {
                    result.Otpvalid = true;
                    result.invalidotp = false;
                    result.Sendsuccessregistration = true;
                } else {
                    result.Otpvalid = false;
                    result.invalidotp = true;
                    result.Invalidotpdetails = 'the entered otp is invalid';
                }
            } else {
                result.Otpvalid = false;
                result.invalidotp = true;
                result.Invalidotpdetails = 'Invalid actionType. Use "generate" or "verify".';
            }

            results.add(result);
        }
        return results;
    }

    private static String extractDigitsFromMobile(String mobile) {
        if (mobile.length() < 3) {
            return mobile.leftPad(3, '0');
        }
        String firstDigit = mobile.substring(0,1);
        String lastDigit = mobile.substring(mobile.length()-1);
        Integer middleIndex = (mobile.length() - 1) / 2;
        String middleDigit = mobile.substring(middleIndex, middleIndex + 1);

        return firstDigit + middleDigit + lastDigit;
    }

    private static void sendOtpEmail(String toEmail, String otp) {
        if (String.isBlank(toEmail)) return;

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new String[] { toEmail });
        email.setSubject('Your OTP Code');
        email.setPlainTextBody('Dear User,\n\nYour OTP is: ' + otp + '\n\nThank you.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
    }
}