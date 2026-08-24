public with sharing class BulkXMLGenerator implements Database.Batchable<SObject>, Database.Stateful {
    private List<XMLGenerator.FlowInput> inputs;
    private List<String> globalXmlChunks = new List<String>();

    private List<ContentVersion> outputFiles = new List<ContentVersion>();

    private Integer totalCount = 0;
    private Decimal totalCompensations = 0;

    private List<VolunteerShift__c> updatedShifts = new List<VolunteerShift__c>();
    private List<Volunteer__c> updatedVolunteers = new List<Volunteer__c>();

    private Set<Id> processedGroupIds = new Set<Id>();

    private static Map<String, String> replacements = new Map<String, String>();
    static{
        for(Char_Replacement__mdt charReplace: Char_Replacement__mdt.getAll().values()){
            if(charReplace.Source__c != null){
                String source = charReplace.Source__c == '[space]' ? ' ' : charReplace.Source__c;
                String target = charReplace.Target_character__c != null ? charReplace.Target_character__c : '';
                replacements.put(source, target);
            }
        }
    }

    public BulkXMLGenerator(List<XMLGenerator.FlowInput> inputs){
        this.inputs = inputs;
    }

    public Database.QueryLocator start(Database.BatchableContext bc){
        Set<Id> eventId = new Set<Id>();
        for (XMLGenerator.FlowInput input : inputs){
            eventId.add(input.eventId);
        }
        return Database.getQueryLocator([SELECT Name,
                                                IndividualCompensationTotal__c,
                                                CompensationAndExpensesPayed__c,
                                                Contact__r.IBAN__c,
                                                Contact__r.IBANAccountOwner__c,
                                                Status__c,
                                                VolunteerShift__c,
                                                VolunteerShift__r.Name,
                                                VolunteerShift__r.Event__c,
                                                VolunteerShift__r.IsIBANPayment__c,
                                                VolunteerShift__r.ShiftLeader__r.IBAN__c,
                                                VolunteerShift__r.CompensationTotalShiftLeader__c,
                                                VolunteerShift__r.ShiftLeader__r.IBANAccountOwner__c,
                                                VolunteerShift__r.CompensationAndExpensesPayed__c
                                        FROM Volunteer__c
                                        WHERE VolunteerShift__r.Event__c IN :eventId
                                        ORDER BY VolunteerShift__c
                                        ]);
    }

    public void execute(Database.BatchableContext bc, List<Volunteer__c> scope){
        try{
            Boolean isCompensationAndExpensesStatusChanged = false;
            Boolean isExportForAlreadyPaid = false;
            if(this.inputs != null) {
                isCompensationAndExpensesStatusChanged = this.inputs[0].isCompensationAndExpensesStatusChanged;
                isExportForAlreadyPaid = this.inputs[0].isExportForAlreadyPaid;
            }
            //for(Integer i = 0; i < 10; i++){
                for(Volunteer__c vol: scope){
                    if(!processedGroupIds.contains(vol.VolunteerShift__c)) {
                        processedGroupIds.add(vol.VolunteerShift__c);
                        Boolean isCurrentGroupValid = true;
                        if(String.isBlank(vol.VolunteerShift__r.ShiftLeader__r.IBAN__c) ||
                                        vol.VolunteerShift__r.IsIBANPayment__c == false ||
                                        vol.VolunteerShift__r.CompensationTotalShiftLeader__c == null ||
                                        vol.VolunteerShift__r.CompensationTotalShiftLeader__c <= 0 ||
                                        String.isBlank(vol.VolunteerShift__r.ShiftLeader__r.IBANAccountOwner__c)
                                        ) {
                            isCurrentGroupValid = false;
                        }
                        if(isCompensationAndExpensesStatusChanged == true){
                            vol.VolunteerShift__r.CompensationAndExpensesPayed__c = true;
                            updatedShifts.add(vol.VolunteerShift__r);
                        }

                        Boolean shouldExportLeader = isCurrentGroupValid == true
                                                                        && !(isExportForAlreadyPaid == false
                                                                        && vol.VolunteerShift__r.CompensationAndExpensesPayed__c == true
                                                                        );
                        if(shouldExportLeader == true){
                            String safeShiftName = newString(vol.VolunteerShift__r.Name);
                            String finalShiftName = System.Label.PrefixForShiftLeaders + safeShiftName;
                            String shiftLeaderXml = addCommonBlocksToXML(
                                vol.VolunteerShift__c,
                                vol.VolunteerShift__r.CompensationTotalShiftLeader__c,
                                vol.VolunteerShift__r.ShiftLeader__r.IBANAccountOwner__c,
                                vol.VolunteerShift__r.ShiftLeader__r.IBAN__c,
                                finalShiftName
                            );
                            if(vol.VolunteerShift__r.ShiftLeader__c != null){
                                totalCount += 1;
                            }
                            totalCompensations += vol.VolunteerShift__r.CompensationTotalShiftLeader__c;
                            globalXmlChunks.add(shiftLeaderXml);
                        }
                    }
                    Boolean isVolunteerValid = true;
                    if(isExportForAlreadyPaid == false && vol.CompensationAndExpensesPayed__c == true) {
                        isVolunteerValid = false;
                    }
                    if(vol.IndividualCompensationTotal__c == null ||
                       vol.IndividualCompensationTotal__c <= 0 ||
                        String.isBlank(vol.Contact__r.IBAN__c) ||
                        String.isBlank(vol.Contact__r.IBANAccountOwner__c) ||
                        vol.Status__c != DataHelper.VOLUNTEER_STATUS_PARTICIPATION ||
                        vol.VolunteerShift__r.IsIBANPayment__c == false)
                    {
                        isVolunteerValid = false;
                    }
                    if(isCompensationAndExpensesStatusChanged == true){
                        vol.CompensationAndExpensesPayed__c = true;
                        updatedVolunteers.add(vol);
                    }
                    if(isVolunteerValid == true){
                        totalCount += 1;
                        totalCompensations += vol.IndividualCompensationTotal__c;
                        String safeVolName = newString(vol.VolunteerShift__r.Name);
                        String finalVolName = System.Label.PrefixForVolunteers + safeVolName;
                        String volunteerXml = addCommonBlocksToXML(
                            vol.Name,
                            vol.IndividualCompensationTotal__c,
                            vol.Contact__r.IBANAccountOwner__c,
                            vol.Contact__r.IBAN__c,
                            finalVolName
                        );
                        globalXmlChunks.add(volunteerXml);
                    }
                }
            //}
            if(!updatedShifts.isEmpty()){
                update updatedShifts;
            }
            if(!updatedVolunteers.isEmpty()){
                update updatedVolunteers;
            }
        }catch(Exception e){
            System.debug(System.Label.GenerationErrorLabel + e.getMessage());
        }
    }

    public void finish(Database.BatchableContext bc){
        Id currentEventId;
        Boolean isCompensationAndExpensesStatusChanged = false;
        Boolean isExportForAlreadyPaid = false;
        if(this.inputs != null){
            currentEventId = inputs[0].eventId;
            isCompensationAndExpensesStatusChanged = inputs[0].isCompensationAndExpensesStatusChanged;
            isExportForAlreadyPaid = inputs[0].isExportForAlreadyPaid;
        }
        try{
            List<VolunteerShift__c> emptyShifts = [
                SELECT Id,
                    Name,
                    CompensationTotalShiftLeader__c,
                    ShiftLeader__r.IBAN__c,
                    ShiftLeader__r.IBANAccountOwner__c
                FROM VolunteerShift__c
                WHERE Event__c = :currentEventId
                AND Id NOT IN :processedGroupIds
                AND IsIBANPayment__c = true
                AND CompensationTotalShiftLeader__c > 0
                AND CompensationTotalShiftLeader__c != null
                AND ShiftLeader__r.IBANAccountOwner__c != null
            ];
            for (VolunteerShift__c emptyShift : emptyShifts) {
                if(isCompensationAndExpensesStatusChanged == true){
                    emptyShift.CompensationAndExpensesPayed__c = true;
                    updatedShifts.add(emptyShift);
                }
                if (String.isNotBlank(emptyShift.ShiftLeader__r.IBAN__c) &&
                                    !(isExportForAlreadyPaid == false &&
                                    emptyShift.CompensationAndExpensesPayed__c == true)){
                    String safeShiftName = newString(emptyShift.Name);
                    String finalShiftName = System.Label.PrefixForShiftLeaders + safeShiftName;
                    String emptyShiftXml = addCommonBlocksToXML(
                        emptyShift.Id,
                        emptyShift.CompensationTotalShiftLeader__c,
                        emptyShift.ShiftLeader__r.IBANAccountOwner__c,
                        emptyShift.ShiftLeader__r.IBAN__c,
                        finalShiftName
                    );
                    globalXmlChunks.add(emptyShiftXml);
                    if(emptyShift.ShiftLeader__c != null){
                        totalCount += 1;
                    }
                    totalCompensations += emptyShift.CompensationTotalShiftLeader__c;
                }
            }
        }catch(Exception e){
            System.debug(System.Label.GenerationErrorLabel + e.getMessage());
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
        grpHdrNode.addChildElement('MsgId', mainNs, '').addTextNode(currentEventId + Datetime.now().format('HHmmss'));
        grpHdrNode.addChildElement('CreDtTm', mainNs, '').addTextNode(Datetime.now().format('yyyyMMdd'));
        grpHdrNode.addChildElement('NbOfTxs', mainNs, '').addTextNode(String.valueOf(this.totalCount));
        grpHdrNode.addChildElement('CtrlSum', mainNs, '').addTextNode(String.valueOf(this.totalCompensations));
        dom.XmlNode initgPty = grpHdrNode.addChildElement('InitgPty', mainNs, '');
        initgPty.addChildElement('Nm', mainNs, '').addTextNode('Company Name');
        dom.XmlNode pmtInf = firstNode.addChildElement('PmtInf', mainNs, '');
        pmtInf.addChildElement('PmtInfId', mainNs, '').addTextNode(currentEventId + Datetime.now().format('HHmmss'));
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

        ContentVersion cv = new ContentVersion();
        cv.Title = 'Export_Event_' + '_' + Datetime.now().format('yyyyMMdd');
        cv.PathOnClient = 'Export_Event.xml';
        cv.VersionData = Blob.valueOf(finalXmlDocument);
        cv.Description = String.valueOf(this.totalCount) + '/' + String.valueOf(this.totalCompensations);
        cv.FirstPublishLocationId = currentEventId;
        outputFiles.add(cv);
        if(!outputFiles.isEmpty()){
            insert outputFiles;
        }
        cv = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
        Id myContentDocumentId = cv.ContentDocumentId;

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTargetObjectId(UserInfo.getUserId());
        mail.setSaveAsActivity(false);
        mail.setSubject(System.Label.EmailSubjectLabel);
        String fileUrl = URL.getOrgDomainUrl().toExternalForm() + '/lightning/r/ContentDocument/' + myContentDocumentId + '/view';
        String formattedBody = System.Label.EmailBodyLabel.replace('{0}', fileUrl);
        mail.setPlainTextBody(formattedBody);
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
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
        String cleanText = input;
        for(String sourceForLook: replacements.keySet()){
            cleanText = cleanText.replace(sourceForLook, replacements.get(sourceForLook));
        }
    return cleanText;
    }
}
