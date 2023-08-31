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

    helm_template_command="helm template -n openverso ueransim-10k-test openverso/ueransim-ues \
        --set ues.initialMSISDN=${imsi_id} \
        --values https://raw.githubusercontent.com/DISHDevEx/napp/main/napp/open5gs_values/gnb_ues_values.yaml"

    helm_upgrade_command="helm -n openverso upgrade --install ueransim-10k-test openverso/ueransim-ues \
        --set ues.initialMSISDN=${imsi_id} \
        --values https://raw.githubusercontent.com/DISHDevEx/napp/main/napp/open5gs_values/gnb_ues_values.yaml"

    echo "Running helm template command: ${helm_template_command}"
    $helm_template_command

    echo "Running helm upgrade command: ${helm_upgrade_command}"
    $helm_upgrade_command
}

ue_populate() {
  echo "command ue_populate running with ${imsi_id}"
  populate_pod_name=$(kubectl -n openverso get pod --output=jsonpath={.items..metadata.name} -l app.kubernetes.io/component=populate)

  if [ $? -eq 0 ]; then 
    kubectl -n openverso exec $populate_pod_name -- open5gs-dbctl add_ue_with_slice $imsi_id 465B5CE8B199B49FAA5F0A2EE238A6BC E8ED289DEBA952E4283B54E88E6183CA internet 1 111111
  fi
}

for _ in {1..10}; do
    generate_random_imsi
    ue_populate
    echo "Subscribing UE with IMSI: ${imsi_id}"
    run_helm_commands
    echo "Allocating IMSI: ${imsi_id} to UE with helm"

    # Add ping command to yahoo.com
    ping_command="ping -c 5 yahoo.com" 
    echo "Executing ping command: $ping_command"
    $ping_command > ./stress_test_logs.txt 2> ./stress_test_error_logs.txt # this outputs the logs from each ping to "stress_test_logs.txt" and any error logs to "stress_test_error_logs.txt"
    sh ./update_s3_test_results.sh # this reflects the changes made to the local files: "stress_test_logs.txt" & "stress_test_error_logs.txt" in S3. perhaps remove this and add it as the last step of CI/CD pipeline?
done