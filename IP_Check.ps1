# Prompt the user to enter the API key for AbuseIPDB
$apiKey = Read-Host "Enter your AbuseIPDB API key"

# Run netstat -ano and store the output in a variable
$netstat = netstat -ano

# Iterate through each line of the netstat output
foreach ($line in $netstat) {
    # Check if the line contains a foreign address
    if ($line -match "\s+(\d+\.\d+\.\d+\.\d+):(\d+)\s+(\d+\.\d+\.\d+\.\d+):(\d+)\s+(\S+)\s*") {
        # Extract the foreign address and port number
        $foreignAddress = $matches[3]
        $foreignPort = $matches[4]
        
        # Build the URL for the AbuseIPDB API
        $url = "https://api.abuseipdb.com/api/v2/check?ipAddress=$foreignAddress&maxAgeInDays=90"

        # Create a new HTTP request with the API key in the headers
        $request = Invoke-WebRequest -Uri $url -Headers @{Key = $apiKey}

        # Convert the JSON response to a PowerShell object
        $response = ConvertFrom-Json $request.Content

        # Check if the address is listed in the API response
        if ($response.data.abuseConfidenceScore -gt 0) {
            # Extract the domain name and country code from the API response
            $domain = $response.data.domain
            $countryCode = $response.data.countryCode
            
            # Use the country code to get the country name from the API
            $countryUrl = "https://restcountries.com/v2/alpha/$countryCode"
            $countryRequest = Invoke-WebRequest -Uri $countryUrl
            $countryResponse = ConvertFrom-Json $countryRequest.Content
            $country = $countryResponse.name

            # Print a warning message to the user
            Write-Host "Warning: $foreignAddress ($domain, $country) is listed on the AbuseIPDB with a score of $($response.data.abuseConfidenceScore)"
        }
    }
}
