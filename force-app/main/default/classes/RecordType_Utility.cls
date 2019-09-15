global class RecordType_Utility {

    public static Map<String,Map<String,Id>> staticRecTypesMap;
    public static Map<Id,String> staticRecLabelsMap;
    public static Map<Id,String> staticRecDevNameMap;
    public static Map<String,List<RecordType>> recTypesListMap; // sObjectName,list<RecordTypes>

    // Static Methods
    public static list<RecordType> getActiveRecTypes(String objName){
        if(recTypesListMap == null) setStaticMaps();
        return recTypesListMap.get(objName);
    }

    public static list<selectOption> getRecordTypeOptions(String objName){
        if(staticRecTypesMap == null) setStaticMaps();

        list<selectOption> retList = new list<selectOption>();

        for(string v : staticRecTypesMap.get(objName).keySet()) {
            Id recId = staticRecTypesMap.get(objName).get(v);
            retList.add(new selectOption(recId, staticRecLabelsMap.get(recId)));
        }
        retList.sort();
        retList.add(0, new selectOption('','-Select a Type-'));
        return retList;
    }

    public static Id getId(String obj, String name){
        if(staticRecTypesMap == null) setStaticMaps();
        return staticRecTypesMap.get(obj).get(name);
    }

    public static void setStaticMaps(){
        recTypesListMap = new map<String,List<RecordType>>();
        staticRecTypesMap = new Map<String,Map<String,ID>>();
        staticRecLabelsMap = new Map<Id,String>();
        staticRecDevNameMap = new Map<Id,String>() ;

        for(RecordType rec : [SELECT Id, Name, DeveloperName, SObjectType FROM RecordType Where IsActive = true ORDER BY SObjectType asc]){

            if(recTypesListMap.containsKey(rec.SObjectType)){
                recTypesListMap.get(rec.SObjectType).add(rec);
            } else{
                recTypesListMap.put(rec.SObjectType, new list<RecordType>{rec});
            }

            if(staticRecTypesMap.containsKey(rec.SObjectType)){
                staticRecTypesMap.get(rec.SObjectType).put(rec.DeveloperName,rec.Id);
            } else {
                staticRecTypesMap.put(rec.SObjectType, new Map<String,ID>{rec.DeveloperName => rec.Id});
            }

            staticRecLabelsMap.put(rec.Id, rec.Name);
            staticRecDevNameMap.put(rec.Id,rec.DeveloperName);
        }
    }

}