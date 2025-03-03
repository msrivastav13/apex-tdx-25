trigger LowInkTrigger on Low_Ink__e(after insert) {
    // Emit telemetry
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
    // Track the last processed replay ID for checkpointing
    String lastProcessedReplayId;

    // Collect all device IDs from the events
    Set<Decimal> deviceIds = new Set<Decimal>();

    for (Low_Ink__e event : Trigger.new) {
        deviceIds.add(event.DeviceId__c);
        lastProcessedReplayId = event.ReplayId; // Keep track of replay ID for checkpoint
    }

    // Process all device IDs in bulk and get the results
    PlatformEventDemo.ProcessingResult results = PlatformEventDemo.processDeviceEvents(
        deviceIds
    );

    // Handle resource availability issues
    if (results.hasResourceIssues()) {
        // Retry up to 3 times without setting resume checkpoint
        if (EventBus.TriggerContext.currentContext().retries < 3) {
            throw new EventBus.RetryableException(
                'Resource unavailable. Retry attempt: ' +
                EventBus.TriggerContext.currentContext().retries
            );
        } else {
            System.debug(
                'Failed after maximum retries: ' +
                results.getResourceIssueMessage()
            );
        }
    }

    // Handle external service issues
    if (results.hasExternalServiceIssues()) {
        // Retry for external service issues without setting resume checkpoint
        if (EventBus.TriggerContext.currentContext().retries < 3) {
            throw new EventBus.RetryableException(
                'External service unavailable. Retry attempt: ' +
                EventBus.TriggerContext.currentContext().retries
            );
        } else {
            System.debug(
                'Failed after maximum retries: ' +
                results.getExternalServiceIssueMessage()
            );
        }
    }

    // Handle limit issues
    if (results.hasLimitIssues()) {
        try {
            // Set checkpoint for governor limit issues but don't retry
            EventBus.TriggerContext.currentContext()
                .setResumeCheckpoint(lastProcessedReplayId);
            throw new LimitException(
                'Governor limit would be exceeded processing this batch: ' +
                results.getLimitIssueMessage()
            );
        } catch (exception e) {
            if (EventBus.TriggerContext.currentContext().retries < 2) {
                throw new EventBus.RetryableException(
                    'Retry again for partial batch'
                );
            } else {
                System.debug(
                    'Failed after maximum retries: ' +
                    results.getLimitIssueMessage()
                );
            }
        }
    }
}
