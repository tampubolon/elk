# Parser Tool
I create a Golang CLI tool and a Python script for parsing the log. 

## 1. Golang CLI
This CLI tool is designed to help Site Reliability Engineers (SREs) parse raw log files, transform them into structured JSON suitable for ingestion into Elasticsearch, and compute useful metrics such as error rates, average response times, and total transactions.
Why chose Golang for the CLI tool?
Go is a powerful and simple language, widely used for building CLI tools in the DevOps ecosystem. Popular projects like Docker, Kubernetes, Prometheus, and Terraform rely heavily on Go for their CLI interfaces. While Go has a native flag package for handling command-line arguments, using the Cobra package makes it even easier to create structured, user-friendly CLI applications.

---

### Features
- Parse logs: Converts raw log files into Elasticsearch Bulk API JSON format.
- Compute metrics: Extracts key metrics (error rate, average response time, transaction count) from logs and outputs them in JSON.

---

### Prerequisites
Go installed (version 1.20+ recommended)

---

### Setup

Clone this repository and install dependencies:
```
git clone git@github.com:tampubolon/elk.git
cd log-parser-tool
go mod init sawitpro
go mod tidy
```

---

### Build
```
go build -o sawitpro main.go
```
This will generate a binary named sawitpro.

---

### Usage
#### Parse Log 
Converts raw logs into Elasticsearch Bulk API format.
```./sawitpro parse-log --input sample.log --output-file parsed.json```
- `--input`: Path to the raw log file.

- `--output-file`: Path to save the structured JSON (default: parsed.json).

Example output in parsed.json:
```
{ "index": { "_index": "ecommerce-index", "_id": "1" } }
{ "timestamp": "2025-08-15 13:45:00", "microservice": "checkout", "status": 200, "response_time": 120, "user_id": "user1234", "transaction_id": "tx5678", "description": "Purchased iPhone 13" }
```
#### Compute Metrics
Computes useful metrics from the log file and outputs them in JSON.
```./sawitpro compute-metrics --input sample.log --output-file metrics.json```

- `--input`: Path to the raw log file.

- `--output-file`: Path to save the metrics JSON (default: metrics.json).

Example output in metrics.json:
```
{
  "total_transactions": 1200,
  "error_rate": 0.05,
  "average_response_time": 210
}
```

---
</br>

## 2. Python Script
`parser.py`, this Python script parses a `.log` file and converts it into a `.json` file formatted for **Elasticsearch bulk ingestion**.

---

### Features
- Reads a structured log file.
- Parses each line using a regular expression.
- Generates a JSON output compatible with Elasticsearch bulk API.
- Automatically assigns unique `_id` values for each log entry.

---

### Requirements
- Python 3.x

No external packages are required; the script uses Python's built-in `re` module.

---

### Usage

1. Place your log file in the same directory as the script (default: `sample.log`).
2. Modify the `input_file` and `output_file` variables if needed:

```python
input_file = "sample.log"
output_file = "parsed_sample.json"
```

---

### Run the script
`python log_parser.py`

---

### Log Format
sampe.log format:
```
[timestamp] [microservice] [status] [response_time]ms [user_id] [transaction_id] [description]
```

Example:
```
[timestamp] [microservice] [status] [response_time]ms [user_id] [transaction_id] [description]
```

Output Format:

The generated JSON file will include Elasticsearch bulk indexing commands:
```
{ "index": { "_index": "ecommerce-index", "_id": "1" } }
{ "timestamp": "2025-08-16T12:34:56Z", "microservice": "payment", "status": 200, "response_time": 150, "user_id": "user123", "transaction_id": "txn789", "description": "Payment successful" }
```
