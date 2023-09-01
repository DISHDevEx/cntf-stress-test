#!/usr/bin/env bash
set -e 

# this script connects 10k UEs to open5GS and pings yahoo everytime a new UE is subscribed.

generate_random_imsi() {
    digits=10
    current_time=$(date +%s)
    random_number=$((current_time * (1 + RANDOM % 10000)))
    while [ ${#random_number} -lt 12 ]; do
        random_number="${random_number}$(shuf -i 0-9 -n 1)"
    done
    imsi_id="${random_number:0:$digits}"
    echo $imsi_id
}

run_helm_commands() {
    echo "command helm running with ${imsi_id}"

    helm_template_command="helm template -n cntf-tests ueransim-10k-test openverso/ueransim-ues \
        --set ues.initialMSISDN=${imsi_id} \
        --values https://raw.githubusercontent.com/DISHDevEx/napp/main/napp/open5gs_values/gnb_ues_values.yaml"

    helm_upgrade_command="helm -n cntf-tests upgrade --install ueransim-10k-test openverso/ueransim-ues \
        --set ues.initialMSISDN=${imsi_id} \
        --values https://raw.githubusercontent.com/DISHDevEx/napp/main/napp/open5gs_values/gnb_ues_values.yaml"

    echo "Running helm template command: ${helm_template_command}"
    $helm_template_command

    echo "Running helm upgrade command: ${helm_upgrade_command}"
    $helm_upgrade_command
}

ue_populate() {
  echo "command ue_populate running with ${imsi_id}"
  populate_pod_name=$(kubectl -n cntf-tests get pod --output=jsonpath={.items..metadata.name} -l app.kubernetes.io/component=populate)

  if [ $? -eq 0 ]; then 
    kubectl -n cntf-tests exec $populate_pod_name -- open5gs-dbctl add_ue_with_slice $imsi_id 465B5CE8B199B49FAA5F0A2EE238A6BC E8ED289DEBA952E4283B54E88E6183CA internet 1 111111
  fi
}

for _ in {1..10}; do
    generate_random_imsi
    ue_populate
    echo "Subscribing UE with IMSI: ${imsi_id}"
    echo "stress_test_ue_subscribed: ${imsi_id}" > stress_test_logs.json
    sh ./update_s3_test_results.sh 
    run_helm_commands
    echo "Allocating IMSI: ${imsi_id} to UE with helm"
    echo "stress_test_ue_connected: ${imsi_id}" > stress_test_logs.json
    sh ./update_s3_test_results.sh 

    data_size_in_bytes=$((3 * 1024 * 1024))  # 3MB in bytes

    # Generate random data to simulate the upload
    random_data=$(openssl rand -base64 $data_size_in_bytes | tr -d '\n')

    # Only create random_txt file if it does not exist
    if [ ! -e random_data.txt ]; then
        # Generate random data to simulate the upload
        random_data=$(openssl rand -base64 $data_size_in_bytes | tr -d '\n')

        # Write random_data to a file
        echo "$random_data" > random_data.txt

        echo "Random data has been saved to random_data.txt"
    else
        echo "random_data.txt already exists. Skipping generation."
    fi

    # upload_speed is measured in bytes/seconds 
    upload_speed=$(curl -w '%{speed_upload}' -T random_data.txt https://postman-echo.com/post)

    # change bytes/seconds to mb/seconds 
    upload_speed_mb=$(echo "scale=2; $upload_speed / 125000" | bc)

    #write logs to stess_test_logs file
    echo "stress_test_upload_speed: $upload_speed_mb MB/s" > stress_test_logs.json

    #update s3 with test results 
    sh ./update_s3_test_results.sh 

    
    # # Add ping command to yahoo.com
    # ping_command="ping -c 5 yahoo.com"
    # echo "Executing ping command: $ping_command"
    # ping_output="$($ping_command)"
    # ping_output_no_linebreaks="${ping_output//$'\n'/ }"  # Replace newline with space
    # ping_json='{"ping_output": "'"$ping_output_no_linebreaks"'", "test": "stress_test"}'

    # echo "$ping_json" > stress_test_logs.json || { echo "Error message" > stress_test_error_logs.json; } # this outputs the logs from each ping to "stress_test_logs.json" and any error logs to "stress_test_error_logs.json"
    
done
