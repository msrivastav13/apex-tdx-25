public class RobustQueueableExample implements Queueable {
    // Main execute method for Queueable
    public void execute(QueueableContext context) {
        String jobId = context.getJobId();
        System.debug('Queueable job started with ID: ' + jobId);

        // Attach the RetryFinalizer
        RetryFinalizer finalizer = new RetryFinalizer();
        System.attachFinalizer(finalizer);

        Integer currentDepth = System.AsyncInfo.getCurrentQueueableStackDepth();
        System.debug('Current depth: ' + currentDepth);

        // Deduplication to avoid running the same logic more than once for the same job
        AsyncOptions options = new AsyncOptions();
        options.DuplicateSignature = QueueableDuplicateSignature.Builder()
            .addId(UserInfo.getUserId())
            .addString('DemoQueueable')
            .build();

        // Depth control logic (only enqueue another job if within depth limit)
        if (currentDepth < System.AsyncInfo.getMaximumQueueableStackDepth()) {
            // Enqueue the next job with deduplication but without resetting depth
            System.enqueueJob(new RobustQueueableExample(), options);
        } else {
            System.debug(
                'Max depth reached. No more jobs enqueued for Job Id ' + jobId
            );
        }
    }

    // Static method to initialize the process with depth control and deduplication
    public static void startProcess(Integer depth) {
        // Start the queueable process with depth control and deduplication
        AsyncOptions asyncOptions = new AsyncOptions();
        asyncOptions.MaximumQueueableStackDepth = depth;
        asyncOptions.DuplicateSignature = QueueableDuplicateSignature.Builder()
            .addId(UserInfo.getUserId())
            .addString('DemoQueueable')
            .build();

        // Enqueue the first job with depth control and deduplication
        System.enqueueJob(new RobustQueueableExample(), asyncOptions);
    }
}
