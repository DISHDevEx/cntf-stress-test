# CNTF - Stress Test

## Purpose
This source code repository stores the configurations to load ten thousand User Equipment devices (UEs) to the 5g network while simultaneously uploading data packets to webservers.

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
└── stress_test_error_logs.json         file which stores standard error logs from "stress_test.sh" test locally 
|
|
└── stress_test_logs.json               file which stores standard output logs from "stress_test.sh" test locally
|
|
└── s3_test_results_coralogix.py       converts local files into s3 objects 
|
|
└── cntf_tests_namespace.yaml          creates a namespace called "cntf-tests" where a new deployment of ueransim and open5gs is made and is tested via the stress_test.sh script
|  
|
└── update_s3_test_results.sh          updates test result data from stress test both locally and in aws       
