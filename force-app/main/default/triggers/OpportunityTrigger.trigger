trigger OpportunityTrigger on Opportunity(after update) {
    switch on Trigger.OperationType {
        when AFTER_UPDATE {
            OpportunityTriggerHandler handler = new OpportunityTriggerHandler();
            handler.handleAfterUpdate(Trigger.new);
        }
    }
}