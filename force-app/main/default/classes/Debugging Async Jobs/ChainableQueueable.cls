public class ChainableQueueable implements Queueable {
    Integer executionNumber;
    String jobId;

    // Constructor to accept execution number and job identifier
    public ChainableQueueable(Integer executionNumber, String jobId) {
        this.executionNumber = executionNumber;
        this.jobId = jobId;
    }

    public void execute(QueueableContext context) {
        // Log the execution number and job ID
        System.debug(
            'Execution Number: ' + executionNumber + ', Job ID: ' + jobId
        );

        // Chain another Queueable if execution count is less than 5
        if (executionNumber < 5) {
            System.enqueueJob(
                new ChainableQueueable(executionNumber + 1, jobId)
            );
        }
    }
}
