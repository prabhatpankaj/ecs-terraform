#!/bin/bash

# Check if required environment variables are set
if [[ -z "$GH_PAT" || -z "$GH_HOST" ]]; then
    echo "Error: GH_PAT and GH_HOST environment variables must be set."
    exit 1
fi

# Function to get list of organizations
get_organizations() {
    curl -s -H "Authorization: token $GH_PAT" "https://$GH_HOST/api/v3/user/orgs" | jq -r '.[].login'
}

# Function to get list of repositories in an organization
get_repositories() {
    local org="$1"
    curl -s -H "Authorization: token $GH_PAT" "https://$GH_HOST/api/v3/orgs/$org/repos" | jq -r '.[].full_name'
}

# Function to get list of open pull requests in a repository
get_pull_requests() {
    local repo="$1"
    curl -s -H "Authorization: token $GH_PAT" "https://$GH_HOST/api/v3/repos/$repo/pulls" | jq -r '.[] | select(.state == "open") | .html_url'
}

# Main script
main() {
    organizations=$(get_organizations)
    
    for org in $organizations; do
        echo "Organization: $org"
        
        repositories=$(get_repositories "$org")
        
        for repo in $repositories; do
            echo "Repository: $repo"
            
            pull_requests=$(get_pull_requests "$repo")
            
            if [[ -n "$pull_requests" ]]; then
                echo "Open Pull Requests:"
                echo "$pull_requests"
            else
                echo "No open pull requests found."
            fi
        done
    done
}

main
