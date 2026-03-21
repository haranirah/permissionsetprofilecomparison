@IsTest
public class ProjectControllerTest {

    @IsTest
    static void testCreateAndUpdateProject() {
        Project__c proj = new Project__c(
            Name = 'Test Project',
            Status__c = 'Planned',
            Start_Date__c = Date.today(),
            End_Date__c = Date.today().addDays(10)
        );

        Test.startTest();
        Project__c createdProj = ProjectController.createProject(proj);
        createdProj.Status__c = 'In Progress';
        ProjectController.updateProject(createdProj);
        List<Project__c> projects = ProjectController.getProjects();
        Test.stopTest();

        System.assertEquals(1, projects.size());
        System.assertEquals('In Progress', projects[0].Status__c);
    }
}