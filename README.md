# CNTF - Stress Test

## Purpose
This source code repository stores the configurations to load thousands of User Equipment devices (UEs) to the 5g network while simultaneously uploading data to a webserver. This test gives insights on how well a 5g network can maintain quick upload speeds under heavy traffic.

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
* To view the parsed & visualized data resulting from tests run by various CNTF repositories, please visit CNTF's dedicated Coralogix tenant: https://dish-wireless-network.atlassian.net/wiki/spaces/MSS/pages/543326302/Coralogix+BOAT+Change+Request 
    * Note: *You must have an individual account created by Coralogix to gain access to this tenant.*
    
Steps to view dashboards:
1. At the top of the page select the dropdown next to "Dashboards"
2. Select "Custom Dashboards" (All dashboards should have the tag "CNTF")

* To view raw data resulting from test runs, please look at the data stored in AWS S3 buckets dedicated to CNTF.


## Project Structure
```
├── open5gs
|   ├── infrastructure                 contains infrastructure-as-code and helm configurations for open5gs & ueransim
|      	├── eks
|           └── fluentd-override.yaml  configures fluentd daemonset within the cluster
|           └── otel-override.yaml     configures opentelemtry daemonset within the cluster
|           └── provider.tf
|           └── main.tf                    
|           └── variables.tf                
|           └── outputs.tf 
|           └── versions.tf
|
└── .gitlab-ci.yml                     contains configurations to run CI/CD pipeline
|
|
└── README.md  
|
|
└── open5gs_values.yml                 these values files contain configurations to customize resources defined in the open5gs & ueransim helm charts
└── openverso_ueransim_gnb_values.yml                 
└── openverso_ueransim_ues_values.yml 
|
|
└── stress_test.sh                     loads ten thousand ues on the 5g network while simultaneously making HTTP requests to webservers
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
└── cntf_tests_namespace.yaml          creates a namespace called "cntf-tests" where a new deployment of ueransim and 5g core is made and is tested via the stress_test.sh script
|  
|
└── update_s3_test_results.sh          updates test result data from stress test both locally and in aws       
