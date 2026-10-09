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

        VolunteerShift__c emptyShift = new VolunteerShift__c(
            Name = 'Empty Shift',
            Event__c = testEvent.Id,
            IsIBANPayment__c = true,
            IndividualCompensationShiftLeader__c = 100.00,
            ShiftLeader__c = leaderContact.Id,
            CompensationAndExpensesPayed__c = false
        );
        insert emptyShift;

        Volunteer__c testVolunteer = new Volunteer__c(
            VolunteerShift__c = testShift.Id,
            IndividualCompensation__c = 50.00,
            Contact__c = volunteerContact.Id,
            CompensationAndExpensesPayed__c = false,
            Status__c = DataHelper.VOLUNTEER_STATUS_PARTICIPATION
        );
        insert testVolunteer;
    }

    @isTest
    static void testPositiveExport() {
        Event__c event = [SELECT Id FROM Event__c LIMIT 1];

        XMLGenerator.FlowInput input = new XMLGenerator.FlowInput();
        input.eventId = event.Id;
        input.isExportForAlreadyPaid = true;
        input.isCompensationAndExpensesStatusChanged = true;

        Test.startTest();
        List<XMLGenerator.FlowOutput> outputs = XMLGenerator.generateXML(new List<XMLGenerator.FlowInput>{input});
        Test.stopTest();

        VolunteerShift__c updatedShift = [SELECT CompensationAndExpensesPayed__c FROM VolunteerShift__c WHERE Event__c = :event.Id LIMIT 1];
        System.assertEquals(true, updatedShift.CompensationAndExpensesPayed__c, 'The Shiftgroup`s status must be set to “true”');

        Volunteer__c updatedVol = [SELECT CompensationAndExpensesPayed__c FROM Volunteer__c WHERE VolunteerShift__r.Event__c = :event.Id LIMIT 1];
        System.assertEquals(true, updatedVol.CompensationAndExpensesPayed__c, 'The volunteer`s status must be set to “true”');

        Integer filesCount = [SELECT COUNT() FROM ContentVersion];
        System.assert(filesCount > 0, 'The XML file must be generated and saved');
    }


    @isTest
    static void testFreeLeaderAndPaidVolunteer() {
        Event__c event = [SELECT Id FROM Event__c LIMIT 1];

        VolunteerShift__c shift = [SELECT Id FROM VolunteerShift__c LIMIT 1];
        shift.IndividualCompensationShiftLeader__c = 0;
        update shift;

        XMLGenerator.FlowInput input = new XMLGenerator.FlowInput();
        input.eventId = event.Id;
        input.isExportForAlreadyPaid = true;
        input.isCompensationAndExpensesStatusChanged = false;

        Test.startTest();
        List<XMLGenerator.FlowOutput> outputs = XMLGenerator.generateXML(new List<XMLGenerator.FlowInput>{input});
        Test.stopTest();

        System.assertEquals(true, outputs[0].isBatchNeeded, 'Batch needs to find a volunteer, even though the leader is unpaid');

        Volunteer__c updatedVol = [SELECT CompensationAndExpensesPayed__c FROM Volunteer__c LIMIT 1];
        System.assertEquals(false, updatedVol.CompensationAndExpensesPayed__c, 'The status should not change');
    }

    @isTest
    static void testNegativeExport() {
        Event__c event = [SELECT Id FROM Event__c LIMIT 1];

        List<VolunteerShift__c> shifts = [SELECT Id FROM VolunteerShift__c];
        for (VolunteerShift__c s : shifts) {
            s.CompensationAndExpensesPayed__c = true;
        }
        update shifts;

        List<Volunteer__c> vols = [SELECT Id FROM Volunteer__c];
        for (Volunteer__c v : vols) {
            v.CompensationAndExpensesPayed__c = true;
        }
        update vols;

        XMLGenerator.FlowInput input = new XMLGenerator.FlowInput();
        input.eventId = event.Id;
        input.isExportForAlreadyPaid = false;

        Test.startTest();
        List<XMLGenerator.FlowOutput> outputs = XMLGenerator.generateXML(new List<XMLGenerator.FlowInput>{input});
        Test.stopTest();

        System.assertEquals(false, outputs[0].isBatchNeeded, 'The file should not be generated, since everyone has already been paid');
    }

    @isTest
    static void testNegativeMissingIBAN() {
        Event__c event = [SELECT Id FROM Event__c LIMIT 1];

        List<Contact> contactsToUpdate = [SELECT Id, IBAN__c FROM Contact];
        for(Contact c : contactsToUpdate) {
            c.IBAN__c = null;
        }
        update contactsToUpdate;

        XMLGenerator.FlowInput input = new XMLGenerator.FlowInput();
        input.eventId = event.Id;
        input.isExportForAlreadyPaid = false;
        
        Test.startTest();
        List<XMLGenerator.FlowOutput> outputs = XMLGenerator.generateXML(new List<XMLGenerator.FlowInput>{input});
        Test.stopTest();

        System.assertEquals(false, outputs[0].isBatchNeeded, 'The file should not be generated because there is no IBAN');
        System.assertEquals('No shifts or volunteers meeting the criteria were found for this event. The file cannot be generated.', outputs[0].message, 'An error message should appear');
    }


    @isTest
    static void testEmptyShift() {
        Event__c event = [SELECT Id FROM Event__c LIMIT 1];

        Contact leader = [SELECT Id, IBAN__c FROM Contact WHERE LastName = 'LeaderContact' LIMIT 1];

        VolunteerShift__c shift = [SELECT Id FROM VolunteerShift__c WHERE Name = 'Empty Shift'LIMIT 1];

        XMLGenerator.FlowInput input = new XMLGenerator.FlowInput();
        input.eventId = event.Id;
        input.isExportForAlreadyPaid = false;
        input.isCompensationAndExpensesStatusChanged = true;

        Test.startTest();
        List<XMLGenerator.FlowOutput> outputs = XMLGenerator.generateXML(new List<XMLGenerator.FlowInput>{input});
        Test.stopTest();

        VolunteerShift__c updatedEmptyShift = [
            SELECT CompensationAndExpensesPayed__c
            FROM VolunteerShift__c
            WHERE Id = :shift.Id
        ];
        Integer filesCount = [SELECT COUNT() FROM ContentVersion];
        System.assertEquals(true, updatedEmptyShift.CompensationAndExpensesPayed__c, 'The empty shift`s status must be set to true');
        System.assert(filesCount > 0, 'The XML file must be generated and saved');
    }
}
