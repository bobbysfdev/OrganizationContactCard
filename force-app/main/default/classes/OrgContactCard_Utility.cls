/**
 * Created by bob on 1/13/19.
 */

public without sharing class OrgContactCard_Utility {

    public static Id HH_Account_RecordTypeId = RecordType_Utility.getId('Account', 'HH_Account');
    public static Id Organization_Contact_Card_RecordTypeId = RecordType_Utility.getId('Contact', 'Organization_Contact_Card');

    public virtual class OrgContactCardException extends Exception {}

    // Private Methods //
    private static boolean contactCardNeedsUpdate(Account acc, Contact con) {
        if(con.LastName != acc.Name) return true;
        if(con.Email != acc.AccountEmail__c) return true;
        if(con.Phone != acc.Phone) return true;
        return false;
    }

    private static contact processContactCard(Account acc, Contact con) {
        con.LastName = acc.Name;
        con.RecordTypeId = Organization_Contact_Card_RecordTypeId;
        con.AccountId = acc.Id;
        con.Email = acc.AccountEmail__c;
        con.Phone = acc.Phone;
        con.Title = 'Organization';
        return con;
    }

    private static contact returnNewContactCard(Account acc) {
        Contact con = new Contact();
        return processContactCard(acc,con);
    }
    private static void upsertContacts(list<Contact> contacts) {
        system.debug('Upsert Contacts Called: '+contacts.size());

        if(contacts.size() > 0) {

            list<Contact> updateCons = new list<Contact>();
            list<Contact> insertCons = new list<Contact>();

            for(Contact con : contacts) {
                if(string.isBlank(con.Id)) insertCons.add(con);
                else updateCons.add(con);
            }

            system.Savepoint sv = Database.setSavepoint();

            Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.allowSave = true;
            dml.DuplicateRuleHeader.runAsCurrentUser = false;
            Boolean success = true;

            try {

                if(updateCons.size()>0) {
                    Database.SaveResult[] sr = Database.update(updateCons, dml);
                    for(Database.SaveResult res : sr) {
                        if(!res.isSuccess()) {
                            success = false;
                            System.debug('Update Error: '+res.errors);
                        }
                    }
                }

                if(insertCons.size()>0) {
                    Database.SaveResult[] sr = Database.insert(insertCons, dml);
                    for(Database.SaveResult res : sr) {
                        if(!res.isSuccess()) {
                            success = false;
                            System.debug('Update Error: '+res.errors);
                        }
                    }
                }

            } catch(Exception ex) {
                system.debug('Upsert Exception: '+ex.getMessage());
                Database.rollback(sv);
            } finally {

            }
        }
    }


    // private static varibles //
    private static set<Id> processedAccountIds = new set<Id>();
    private static map<Id,Account> accountMap; // accountId, Account
    private static map<Id,Contact> allContacts;
    private static map<Id,list<Contact>> contactCardMap; // accountId, list<Contact> (recordType contact card);
    private static set<Id> accountChangeSet; // account Ids with changed name/email/phone
    private static set<Id> contactsToMerge; // account Ids with duplicate contact cards
    private static list<Contact> upsertContacts; // contacts to upsert

    private static integer itr = 0;

    // Public Methods //
    public static void handleTrigger(map<Id,Account> accMap) {
        system.debug('handleTrigger called: '+ itr);
        itr++;

        for(Account acc : accMap.values()) {
            if(processedAccountIds.contains(acc.Id)) accMap.remove(acc.Id);
        }


        system.debug('accMap: '+accMap.size());


        if(accMap.size() > 1) {
            Id batchInstanceId = Database.executeBatch(new OrgContactCard_Batch(accMap.keySet()), 200);
        } else if (accMap.size() > 0) {
            processAccounts(accMap);
        }

    }
    public static void processAccounts(map<Id,Account> accountsToProcessMap) {
        system.debug('processAccounts called: '+accountsToProcessMap.size());
        processedAccountIds.addAll(accountsToProcessMap.keySet());


        map<Id,Contact> accContactMap = new map<Id,Contact>();
        for(Account acc : [
                SELECT Id, Name, Phone, AccountEmail__c, (Select Id, LastName, Phone, Email FROM Contacts WHERE RecordTypeId = : Organization_Contact_Card_RecordTypeId)
                From Account
                Where Id IN : accountsToProcessMap.keySet()
        ]) {


            system.debug('acc.Contacts.size(): '+acc.Contacts.size());


            if(acc.Contacts.size() > 1) {
                Contact MasterContact = processContactCard(acc,acc.Contacts[0]);
                for(Integer i = 1; i < acc.Contacts.size(); i++) {
                    try{
                        Merge MasterContact processContactCard(acc,acc.Contacts[i]);
                    } catch(Exception ex) {
                        system.debug('Merge Exception: '+ex.getMessage());
                    }
                }
            } else if(acc.Contacts.size() > 0) {
                Contact singleContact = acc.Contacts[0];
                if(contactCardNeedsUpdate(acc,singleContact)) accContactMap.put(acc.Id,processContactCard(acc,singleContact));
            } else {
                accContactMap.put(acc.Id,returnNewContactCard(acc));
            }
        }

        if(accContactMap.size()>0) upsertContacts(accContactMap.values());

    }

}