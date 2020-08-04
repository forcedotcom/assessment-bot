public with sharing class AssessmentDefinitionImportExportService {

    private static final String RECORDS_KEY = 'records';
    private static final String ID_KEY = 'Id';
    private static final String NAME_KEY = 'Name';
    private static final String CUSTOM_SUFFIX = '__c';
    
    private static final Set<String> OBJECT_KEYS_FILTER = new Set<String> {
        'attributes',
        'done',
        'totalSize',
        'RecordTypeId'};

    private static final Schema.SObjectType TOP_SOBJECT_TYPE = Assessment_Definition__c.SObjectType;
    private static final Schema.SObjectField TOP_SOBJECT_EXPORT_FILTER_FIELD = Assessment_Definition__c.Assessment_Definition_Id__c;

    private static final List<Schema.SObjectType> OBSERVABLE_TYPES_ORDER = new List<Schema.SObjectType> {
        Assessment_Definition__c.SObjectType,
        Assessment_Definition_Signal__c.SObjectType,
        Assessment_Definition_Item__c.SObjectType,
        Assessment_Definition_Item_Choice__c.SObjectType,
        Assessment_Definition_Decision_Signal__c.SObjectType,
        Assessment_Definition_Item_Event__c.SObjectType
    };

    // Boolean value indicates if we care about the Name field for the observable type
    // Not doing this check dynamically to avoid field map iteration for non-custom fields
    private static final Map<Schema.SObjectType, Boolean> OBSERVABLE_TYPES = new Map<Schema.SObjectType, Boolean> {
        Assessment_Definition__c.SObjectType => true,
        Assessment_Definition_Signal__c.SObjectType => true,
        Assessment_Definition_Item__c.SObjectType => true,
        Assessment_Definition_Item_Choice__c.SObjectType => false,
        Assessment_Definition_Decision_Signal__c.SObjectType => false,
        Assessment_Definition_Item_Event__c.SObjectType => false
    };

    public static void importDefinition(String importJSON) {
        if (importJSON == null) {
            return;
        }
        Map<String,Object> importMap = (Map<String,Object>)JSON.deserializeUntyped(importJSON);
        
        Map<String, SObject> importedObjects = new Map<String, SObject>();
        for (Schema.SObjectType t : OBSERVABLE_TYPES_ORDER) {
            importSObject(importMap, importedObjects, t); 
        }
    }

    public static String exportDefinition(String selectedDefinition) {
        Set<String> subSelects = new Set<String>();
        Schema.DescribeSObjectResult describe = TOP_SOBJECT_TYPE.getDescribe();
            List<Schema.ChildRelationship> childRelationships = describe.getChildRelationships();
            for (Schema.ChildRelationship cr : childRelationships) {
                if (OBSERVABLE_TYPES.containsKey(cr.getChildSObject())) {
                    Set<String> stdFields = new Set<String>{ID_KEY};
                    if (OBSERVABLE_TYPES.get(cr.getChildSObject())) {
                        stdFields.add(NAME_KEY);
                    }
                    List<String> childRelationshipFields = getCustomFields(stdFields, cr.getChildSObject());
                    subSelects.add('(select '+String.join(childRelationshipFields, ',')+' from '+cr.getRelationshipName()+')');
                }
            }
        
        List<String> selectFields = getCustomFields(new Set<String>{ID_KEY, NAME_KEY}, TOP_SOBJECT_TYPE);
        selectFields.addAll(subSelects);
        Schema.DescribeFieldResult fieldDescribe = TOP_SOBJECT_EXPORT_FILTER_FIELD.getDescribe();
        
        String soql = 'select '+String.join(selectFields, ',')+ ' from '+describe.getName()+' where '+fieldDescribe.getName()+' = :selectedDefinition';
        List<sObject> defs = Database.query(soql);
        if (defs.isEmpty()) {
            return null;
        }
        Object defJsonMap = JSON.deserializeUntyped(JSON.serialize(defs.get(0)));
        removeFilteredKeys(defJsonMap); 
        return JSON.serializePretty(defJsonMap);
    }

    public static List<SelectOption> getDefinitionOptions() {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeSObjectResult describe = TOP_SOBJECT_TYPE.getDescribe();
        Schema.DescribeFieldResult fieldDescribe = TOP_SOBJECT_EXPORT_FILTER_FIELD.getDescribe();
        String soql = 'select Name,'+fieldDescribe.getName()+ ' from '+describe.getName()+' order by CreatedDate desc limit 500';
        List<SObject> records = Database.query(soql);
        for (SObject so : records) {
            options.add(new SelectOption((String)so.get(fieldDescribe.getName()), (String)so.get(NAME_KEY)));
        }
        return options;
    }

    private static void importSObject(Map<String,Object> importMap, Map<String, SObject> importedObjects, Schema.SObjectType sobjectType) {
        String recordsMapKey = null;
        if (sobjectType != TOP_SOBJECT_TYPE) {
            Schema.DescribeSObjectResult describe = TOP_SOBJECT_TYPE.getDescribe();
            List<Schema.ChildRelationship> childRelationships = describe.getChildRelationships();
            for (Schema.ChildRelationship cr : childRelationships) {
                if (cr.getChildSObject() == sobjectType) {
                    recordsMapKey = cr.getRelationshipName();
                   	break;
                }
            }
        }

        if (recordsMapKey == null) {
            Map<String, Object> topLevelObj = new Map<String, Object>();
            for (String key : importMap.keySet()){
                if (importMap.get(key) instanceof Map<String, Object>){
                    continue;
                }
                topLevelObj.put(key, importMap.get(key));
            }
            fillSObject(topLevelObj, importedObjects, sobjectType);
        } else {
            Map<String, Object> topLevelObj = (Map<String, Object>)importMap.get(recordsMapKey);
            if (topLevelObj == null) return;
            List<Object> recordsList = (List<Object>)topLevelObj.get(RECORDS_KEY);
            if (recordsList == null) return;
            for(Object obj : recordsList) {
                fillSObject((Map<String, Object>)obj, importedObjects, sobjectType);
            }
        }
        insertNewRecords(importedObjects);
    }

    private static void fillSObject(Map<String, Object> recordMap, Map<String, SObject> importedObjects, Schema.SObjectType sobjectType) {
        SObject so = sobjectType.newSObject();
        String importId = null;
        for(String key : recordMap.keySet()) {
            Object value = recordMap.get(key);
            if (key == ID_KEY) {
                importId = (String)value;
                continue;
            }
            if (value instanceof Id) {
                SObject sobj = importedObjects.get((String)value);
                if (sobj != null) {
                    value = sobj.Id;
                }
            }
            so.put(key, value);
        }
        importedObjects.put(importId, so);
    }
    
    private static void insertNewRecords(Map<String, SObject> importedObjects) {
        List<SObject> newRecords = new List<SObject>();
        for (SObject so : importedObjects.values()) {
            if (so.Id == null) {
                newRecords.add(so);
            }
        }
        if (newRecords.isEmpty()){
            return;
        }
        insert newRecords;
        // Clear other fields from heap
        for (SObject so : newRecords) {
            Id sobjectId = Id.valueOf(so.Id);
            so.clear();
            so.Id = sobjectId;
        }
    }

    private static List<String> getCustomFields(Set<String> standardFields, Schema.SObjectType sObjectType) {
        List<String> result = new List<String>();
        result.addAll(standardFields);
        Schema.DescribeSObjectResult describe = sObjectType.getDescribe();
        Map<String, Schema.SObjectField> fieldsMap = describe.fields.getMap();
        for(String fieldName : fieldsMap.keySet()) {
            if (!fieldName.endsWith(CUSTOM_SUFFIX)) { 
            	continue;
            }
            Schema.SObjectField field = fieldsMap.get(fieldName);
            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
            if (!fieldDescribe.isCalculated() && fieldDescribe.isCreateable()) {
                result.add(fieldName);
            }
        }
        return result;
    }

    private static void removeFilteredKeys(Object defJsonMap) {
        if (defJsonMap instanceof Map<String, Object>){
            Map<String, Object> objectMap = (Map<String, Object>)defJsonMap;
            for (String key : objectMap.keySet()) {
                if(OBJECT_KEYS_FILTER.contains(key)){
                    objectMap.remove(key);
                } else {
                	removeFilteredKeys(objectMap.get(key));
                }
            }
        } else if (defJsonMap instanceof List<Object>) {
            for (Object obj : (List<Object>)defJsonMap) {
                removeFilteredKeys(obj);
            }
        }
    }

}
