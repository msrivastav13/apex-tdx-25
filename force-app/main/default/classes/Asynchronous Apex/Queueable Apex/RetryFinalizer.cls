public class RetryFinalizer implements Finalizer {
    // Finalize method to retry the job if it fails
    public void execute(FinalizerContext context) {
        String parentJobId = context.getAsyncApexJobId();
        if (context.getResult() == ParentJobResult.UNHANDLED_EXCEPTION) {
            System.debug('Retrying job');
            // Re-enqueue the job with updated retry count
            System.enqueueJob(new RobustQueueableExample());
        } else {
            System.debug('Finalizer: Job did not fail');
        }
    }
}
