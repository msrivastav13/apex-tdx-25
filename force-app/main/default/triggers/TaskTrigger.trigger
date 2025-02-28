trigger TaskTrigger on Task(after insert) {
    switch on Trigger.OperationType {
        when AFTER_INSERT {
            TaskTriggerHandler handler = new TaskTriggerHandler();
            handler.handleAfterInsert(Trigger.new);
        }
    }
}