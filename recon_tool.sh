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

# Perform CVE scanning using Nuclei
echo -e "Performing CVE scanning..."
nuclei -t /root/nuclei-templates/cves/ -l "$folder_name/all_subdomains.txt" | tee "$folder_name/cves_scan.txt"

# Perform vulnerability scanning using Nuclei
echo -e "Performing vulnerability scanning..."
nuclei -t /root/nuclei-templates/vulnerabilities/ -l "$folder_name/all_subdomains.txt" | tee "$folder_name/vulnerability_scan.txt"

# Detect exposures using Nuclei
echo -e "Detecting exposures..."
nuclei -t /root/nuclei-templates/exposures/ -l "$folder_name/all_subdomains.txt" | tee "$folder_name/exposures.txt"

# Detect exposed panels using Nuclei
echo -e "Detecting exposed panels..."
nuclei -t /root/nuclei-templates/exposed-panels/ -l "$folder_name/all_subdomains.txt" | tee "$folder_name/exposed_panels.txt"

echo -e "Reconnaissance completed. Results saved in the folder: $folder_name"
