public with sharing class PlatformEventDemo {
    public static void processDeviceEvents(Set<Decimal> deviceIds) {
        Integer processedCount = 0;
        
        for (Decimal deviceId : deviceIds) {
            // Count processed events to demonstrate checkpoint scenario
            processedCount++;
            
            // Simulate different processing scenarios based on device ID
            if (Math.mod(deviceId.intValue(), 2) == 0) {
                // Even IDs: Simulate resource availability issue
                throw new PlatformEventsDemoException(
                    'Device ' + deviceId + ' - Resource not available'
                );
            } else if (Math.mod(deviceId.intValue(), 3) == 0) {
                // Divisible by 3: Simulate external service issue
                throw new CalloutException(
                    'Device ' + deviceId + ' - External service unavailable'
                );
            }
            
            // If we get here, process was successful
            System.debug('Successfully processed device: ' + deviceId);
            
            // Simulate hitting governor limit after processing 3 events
            if (processedCount >= 3) {
                throw new LimitException('Hit governor limit after processing ' + processedCount + ' events');
            }
        }
    }
    
    public class PlatformEventsDemoException extends Exception {
    }
}
