public inherited sharing class AccountTriggerHandler {
    
    public static Boolean isAccountInsertTriggerRunningToCreateTask = false;

    public void handleAfterInsert(List<Account> newAccounts) {
        createFollowUpTask(newAccounts);
    }

    public void createFollowUpTask(List<Account> newAccounts) {
        // Block the logic 
        if(AccountTriggerHandler.isAccountInsertTriggerRunningToCreateTask) {
            return;
        }
        //The guard is set before the DML to prevent infinite recursion. 
        // This stops the trigger from running again on the task update
        AccountTriggerHandler.isAccountInsertTriggerRunningToCreateTask = true;
        List<Task> newTasks = new List<Task>();
        // Create a new Task for each inserted Account
        for (Account acc : newAccounts) {
            String competitorName = acc.Competitor_Name__c ?? '';
            Task newTask = new Task(
                Subject = 'New Sales Call for ' + acc.Name,
                WhatId = acc.Id,
                ActivityDate = System.today().addDays(7),
                Status = 'Not Started'
            );
            newTasks.add(newTask);
        }

        // Insert the newly created Tasks
        if (!newTasks.isEmpty()) {
            insert newTasks;
        }
        // The guard is unset after the DML so that the trigger will run
        //  on the next batch of 200 records. 
        // This allows the trigger to continue processing future chunks of records.
        AccountTriggerHandler.isAccountInsertTriggerRunningToCreateTask = false;
    }
}