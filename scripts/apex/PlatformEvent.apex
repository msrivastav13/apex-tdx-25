// Test scenarios for Platform Events
List<Low_Ink__e> events = new List<Low_Ink__e>();

// Scenario 1: Events that will need resource retry (even IDs)
for (Integer i = 0; i < 2; i++) {
    events.add(new Low_Ink__e(
        DeviceId__c = i * 2,  // Will generate 0, 2
        Status__c = 'Normal'
    ));
}

// Scenario 2: Events that will need callout retry (divisible by 3)
for (Integer i = 1; i <= 2; i++) {
    events.add(new Low_Ink__e(
        DeviceId__c = i * 3,  // Will generate 3, 6
        Status__c = 'Normal'
    ));
}

// Scenario 3: Events that will process successfully
events.add(new Low_Ink__e(
    DeviceId__c = 1,
    Status__c = 'Normal'
));
events.add(new Low_Ink__e(
    DeviceId__c = 5,
    Status__c = 'Normal'
));

// Scenario 4: Additional events to demonstrate governor limit checkpoint
for (Integer i = 7; i < 10; i++) {
    events.add(new Low_Ink__e(
        DeviceId__c = i,
        Status__c = 'Normal'
    ));
}

// Publish events in batch
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

/* This setup demonstrates three key platform event handling scenarios:
 * 
 * 1. RetryableException for resource issues (DeviceIds 0, 2)
 *    - Even numbered devices simulate resource availability issues
 *    - Will retry up to 3 times waiting for resource
 * 
 * 2. RetryableException for external service (DeviceIds 3, 6)
 *    - Devices divisible by 3 simulate temporary external service issues
 *    - Will retry automatically when service is available
 * 
 * 3. Governor Limit Checkpoint (After 3 successful processes)
 *    - After processing 3 events successfully, hits a governor limit
 *    - Sets checkpoint to last successful event
 *    - Platform will resume processing from checkpoint automatically
 * 
 * 4. Normal Processing (DeviceIds 1, 5)
 *    - These events demonstrate successful processing
 */
