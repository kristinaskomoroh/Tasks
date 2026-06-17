public with sharing class BulkXMLGenerator implements Queueable {
    private List<XMLGenerator.FlowInput> inputs;

    public BulkXMLGenerator(List<XMLGenerator.FlowInput> inputs){
        this.inputs = inputs;
    }

    public void execute(QueueableContext context){
        List<ContentVersion> outputFiles = new List<ContentVersion>();
        List<Volunteer__c> updatedVolunteers = new List<Volunteer__c>();
        List<VolunteerShift__c> updatedShifts = new List<VolunteerShift__c>();

        try{
            Set<Id> eventId = new Set<Id>();
            for (XMLGenerator.FlowInput input : inputs){
                eventId.add(input.eventId);
            }
            Map<Id, Event__c> eventMap = new Map<Id, Event__c>([
                SELECT Id, Name,
                    (SELECT Id, Name, ShiftLeader__r.IBANAccountOwner__c, ShiftLeader__r.IBAN__c,
                            IndividualCompensationShiftLeader__c, DefaultCompensation__c,
                            CompensationTotalShiftLeader__c, ShiftLeader__c, ShiftLeader__r.Name, CompensationAndExpensesPayed__c
                    FROM VolunteerShifts__r
                    WHERE IsIBANPayment__c = true
                    AND CompensationTotalShiftLeader__c != null
                    AND CompensationTotalShiftLeader__c > 0
                    AND ShiftLeader__r.IBANAccountOwner__c != null
                    )
                FROM Event__c
                WHERE Id IN :eventId
            ]);
            Map<Id, List<Volunteer__c>> shiftToVolunteersMap = new Map<Id, List<Volunteer__c>>();
            for (Volunteer__c vol : [
                SELECT Id, Name, VolunteerShift__c, IndividualCompensationTotal__c, CompensationAndExpensesPayed__c, COntact__r.Name, Contact__r.IBAN__c, Contact__r.IBANAccountOwner__c
                FROM Volunteer__c
                WHERE VolunteerShift__r.Event__c IN :eventId
                AND VolunteerShift__r.IsIBANPayment__c = true
                AND IndividualCompensationTotal__c != null
                AND IndividualCompensationTotal__c > 0
                AND Contact__r.IBANAccountOwner__c != null
                AND Status__c = 'Participation'
                ]){
                if(vol.Contact__r != null && vol.Contact__r.IBAN__c != null){
                    if (!shiftToVolunteersMap.containsKey(vol.VolunteerShift__c)) {
                        shiftToVolunteersMap.put(vol.VolunteerShift__c, new List<Volunteer__c>());
                    }
                    shiftToVolunteersMap.get(vol.VolunteerShift__c).add(vol);
                    }
                }
            
            List<String> orderedXmlStrings = new List<String>();
                for(XMLGenerator.FlowInput input: inputs) {
                    Event__c currentEvent = eventMap.get(input.eventId);
                    String xmlString = buildXML(currentEvent, shiftToVolunteersMap, input.toggleFirst, input.toggleSecond, updatedVolunteers, updatedShifts);
                    orderedXmlStrings.add(xmlString);   
                    if(currentEvent != null){
                        ContentVersion cv = new ContentVersion();
                        cv.Title = 'Export_Event_' + currentEvent.Name + '_' + Datetime.now().format('yyyyMMdd');
                        cv.PathOnClient = 'Export_Event.xml';
                        cv.VersionData = Blob.valueOf(xmlString);
                        cv.FirstPublishLocationId = currentEvent.Id;
                        outputFiles.add(cv);
                    }
                }
                if(!outputFiles.isEmpty()){
                    insert outputFiles;
                }
                if(!updatedVolunteers.isEmpty()){
                    update updatedVolunteers;
                }
                if(!updatedShifts.isEmpty()){
                    update updatedShifts;
                }
        }catch(Exception e){ 
            System.debug('Background generation error: ' + e.getMessage());
        }       
    }

    private static String buildXML(Event__c currentEvent, Map<Id, List<Volunteer__c>> shiftToVolunteersMap,
    Boolean toggleFirst, Boolean toggleSecond, List<Volunteer__c> updatedVolunteers, List<VolunteerShift__c> updatedShifts){
        String xmlString = '';
        if(currentEvent != null){
            DOM.Document doc = new DOM.Document();

            Export_Config__mdt config = Export_Config__mdt.getInstance('SEPA_Payments');
            String mainNs = config.Main_Namespace__c.trim();
            String xsiNs = config.XSI_namespace__c.trim();
            String schemaLocationValue = config.Schema_location_value__c.trim();

            dom.XmlNode rootNode = doc.createRootElement('Document', mainNs, '');

            rootNode.setNamespace('xsi', xsiNs);
            rootNode.setAttributeNs('schemaLocation', schemaLocationValue, xsiNs, null);

            dom.XmlNode firstNode = rootNode.addChildElement('CstmrCdtTrfInitn', mainNs, '');
            dom.XmlNode grpHdrNode = firstNode.addChildElement('GrpHdr', mainNs, '');
            grpHdrNode.addChildElement('MsgId', mainNs, '').addTextNode(currentEvent.Id + '_' + Datetime.now().format('HHmmss'));
            grpHdrNode.addChildElement('CreDtTm', mainNs, '').addTextNode(Datetime.now().format('yyyyMMdd'));

            Set<Id> processedContacts = new Set<Id>();
            Integer totalCount = 0;
            for(VolunteerShift__c shift : currentEvent.VolunteerShifts__r) {
                if(toggleSecond == false && shift.CompensationAndExpensesPayed__c == true) continue;
                if(shift.ShiftLeader__c != null && !processedContacts.contains(shift.ShiftLeader__c)) {
                    processedContacts.add(shift.ShiftLeader__c);
                    totalCount += 1;
                }
        
                List<Volunteer__c> volunteers = shiftToVolunteersMap.get(shift.Id);
                if(volunteers != null) {
                    for(Volunteer__c vol: volunteers){
                        if(toggleSecond == false && vol.CompensationAndExpensesPayed__c == true) continue;
                        if(vol.Contact__c != null) {
                            totalCount += 1;
                        }
                    }
                }
            }
            grpHdrNode.addChildElement('NbOfTxs', mainNs, '').addTextNode(String.valueOf(totalCount));

            Decimal totalCompensations = 0;
            for(VolunteerShift__c shift: currentEvent.VolunteerShifts__r){
                if(toggleFirst == true){
                    shift.CompensationAndExpensesPayed__c = true;
                    updatedShifts.add(shift);
                }
                if(toggleSecond == false && shift.CompensationAndExpensesPayed__c == true) continue;
                if(shift.DefaultCompensation__c != null && shift.IndividualCompensationShiftLeader__c > 0){
                    totalCompensations += shift.CompensationTotalShiftLeader__c;
                }
                List<Volunteer__c> volunteers = shiftToVolunteersMap.get(shift.Id);
                if(volunteers != null) {
                    for(Volunteer__c vol: volunteers){
                        if(toggleSecond == false && vol.CompensationAndExpensesPayed__c == true) continue;
                        if(toggleFirst == true){
                            vol.CompensationAndExpensesPayed__c = true;
                            updatedVolunteers.add(vol);
                        }
                        totalCompensations += vol.IndividualCompensationTotal__c;
                    }
                }
            }
            grpHdrNode.addChildElement('CtrlSum', mainNs, '').addTextNode(String.valueOf(totalCompensations));
            dom.XmlNode initgPty = grpHdrNode.addChildElement('InitgPty', mainNs, '');
            initgPty.addChildElement('Nm', mainNs, '').addTextNode('Company Name');
            dom.XmlNode pmtInf = firstNode.addChildElement('PmtInf', mainNs, '');
            pmtInf.addChildElement('PmtInfId', mainNs, '').addTextNode(currentEvent.Id + '_' + Datetime.now().format('HHmmss'));
            pmtInf.addChildElement('PmtMtd', mainNs, '').addTextNode('TRF');
            pmtInf.addChildElement('BtchBookg', mainNs, '').addTextNode('true');
            pmtInf.addChildElement('NbOfTxs', mainNs, '').addTextNode(String.valueOf(totalCount));
            pmtInf.addChildElement('CtrlSum', mainNs, '').addTextNode(String.valueOf(totalCompensations));
            dom.XmlNode pmtTpInf = pmtInf.addChildElement('PmtTpInf', mainNs, '');
            dom.XmlNode svcLvl = pmtTpInf.addChildElement('SvcLvl', mainNs, '');
            svcLvl.addChildElement('Cd', mainNs, '').addTextNode('SEPA');
            pmtInf.addChildElement('ReqdExctnDt', mainNs, '').addTextNode(Datetime.now().format('yyyyMMdd'));
            dom.XmlNode dbtr = pmtInf.addChildElement('Dbtr', mainNs, '');
            dom.XmlNode nm = dbtr.addChildElement('Nm', mainNs, '').addTextNode('Company Name');
            dom.XmlNode dbtrAcct = pmtInf.addChildElement('DbtrAcct', mainNs, '');
            dom.XmlNode id = dbtrAcct.addChildElement('Id', mainNs, '');
            id.addChildElement('IBAN', mainNs, '').addTextNode('IBAN');
            dom.XmlNode dbtrAgt = pmtInf.addChildElement('DbtrAgt', mainNs, '');
            dom.XmlNode finInstnId = dbtrAgt.addChildElement('FinInstnId', mainNs, '');
            finInstnId.addChildElement('BIC', mainNs, '').addTextNode('BIC');
            pmtInf.addChildElement('ChrgBr', mainNs, '').addTextNode('SLEV');
            for (VolunteerShift__c shift: currentEvent.VolunteerShifts__r){
                if(toggleSecond == false && shift.CompensationAndExpensesPayed__c == true) continue;
                String safeShiftName = newString(shift.ShiftLeader__r.Name);
                String finalShiftName = System.Label.PrefixForShiftLeaders + ' ' + safeShiftName;
                addCommonBlocksToXML(pmtInf, mainNs, shift.ShiftLeader__c, shift.CompensationTotalShiftLeader__c, shift.ShiftLeader__r.IBANAccountOwner__c, shift.ShiftLeader__r.IBAN__c, finalShiftName);
                List<Volunteer__c> volunteers = shiftToVolunteersMap.get(shift.Id);
                    if(volunteers != null) {
                        for(Volunteer__c vol: volunteers){
                            if(toggleSecond == false && vol.CompensationAndExpensesPayed__c == true) continue;
                            String finalVolName = System.Label.PrefixForVolunteers + ' ' + vol.Name;
                            addCommonBlocksToXML(pmtInf, mainNs, vol.Name, vol.IndividualCompensationTotal__c, vol.Contact__r.IBANAccountOwner__c, vol.Contact__r.IBAN__c, finalVolName);
                        }
                    }
                }
            xmlString = doc.toXmlString(); 
        }
        return xmlString;
    }
    

    private static void addCommonBlocksToXML(dom.XmlNode pmtInf, String mainNs, String value, Decimal compensation, String IBANAccount, String iban, String name){
        dom.XmlNode cdtTrfTxInf = pmtInf.addChildElement('CdtTrfTxInf', mainNs, '');
        dom.XmlNode pmtId = cdtTrfTxInf.addChildElement('PmtId', mainNs, '');
        pmtId.addChildElement('EndToEndId', mainNs, '').addTextNode(value);
        dom.XmlNode amt = cdtTrfTxInf.addChildElement('Amt', mainNs, '');
        amt.addChildElement('InstdAmt', mainNs, '').addTextNode('Ccy="EUR">' + compensation);
        dom.XmlNode cdtr = cdtTrfTxInf.addChildElement('Cdtr', mainNs, '');
        cdtr.addChildElement('Nm', mainNs, '').addTextNode(IBANAccount);
        dom.XmlNode cdtrAcct = cdtTrfTxInf.addChildElement('CdtrAcct', mainNs, '');
        cdtrAcct.addChildElement('Id', mainNs, '').addTextNode(iban);
        dom.XmlNode rmtInf = cdtTrfTxInf.addChildElement('RmtInf', mainNs, '');
        rmtInf.addChildElement('Ustrd', mainNs, '').addTextNode(name);
    }

    private static String newString(String input) {
        if(String.isBlank(input)) return input;
        List<Char_Replacement__mdt> characters = Char_Replacement__mdt.getAll().values();
        String cleanText = input;
        for(Char_Replacement__mdt charReplace: characters){
            if(charReplace.Source__c != null){
                String replacement = charReplace.Target_character__c != null ? charReplace.Target_character__c : '';
                cleanText = cleanText.replace(charReplace.Source__c, replacement);
            } 
        }
    return cleanText;
    }
}
    