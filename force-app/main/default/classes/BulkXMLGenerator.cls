public with sharing class BulkXMLGenerator implements Database.Batchable<SObject>, Database.Stateful {
    private List<XMLGenerator.FlowInput> inputs;
    private List<String> globalXmlChunks = new List<String>();

    private Map<Id, List<Volunteer__c>> shiftToVolunteersMap = new Map<Id, List<Volunteer__c>>();
    private List<Volunteer__c> updatedVolunteers = new List<Volunteer__c>();
    private List<VolunteerShift__c> updatedShifts = new List<VolunteerShift__c>();
    private List<ContentVersion> outputFiles = new List<ContentVersion>();

    private Set<Id> processedContacts = new Set<Id>();
    private Integer totalCount = 0;
    private Decimal totalCompensations = 0;

    public BulkXMLGenerator(List<XMLGenerator.FlowInput> inputs){
        this.inputs = inputs;
    }

    public Database.QueryLocator start(Database.BatchableContext bc){
        Set<Id> eventId = new Set<Id>();
        for (XMLGenerator.FlowInput input : inputs){
            eventId.add(input.eventId);
        }
        return Database.getQueryLocator([SELECT Id, Name, ShiftLeader__r.IBANAccountOwner__c, ShiftLeader__r.IBAN__c,
                                                IndividualCompensationShiftLeader__c, DefaultCompensation__c,
                                                CompensationTotalShiftLeader__c, ShiftLeader__c, ShiftLeader__r.Name, CompensationAndExpensesPayed__c
                                        FROM VolunteerShift__c
                                        WHERE Event__c IN: eventId
                                        AND IsIBANPayment__c = true
                                        AND CompensationTotalShiftLeader__c != null
                                        AND CompensationTotalShiftLeader__c > 0
                                        AND ShiftLeader__r.IBANAccountOwner__c != null]);
    }

    public void execute(Database.BatchableContext bc, List<VolunteerShift__c> scope){
        try{
            Set<Id> shiftIds = new Set<Id>();
            for(VolunteerShift__c shift : scope) {
                shiftIds.add(shift.Id);
            }
        shiftToVolunteersMap = new Map<Id, List<Volunteer__c>>();
        for (Volunteer__c vol : [
            SELECT Id, Name, VolunteerShift__c, IndividualCompensationTotal__c, CompensationAndExpensesPayed__c, COntact__r.Name, Contact__r.IBAN__c, Contact__r.IBANAccountOwner__c
            FROM Volunteer__c
            WHERE VolunteerShift__c IN :shiftIds
            AND VolunteerShift__r.IsIBANPayment__c = true
            AND IndividualCompensationTotal__c != null
            AND IndividualCompensationTotal__c > 0
            AND Contact__r.IBANAccountOwner__c != null
            AND Status__c = 'Participation'
            ]){
            if(vol.Contact__r != null && vol.Contact__r.IBAN__c != null){
                if (!shiftToVolunteersMap.containsKey(vol.VolunteerShift__c)) {
                    this.shiftToVolunteersMap.put(vol.VolunteerShift__c, new List<Volunteer__c>());
                }
                shiftToVolunteersMap.get(vol.VolunteerShift__c).add(vol);
            }
        }
        List<String> currentScopeXml = new List<String>();
        Boolean toggleFirst = false;
        Boolean toggleSecond = false;
        if(this.inputs != null) {
            toggleFirst = this.inputs[0].toggleFirst;
            toggleSecond = this.inputs[0].toggleSecond;
        }
        for(Integer i = 0; i < 10; i++){
            for(VolunteerShift__c shift: scope){
                if(toggleSecond == false && shift.CompensationAndExpensesPayed__c == true) continue;
                if(shift.ShiftLeader__c != null && !processedContacts.contains(shift.ShiftLeader__c)) {
                    processedContacts.add(shift.ShiftLeader__c);
                    totalCount += 1;
                }
                if(toggleFirst == true){
                    shift.CompensationAndExpensesPayed__c = true;
                    updatedShifts.add(shift);
                }
                if(shift.DefaultCompensation__c != null && shift.IndividualCompensationShiftLeader__c > 0){
                    totalCompensations += shift.CompensationTotalShiftLeader__c;
                }

                String safeShiftName = newString(shift.ShiftLeader__r.Name);
                String finalShiftName = System.Label.PrefixForShiftLeaders + ' ' + safeShiftName;
                String shiftLeaderXml = addCommonBlocksToXML(shift.Id, shift.CompensationTotalShiftLeader__c, shift.ShiftLeader__r.IBANAccountOwner__c, shift.ShiftLeader__r.IBAN__c, finalShiftName);
                currentScopeXml.add(shiftLeaderXml);
            
                List<Volunteer__c> volunteers = shiftToVolunteersMap.get(shift.Id);
                if(volunteers != null) {
                    for(Volunteer__c vol : volunteers) {
                        if(toggleSecond == false && vol.CompensationAndExpensesPayed__c == true) continue;
                        if(vol.Contact__c != null) {
                            totalCount += 1;
                        }
                        if(toggleFirst == true){
                            vol.CompensationAndExpensesPayed__c = true;
                            updatedVolunteers.add(vol);
                        }
                        totalCompensations += vol.IndividualCompensationTotal__c;
                        String finalVolName = System.Label.PrefixForVolunteers + ' ' + vol.Name;
                        String volunteerXml = addCommonBlocksToXML(vol.Name, vol.IndividualCompensationTotal__c, vol.Contact__r.IBANAccountOwner__c, vol.Contact__r.IBAN__c, finalVolName);
                        currentScopeXml.add(volunteerXml);
                    }
                }
            }
        }
        if(!currentScopeXml.isEmpty()){
            globalXmlChunks.add(String.join(currentScopeXml, ''));
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

    public void finish(Database.BatchableContext bc){
        Id currentEventId;
        if(this.inputs != null){
            currentEventId = this.inputs[0].eventId;
        }
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
        grpHdrNode.addChildElement('MsgId', mainNs, '').addTextNode(currentEventId + '_' + Datetime.now().format('HHmmss'));
        grpHdrNode.addChildElement('CreDtTm', mainNs, '').addTextNode(Datetime.now().format('yyyyMMdd'));

        grpHdrNode.addChildElement('NbOfTxs', mainNs, '').addTextNode(String.valueOf(this.totalCount));

        grpHdrNode.addChildElement('CtrlSum', mainNs, '').addTextNode(String.valueOf(this.totalCompensations));
        dom.XmlNode initgPty = grpHdrNode.addChildElement('InitgPty', mainNs, '');
        initgPty.addChildElement('Nm', mainNs, '').addTextNode('Company Name');
        dom.XmlNode pmtInf = firstNode.addChildElement('PmtInf', mainNs, '');
        pmtInf.addChildElement('PmtInfId', mainNs, '').addTextNode(currentEventId + '_' + Datetime.now().format('HHmmss'));
        pmtInf.addChildElement('PmtMtd', mainNs, '').addTextNode('TRF');
        pmtInf.addChildElement('BtchBookg', mainNs, '').addTextNode('true');
        pmtInf.addChildElement('NbOfTxs', mainNs, '').addTextNode(String.valueOf(this.totalCount));
        pmtInf.addChildElement('CtrlSum', mainNs, '').addTextNode(String.valueOf(this.totalCompensations));
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

        pmtInf.addTextNode('Manual_String');

        String baseXmlString = doc.toXmlString(); 

        String allPeople = String.join(globalXmlChunks, '');
        String finalXmlDocument = baseXmlString.replace('Manual_String', allPeople);

        globalXmlChunks.clear();

        ContentVersion cv = new ContentVersion();
        cv.Title = 'Export_Event_' + '_' + Datetime.now().format('yyyyMMdd');
        cv.PathOnClient = 'Export_Event.xml';
        cv.VersionData = Blob.valueOf(finalXmlDocument);
        cv.FirstPublishLocationId = currentEventId;
        outputFiles.add(cv);
        if(!outputFiles.isEmpty()){
            insert outputFiles;
        }
    }

    private static String addCommonBlocksToXML(String value, Decimal compensation, String IBANAccount, String iban, String name){
        String xmlNode = 
        '<CdtTrfTxInf>' +
            '<PmtId>' +
                '<EndToEndId>' + value + '</EndToEndId>' +
            '</PmtId>' +
            '<Amt>' +
                '<InstdAmt Ccy="EUR">' + compensation + '</InstdAmt>' +
            '</Amt>' +
            '<Cdtr>' +
                '<Nm>' + IBANAccount + '</Nm>' +
            '</Cdtr>' +
            '<CdtrAcct>' +
                '<Id>' +
                    '<IBAN>' + iban + '</IBAN>' +
                '</Id>' +
            '</CdtrAcct>' +
            '<RmtInf>' +
                '<Ustrd>' + name + '</Ustrd>' +
            '</RmtInf>' +
        '</CdtTrfTxInf>';
    return xmlNode;
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