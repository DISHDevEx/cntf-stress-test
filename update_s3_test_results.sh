#!usr/bin/env bash

# this script updates the objects in the s3 bucket "cntf-open5gs-coralogix-test-results" with any changes made to their corresponding local files. 

udpate_s3() {
   aws s3 cp ./stress_test_logs.json s3://cntf-open5gs-test-results/stress_test_logs.json
   aws s3 cp ./stress_test_error_logs.json s3://cntf-open5gs-test-results/stress_test_error_logs.json
}

udpate_s3
