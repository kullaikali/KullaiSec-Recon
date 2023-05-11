#!/bin/bash

# Color variables
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Print colorful banner with custom name
echo -e "${GREEN}"
echo ' ***********************************************************************'
 echo ' ██╗░░██╗██╗░░░██╗██╗░░░░░██╗░░░░░░█████╗░██╗  ░██████╗███████╗░█████╗░'
 echo ' ██║░██╔╝██║░░░██║██║░░░░░██║░░░░░██╔══██╗██║  ██╔════╝██╔════╝██╔══██╗'
 echo ' █████═╝░██║░░░██║██║░░░░░██║░░░░░███████║██║  ╚█████╗░█████╗░░██║░░╚═╝'
 echo ' ██╔═██╗░██║░░░██║██║░░░░░██║░░░░░██╔══██║██║░  ╚═══██╗██╔══╝░░██║░░██╗'
 echo ' ██║░╚██╗╚██████╔╝███████╗███████╗██║░░██║██║  ██████╔╝███████╗╚█████╔╝'
 echo ' ╚═╝░░╚═╝░╚═════╝░╚══════╝╚══════╝╚═╝░░╚═╝╚═╝  ╚═════╝░╚══════╝░╚════╝░'
echo ' ***********************************************************************'
echo 'You need Subfinder, AssetFinder, Nuclei to run this TooL!!!!'
echo -e "${NC}"

# Prompt for target domain
read -p "Enter the target domain: " target

# Create a folder for the target domain
folder_name=$(echo "$target" | sed 's/\./_/g')
mkdir -p "$folder_name"

# Perform subdomain enumeration using Subfinder
echo -e "Performing subdomain enumeration with Subfinder..."
subfinder -d $target -o "$folder_name/subdomains_subfinder.txt"

# Perform subdomain enumeration using Assetfinder
echo -e "Performing subdomain enumeration with Assetfinder..."
assetfinder --subs-only $target | tee "$folder_name/subdomains_assetfinder.txt"

# Combine subdomains from Subfinder and Assetfinder, sort them, and create a final subdomain list
cat "$folder_name/subdomains_subfinder.txt" "$folder_name/subdomains_assetfinder.txt" | sort -u >> "$folder_name/all_subdomains.txt"

# Define your Slack webhook URL
webhook_url="https://hooks.slack.com/services/YOUR/WEBHOOK/URL"

# Function to send a message to Slack
send_to_slack() {
  local message="$1"
  curl -X POST -H 'Content-type: application/json' --data '{"text":"'"$message"'"}' "$webhook_url"
}

# Perform CVE scanning using Nuclei and send notification if any CVEs are found
echo -e "Performing CVE scanning..."
cve_scan_output=$(nuclei -t /root/nuclei-templates/cves/ -l "$folder_name/all_subdomains.txt")
if [[ -n "$cve_scan_output" ]]; then
  send_to_slack "CVEs found:\n$cve_scan_output"
fi

# Perform vulnerability scanning using Nuclei and send notification if any vulnerabilities are found
echo -e "Performing vulnerability scanning..."
vulnerability_scan_output=$(nuclei -t /root/nuclei-templates/vulnerabilities/ -l "$folder_name/all_subdomains.txt")
if [[ -n "$vulnerability_scan_output" ]]; then
  send_to_slack "Vulnerabilities found:\n$vulnerability_scan_output"
fi

# Detect exposures using Nuclei and send notification if any exposures are found
echo -e "Detecting exposures..."
exposures_output=$(nuclei -t /root/nuclei-templates/exposures/ -l "$folder_name/all_subdomains.txt")
if [[ -n "$exposures_output" ]]; then
  send_to_slack "Exposures found:\n$exposures_output"
fi

# Detect exposed panels using Nuclei and send notification if any exposed panels are found
echo -e "Detecting exposed panels..."
exposed_panels_output=$(nuclei -t /root/nuclei-templates/exposed-panels/ -l "$folder_name/all_subdomains.txt")
if [[ -n "$exposed_panels_output" ]]; then
  send_to_slack "Exposed panels found:\n$exposed_panels_output"
fi

echo -e "Reconnaissance completed. Results saved in the folder: $folder_name"
