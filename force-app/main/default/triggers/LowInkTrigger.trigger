trigger LowInkTrigger on Low_Ink__e(after insert) {
    // Track successfully processed events
    Integer processedCount = 0;
    String lastProcessedReplayId;
    
    try {
        // Process each event in the batch
        for (Low_Ink__e event : Trigger.new) {
            try {
                // Process the event
                PlatformEventDemo.processDeviceEvents(new Set<Decimal>{event.DeviceId__c});
                
                // Update tracking variables after successful processing
                processedCount++;
                lastProcessedReplayId = event.ReplayId;
                
            } catch (CalloutException ce) {
                // For transient external service errors - will retry
                throw new EventBus.RetryableException(
                    'External service temporarily unavailable. Will retry.'
                );
            } catch (PlatformEventDemo.PlatformEventsDemoException pe) {
                // For resource availability issues - will retry up to 3 times
                if (EventBus.TriggerContext.currentContext().retries < 3) {
                    throw new EventBus.RetryableException(
                        'Resource unavailable. Retry attempt: ' + 
                        EventBus.TriggerContext.currentContext().retries
                    );
                } else {
                    System.debug('Failed after maximum retries: ' + pe.getMessage());
                }
            } catch (LimitException le) {
                // For governor limits - set checkpoint and retry remaining events later
                EventBus.TriggerContext.currentContext().setResumeCheckpoint(lastProcessedReplayId);
                throw le;
            }
        }
    } catch (Exception e) {
        // Emit telemetry for monitoring platform event processing
        EventBus.publish(new SubscriberTelemetry__e(
            Topic__c = 'Low_Ink__e',
            ApexTrigger__c = 'LowInkTrigger',
            Position__c = [SELECT Position FROM EventBusSubscriber WHERE Topic = 'Low_Ink__e'][0].Position,
            BatchSize__c = Trigger.new.size(),
            Retries__c = EventBus.TriggerContext.currentContext().retries,
            LastError__c = e.getMessage()
        ));
        throw e;
    }
}
