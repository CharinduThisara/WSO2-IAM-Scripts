#!/bin/bash

# Check if all necessary arguments are provided
if [ "$#" -lt 8 ]; then
    echo "Error: Not all necessary arguments are provided."
    exit 1
fi

deployment_file_path=$1
db_username=$2
db_password=$3
identity_db_name=$4
shared_db_name=$5
enable_pool_options=$6
db_type=$7

# Function to get MySQL database configuration
get_mysql_db_config() {
    local identity_db_name=$1
    local shared_db_name=$2
    local db_username=$3
    local db_password=$4

    cat <<EOF
[database.identity_db]
type = "mysql"
url = "jdbc:mysql://localhost:3306/${identity_db_name}?allowPublicKeyRetrieval=true&useSSL=false"
username = "${db_username}"
password = "${db_password}"
port = "3306"

[database.shared_db]
type = "mysql"
url = "jdbc:mysql://localhost:3306/${shared_db_name}?allowPublicKeyRetrieval=true&useSSL=false"
username = "${db_username}"
password = "${db_password}"
port = "3306"
EOF
}

# Read the file
lines=$(<"$deployment_file_path")

# Remove existing configurations
new_lines=""
skip=false
while IFS= read -r line; do
    if [[ $line == *[database.identity_db]* || $line == *[database.shared_db]* ]]; then
        skip=true
    elif $skip && [[ $line == [* && $line == *] ]]; then
        skip=false
    fi
    if ! $skip; then
        new_lines+="$line"
        new_lines+=$'\n'
    fi
done <<< "$lines"

# Append new configurations
new_lines+=$(get_mysql_db_config "$identity_db_name" "$shared_db_name" "$db_username" "$db_password")
if [ "$enable_pool_options" == "true" ]; then
    echo "Enabling pool options for databases."
    # Assuming that db_advanced_config is a variable or command that you want to append
    # For example, you can define it like this: db_advanced_config="some_content"
    new_lines+=$'\n'
    new_lines+="$db_advanced_config"
fi

# Write the updated content back to the file
echo "$new_lines" > "$deployment_file_path"

echo "Database configurations updated in deployment.toml."
