public with sharing class SoqlController {
    @AuraEnabled(cacheable=true)
    public static List<Map<String,String>> getAllObjects(){
        List<Map<String,String>> objects = new List<Map<String,String>>();
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        for(String objName: gd.keySet() ){
            Schema.DescribeSObjectResult res = gd.get(objName).getDescribe();
           if (res.isQueryable() && res.isAccessible() && !res.isCustomSetting()) {
                if (res.isCustom() || (res.isSearchable() && res.isUpdateable() && res.isCreateable())) {
                Map<String,String> objMap = new Map<String,String>();
                objMap.put('label', res.getLabel());
                objMap.put('value', res.getName());
                objects.add(objMap);
                }
            }
        }
    return objects;
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getObjectFields(String objectName) {
    List<Map<String, String>> options = new List<Map<String, String>>();
        Schema.SObjectType sobjType = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult describe = sobjType.getDescribe();
        Map<String, Schema.SObjectField> fieldsMap = describe.fields.getMap();
        Set<String> excludeFields = new Set<String>{                 
            'IsDeleted',         
            'CreatedDate',       
            'CreatedById',        
            'LastModifiedDate',   
            'LastModifiedById',   
            'SystemModstamp',     
            'LastViewedDate',     
            'LastReferencedDate'
            };
        for (Schema.SObjectField fld : fieldsMap.values()) {
            Schema.DescribeFieldResult f = fld.getDescribe();
            String fieldName = f.getName();
            if (f.isAccessible() && !excludeFields.contains(fieldName)) {
                if (fieldName.contains('SystemModstamp')) continue;
                Map<String, String> option = new Map<String, String>();
                option.put('label', f.getLabel());
                option.put('value', f.getName());
                options.add(option);
            }
        }
    return options;
    }

    @AuraEnabled
    public static List<SObject> executeSOQL(String query){
        return Database.query(query);
    }
}
