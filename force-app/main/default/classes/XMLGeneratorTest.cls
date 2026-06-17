@isTest
public class XMLGeneratorTest {
    @testSetup
    public static void setupTestData() {
        Event__c testEvent = new Event__c(Name = 'Test_Event');
        insert testEvent;
        
        Contact shiftLeaderContact = new Contact(LastName = 'ShiftLeader', FirstName = 'Ivan', IBAN__c = 'PL12345678901234567890123456', IBANAccountOwner__c = 'test');
        Contact volunteerContact = new Contact(LastName = 'Volunteer', FirstName = 'Petr', IBANAccountOwner__c = null, IBAN__c = ' ');
        insert new List<Contact>{shiftLeaderContact, volunteerContact};
        
        VolunteerShift__c shiftPaid = new VolunteerShift__c(
            Name = 'Test_#$&*Shift',
            ShiftLeader__c = shiftLeaderContact.Id,
            Event__c = testEvent.Id,
            CompensationAndExpensesPayed__c = true,
            DefaultCompensation__c = 10,
            IndividualCompensationShiftLeader__c = 230,
            IsIBANPayment__c = true
        );
        insert shiftPaid;

        VolunteerShift__c shiftUnpaid = new VolunteerShift__c(
            Name = 'Test_!!!*Shift',
            Event__c = testEvent.Id,
            CompensationAndExpensesPayed__c = false,
            DefaultCompensation__c = 0,
            IndividualCompensationShiftLeader__c = 0,
            IsIBANPayment__c = true
        );
        insert shiftUnpaid;

        
        Volunteer__c vol1 = new Volunteer__c(
            VolunteerShift__c = shiftPaid.Id,
            Contact__c = volunteerContact.Id,
            Status__c = 'Participation',
            IndividualCompensation__c = 289,
            CompensationAndExpensesPayed__c = true
        );
        
        Volunteer__c vol2 = new Volunteer__c(
            VolunteerShift__c = shiftUnpaid.Id,
            Contact__c = volunteerContact.Id,
            Status__c = 'Participation',
            IndividualCompensation__c = 10,
            CompensationAndExpensesPayed__c = false
        );

        Volunteer__c vol3 = new Volunteer__c(
            VolunteerShift__c = shiftUnpaid.Id,
            Status__c = 'Participation',
            IndividualCompensation__c = 10,
            CompensationAndExpensesPayed__c = false
        );
        insert new List<Volunteer__c>{vol1, vol2, vol3};
    }

    @isTest
    public static void testGenerateXML_WithToggleFalse() {
        Event__c eventToTest = [SELECT Id FROM Event__c LIMIT 1];
        
        XMLGenerator.FlowInput input = new XMLGenerator.FlowInput();
        input.eventId = eventToTest.Id;
        input.toggleFirst = false;
        input.toggleSecond = false;
        
        List<XMLGenerator.FlowInput> inputs = new List<XMLGenerator.FlowInput>{input};
        Test.startTest();

        List<XMLGenerator.FlowOutput> outputs = XMLGenerator.generateXML(inputs);
        
        Test.stopTest();
        
        System.assertEquals(1, outputs.size(), 'The method must return a single response for Flow');
        
        List<ContentVersion> generatedFiles = [
            SELECT Id, Title, PathOnClient, FirstPublishLocationId 
            FROM ContentVersion 
            WHERE FirstPublishLocationId = :eventToTest.Id
        ];
        
        System.assertEquals(1, generatedFiles.size(), 'The XML file must be generated and saved in the database');
        System.assertEquals(eventToTest.Id, generatedFiles[0].FirstPublishLocationId, 'The file must be attached to the event');
    }

    @isTest
    public static void testGenerateXML_WithToggleTrue() {
        Event__c eventToTest = [SELECT Id FROM Event__c LIMIT 1];
        
        XMLGenerator.FlowInput input = new XMLGenerator.FlowInput();
        input.eventId = eventToTest.Id;
        input.toggleFirst = true;
        input.toggleSecond = true;
        
        List<XMLGenerator.FlowInput> inputs = new List<XMLGenerator.FlowInput>{input};
        Test.startTest();

        List<XMLGenerator.FlowOutput> outputs = XMLGenerator.generateXML(inputs);
        
        Test.stopTest();
        
        System.assertEquals(1, outputs.size(), 'The method must return a single response for Flow');
        
        List<ContentVersion> generatedFiles = [
            SELECT Id, Title, PathOnClient, FirstPublishLocationId 
            FROM ContentVersion 
            WHERE FirstPublishLocationId = :eventToTest.Id
        ];
        
        System.assertEquals(1, generatedFiles.size(), 'The XML file must be generated and saved in the database');
        System.assertEquals(eventToTest.Id, generatedFiles[0].FirstPublishLocationId, 'The file must be attached to the event');
    }
}