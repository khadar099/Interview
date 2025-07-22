#!/bin/bash

# ---------------------------------------
# JFrog Artifactory Cleanup Script
# ---------------------------------------
# This script finds and deletes artifacts
# older than X days to reduce storage cost.
# ---------------------------------------

# ====== CONFIGURATION ======
ARTIFACTORY_URL="https://your-jfrog-url/artifactory"
REPO="your-repo-name"                    # Repository name (e.g., libs-release-local)
API_KEY="your-api-key"                  # Or use user:password with basic auth
OLDER_THAN_DAYS=30                      # Age in days to consider artifacts "stale"
DRY_RUN=true                            # Set to false to actually delete artifacts

# ====== FUNCTIONS ======

# Function to convert ISO 8601 to Unix timestamp
iso_to_unix() {
    date -d "$1" +%s
}

# Fetch artifacts metadata from JFrog
fetch_artifacts() {
    echo "Fetching artifacts from repository: $REPO"
    curl -s -H "X-JFrog-Art-Api:$API_KEY" \
         "$ARTIFACTORY_URL/api/search/creation?repos=$REPO" \
         | jq -r '.results[].uri'
}

# Check and delete artifacts older than threshold
cleanup_old_artifacts() {
    local now=$(date +%s)
    local count=0

    for artifact_url in $(fetch_artifacts); do
        # Get artifact metadata
        metadata=$(curl -s -H "X-JFrog-Art-Api:$API_KEY" "$artifact_url")
        created_date=$(echo "$metadata" | jq -r '.created')
        artifact_path=$(echo "$metadata" | jq -r '.uri')

        # Convert creation date to Unix time
        created_unix=$(iso_to_unix "$created_date")

        # Calculate age in days
        age_days=$(( (now - created_unix) / 86400 ))

        if [[ $age_days -ge $OLDER_THAN_DAYS ]]; then
            echo "Artifact $artifact_path is $age_days days old and qualifies for deletion."

            if [[ "$DRY_RUN" == false ]]; then
                delete_url=$(echo "$artifact_url" | sed "s|api/storage/||")
                curl -s -X DELETE -H "X-JFrog-Art-Api:$API_KEY" "$delete_url"
                echo "Deleted: $delete_url"
                ((count++))
            fi
        fi
    done

    echo "Cleanup complete. Total deleted: $count"
}

# ====== EXECUTE SCRIPT ======

echo "Starting artifact cleanup in Artifactory..."
cleanup_old_artifacts
echo "Done."
