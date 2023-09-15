# CNTF - Stress Test

## Purpose
This source code repository stores the configurations to load thousands of User Equipment devices (UEs) to the 5g network while also uploading data to a webserver. This test gives insights on how well a 5g network can maintain quick upload speeds under heavy traffic.

## Deployment
Prerequisites:
* *Please ensure that you have configured the [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-quickstart.html) to authenticate to an AWS environment where you have adequate permissions to create an EKS cluster, security groups and IAM roles* 
* *Please ensure that the pipeline in the "CNTF-Main" repository has been successfully deployed, as this ensures that all necessary components are available to support the execution of scripts in this repository.*  


Steps:
1. [Mirror](https://docs.gitlab.com/ee/user/project/repository/mirror/) this repository OR connect it [externally](https://docs.gitlab.com/ee/ci/ci_cd_for_external_repos/) to Gitlab 
2. Perform a "Git clone" of this repository on your local machine
3. Set up a private Gitlab runner on the CNTF EKS cluster (***Note:*** *You only need to do this process once, this runner can be used by the other CNTF repositories you execute*):
    * In Gitlab, on the left side of the screen, hover over "settings" and select "CI/CD"
    * Next to "Runners" select "expand"
    * Unselect "Enable shared runners for this project"
    * Click "New project runner"
    * Under "Operating systems" select "Linux"
    * Fill out the "Tags" section and select "Run untagged jobs"
    * Scroll to the bottom and select "Create runner"
    * Copy and save the "runner token" listed under "Step 1"
    * Select "Go to runners page", you should now see your runner listed with a warning sign next to it under "Assigned project runners"
    * On your local terminal:
        * Install the helm gitlab repository: "helm repo add gitlab https://charts.gitlab.io"
        * intialize helm (for helm version 2): "helm init" 
        * create a namespace for your gitlab runner(s) in the cntf cluster: "kubectl create namespace <_NAMESPACE_ (e.g. "gitlab-runners")>"
        * Install your created runner via helm: 
        "helm upgrade --install <_RUNNER_NAME_> -n <_NAMESPACE_> --set runnerRegistrationToken=<_RUNNER_TOKEN_> --set gitlabUrl=http://www.gitlab.com gitlab/gitlab-runner"
        * Check to see if your runner is working: "kubectl get pods -n <_NAMESPACE_>" (you should see "1/1" under "READY" and "Running" under "STATUS")
        * Give your runner cluster-wide permissions: "kubectl apply -f gitlab-runner-rbac.yaml"
    * In Gitlab, Under "Assigned project runners" you should now see that your runner has a green circle next to it, signaling a "ready" status
    * **How to re-use this runner for other CNTF repositories:**
        * Hover over "Settings" and select "CI/CD"
        * Under "Other available runners", find the runner you have created and select "Enable for this project".

4. Authenticate [Gitlab with AWS](https://docs.gitlab.com/ee/ci/cloud_deployment/)
5. Run the CI/CD pipeline:
    * On the left side of the screen click the drop-down arrow next to "Build" and select "Pipelines"
    * In the top right hand corner select "Run Pipeline"
    * In the drop-down under "Run for branch name or tag" select the appropriate branch name and click "Run Pipeline"
    * Once again, click the drop-down arrow next to "Build" and select "Pipelines", you should now see the pipeline being executed

## Pipeline Stages
Goal of each stage in the pipeline (refer to ".gitlab-ci.yml" for more details):
* "load_network" - subscribes thousands of UEs to the network
* "send_data" - send 3MB data file to endpoint
* "update_tests" - update test results locally and in AWS
* "cleanup" - removes all UE subscriptions from network database


## Coralogix Dashboards
To view parsed & visualized data resulting from tests run by various CNTF repositories, please visit CNTF's dedicated [Coralogix tenant](https://dish-wireless-network.atlassian.net/wiki/spaces/MSS/pages/509509825/Coralogix+CNTF+Dashboards)
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
