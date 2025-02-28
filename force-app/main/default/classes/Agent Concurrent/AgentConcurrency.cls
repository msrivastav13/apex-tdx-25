public with sharing class AgentConcurrency {
    /**
     * @description Launches multiple concurrent booking processes for test contacts
     * @param sessionId The Session ID to book the contacts for
     */
    public static void executeParallelBookings(Id sessionId) {
        if (sessionId == null) {
            System.debug('Session ID is required');
            return;
        }
        
        // Find contacts with FirstName = 'Test' (up to 10)
        List<Contact> testContacts = [
            SELECT Id, FirstName, LastName, Email
            FROM Contact
            WHERE FirstName = 'Test'
            LIMIT 10
        ];
        
        if (testContacts.isEmpty()) {
            System.debug('No test contacts found');
            return;
        }
        
        System.debug('Found ' + testContacts.size() + ' test contacts. Launching parallel booking jobs...');
        
        // Launch a booking job for each contact
        for (Contact c : testContacts) {
            System.enqueueJob(new BookingQueueableWithLock(sessionId, c.Id));
        }
    }
    
    /**
     * @description Queueable class that creates a booking with record locking
     */
    public class BookingQueueableWithLock implements Queueable {
        private Id sessionId;
        private Id contactId;
        
        public BookingQueueableWithLock(Id sessionId, Id contactId) {
            this.sessionId = sessionId;
            this.contactId = contactId;
        }
        
        public void execute(QueueableContext context) {
            try {
                // Lock the session record to prevent conflicts
                Session__c sessionLock = [
                    SELECT Id, Name, Capacity__c
                    FROM Session__c
                    WHERE Id = :sessionId
                    FOR UPDATE
                ];

                // Count existing bookings for this session
            Integer currentBookings = [
                SELECT COUNT() 
                FROM Booking__c 
                WHERE Session__c = :sessionId
                WITH USER_MODE
            ];
                
                // Add a 30-second delay to simulate longer processing time
                System.debug('Adding 30-second delay for contact: ' + contactId);
                Long startTime = System.currentTimeMillis();
                Long delayInMilliseconds = 30 * 1000; // 30 seconds
                while (System.currentTimeMillis() - startTime < delayInMilliseconds) {
                    // Actively wait to simulate processing time
                }
                System.debug('Delay complete for contact: ' + contactId);
                
                if (sessionLock.Capacity__c != null && currentBookings >= sessionLock.Capacity__c) {
                    System.debug('Session is at full capacity. Cannot create new booking for contact: ' + contactId);
                    return;
                }
                
                // Check for existing bookings for this contact and session
                List<Booking__c> existingBookings = [
                    SELECT Id 
                    FROM Booking__c 
                    WHERE Session__c = :sessionId 
                    AND Contact__c = :contactId
                    LIMIT 1
                ];
                
                if (!existingBookings.isEmpty()) {
                    System.debug('A booking already exists for contact: ' + contactId);
                    return;
                }
                
                // Create booking record
                Booking__c newBooking = new Booking__c();
                newBooking.Session__c = sessionId;
                newBooking.Contact__c = contactId;
                newBooking.Status__c = 'COMPLETED';
                
                // Insert the record
                insert as system newBooking;
                
                System.debug('Created booking for contact: ' + contactId + ' with booking ID: ' + newBooking.Id);
                
            } catch (Exception e) {
                System.debug('Error in BookingQueueableWithLock: ' + e.getMessage() + ' - ' + e.getStackTraceString());
            }
        }
    }
}