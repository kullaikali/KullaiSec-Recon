#!/bin/bash

# Color variables
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Print colorful banner with custom name
echo -e "${GREEN}"
echo ' KullaiSecKullaiSecKullaiSecKullaiSecKullaiSecKullaiSecKullaiSecKullaiSecKullaiSecKullaiSecKullaiSecKullaiSec'
echo ' KullaiSecKullaiSecKullaiSecKullaiSecKullaiSecKullaiSecKullaiSecKullaiSecKullaiSecKullaiSecKullaiSecKullaiSec'
echo ' KullaiSecKullaiSecKullaiSecKullaiSecKullaiSecKullaiSecKullaiSecKullaiSecKullaiSecKullaiSecKullaiSecKullaiSec'
echo ' KullaiSecKullaiSecKullaiSecKullaiSecKullaiSecKullaiSecKullaiSecKullaiSecKullaiSecKullaiSecKullaiSecKullaiSec'
echo ' KullaiSecKullaiSecKullaiSecKullaiSecKullaiSecKullaiSecKullaiSecKullaiSecKullaiSecKullaiSecKullaiSecKullaiSec'
echo ' KullaiSecKullaiSecKullaiSecKullaiSecKullaiSecKullaiSecKullaiSecKullaiSecKullaiSecKullaiSecKullaiSecKullaiSec'
echo -e "${NC}"

# Prompt for target domain
read -p "Enter the target domain: " target

# Create a folder for the target domain
folder_name=$(echo "$target" | sed 's/\./_/g')
mkdir -p "$folder_name"

# Perform subdomain enumeration using subfinder
echo -e "Performing subdomain enumeration with subfinder..."
subfinder -d $target -o "$folder_name/subdomains.txt"
cat "$folder_name/subdomains.txt" | sort -u >> "$folder_name/all_subdomains.txt"

# Perform subdomain enumeration using amass
echo -e "Performing subdomain enumeration with amass..."
amass enum -d $target -o "$folder_name/subdomains.txt"
cat "$folder_name/subdomains.txt" | sort -u >> "$folder_name/all_subdomains.txt"

# Perform CVE scanning using Nuclei
echo -e "Performing CVE scanning..."
nuclei -t /root/nuclei-templates/cves/ -l "$folder_name/all_subdomains.txt" | tee "$folder_name/cves_scan.txt"

# Perform vulnerability scanning using Nuclei
echo -e "Performing vulnerability scanning..."
nuclei -t /root/nuclei-templates/vulnerabilities/ -l "$folder_name/all_subdomains.txt" | tee "$folder_name/vulnerability_scan.txt"

# Detect exposed panels using Nuclei
echo -e "Detecting exposed panels..."
nuclei -t /root/nuclei-templates/exposed-panels/ -l "$folder_name/all_subdomains.txt" | tee "$folder_name/exposed_panels.txt"

echo -e "Reconnaissance completed. Results saved in the folder: $folder_name"
