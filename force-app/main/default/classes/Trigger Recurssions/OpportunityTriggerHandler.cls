public inherited sharing class OpportunityTriggerHandler {
    public void handleAfterUpdate(List<Opportunity> newOpportunities) {
        updateLastOpportunityClosedDateOnAccount(newOpportunities);
    }

    public void updateLastOpportunityClosedDateOnAccount(
        List<Opportunity> newOpportunities
    ) {
        List<Account> lstAccountsToUpdate = new List<Account>();
        for (Opportunity opp : newOpportunities) {
            Account accToUpdate = new Account();
            accToUpdate.Id = opp.AccountId;
            accToUpdate.Last_Opportunity_Closed_Date__c = opp.CloseDate;
            lstAccountsToUpdate.add(accToUpdate);
        }
        update lstAccountsToUpdate;
    }
}