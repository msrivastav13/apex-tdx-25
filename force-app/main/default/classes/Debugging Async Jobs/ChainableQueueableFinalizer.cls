public class ChainableQueueableFinalizer implements Finalizer {
    String jobId;

    // Constructor to accept job identifier
    public ChainableQueueableFinalizer(String jobId) {
        this.jobId = jobId;
    }

    public void execute(FinalizerContext finalizerContext) {
        // Log when the finalizer is executed
        System.debug('Finalizer triggered for Job ID: ' + jobId + ', Apex Job ID: ' + finalizerContext.getAsyncApexJobId());
    }
}
