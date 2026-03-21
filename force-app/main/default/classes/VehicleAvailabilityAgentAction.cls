public with sharing class VehicleAvailabilityAgentAction {

    public class InputWrapper {
        @InvocableVariable(required=true)
        public String city;          // Location Name (City)

        @InvocableVariable(required=true)
        public String vehicleType;   // Vehicle Type input (Car, Bike, Cycle)
    }

    public class OutputWrapper {
        @InvocableVariable
        public String message;
    }

    @InvocableMethod(label='Get Vehicle Availability for Agent')
    public static List<OutputWrapper> getAvailableVehicles(List<InputWrapper> inputList) {
        List<OutputWrapper> results = new List<OutputWrapper>();

        for (InputWrapper input : inputList) {
            String responseMessage = '';

            // Query location by city name
            List<Location_DriveNServe__c> locations = [
                SELECT Id
                FROM Location_DriveNServe__c
                WHERE Name = :input.city
                LIMIT 1
            ];

            if (!locations.isEmpty()) {
                Id pickupLocationId = locations[0].Id;

                // Query vehicles matching the type and location
                List<Vehicle__c> vehicles = [
                    SELECT Name, Vehicle_Number__c, Color__c, Daily_Price__c, Pickup_Location__c, Transmission__c, Vehicle_Type__c
                    FROM Vehicle__c
                    WHERE Is_Available__c = true
                    AND Vehicle_Type__c = :input.vehicleType
                    AND Pickup_Location__c = :pickupLocationId
                ];

                if (!vehicles.isEmpty()) {
                    responseMessage = 'Available ' + input.vehicleType + 's in ' + input.city + ':\n';
                    Integer count = 1;

                    for (Vehicle__c v : vehicles) {
                        responseMessage += count + '. ' + v.Name + 
                                           ' | Color: ' + v.Color__c +
                                           ' | Transmission: ' + v.Transmission__c +
                                           ' | Daily Price: ₹' + v.Daily_Price__c +
                                           ' | Vehicle Number: ' + v.Vehicle_Number__c + '\n';
                        count++;
                    }
                } else {
                    responseMessage = 'No available ' + input.vehicleType + 's found in ' + input.city + '.';
                }
            } else {
                responseMessage = 'No location found for the city: ' + input.city + '.';
            }

            OutputWrapper output = new OutputWrapper();
            output.message = responseMessage;
            results.add(output);
        }

        return results;
    }
}