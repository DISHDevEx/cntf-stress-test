# CNTF - Stress Test

## Purpose
This source code repository stores the configurations to load ten thousand User Equipment devices (UEs) to the 5g network while simultaneously uploading data packets to webservers.

## Deployment
Prerequisites:

* *Please ensure that you have configured the AWS CLI to authenticate to an AWS environment where you have adequate permissions to create a cluster, security groups and IAM roles.*

* *Please ensure that the "CNTF-Main" branch has been deployed, as this ensures that the cluster and other necessary AWS infrastructure are available to support the execution of scripts in this repository.*  

Steps:
1. Mirror this repository in Gitlab or connect this repository externally to Gitlab 
2. Authenticate Gitlab with AWS: https://docs.gitlab.com/ee/ci/cloud_deployment/
3. In Gitlab, click the drop-down arrow next to "Build" and select "Pipelines"
4. In the top right hand corner select "Run Pipeline"
5. In the drop-down under "Run for branch name or tag" select the appropriate name for this branch and click "Run Pipeline"
6. Once again, click the drop-down arrow next to "Build" and select "Pipelines", you should now see the pipeline being executed


## Project structure
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
└── cntf_tests_namespace.yaml          creates a namespace called "cntf-tests" where a new deployment of ueransim and open5gs is made and is tested via the stress_test.sh script
|  
|
└── update_s3_test_results.sh          updates test result data from stress test both locally and in aws       
