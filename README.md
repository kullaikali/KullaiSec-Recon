# KullaiSec-Recon

Copy the above code into a file named recon_tool.sh.

Make the file executable by running chmod +x recon_tool.sh.

Install the required dependencies (subfinder, amass, and nuclei) using your package manager.

Download and configure any necessary data sources for subfinder and amass.

Download the desired nuclei templates and place them in the appropriate directories (nuclei-templates/).

Run the tool by executing ./recon_tool.sh.

You will be prompted to enter the target domain. Provide the domain and press Enter.

The script will create a folder for the target domain, perform subdomain enumeration, CVE scanning, vulnerability scanning, and exposed panel detection, and save the results in the respective folders.

Each target domain will have its own folder containing the subdomains.txt, all_subdomains.txt, cve_scan.txt, vulnerability_scan.txt, and exposed_panels.txt files.

Thank You 
KullaiSec
