public with sharing class PlatformEventDemo {
    // Class to hold processing results
    public class ProcessingResult {
        public Set<Decimal> successfulDevices = new Set<Decimal>();
        public Set<Decimal> resourceUnavailableDevices = new Set<Decimal>();
        public Set<Decimal> externalServiceDevices = new Set<Decimal>();
        
        public Boolean hasResourceIssues() {
            return !resourceUnavailableDevices.isEmpty();
        }
        
        public Boolean hasExternalServiceIssues() {
            return !externalServiceDevices.isEmpty();
        }
        
        public Boolean hasSuccessfulDevices() {
            return !successfulDevices.isEmpty();
        }
        
        public String getResourceIssueMessage() {
            List<String> deviceStrings = new List<String>();
            for (Decimal deviceId : resourceUnavailableDevices) {
                deviceStrings.add(String.valueOf(deviceId));
            }
            return 'Resource not available for devices: ' + String.join(deviceStrings, ', ');
        }
        
        public String getExternalServiceIssueMessage() {
            List<String> deviceStrings = new List<String>();
            for (Decimal deviceId : externalServiceDevices) {
                deviceStrings.add(String.valueOf(deviceId));
            }
            return 'External service unavailable for devices: ' + String.join(deviceStrings, ', ');
        }
    }

    public static ProcessingResult processDeviceEvents(Set<Decimal> deviceIds) {
        ProcessingResult result = new ProcessingResult();
        
        // Categorize devices based on their ID
        for (Decimal deviceId : deviceIds) {
            if (Math.mod(deviceId.intValue(), 2) == 0) {
                // Even IDs: Will simulate resource availability issue
                result.resourceUnavailableDevices.add(deviceId);
            } else if (Math.mod(deviceId.intValue(), 3) == 0) {
                // Divisible by 3: Will simulate external service issue
                result.externalServiceDevices.add(deviceId);
            } else {
                // Process successful devices immediately
                System.debug('Successfully processed device: ' + deviceId);
                result.successfulDevices.add(deviceId);
            }
        }
        
        // Simulate hitting governor limit if processing too many successful events
        if (result.successfulDevices.size() >= 3) {
            throw new LimitException('Hit governor limit after processing ' + result.successfulDevices.size() + ' events');
        }
        
        return result;
    }
    
    public class PlatformEventsDemoException extends Exception {
    }
}
