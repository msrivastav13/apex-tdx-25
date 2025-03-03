/**
 * Utility class for handling Platform Event telemetry
 * Centralizes telemetry publishing logic to avoid code duplication
 */
public without sharing class EventTelemetry {
    /**
     * Parameter class to encapsulate telemetry data
     */
    public class TelemetryParams {
        public String topic;
        public String triggerName;
        public Integer batchSize;
        public String errorMessage;
        public Integer successCount;
        
        public TelemetryParams(String topic, String triggerName, Integer batchSize) {
            this.topic = topic;
            this.triggerName = triggerName;
            this.batchSize = batchSize;
        }
    }
    
    /**
     * Publishes telemetry for a platform event subscriber
     * @param params The telemetry parameters
     */
    public static void publishTelemetry(TelemetryParams params) {
        try {
            // Query for the subscriber position just once
            Decimal position = getSubscriberPosition(params.topic);
            
            // Create and publish the telemetry event
            EventBus.publish(new SubscriberTelemetry__e(
                Topic__c = params.topic,
                ApexTrigger__c = params.triggerName,
                Position__c = position,
                BatchSize__c = params.batchSize,
                Retries__c = EventBus.TriggerContext.currentContext().retries,
                LastError__c = params.errorMessage
            ));
        } catch (Exception ex) {
            // If telemetry publication fails, just log the error
            System.debug('Failed to publish telemetry: ' + ex.getMessage());
            System.debug('Original error: ' + params.errorMessage);
        }
    }
    
    /**
     * Publishes success telemetry for a platform event subscriber
     * @param params The telemetry parameters
     */
    public static void publishSuccessTelemetry(TelemetryParams params) {
        params.errorMessage = 'Success: ' + params.successCount + ' events processed';
        publishTelemetry(params);
    }
    
    /**
     * Gets the subscriber position for a given topic
     * @param topic The platform event API name
     * @return The subscriber position
     */
    private static Decimal getSubscriberPosition(String topic) {
        try {
            
            List<EventBusSubscriber> subscribers = [
                SELECT Position 
                FROM EventBusSubscriber 
                WHERE Topic = :topic
                WITH SYSTEM_MODE
                LIMIT 1
            ];
            
            if (!subscribers.isEmpty()) {
                return subscribers[0].Position;
            }
        } catch (Exception e) {
            System.debug('Error retrieving subscriber position: ' + e.getMessage());
        }
        
        return null;
    }
    
    /**
     * Logs telemetry with error information
     * @param topic The platform event API name
     * @param triggerName The name of the trigger
     * @param batchSize The size of the batch being processed
     * @param issueType The type of issue encountered
     * @param errorMessage The error message details
     */
    public static void logTelemetry(String topic, String triggerName, Integer batchSize, String issueType, String errorMessage) {
        TelemetryParams params = new TelemetryParams(
            topic, triggerName, batchSize
        );
        params.errorMessage = issueType + ': ' + errorMessage;
        publishTelemetry(params);
    }
} 