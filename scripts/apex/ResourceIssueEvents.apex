// Test scenario for Platform Events - Resource Issues
List<Low_Ink__e> events = new List<Low_Ink__e>();

// Scenario 1: Resource issues (events with even IDs)
events.add(new Low_Ink__e(
    DeviceId__c = 2,
    Status__c = 'Normal'
));
events.add(new Low_Ink__e(
    DeviceId__c = 4,
    Status__c = 'Normal'
));
events.add(new Low_Ink__e(
    DeviceId__c = 8,
    Status__c = 'Normal'
));
events.add(new Low_Ink__e(
    DeviceId__c = 14,
    Status__c = 'Normal'
));

// Publish events in batch
System.debug('Publishing events that simulate resource issues (even IDs):');
System.debug('- Resource issues expected for IDs: 2, 4, 8, 14');
List<Database.SaveResult> results = EventBus.publish(events);

// Process and display results
for (Integer i = 0; i < results.size(); i++) {
    if (results[i].isSuccess()) {
        System.debug('Successfully published event for DeviceId: ' + events[i].DeviceId__c);
    } else {
        for(Database.Error err : results[i].getErrors()) {
            System.debug('Error publishing event for DeviceId: ' + events[i].DeviceId__c);
            System.debug('Error: ' + err.getMessage());
        }
    }
} 