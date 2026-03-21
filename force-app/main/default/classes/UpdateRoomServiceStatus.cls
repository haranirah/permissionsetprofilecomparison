public with sharing class UpdateRoomServiceStatus {

    public class StatusUpdateInput {
        @InvocableVariable(required=true)
        public String roomServiceName;  // Auto Number: Name

        @InvocableVariable(required=true)
        public String newStatus;        // Input: New, PickedUp, In Progress, Ready (case-insensitive)
    }

    public class StatusUpdateOutput {
        @InvocableVariable
        public String message;

        @InvocableVariable
        public Boolean success;
    }

    @InvocableMethod(label='Update Room Service Status')
    public static List<StatusUpdateOutput> updateStatus(List<StatusUpdateInput> requests) {
        List<StatusUpdateOutput> results = new List<StatusUpdateOutput>();

        Set<String> namesToUpdate = new Set<String>();
        for (StatusUpdateInput input : requests) {
            namesToUpdate.add(input.roomServiceName);
        }

        // Query records by Name (Auto Number)
        Map<String, Room_Service_Request__c> nameToRecord = new Map<String, Room_Service_Request__c>();
        for (Room_Service_Request__c rec : [
            SELECT Id, Name, Status__c FROM Room_Service_Request__c
            WHERE Name IN :namesToUpdate
        ]) {
            nameToRecord.put(rec.Name, rec);
        }

        // Allowed statuses (standardized)
        Map<String, String> validStatuses = new Map<String, String>{
            'new' => 'New',
            'pickedup' => 'PickedUp',
            'in progress' => 'In Progress',
            'ready' => 'Ready'
        };

        List<Room_Service_Request__c> recordsToUpdate = new List<Room_Service_Request__c>();

        for (StatusUpdateInput input : requests) {
            StatusUpdateOutput output = new StatusUpdateOutput();
            Room_Service_Request__c record = nameToRecord.get(input.roomServiceName);

            if (record == null) {
                output.success = false;
                output.message = 'Room service request with Name "' + input.roomServiceName + '" not found.';
            } else {
                String cleanedStatus = input.newStatus != null ? input.newStatus.trim().toLowerCase() : '';
                String normalizedStatus = validStatuses.get(cleanedStatus);

                if (normalizedStatus == null) {
                    output.success = false;
                    output.message = 'Invalid status: "' + input.newStatus + '". Allowed: New, PickedUp, In Progress, Ready.';
                } else {
                    record.Status__c = normalizedStatus;
                    recordsToUpdate.add(record);
                    output.success = true;
                    output.message = 'Updated status to "' + normalizedStatus + '" for Name "' + input.roomServiceName + '".';
                }
            }

            results.add(output);
        }

        if (!recordsToUpdate.isEmpty()) {
            try {
                update recordsToUpdate;
            } catch (Exception e) {
                for (StatusUpdateOutput output : results) {
                    output.success = false;
                    output.message = 'Update failed: ' + e.getMessage();
                }
            }
        }

        return results;
    }
}