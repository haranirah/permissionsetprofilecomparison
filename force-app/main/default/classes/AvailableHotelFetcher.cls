public with sharing class AvailableHotelFetcher {

    public class HotelInput {
        @InvocableVariable(label='Destination City')
        public String destinationCity;
    }

    public class HotelOutput {
        @InvocableVariable(label='Message')
        public String message;
    }

    @InvocableMethod(label='Fetch Available Hotels')
    public static List<HotelOutput> fetchHotels(List<HotelInput> requests) {
        List<HotelOutput> responses = new List<HotelOutput>();

        for(HotelInput req : requests) {
            String responseMessage = '';

            List<Hotel__c> hotels = [
                SELECT Name, Rating__c, Amenities__c, Address__c, Price_Per_Night__c
                FROM Hotel__c
                WHERE City__c = :req.destinationCity
                AND Available__c = true
            ];

            if(!hotels.isEmpty()) {
                responseMessage = 'Available hotels in ' + req.destinationCity + ':\n';
                Integer count = 1;
                for(Hotel__c hotel : hotels) {
                    responseMessage += count + '. ' + hotel.Name +
                        ' | Rating: ' + hotel.Rating__c +
                        ' | Amenities: ' + hotel.Amenities__c +
                        ' | Address: ' + hotel.Address__c +
                        ' | Price per Night: ₹' + hotel.Price_Per_Night__c + '\n';
                    count++;
                }
            } else {
                responseMessage = 'No available hotels found in ' + req.destinationCity + '.';
            }

            HotelOutput output = new HotelOutput();
            output.message = responseMessage;
            responses.add(output);
        }

        return responses;
    }
}