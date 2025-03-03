// Test scenario for Platform Events - External Service Issues
List<Low_Ink__e> events = new List<Low_Ink__e>();

// Scenario 2: External service issues (events with IDs divisible by 3)
events.add(new Low_Ink__e(
    DeviceId__c = 3,
    Status__c = 'Normal'
));
events.add(new Low_Ink__e(
    DeviceId__c = 9,
    Status__c = 'Normal'
));
events.add(new Low_Ink__e(
    DeviceId__c = 21,
    Status__c = 'Normal'
));
events.add(new Low_Ink__e(
    DeviceId__c = 27,
    Status__c = 'Normal'
));

// Publish events in batch
System.debug('Publishing events that simulate external service issues (IDs divisible by 3):');
System.debug('- External service issues expected for IDs: 3, 9, 21, 27');
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