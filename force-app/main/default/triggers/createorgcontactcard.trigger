trigger createorgcontactcard on Account (after insert, after update) {

    system.debug('createorgcontactcard trigger called: ');

    map<Id,Account> accountMap = new map<Id,Account>(trigger.new);
    for(Account acc : accountMap.values()) {
        if(acc.RecordTypeId == OrgContactCard_Utility.HH_Account_RecordTypeId) {
            accountMap.remove(acc.Id);
            continue;
        }
        if(string.isEmpty(acc.Phone)) {
            acc.addError('Account Phone Is Required');
            accountMap.remove(acc.Id);
            continue;
        }
        if(string.isEmpty(acc.AccountEmail__c)) {
            acc.addError('Account Email Is Required');
            accountMap.remove(acc.Id);
            continue;
        }
    }

    if(accountMap.size()>0) OrgContactCard_Utility.handleTrigger(accountMap);

}