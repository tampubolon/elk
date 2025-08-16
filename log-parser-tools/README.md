# Parser Tool
I create a golang CLI tool and a python script for parsing the log.

## Golang CLI
This CLI tool is designed to help Site Reliability Engineers (SREs) parse raw log files, transform them into structured JSON suitable for ingestion into Elasticsearch, and compute useful metrics such as error rates, average response times, and total transactions.

### Features
Parse logs: Converts raw log files into Elasticsearch Bulk API JSON format.

Compute metrics: Extracts key metrics (error rate, average response time, transaction count) from logs and outputs them in JSON.


### Prerequisites
Go installed (version 1.20+ recommended)

### Setup

Clone this repository and install dependencies:
```
git clone <your-repo-url>
cd <your-repo-folder>
go mod init logcli
go mod tidy
```

### Build
```
go build -o sawitpro main.go
```
This will generate a binary named sawitpro.


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



## Python Script
`parser.py`
