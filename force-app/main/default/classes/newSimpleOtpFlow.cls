public with sharing class newSimpleOtpFlow {

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
        public String message;
    }

    // List of static backup OTPs
    private static final List<String> BACKUP_OTPS = new List<String>{'101010', '202020', '303030', '404040', '505050', '606060', '707070', '808080', '909090', '111111'};

    @InvocableMethod(label='Generate or Verify Deterministic OTP with Backup')
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
                generatedOtp = BACKUP_OTPS[0]; // Default backup OTP if generation fails
            }

            if (input.actionType == 'generate') {
                try {
                    sendOtpEmail(input.email, generatedOtp);
                    result.message = 'OTP sent to ' + input.email;
                } catch (Exception ex) {
                    System.debug('Failed to send email: ' + ex.getMessage());
                    result.message = 'OTP generated but email not sent. Use one of the backup OTPs: ' + String.join(BACKUP_OTPS, ', ');
                }

            } else if (input.actionType == 'verify') {
                if (String.isBlank(input.otp)) {
                    result.message = 'OTP not provided for verification';
                } else if (input.otp == generatedOtp || BACKUP_OTPS.contains(input.otp)) {
                    result.message = 'OTP verified successfully';
                } else {
                    result.message = 'Invalid OTP';
                }
            } else {
                result.message = 'Invalid actionType. Use "generate" or "verify".';
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