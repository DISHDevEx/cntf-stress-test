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
    run_helm_commands
    echo "Allocating IMSI: ${imsi_id} to UE with helm"

    # Define the upload URL
    upload_url="https://postman-echo.com/post"

    # Generate 3MB of random data
    data_size_mb=3
    data="$(dd if=/dev/urandom bs=1M count=$data_size_mb 2>/dev/null | base64)"

    # Perform the upload using curl and measure the upload speed
    upload_command="curl -X POST -d '$data' $upload_url"
    echo "Executing upload command: $upload_command"
    upload_output="$($upload_command)"

    # Prepare the output as JSON
    upload_json='{"upload_output": "'"$upload_output"'", "test": "upload_speed_test"}'

    # Display the JSON output
    echo "$upload_json" > stress_test_logs.json || { echo "Error message" > stress_test_error_logs.json; }



    # # Add ping command to yahoo.com
    # ping_command="ping -c 5 yahoo.com"
    # echo "Executing ping command: $ping_command"
    # ping_output="$($ping_command)"
    # ping_output_no_linebreaks="${ping_output//$'\n'/ }"  # Replace newline with space
    # ping_json='{"ping_output": "'"$ping_output_no_linebreaks"'", "test": "stress_test"}'

    # echo "$ping_json" > stress_test_logs.json || { echo "Error message" > stress_test_error_logs.json; } # this outputs the logs from each ping to "stress_test_logs.json" and any error logs to "stress_test_error_logs.json"
    sh ./update_s3_test_results.sh 
done
