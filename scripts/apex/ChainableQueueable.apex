// Triggering the queueable chain with an initial execution count and unique job ID
//Get info about the current request
Request reqInfo = Request.getCurrent();

//Get the identifier for this request, which is universally unique
//Same as REQUEST_ID in event monitoring
String currentRequestId = reqInfo.getRequestId();

System.enqueueJob(new ChainableQueueable(1, currentRequestId));