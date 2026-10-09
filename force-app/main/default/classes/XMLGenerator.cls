public with sharing class XMLGenerator {
    public class FlowInput {
        @InvocableVariable public Id eventId;
        @InvocableVariable public Boolean isCompensationAndExpensesStatusChanged;
        @InvocableVariable public Boolean isExportForAlreadyPaid;
    }
    public class FlowOutput {
        @InvocableVariable public String message;
        @InvocableVariable public Boolean isBatchNeeded = false;
        @InvocableVariable public Id jobId;
    }

    @InvocableMethod
    public static List<FlowOutput> generateXML(List<FlowInput> inputs) {
        List<FlowOutput> results = new List<FlowOutput>();
        FlowOutput output = new FlowOutput();
        Id eventId = inputs[0].eventId;
        Boolean isCompensationAndExpensesStatusChanged = inputs[0].isCompensationAndExpensesStatusChanged;
        Boolean isExportForAlreadyPaid = inputs[0].isExportForAlreadyPaid;
        for(VolunteerShift__c shift: [SELECT Id,
                                             ShiftLeader__r.IBAN__c,
                                             CompensationAndExpensesPayed__c
                                      FROM VolunteerShift__c
                                      WHERE Event__c =: eventId
                                      AND IsIBANPayment__c = true
                                      AND CompensationTotalShiftLeader__c != null
                                      AND CompensationTotalShiftLeader__c > 0
                                      AND ShiftLeader__r.IBANAccountOwner__c != null
                                      LIMIT 50000
        ]){
            Boolean isLeaderValid = true;
            if(String.isBlank(shift.ShiftLeader__r.IBAN__c)){
                isLeaderValid = false;
            }
            if(isExportForAlreadyPaid == false && shift.CompensationAndExpensesPayed__c == true){
                isLeaderValid = false;
            }
            if(isLeaderValid == true) {
                output.isBatchNeeded = true;
                break;
            }
        }
        if(output.isBatchNeeded == true) {
            output.jobId = Database.executeBatch(new BulkXmlGenerator(inputs), 200);
        }
        if(output.isBatchNeeded == false) {
            for(Volunteer__c volunteer:[SELECT Id,
                                             Contact__r.IBAN__c,
                                             CompensationAndExpensesPayed__c
                                      FROM Volunteer__c
                                      WHERE VolunteerShift__r.Event__c =: eventId
                                      AND VolunteerShift__r.IsIBANPayment__c = true
                                      AND IndividualCompensationTotal__c != null
                                      AND Contact__r.IBANAccountOwner__c != null
                                      AND Status__c = :DataHelper.VOLUNTEER_STATUS_PARTICIPATION
                                      LIMIT 50000
        ]){
            Boolean isVolunteerValid = true;
            if(String.isBlank(volunteer.Contact__r.IBAN__c)){
                isVolunteerValid = false;
            }
            if(isExportForAlreadyPaid == false && volunteer.CompensationAndExpensesPayed__c == true){
                isVolunteerValid = false;
            }
            if(isVolunteerValid == true) {
                output.isBatchNeeded = true;
                break;
            }
        }
    }
    if(output.isBatchNeeded == true) {
        output.jobId = Database.executeBatch(new BulkXmlGenerator(inputs), 200);
    }
    else{
        output.message = System.Label.EventErrorLabel;
    }
    results.add(output);
    return results;
    }
}