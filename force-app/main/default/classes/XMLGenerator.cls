public with sharing class XMLGenerator {
    public class FlowInput {
        @InvocableVariable public Id eventId;
        @InvocableVariable public Boolean isCompensationAndExpensesStatusChanged;
        @InvocableVariable public Boolean isExportForAlreadyPaid;
    }
    public class FlowOutput {
        @InvocableVariable public String message;
        @InvocableVariable public Boolean isBatchNeeded = false;
    }

    @InvocableMethod
    public static List<FlowOutput> generateXML(List<FlowInput> inputs) {
        List<FlowOutput> results = new List<FlowOutput>();
        FlowOutput output = new FlowOutput();
        Id eventId = inputs[0].eventId;
        Boolean isCompensationAndExpensesStatusChanged = inputs[0].isCompensationAndExpensesStatusChanged;
        Boolean isExportForAlreadyPaid = inputs[0].isExportForAlreadyPaid;
        Boolean isLeaderValid = true;
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
            if(String.isBlank(shift.ShiftLeader__r.IBAN__c)) isLeaderValid = false;
            if(isExportForAlreadyPaid == false && shift.CompensationAndExpensesPayed__c == true) isLeaderValid = false;
            if(isLeaderValid) {
                output.isBatchNeeded = true;
                break;
            }
        }
        if(output.isBatchNeeded == true) Database.executeBatch(new BulkXmlGenerator(inputs), 200);
        else output.message = System.Label.EventErrorLabel;
        results.add(output);
        return results;
    }
}