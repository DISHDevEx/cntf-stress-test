#!/usr/bin/env bash

#!/bin/sh

# Generate random 10-digit number for IMSI
generate_random_imsi() {
    digits=10
    a=$(date +%s)
    b=$((a*RANDOM))
    while [ ${#b} -lt 12 ]; do
        b="${b}$RANDOM"
    done
    IMSI_ID=$(echo "$b" | cut -c 1-$digits)
    echo "$IMSI_ID"
}

# Loop to subscribe 10 UEs
for _ in $(seq 1 10); do
    IMSI_ID=$(generate_random_imsi)
    echo "Subscribing UE with IMSI: $IMSI_ID"

    # Exec into populate pod and create UE subscription with the IMSI ID
    POPULATE_POD=$(kubectl -n openverso get pod --output=jsonpath='{.items..metadata.name}' -l app.kubernetes.io/component=populate)
    kubectl -n openverso exec "$POPULATE_POD" -- open5gs-dbctl add_ue_with_slice "${CI_PIPELINE_ID}" 465B5CE8B199B49FAA5F0A2EE238A6BC E8ED289DEBA952E4283B54E88E6183CA internet 1 "$IMSI_ID"
    
    # Append IMSI_ID to IMSI_IDs.txt for later use
    echo "$IMSI_ID" >> IMSI_IDs.txt
done
