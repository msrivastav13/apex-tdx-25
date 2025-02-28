trigger AccountTriggerRecursion on Account(after insert) {
    switch on Trigger.OperationType {
        when AFTER_INSERT {
            AccountTriggerHandler handler = new AccountTriggerHandler();
            handler.handleAfterInsert(Trigger.new);
        }
    }
}