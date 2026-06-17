public with sharing class XMLGenerator {
    public class FlowInput {
        @InvocableVariable public Id eventId;
        @InvocableVariable public Boolean toggleFirst;
        @InvocableVariable public Boolean toggleSecond;
    }

    public class FlowOutput {
        @InvocableVariable public Id contentDocumentId;
    }

    @InvocableMethod
    public static List<FlowOutput> generateXML(List<FlowInput> inputs) {
        if(inputs != null && !inputs.isEmpty()) {
            System.enqueueJob(new BulkXmlGenerator(inputs));
        }

        List<FlowOutput> outputs = new List<FlowOutput>();
        for(FlowInput input : inputs) {
            FlowOutput out = new FlowOutput();
            outputs.add(out);
        }
        return outputs;
    }
}