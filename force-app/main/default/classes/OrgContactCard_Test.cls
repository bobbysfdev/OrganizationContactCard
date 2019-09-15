@isTest
public class OrgContactCard_Test {

    private static list<Account> myAccounts = new list<Account>();
    private static list<RecordType> recList =  RecordType_Utility.getActiveRecTypes('Account');
    private static integer num = 0;

    @TestSetup
    private static void setupAccounts() {
        for(RecordType recT : recList){
            for(integer i = 0; i < 40; i++){
                if(num >= 200) break;
                Account acc = new Account();
                acc.Name = 'TestAccount'+num;
                acc.Phone = '111-111-1111';
                acc.AccountEmail__c = 'johnDoe'+num+'@gmail.com';
                acc.RecordTypeId = recT.Id;
                myAccounts.add(acc);
                num++;
            }
        }

        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true;


        try {
            Database.SaveResult[] results = Database.insert(myAccounts, dml);
            for(Database.SaveResult res :  results) {
                if(!res.isSuccess()) {
                    for(Database.Error err : res.getErrors()) {
                        System.debug('The following error has occurred.');
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Account fields that affected this error: ' + err.getFields());
                    }
                }
            }
        }
        catch(Exception ex) {
            system.debug('testNewAccounts Exception: '+ex.getMessage());
        }
    }

    @IsTest
    private static void testSingleAccount() {
        Account acc = new Account();
        acc.Name = 'TestAccount'+num;
        acc.Phone = '111-111-1111';
        acc.AccountEmail__c = acc.Name+'@gmail.com';
        acc.RecordTypeId = RecordType_Utility.getId('Account','Organization');


        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true;


        test.startTest();
        try {

            Database.SaveResult accInsertResult = Database.insert(acc, dml);
            if(!accInsertResult.isSuccess()) {
                for(Database.Error err : accInsertResult.getErrors()) {
                    System.debug('The following error has occurred.');
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Account fields that affected this error: ' + err.getFields());
                }
            }

        }
        catch(Exception ex) {
            system.debug('testNewAccounts Exception: '+ex.getMessage());
        }
        test.stopTest();
    }

    @IsTest
    private static void testUpdateAccounts() {
        map<Id,Account> accMap = new map<Id,Account>();
        accMap.putAll([SELECT Id, Name, Phone, AccountEmail__c From Account Where RecordTypeId != : OrgContactCard_Utility.HH_Account_RecordTypeId]);

        Integer itr = 0;
        for(Account acc : accMap.Values()) {
            if(itr < 30) acc.Name = 'New Name '+itr;
            else if(itr >= 30 && itr < 100) acc.Phone = '111-111-1111';
            else acc.AccountEmail__c = 'myEmail'+itr+'@gmail.com';
            itr++;
        }


        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true;


        test.startTest();
        try {
            Database.SaveResult[] results = Database.update(accMap.values(), dml);
            for(Database.SaveResult res :  results) {
                if(!res.isSuccess()) {
                    for(Database.Error err : res.getErrors()) {
                        System.debug('The following error has occurred.');
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Account fields that affected this error: ' + err.getFields());
                    }
                }
            }
        }
        catch(Exception ex) {
            system.debug('testNewAccounts Exception: '+ex.getMessage());
        }
        test.stopTest();
    }

    @IsTest
    private static void testMergeCards() {

        list<Account> allAccounts = [Select Id, Name From Account WHERE RecordTypeId != : OrgContactCard_Utility.HH_Account_RecordTypeId];

        list<Contact> newCons = new List<Contact>();
        for(Account acc : allAccounts) {
            for(Integer i = 0; i < 2;i++) {
                Contact con = new Contact();
                con.LastName = acc.Name;
                con.RecordTypeId = OrgContactCard_Utility.Organization_Contact_Card_RecordTypeId;
                con.AccountId = acc.Id;
                newCons.add(con);
            }
            acc.Name = acc.Name+'Itr';
        }

        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true;


        test.startTest();
        try {
            Database.SaveResult[] results = Database.insert(newCons, dml);
            for(Database.SaveResult res :  results) {
                if(!res.isSuccess()) {
                    for(Database.Error err : res.getErrors()) {
                        System.debug('The following error has occurred.');
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Contact fields that affected this error: ' + err.getFields());
                    }
                }
            }
        }
        catch(Exception ex) {
            system.debug('TestMerge Exception: '+ex.getMessage());
        }


        try {
            Database.SaveResult[] results = Database.update(allAccounts, dml);
            for(Database.SaveResult res :  results) {
                if(!res.isSuccess()) {
                    for(Database.Error err : res.getErrors()) {
                        System.debug('The following error has occurred.');
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Contact fields that affected this error: ' + err.getFields());
                    }
                }
            }
        }
        catch(Exception ex) {
            system.debug('testNewAccounts Exception: '+ex.getMessage());
        }

        test.stopTest();
    }

}