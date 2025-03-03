trigger LowInkTrigger on Low_Ink__e(after insert) {
    // Track the last processed replay ID for checkpointing
    String lastProcessedReplayId;
    
    try {
        // Collect all device IDs from the events
        Set<Decimal> deviceIds = new Set<Decimal>();
        
        for (Low_Ink__e event : Trigger.new) {
            deviceIds.add(event.DeviceId__c);
            lastProcessedReplayId = event.ReplayId; // Keep track of replay ID for checkpoint
        }
        
        // Process all device IDs in bulk and get the results
        PlatformEventDemo.ProcessingResult results = PlatformEventDemo.processDeviceEvents(deviceIds);
        
        // Handle resource availability issues
        if (results.hasResourceIssues()) {
            EventTelemetry.logTelemetry('Low_Ink__e', 'LowInkTrigger', Trigger.new.size(), 'Resource issue', results.getResourceIssueMessage());
            
            // Retry up to 3 times without setting resume checkpoint
            if (EventBus.TriggerContext.currentContext().retries < 3) {
                throw new EventBus.RetryableException(
                    'Resource unavailable. Retry attempt: ' + 
                    EventBus.TriggerContext.currentContext().retries
                );
            } else {
                System.debug('Failed after maximum retries: ' + results.getResourceIssueMessage());
            }
        }
        
        // Handle external service issues
        if (results.hasExternalServiceIssues()) {
            EventTelemetry.logTelemetry('Low_Ink__e', 'LowInkTrigger', Trigger.new.size(), 'External service issue', results.getExternalServiceIssueMessage());
            
            // Retry for external service issues without setting resume checkpoint
            if (EventBus.TriggerContext.currentContext().retries < 3) {
                throw new EventBus.RetryableException(
                    'External service unavailable. Retry attempt: ' + 
                    EventBus.TriggerContext.currentContext().retries
                );
            } else {
                System.debug('Failed after maximum retries: ' + results.getExternalServiceIssueMessage());
            }
        }
        
        // Log success telemetry if we processed any devices successfully
        if (results.hasSuccessfulDevices()) {
            EventTelemetry.TelemetryParams successParams = new EventTelemetry.TelemetryParams(
                'Low_Ink__e', 'LowInkTrigger', Trigger.new.size()
            );
            successParams.successCount = results.successfulDevices.size();
            EventTelemetry.publishSuccessTelemetry(successParams);
        }
        
    } catch (Exception e) {
        // Unified exception handling
        EventTelemetry.logTelemetry('Low_Ink__e', 'LowInkTrigger', Trigger.new.size(), 'Exception', e.getMessage());
        
        // Handle different types of exceptions appropriately
        if (e instanceof CalloutException) {
            // Transient errors that can be fixed with a retry - no checkpoint
            if (EventBus.TriggerContext.currentContext().retries < 3) {
                throw new EventBus.RetryableException(
                    'Transient error during processing. Retry attempt: ' + 
                    EventBus.TriggerContext.currentContext().retries
                );
            } else {
                System.debug('Failed after maximum retries for transient error: ' + e.getMessage());
            }
        } else if (e instanceof LimitException || e instanceof System.LimitException) {
            // Governor limit exceptions - set checkpoint but no retry
            // Set checkpoint ONLY for governor limit exceptions
            EventBus.TriggerContext.currentContext().setResumeCheckpoint(lastProcessedReplayId);
            System.debug('Governor limit exceeded. Event processing checkpointed but not retried: ' + e.getMessage());
        } else {
            // For other exceptions that cannot be handled by retry, re-throw
            throw e;
        }
    }
}
