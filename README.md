## ELK Stack

#### Demo
Below screen recording video is ELK demo, it shows the ingested logs, dashboard, infrastructure monitoring and ELK cluster info:
![alt text](assets/sawitpro-elk.gif)

#### EKS Cluster Access Credential
You can access the ELK cluster from:
- Cluster: http://34.86.95.104:5601/
- Username: `sawitpro`
- Password: `SawitProTeam2025`

#### Step to Setup ELK Infrastructure
This ELK infrastructure runs on top of GCP VM. 
The ELK stack run using Docker container managed by Docker Compose.
Step to setup this ELK infrastructure:
- Provision GCP VM from GCP console
- Setup correct firewall for the VM to make Kibana accessible from internet.
- Access the VM using SSH.
- Clone this repo into the VM
- Add `.env` into the root folder of this project, the file should look like below:
    ```
    # Password for the 'kibana_system' user (at least 6 characters)
    KIBANA_PASSWORD=changeme

    # Version of Elastic products
    STACK_VERSION=8.18.4

    # Set the cluster name
    CLUSTER_NAME=sawitpro-martinus-elk

    # Set to 'basic' or 'trial' to automatically start the 30-day trial
    LICENSE=basic
    #LICENSE=trial

    # Port to expose Elasticsearch HTTP API to the host
    ES_PORT=9200

    # Port to expose Kibana to the host
    KIBANA_PORT=5601

    # Increase or decrease based on the available host memory (in bytes)
    ES_MEM_LIMIT=1073741824
    KB_MEM_LIMIT=1073741824
    LS_MEM_LIMIT=1073741824

    # SAMPLE Predefined Key only to be used in POC environments
    ENCRYPTION_KEY=c34d38b3a14956121ff2170e5030b471551370178f43e5626eec58b04a30fae2
    ```
    - run `docker-compose` on root folder of this project (where docker compose file located):
    ```
    docker-compose up -d
    ```
    - Access Kibana from GCP VM Public IP.
    - Setup Elasticsearch `index` for log, upload parsed log, setup `data view`, and `dashboard`.


### Dashboard
ELK Dashboard can be access from (this link)[http://34.86.95.104:5601/app/dashboards#/view/5c15b215-6b75-4c57-a0b6-79d530b19667?_g=(filters:!(),refreshInterval:(pause:!f,value:10000),time:(from:now-15m,to:now))]   
![alt text](assets/image.png) 

#### Reference
- https://www.elastic.co/blog/getting-started-with-the-elastic-stack-and-docker-compose

