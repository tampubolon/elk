import re

input_file = "sample.log"
output_file = "parsed_sample.json"

with open(input_file, "r") as f:
    lines = f.readlines()

with open(output_file, "w") as f:
    for idx, line in enumerate(lines, start=1):
        # Regex to parse the log line
        match = re.match(r'(\S+ \S+)\s+(\S+)\s+(\d+)\s+(\d+)ms\s+(\S+)\s+(\S+)\s+(.+)', line)
        if match:
            timestamp, microservice, status, response_time, user_id, trans_id, description = match.groups()
            # Write the Elasticsearch bulk action line
            f.write(f'{{ "index": {{ "_index": "ecommerce-index", "_id": "{idx}" }} }}\n')
            # Write the log JSON line
            f.write(
                f'{{ "timestamp": "{timestamp}", "microservice": "{microservice}", '
                f'"status": {status}, "response_time": {response_time}, '
                f'"user_id": "{user_id}", "transaction_id": "{trans_id}", '
                f'"description": "{description}" }}\n'
            )

print(f"Parsed logs written to {output_file}")