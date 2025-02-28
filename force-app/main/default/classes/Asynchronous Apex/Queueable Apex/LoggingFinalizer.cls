// Transaction Finalizer Class
public class LoggingFinalizer implements Finalizer {
    // Buffer to store log messages
    private List<String> logMessages = new List<String>();

    // Method to buffer logs
    public void addLog(String message, String jobId) {
        logMessages.add('Job ID ' + jobId + ': ' + message);
    }

    // Execute method of the Finalizer
    public void execute(FinalizerContext ctx) {
        String parentJobId = ctx.getAsyncApexJobId();
        System.debug('Finalizer executed for job ID: ' + parentJobId);

        // Output all buffered logs
        for (String log : logMessages) {
            System.debug(log);
        }
        if (ctx.getResult() == ParentJobResult.SUCCESS) {
            system.debug('Success..');
        } else {
            system.debug('Failed..');
            // Retry the job with the Failed Ids
        }

        System.debug('Finalizer completed for job ID: ' + parentJobId);
    }
}
