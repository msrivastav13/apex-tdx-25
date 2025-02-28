public with sharing class ForUpdateQueueableCalloutWithSavePoint {
    // Queueable class that updates an Account record
    public class UpdateAccountQueueable implements Queueable, Database.AllowsCallouts {
        public void execute(QueueableContext context) {
            Savepoint sp = Database.setSavepoint();
            // Simulate an update operation on the Account object
            Account aLock = [
                SELECT Id, NumberOfEmployees
                FROM Account
                WHERE Id = '001a5000002ME7pAAG'
                LIMIT 1
                FOR UPDATE
            ];
            // Increment the count by one
            if (aLock.NumberOfEmployees == null) {
                aLock.NumberOfEmployees = 1;
            } else {
                aLock.NumberOfEmployees++;
            }

            Database.rollback(sp);
            Database.releaseSavepoint(sp);

            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://dog.ceo/api/breeds/image/random'); // Set the endpoint URL
            request.setMethod('GET'); // Set the HTTP POST method

            // Set the request headers
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Accept', 'application/json');

            // Send the request
            Http http = new Http();
            HttpResponse response = http.send(request);

            // Process the response
            if (response.getStatusCode() == 200) {
                String responseBody = response.getBody();
                System.debug(responseBody);
                update aLock;
            }
        }
    }

    // Method to demonstrate hitting concurrency limits with an Account update
    public static void demonstrateQueueableBlockingCalloutWithSavePoint() {
        // Reset counter before run
        Account a = [
            SELECT Id, NumberOfEmployees
            FROM Account
            WHERE Id = '001a5000002ME7pAAG'
        ];
        a.NumberOfEmployees = 0;
        update a;

        // Enqueue another job that updates Account records
        for (integer i = 0; i < 25; i++) {
            System.enqueueJob(new UpdateAccountQueueable());
        }
    }
}