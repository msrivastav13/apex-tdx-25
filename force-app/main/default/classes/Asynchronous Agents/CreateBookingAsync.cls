public with sharing class CreateBookingAsync {
    
    // Inner class to handle the request parameters
    public class Request {
        @InvocableVariable(label='Session ID' description='The ID of the session for which the booking is being created' required=true)
        public Id sessionId;
        
        @InvocableVariable(label='Contact ID' description='The ID of the contact for whom the booking is being created' required=true)
        public Id contactId;
    }
    
    // Inner class to handle the response
    public class Response {
        @InvocableVariable(label='Booking Record' description='The created booking record')
        public Booking__c bookingRecord;
        
        @InvocableVariable(label='Success' description='Indicates if the booking was successful')
        public Boolean success;
        
        @InvocableVariable(label='Message' description='Informational message about the booking operation')
        public String message;
        
        // Public constructor
        public Response() {
            this.bookingRecord = null;
            this.success = false;
            this.message = '';
        }
    }
    
    /**
     * @description Creates a booking record based on the provided request
     * @param requests List of Request objects containing sessionId and contactId
     * @return List of Response objects containing the created booking records
     */
    @InvocableMethod(label='Create Booking' description='Creates a booking record for a session and contact')
    public static List<Response> createBookings(List<Request> requests) {
        List<Response> responses = new List<Response>();
        
        for (Request req : requests) {
            responses.add(createSingleBooking(req));
        }
        
        return responses;
    }
    
    /**
     * @description Helper method to create a single booking
     * @param req Request object containing sessionId and contactId
     * @return Response object containing the created booking record
     */
    private static Response createSingleBooking(Request req) {
        Response response = new Response();
        
        try {
            // Validate request parameters
            if (req == null || req.sessionId == null || req.contactId == null) {
                response.message = 'Invalid request parameters';
                return response; // Return empty response
            }
            
            // Check for existing bookings to prevent double booking
            List<Booking__c> existingBookings = [
                SELECT Id, Name, Status__c 
                FROM Booking__c 
                WHERE Session__c = :req.sessionId 
                AND Contact__c = :req.contactId
                WITH USER_MODE
                LIMIT 1
            ];
            
            if (!existingBookings.isEmpty()) {
                // Booking already exists for this session and contact
                response.bookingRecord = existingBookings[0];
                response.success = false;
                response.message = 'A booking already exists for this contact and session';
                return response;
            }
            
            // Check session capacity
            // Get session capacity
            Session__c session = [
                SELECT Id, Capacity__c 
                FROM Session__c 
                WHERE Id = :req.sessionId
                WITH USER_MODE
                LIMIT 1
            ];
            
            // Count existing bookings for this session
            Integer currentBookings = [
                SELECT COUNT() 
                FROM Booking__c 
                WHERE Session__c = :req.sessionId
                WITH USER_MODE
            ];
            
            // Check if session is at capacity
            if (session.Capacity__c != null && currentBookings >= session.Capacity__c) {
                response.success = false;
                response.message = 'Session is at full capacity. Cannot create new booking.';
                return response;
            }
            
            // Create booking record
            Booking__c newBooking = new Booking__c();
            newBooking.Session__c = req.sessionId;
            newBooking.Contact__c = req.contactId;
            newBooking.Status__c = 'PENDING'; // Set initial status
            
            // Insert the record
            insert as user newBooking;
            
            // Retrieve the complete record with generated Name field
            Booking__c insertedBooking = [
                SELECT Id, Name, Status__c, Session__c, Contact__c
                FROM Booking__c 
                WHERE Id = :newBooking.Id
                WITH USER_MODE
                LIMIT 1
            ];
            
            // Enqueue the asynchronous job to process the booking
            Id jobId = BookingQueueable.enqueueBookingProcess(insertedBooking.Id);
            
            // For additional tracking, you could store the job ID on the booking record
            if (jobId != null) {
                insertedBooking.Job_ID__c = jobId; // Assuming you have this field on the Booking__c object
                try {
                    update as user insertedBooking;
                } catch (Exception e) {
                    // Just log error but continue - this is not critical
                    System.debug('Could not update booking with job ID: ' + e.getMessage());
                }
            }
            
            // Set the booking record on the response
            response.bookingRecord = insertedBooking;
            response.success = true;
            response.message = 'Booking created successfully';
                
        } catch (Exception e) {
            // Log error but return empty response
            System.debug('Error creating booking: ' + e.getMessage());
            response.message = 'Error creating booking: ' + e.getMessage();
        }
        
        return response;
    }
}