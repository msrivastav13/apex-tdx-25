trigger LowInkTrigger on Low_Ink__e(after insert) {
    // Emit telemetry (unchanged)
    EventBus.publish(
        new SubscriberTelemetry__e(
            Topic__c = 'Low_Ink__e',
            ApexTrigger__c = 'LowInkTrigger',
            Position__c = [
                SELECT Position
                FROM EventBusSubscriber
                WHERE Topic = 'Low_Ink__e'
            ][0]
            .Position,
            BatchSize__c = Trigger.new.size(),
            Retries__c = EventBus.TriggerContext.currentContext().retries,
            LastError__c = EventBus.TriggerContext.currentContext().lastError
        )
    );

    // Track DeviceIds where status is 'Failed'
    Set<Decimal> setDeviceIds = new Set<Decimal>();
    String lastFailedReplayId;

    for (Low_Ink__e event : Trigger.New) {
        if (event.Status__c == 'Failed') {
            setDeviceIds.add(event.DeviceId__c);
            // Capture the replay ID of the failed event
            lastFailedReplayId = event.ReplayId;
            // Set the resume checkpoint based on the failed event
            EventBus.TriggerContext.currentContext()
                .setResumeCheckpoint(event.ReplayId);
        }
    }

    // Simplified retry mechanism with tracking of DeviceIds
    try {
        PlatformEventDemo.processDeviceEvents(setDeviceIds); // Process all failed device events
    } catch (Exception e) {
        // Retry mechanism: Retry up to 2 times before stopping further retries
        if (EventBus.TriggerContext.currentContext().retries < 2) {
            throw new EventBus.RetryableException(e.getMessage());
        } else {
            // Store the last failed ReplayId for potential reprocessing later
            System.debug('Last failed ReplayId: ' + lastFailedReplayId);
        }
    }
}
