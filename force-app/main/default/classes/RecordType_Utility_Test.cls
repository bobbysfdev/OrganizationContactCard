@isTest
public class RecordType_Utility_Test {

    @isTest static void testingAll(){
        list<RecordType> listAllRecordTypes = [Select Id, SobjectType, DeveloperName From RecordType WHERE IsActive = true];
        RecordType testRecordType = listAllRecordTypes[0];
        list<RecordType> returnListTest = RecordType_Utility.getActiveRecTypes(testRecordType.SObjectType);
        Id recordTypeId = RecordType_Utility.getId(testRecordType.SObjectType,testRecordType.DeveloperName);
        list<selectOption> typeOptions = RecordType_Utility.getRecordTypeOptions(testRecordType.SObjectType);

    }
    
    
}