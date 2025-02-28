public with sharing class PlatformEventDemo {
    public static void processDeviceEvents(Set<Decimal> deviceIds) {
        for (Decimal i : deviceIds) {
            if ((Math.mod(i.intValue(), 2) == 0)) {
                // Standard exception
                throw new PlatformEventsDemoException(
                    'Invalid Custom Exception'
                );
            } else if ((Math.mod(i.intValue(), 3) == 0)) {
                // Divide by zero!
                Integer newAmount = 20 / 0;
            } else if ((Math.mod(i.intValue(), 5)) == 0) {
                // Limits exception
                for (Integer idx = 0; idx < 201; idx++) {
                    Account acc = [SELECT Id FROM Account LIMIT 1];
                }
            } else {
            }
        }
    }
    public class PlatformEventsDemoException extends Exception {
    }
}
