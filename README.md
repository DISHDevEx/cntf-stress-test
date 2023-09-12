# CNTF - Stress Test

## Purpose
This source code repository stores the configurations to load thousands of User Equipment devices (UEs) to the 5g network while also uploading data to a webserver. This test gives insights on how well a 5g network can maintain quick upload speeds under heavy traffic.

## Deployment
Prerequisites:

* *Please ensure that you have configured the AWS CLI to authenticate to an AWS environment where you have adequate permissions to create an EKS cluster, security groups and IAM roles*: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-quickstart.html
* *Please ensure that the pipeline in the "CNTF-Main" repository has been successfully deployed, as this ensures that all necessary components are available to support the execution of scripts in this repository.*  


Steps:
1. Mirror this repository in Gitlab or connect this repository externally to Gitlab 
2. Authenticate Gitlab with AWS: https://docs.gitlab.com/ee/ci/cloud_deployment/
3. Perform these actions inside of the Gitlab repository:
    * On the left side of the screen click the drop-down arrow next to "Build" and select "Pipelines"
    * In the top right hand corner select "Run Pipeline"
    * In the drop-down under "Run for branch name or tag" select the appropriate branch name and click "Run Pipeline"
    * Once again, click the drop-down arrow next to "Build" and select "Pipelines", you should now see the pipeline being executed


## Coralogix Dashboards
To view parsed & visualized data resulting from tests run by various CNTF repositories, please visit CNTF's dedicated Coralogix tenant: https://dish-wireless-network.atlassian.net/wiki/spaces/MSS/pages/543326302/Coralogix+BOAT+Change+Request 
    * Note: *You must have an individual account created by Coralogix to gain access to this tenant.*
    
Steps to view dashboards:
1. At the top of the page select the dropdown next to "Dashboards"
2. Select "Custom Dashboards" (All dashboards should have the tag "CNTF")

Raw data: To view raw data resulting from test runs, please look at the data stored in AWS S3 buckets dedicated to CNTF.


## Project Structure
```
└── .gitlab-ci.yml                     contains configurations to run CI/CD pipeline
|
|
└── README.md  
|
|
└── stress_test.sh                     uploads 3MB of data to a postman endpoint, while doing calculations to predict the maximum upload speed of the network (MBps)
|  
|
└── stress_test_error_logs.json        file which stores standard error logs from "stress_test.sh" test locally 
|
|
└── stress_test_logs.json              file which stores standard output logs from "stress_test.sh" test locally
|
|
└── s3_test_results_coralogix.py       converts local files into s3 objects 
|  
|
└── update_test_results.sh             updates test results both locally and in aws  
|  
|
└── random_data.txt                    stores 3MB worth of data which gets uploaded to postman endpoint   
|  
|
└── load_test.sh                       loads network with thousands of ues
|  
|
└── time_to_populate_database.txt      local storage file for collecting logs relating to the time it takes for new ues to be registered on the network 
```
## Gitlab CI
**Pipeline Stages:**

* load_network - subscribes thousands of UEs to the network
* send_data - send 3MB data file to Postman endpoint
* update_tests - update test results locally and in AWS
* cleanup - removes all UE subscriptions from network database
