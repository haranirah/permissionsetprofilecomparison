public with sharing class AvailableFoodMenuFetcher {

    public class FoodMenuInput {
        @InvocableVariable(label='Hotel Name' required=true)
        public String hotelName;
    }

    public class FoodMenuOutput {
        @InvocableVariable(label='Food Menu Details')
        public String message;
    }

    @InvocableMethod(label='Fetch Food Menu by Hotel')
    public static List<FoodMenuOutput> fetchFoodMenu(List<FoodMenuInput> requests) {
        List<FoodMenuOutput> responses = new List<FoodMenuOutput>();

        for (FoodMenuInput input : requests) {
            String responseMessage = '';

            Hotel__c hotel = [SELECT Id, Name FROM Hotel__c WHERE Name = :input.hotelName LIMIT 1];

            List<Food_Menu__c> foodItems = [
                SELECT Name, Price__c
                FROM Food_Menu__c
                WHERE Hotel__c = :hotel.Id
            ];

            if (!foodItems.isEmpty()) {
                responseMessage = 'Food Menu for ' + hotel.Name + ':\n';
                Integer count = 1;
                for (Food_Menu__c item : foodItems) {
                    responseMessage += count + '. ' + item.Name +
                                       ' | Price: ₹' + item.Price__c + '\n';
                    count++;
                }
            } else {
                responseMessage = 'No food items found for hotel: ' + hotel.Name + '.';
            }

            FoodMenuOutput output = new FoodMenuOutput();
            output.message = responseMessage;
            responses.add(output);
        }

        return responses;
    }
}