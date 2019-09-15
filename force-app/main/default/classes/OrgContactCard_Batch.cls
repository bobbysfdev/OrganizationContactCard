/**
 * Created by bob on 1/13/19.
 */

global without sharing class OrgContactCard_Batch implements Database.Batchable<sObject>{
    global final String Query;
    global final set<Id> accIds;

    global OrgContactCard_Batch(Set<Id> accIds){
        system.debug('call batch: '+accIds.size());
        this.Query = 'Select Id, Name, Phone, AccountEmail__c From Account Where Id IN :accIds';
        this.accIds = accIds;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Account> accs) {
        OrgContactCard_Utility.processAccounts(new Map<Id,Account>(accs));
    }

    global void finish(Database.BatchableContext BC){

    }
}