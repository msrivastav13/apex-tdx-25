public inherited sharing class AcctUpdateTrgrHandlRecrCompareOldvsNew {
    public void handleAfterUpdate(
        List<Account> newAccounts,
        Map<Id, Account> oldAccountMap
    ) {
        updateOpportunityAmountAfterDiscount(newAccounts, oldAccountMap);
    }

    public void updateOpportunityAmountAfterDiscount(
        List<Account> newAccounts,
        Map<Id, Account> oldAccountMap
    ) {
        Map<Id, Account> mapAccountIdByAccount = new Map<Id, Account>();
        List<Opportunity> lstOppToUpdate = new List<Opportunity>();
        for (Account acc : newAccounts) {
            if (
                acc.Discount_Percentage__c != null &&
                (acc.Discount_Percentage__c !=
                oldAccountMap.get(acc.Id).Discount_Percentage__c)
            ) {
                mapAccountIdByAccount.put(acc.Id, acc);
            }
        }
        if (mapAccountIdByAccount.keySet().size() > 0) {
            for (Opportunity opp : [
                SELECT Amount, AccountId
                FROM Opportunity
                WHERE AccountId IN :mapAccountIdByAccount.keyset()
            ]) {
                Decimal discountPercentage = mapAccountIdByAccount.get(
                        opp.AccountId
                    )
                    .Discount_Percentage__c;
                // Calculate the discount amount
                Decimal discountAmount =
                    (discountPercentage / 100) * opp.Amount;
                opp.Amount = opp.Amount - discountAmount;
                lstOppToUpdate.add(opp);
            }
            if (lstOppToUpdate.size() > 0) {
                update lstOppToUpdate;
            }
        }
    }
}