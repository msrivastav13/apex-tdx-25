public with sharing class BookingQueueable implements Queueable {
    private Id bookingId;
    
    /**
     * @description Constructor for the BookingQueueable class
     * @param bookingId The ID of the booking to process
     */
    public BookingQueueable(Id bookingId) {
        this.bookingId = bookingId;
    }
    
    /**
     * @description Main execute method for Queueable
     * @param context The QueueableContext
     */
    public void execute(QueueableContext context) {
        String jobId = context.getJobId();
        System.debug('BookingQueueable job started with ID: ' + jobId);
        
        // Update the booking with the current job ID - no need to query first
        // Create booking object with just the fields we need to update
        Booking__c booking = new Booking__c(
            Id = bookingId,
            Job_ID__c = jobId
        );
        update booking;
        
        // Attach the RetryFinalizer
        RetryFinalizer finalizer = new RetryFinalizer();
        System.attachFinalizer(finalizer);
        
        try {
            // Simulate processing time (sleep for 10 seconds)
            Long startTime = System.currentTimeMillis();
            Long endTime = startTime + 10000; // 10 seconds in milliseconds
            
            while (System.currentTimeMillis() < endTime) {
                // This is a simple way to pause execution
                // In a real implementation, you might want to use a more efficient approach
                // or implement true asynchronous waiting
            }
            
            // Update the booking status to 'COMPLETED' - no need to query first
            Booking__c updatedBooking = new Booking__c(
                Id = bookingId,
                Status__c = 'COMPLETED'
            );
            update updatedBooking;
            
            System.debug('Booking status updated to COMPLETED for ID: ' + bookingId);
        } catch (Exception e) {
            System.debug('Error in BookingQueueable: ' + e.getMessage());
            throw e; // Let the finalizer handle retry logic
        }
    }
    
    /**
     * @description Static method to enqueue the BookingQueueable with deduplication
     * @param bookingId The ID of the booking to process
     * @return Id The ID of the enqueued job
     */
    public static Id enqueueBookingProcess(Id bookingId) {
        // Set up AsyncOptions with deduplication
        AsyncOptions options = new AsyncOptions();
        options.DuplicateSignature = QueueableDuplicateSignature.Builder()
            .addId(bookingId) // Use booking ID as part of signature
            .addString('BookingQueueable')
            .build();
            
        // Enqueue the job with deduplication
        return System.enqueueJob(new BookingQueueable(bookingId), options);
    }
    
    /**
     * @description Finalizer class to handle retry logic for failed queueable jobs
     */
    public with sharing class RetryFinalizer implements Finalizer {
        private final Integer maxRetries = 3;
        
        public void execute(FinalizerContext context) {
            Id parentJobId = context.getAsyncApexJobId();
            
            if (context.getResult() == ParentJobResult.UNHANDLED_EXCEPTION) {
                System.debug('Job failed with ID: ' + parentJobId);
                
                // Get the AsyncApexJob to check retry count
                AsyncApexJob job = [
                    SELECT Id, NumberOfErrors, ExtendedStatus
                    FROM AsyncApexJob 
                    WHERE Id = :parentJobId
                ];
                
                System.debug('Job status: ' + job.ExtendedStatus);
                
                // Check if we should retry
                if (job.NumberOfErrors <= maxRetries) {
                    // Get the booking ID associated with this job
                    Id bookingId = getBookingIdForJob(parentJobId);
                    
                    if (bookingId != null) {
                        System.debug('Retrying job for booking: ' + bookingId);
                        
                        // Re-enqueue with same deduplication signature
                        AsyncOptions options = new AsyncOptions();
                        options.DuplicateSignature = QueueableDuplicateSignature.Builder()
                            .addId(bookingId)
                            .addString('BookingQueueable')
                            .build();
                            
                        System.enqueueJob(new BookingQueueable(bookingId), options);
                    } else {
                        System.debug('Unable to find booking ID for failed job: ' + parentJobId);
                    }
                } else {
                    System.debug('Max retries exceeded. Not retrying.');
                    handleMaxRetries(parentJobId);
                }
            } else {
                System.debug('Job completed successfully');
            }
        }
        
        /**
         * @description Get the booking ID associated with a job
         * @param jobId The ID of the job
         * @return Id The booking ID associated with the job
         */
        private Id getBookingIdForJob(Id jobId) {
            // Query the Booking__c object directly using Job_ID__c field
            List<Booking__c> bookings = [
                SELECT Id 
                FROM Booking__c 
                WHERE Job_ID__c = :jobId
                LIMIT 1
            ];
            
            if (!bookings.isEmpty()) {
                return bookings[0].Id;
            }
            
            return null;
        }
        
        /**
         * @description Handle the case where max retries have been exceeded
         * @param jobId The ID of the failed job
         */
        private void handleMaxRetries(Id jobId) {
            // Get the booking ID by querying the Job_ID__c field
            Id bookingId = getBookingIdForJob(jobId);
            
            if (bookingId != null) {
                // As we only have PENDING and COMPLETED statuses per requirements,
                // we'll keep it as PENDING for failed jobs, but add an error message
                // in the debug logs
                Booking__c booking = new Booking__c(
                    Id = bookingId,
                    Status__c = 'PENDING'
                );
                update booking;
                
                System.debug('FAILURE: Max retries exceeded for booking: ' + bookingId + '. Status left as PENDING.');
            }
        }
    }
}