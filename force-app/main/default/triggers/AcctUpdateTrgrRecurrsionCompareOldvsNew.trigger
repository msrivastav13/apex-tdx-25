trigger AcctUpdateTrgrRecurrsionCompareOldvsNew on Account (after update) {
    switch on Trigger.OperationType {
        when AFTER_UPDATE {
            AcctUpdateTrgrHandlRecrCompareOldvsNew handler = new AcctUpdateTrgrHandlRecrCompareOldvsNew();
            handler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}