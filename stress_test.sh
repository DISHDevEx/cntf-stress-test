# #!/usr/bin/env bash
# set -e 
# #add openssl for random data creation 
# apk add openssl

# #test upload speed 10 times 
# for _ in {1..3}; do
    
#     data_size_in_bytes=$((3 * 1024 * 1024))  # 3MB in bytes

#     # Generate random data to simulate the upload
#     random_data=$(openssl rand -base64 $data_size_in_bytes | tr -d '\n')

#     # Only create random_txt file if it does not exist
#     if [ ! -e random_data.txt ]; then
#         # Generate random data to simulate the upload
#         random_data=$(openssl rand -base64 $data_size_in_bytes | tr -d '\n')

#         # Write random_data to a file
#         echo "$random_data" > random_data.txt

#         echo "Random data has been saved to random_data.txt"
#     else
#         echo "random_data.txt already exists. Skipping generation."
#     fi

#     # upload_speed is measured in bytes/seconds 
#     # upload_speed=$(curl --interface uesimtun0 -w '%{speed_upload}' -T random_data.txt https://postman-echo.com/post)
#     upload_speed=$(curl --interface uesimtun0 -w '%{speed_upload}' -T random_data.txt http://httpbin.org/post)

#     # change bytes/seconds to mb/seconds 
#     upload_speed_mb=$(echo "scale=2; $upload_speed / 125000" | bc)

#     #write logs to stess_test_logs file
#     echo "stress_test_upload_speed: $upload_speed_mb MB/s" >> /tmp/stress_test_logs.json

# done

# #remove random_data
# rm random_data.txt

#!/usr/bin/env bash
set -e
# Add openssl for random data creation
apk add openssl

# Test upload speed 3 times
for _ in {1..3}; do
    data_size_in_bytes=$((3 * 1024 * 1024))  # 3MB in bytes

    # Only create random_data.txt file if it does not exist
    if [ ! -e random_data.txt ]; then
        # Generate random data to simulate the upload
        random_data=$(openssl rand -base64 $data_size_in_bytes | tr -d '\n')

        # Write random_data to a file
        echo "$random_data" > random_data.txt

        echo "Random data has been saved to random_data.txt"
    else
        echo "random_data.txt already exists. Skipping generation."
    fi

    # Upload_speed is measured in bytes/seconds
    upload_speed=$(curl --interface uesimtun0 -w '%{speed_upload}' -T random_data.txt "http://httpbin.org/post")

    # Change bytes/seconds to mb/seconds
    upload_speed_mb=$(echo "scale=2; $upload_speed / 125000" | bc)

    # Write logs to stress_test_logs file
    echo "stress_test_upload_speed: $upload_speed_mb MB/s" >> /tmp/stress_test_logs.json

done

# Remove random_data.txt
rm random_data.txt

