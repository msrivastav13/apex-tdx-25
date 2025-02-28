# Apex Best Practices for Apps and Agents

## TDX 25 Conference Materials

This repository contains code examples and demonstrations for the TDX 25 talk: **"Deep Dive into Apex Best Practices for Apps and Agents"**. The examples showcase advanced patterns for asynchronous Apex development, concurrency control, and robust agent implementation.

## Overview

This project demonstrates industry best practices for building scalable, maintainable, and robust applications on the Salesforce platform, with a specific focus on asynchronous processes and agent patterns. The examples cover:

- Queueable Apex patterns with proper error handling
- Batch Apex with conflict prevention
- Platform Event processing with retry mechanisms
- Row locking strategies for transaction integrity
- Asynchronous booking agents with concurrency control
- Robust finalizer implementation for error recovery

## Repository Structure

- **`force-app/main/default/classes/`**: Contains the Apex classes organized by pattern type
  - **`Asynchronous Agents/`**: Classes for implementing asynchronous booking agents
  - **`Asynchronous Apex/`**: Core asynchronous patterns including Queueable and Batch implementations
  - **`Platform Events/`**: Classes demonstrating platform event processing
  - **`Row Locks/`**: Examples of row locking patterns for transaction integrity
  - **`Debugging Async Jobs/`**: Utilities for debugging asynchronous processes
  
- **`force-app/main/default/triggers/`**: Platform event triggers
  
- **`scripts/apex/`**: Anonymous Apex scripts to demonstrate and execute the examples

## Key Concepts Demonstrated

### 1. Asynchronous Booking Pattern

The `CreateBookingAsync` and `BookingQueueable` classes demonstrate a robust pattern for creating booking records asynchronously, with proper state handling and error recovery.

### 2. Concurrency Control

`AgentConcurrency` shows how to implement row locking to manage concurrent operations, preventing race conditions and ensuring data integrity.

### 3. Queueable Best Practices

`RobustQueueableExample` and `ChainableQueueable` showcase best practices for implementing queueable jobs with:
- Proper depth control
- Deduplication to prevent duplicate processing
- Finalizers for error handling and recovery
- Chainable job patterns

### 4. Row Locking with Callouts

The examples in `ForUpdateQueueableWithCallout` and `ForUpdateQueueableCalloutWithSavePoint` demonstrate how to properly manage database locks when making callouts.

### 5. Batch Apex with Conflict Prevention

`DataProcessingBatch` implements a pattern to prevent multiple instances of the same batch job from running concurrently.

### 6. Platform Event Processing

`PlatformEventDemo` and the `LowInkTrigger` demonstrate best practices for processing platform events with proper error handling and retry mechanisms.

## How to Use These Examples

Each example can be tested using the corresponding anonymous Apex script in the `scripts/apex/` directory:

- **AgentConcurreny.apex**: Tests the concurrent booking agent
- **ChainableQueueable.apex**: Demonstrates chaining queueable jobs
- **DataProcessingBatch.apex**: Executes the batch job with conflict prevention
- **PlatformEvent.apex**: Publishes sample platform events
- **RobustQueueableExample.apex**: Demonstrates the robust queueable pattern

## Prerequisites

- Salesforce Developer Account or Scratch Org
- Salesforce CLI installed
- Custom objects for Booking__c and Session__c

## Deployment

To deploy this code to your org:

```bash
sfdx force:source:deploy -p force-app -u your-org-alias
```

## Running the Examples

To execute any of the anonymous Apex examples:

```bash
sfdx force:apex:execute -f scripts/apex/[script-name].apex -u your-org-alias
```

## Resources

- [Salesforce Apex Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/)
- [Queueable Apex Documentation](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_queueing_jobs.htm)
- [Platform Events Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.platform_events.meta/platform_events/)
- [Batch Apex Documentation](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_batch_interface.htm)

## About TDX 25

Trailblazer DX (TDX) is Salesforce's premier developer conference, bringing together developers, architects, administrators, and partners to learn about the latest innovations and best practices on the Salesforce Platform.

---

## License

This project is licensed under the Creative Commons License - see [Creative Commons Attribution 4.0 International License](https://creativecommons.org/licenses/by/4.0/) for details.
