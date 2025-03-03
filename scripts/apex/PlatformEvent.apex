// Test scenarios for Platform Events
List<Low_Ink__e> events = new List<Low_Ink__e>();

// Scenario 1: Mixed batch of events with different issue types
// Resource issues (even IDs)
events.add(new Low_Ink__e(
    DeviceId__c = 2,
    Status__c = 'Normal'
));
events.add(new Low_Ink__e(
    DeviceId__c = 4,
    Status__c = 'Normal'
));

// External service issues (divisible by 3)
events.add(new Low_Ink__e(
    DeviceId__c = 3,
    Status__c = 'Normal'
));
events.add(new Low_Ink__e(
    DeviceId__c = 9,
    Status__c = 'Normal'
));

// Normal successful events
events.add(new Low_Ink__e(
    DeviceId__c = 1,
    Status__c = 'Normal'
));
events.add(new Low_Ink__e(
    DeviceId__c = 5,
    Status__c = 'Normal'
));

// Publish events in batch
System.debug('Publishing a mixed batch with events that have different issues:');
System.debug('- Resource issues: IDs 2, 4');
System.debug('- External service issues: IDs 3, 9');
System.debug('- Normal events: IDs 1, 5');
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

// Scenario 2: Testing governor limit checkpoint with more successful devices
events = new List<Low_Ink__e>();
// These should trigger the LimitException after 3 successful devices
for (Integer i = 1; i <= 5; i += 2) {
    events.add(new Low_Ink__e(
        DeviceId__c = i,
        Status__c = 'Normal'
    ));
}

System.debug('\nPublishing a batch of successful events to test governor limit checkpoint:');
System.debug('- Successful events: IDs 1, 3, 5 (should hit LimitException after processing 3)');
results = EventBus.publish(events);

/* This demo showcases improved handling of platform events:
 * 
 * 1. Mixed Batch Processing:
 *    - We now process and report on all types of issues in a single batch
 *    - Even-numbered devices (2, 4) have resource availability issues
 *    - Devices divisible by 3 (3, 9) have external service issues
 *    - Other devices (1, 5) are processed successfully
 * 
 * 2. Comprehensive Error Reporting:
 *    - The system now reports ALL issues found in the batch
 *    - No early exit when the first issue is encountered
 *    - Resource issues will still cause retries as appropriate
 *    - External service issues will be handled without retries
 *
 * 3. Governor Limit Handling:
 *    - After processing 3 successful events, hits a governor limit
 *    - Sets checkpoint to last successful event
 *    - Platform will resume processing from checkpoint automatically
 */
