#!/usr/bin/env bash

for _ in {1..10}; do
        a=$(date +%s)
        b=$((a*RANDOM))
        while [ ${#b} -lt 12 ]; do
          b="${b}$RANDOM"
          kubectl -n openverso exec $POPULATE_POD -- open5gs-dbctl add_ue_with_slice ${CI_PIPELINE_ID} 465B5CE8B199B49FAA5F0A2EE238A6BC E8ED289DEBA952E4283B54E88E6183CA internet 1 $IMSI_ID
          IMSI_ID=$(echo "${b:0:digits}")
          echo $IMSI_ID
        done
