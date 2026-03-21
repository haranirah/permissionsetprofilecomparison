public with sharing class ProjectController {
    @AuraEnabled(cacheable=true)
    public static List<Project__c> getProjects() {
        try {
            return [
                SELECT Id,
                       Name,
                       Status__c,
                       Owner__c,
                       Start_Date__c,
                       End_Date__c,
                       Description__c
                FROM Project__c
                ORDER BY CreatedDate DESC
            ];
        } catch (Exception e) {
            throw new AuraHandledException(
                'Error while fetching projects: ' + e.getMessage()
            );
        }
    }
    @AuraEnabled
    public static Project__c createProject(Project__c project) {
        try {
            insert project;
            return project;
        } catch (Exception e) {
            throw new AuraHandledException(
                'Error while creating project: ' + e.getMessage()
            );
        }
    }
    @AuraEnabled
    public static Project__c updateProject(Project__c project) {
        try {
            update project;
            return project;
        } catch (Exception e) {
            throw new AuraHandledException(
                'Error while updating project: ' + e.getMessage()
            );
        }
    }
}