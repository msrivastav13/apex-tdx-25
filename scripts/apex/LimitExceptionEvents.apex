// Test scenario for Platform Events - Limit Exception Events
List<Low_Ink__e> events = new List<Low_Ink__e>();

// Scenario 3: Limit exception events (events with IDs divisible by 5)
events.add(new Low_Ink__e(
    DeviceId__c = 5,
    Status__c = 'Normal'
));
events.add(new Low_Ink__e(
    DeviceId__c = 25,
    Status__c = 'Normal'
));
events.add(new Low_Ink__e(
    DeviceId__c = 35,
    Status__c = 'Normal'
));
events.add(new Low_Ink__e(
    DeviceId__c = 55,
    Status__c = 'Normal'
));

// Publish events in batch
System.debug('Publishing events that trigger limit exceptions (IDs divisible by 5):');
System.debug('- Limit exceptions expected for IDs: 5, 25, 35, 55');
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