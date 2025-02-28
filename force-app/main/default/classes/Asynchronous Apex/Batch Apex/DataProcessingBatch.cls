public class DataProcessingBatch implements Database.Batchable<SObject> {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        // Get the current class name dynamically
        String currentClassName = 'DataProcessingBatch';

        // Get the Apex class Id dynamically using the class name
        Id batchJobClassId = [
            SELECT Id
            FROM ApexClass
            WHERE Name = :currentClassName
            LIMIT 1
        ]
        .Id;

        // Query AsyncApexJob for running or queued jobs of the same class
        List<AsyncApexJob> runningJobs = [
            SELECT Id, Status, CreatedDate
            FROM AsyncApexJob
            WHERE
                ApexClassId = :batchJobClassId
                AND (Status = 'Processing'
                OR Status = 'Queued')
                AND CreatedDate >= :System.now().addHours(-24) // Check within the last 24 hours
            ORDER BY CreatedDate DESC
        ];

        // If there are any jobs that are running or queued, do not proceed with starting a new job
        if (!runningJobs.isEmpty()) {
            throw new BatchExecutionException(
                currentClassName +
                ' is already running or queued. Rescheduling job.'
            );
        }

        // Proceed with the batch job logic
        return Database.getQueryLocator([SELECT Id FROM Account]);
    }

    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        // Batch logic here (e.g., processing the list of Accounts passed in scope)
        System.debug('Processing records: ' + scope);
        simulateDelay();
    }

    public void finish(Database.BatchableContext bc) {
        // Any finish logic you want (e.g., sending notifications, logging)
        System.debug('Batch job finished');
    }

    // Method to simulate a delay by consuming CPU time
    private void simulateDelay() {
        // Simulate delay by running a loop that consumes time
        Long startTime = System.now().getTime();
        Long endTime = startTime + 60000; // Simulate a 60-second (1-minute) delay

        // Loop until 60 seconds have passed
        while (System.now().getTime() < endTime) {
            // Consume some time without doing anything meaningful
            for (Integer i = 0; i < 1000; i++) {
                Math.sqrt(i); // Just an arbitrary calculation to consume CPU
            }
        }
    }

    // Custom Exception Class to handle batch job execution conflicts
    public class BatchExecutionException extends Exception {
        // Exception to throw when a batch job conflict occurs
    }
}
