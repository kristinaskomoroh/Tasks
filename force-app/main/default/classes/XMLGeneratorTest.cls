@isTest
private class XMLGeneratorTest {

    @testSetup
    static void setupTestData() {

        Event__c testEvent = new Event__c(Name = 'Test');
        insert testEvent;

        Contact leaderContact = new Contact(
            LastName = 'LeaderContact',
            IBAN__c = 'DE12345678901234567826374836',
            IBANAccountOwner__c = 'Leader'
        );
        Contact volunteerContact = new Contact(
            LastName = 'VolunteerContact',
            IBAN__c = 'DE98765432109876543298253647',
            IBANAccountOwner__c = 'Volunteer'
        );
        insert new List<Contact>{leaderContact, volunteerContact};

        VolunteerShift__c testShift = new VolunteerShift__c(
            Name = 'Test Shift',
            Event__c = testEvent.Id,
            IsIBANPayment__c = true,
            IndividualCompensationShiftLeader__c = 150.00,
            DefaultCompensation__c = 23.00,
            ShiftLeader__c = leaderContact.Id,
            CompensationAndExpensesPayed__c = false
        );
        insert testShift;

        Volunteer__c testVolunteer = new Volunteer__c(
            VolunteerShift__c = testShift.Id,
            IndividualCompensation__c = 50.00,
            Contact__c = volunteerContact.Id,
            CompensationAndExpensesPayed__c = false,
            Status__c = 'Participation'
        );
        insert testVolunteer;
    }

    @isTest
    static void testPositiveExportBoth() {
        Event__c event = [SELECT Id FROM Event__c LIMIT 1];

        XMLGenerator.FlowInput input = new XMLGenerator.FlowInput();
        input.eventId = event.Id;
        input.isExportForAlreadyPaid = true;
        input.isCompensationAndExpensesStatusChanged = true;

        Test.startTest();

        List<XMLGenerator.FlowInput> inputs = new List<XMLGenerator.FlowInput>{input};
        BulkXMLGenerator batch = new BulkXMLGenerator(inputs);
        Database.executeBatch(batch);
        Test.stopTest();

        VolunteerShift__c updatedShift = [SELECT CompensationAndExpensesPayed__c FROM VolunteerShift__c WHERE Event__c = :event.Id LIMIT 1];
        System.assertEquals(true, updatedShift.CompensationAndExpensesPayed__c, 'The group`s payment status must change to `true`');

        Volunteer__c updatedVol = [SELECT CompensationAndExpensesPayed__c FROM Volunteer__c WHERE VolunteerShift__r.Event__c = :event.Id LIMIT 1];
        System.assertEquals(true, updatedVol.CompensationAndExpensesPayed__c, 'The volunteer`s payment status must change to `true`');
    }

    @isTest
    static void testNegativeAlreadyPaidNoExport() {
        Event__c event = [SELECT Id FROM Event__c LIMIT 1];

        VolunteerShift__c shift = [SELECT Id FROM VolunteerShift__c LIMIT 1];
        shift.CompensationAndExpensesPayed__c = true;
        update shift;

        Volunteer__c vol = [SELECT Id FROM Volunteer__c LIMIT 1];
        vol.CompensationAndExpensesPayed__c = true;
        update vol;

        XMLGenerator.FlowInput input = new XMLGenerator.FlowInput();
        input.eventId = event.Id;
        input.isExportForAlreadyPaid = false;

        Test.startTest();

        List<XMLGenerator.FlowOutput> outputs = XMLGenerator.generateXML(new List<XMLGenerator.FlowInput>{input});
        System.assertEquals(false, outputs[0].isBatchNeeded, 'The file shouldn`t be generated, since all entries have already been paid for');
        Test.stopTest();
    }

    @isTest
    static void testNegativeMissingIBAN() {
        Event__c event = [SELECT Id FROM Event__c LIMIT 1];

        Contact leader = [SELECT Id FROM Contact WHERE LastName = 'LeaderContact' LIMIT 1];
        leader.IBAN__c = null;
        update leader;

        XMLGenerator.FlowInput input = new XMLGenerator.FlowInput();
        input.eventId = event.Id;
        input.isExportForAlreadyPaid = false;
        Test.startTest();

        List<XMLGenerator.FlowOutput> outputs = XMLGenerator.generateXML(new List<XMLGenerator.FlowInput>{input});
        System.assertEquals(false, outputs[0].isBatchNeeded, 'The file shouldn`t be generated, since all entries have already been paid for');
        Test.stopTest();
    }
}