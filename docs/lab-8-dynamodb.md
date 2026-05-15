# Lab 8: DynamoDB (NoSQL & Scalability)

## Objective
Build a serverless, highly scalable NoSQL database and understand key performance patterns like partitioning, sorting, and secondary indexing.

## Architecture
![Lab 8 Architecture](../diagrams/lab-8-dynamodb.svg)

## Key Concepts

### 1. Amazon DynamoDB
A serverless, key-value and document database that delivers single-digit millisecond performance at any scale. It is fully managed and multi-region.

### 2. Partition Key (PK) & Sort Key (SK)
- **Partition Key (Hash Key):** Determines which physical partition the data is stored in. Essential for scalability.
- **Sort Key (Range Key):** Allows you to store multiple items under the same partition key and perform complex range queries (e.g., "get all orders for User 123 placed in May").

### 3. Billing Modes (SAA Exam Focus)
- **On-Demand (Pay-per-request):** Truly serverless. You pay for read/write requests. Best for unpredictable workloads.
- **Provisioned (RCU/WCU):** You specify the capacity. Best for predictable traffic and cost control.

### 4. Global Secondary Index (GSI)
Allows you to query the table using a different Partition Key and Sort Key than the main table. GSIs are essential for supporting multiple access patterns.

### 5. Time to Live (TTL)
Allows you to define a timestamp after which an item is automatically deleted. This helps reduce storage costs and manage data lifecycle without any code.

## Implementation Details
- **Table Name:** `lab-orders-table`
- **PK:** `PK` (String)
- **SK:** `SK` (String)
- **GSI:** `StatusIndex` (Query by Status)
- **Billing:** Pay-per-request (On-demand)

## SAA Exam Takeaways
- **DynamoDB is highly available** across 3 AZs by default.
- **Eventual Consistency vs. Strong Consistency:** Default is eventual; strong consistency can be requested but uses more capacity.
- **Hot Partitions:** Occur when too much traffic hits a single partition key. Distributing PKs evenly is critical.
- **DAX (DynamoDB Accelerator):** An in-memory cache for DynamoDB to achieve microsecond performance.
