// Create an instance of the batch class
DataProcessingBatch batchJob = new DataProcessingBatch();

// Execute the batch job with a specified batch size (e.g., 200 records per batch)
Database.executeBatch(batchJob, 10);