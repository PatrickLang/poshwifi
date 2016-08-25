
I was troubleshooting wifi between my own laptop and a colleagues', and realized that I should just script it. 
The first step is to parse the text output of `netsh wlan show network mode=bssid` to get details of all APs,
then parse it into objects. Reading through a long list of text isn't efficient, especially when there could 
be 50+ APs clogging up the limited wifi spectrum on an expo floor.

I found an existing script from Kris Cieslak on his blog
[./defaultset](http://defaultset.blogspot.ca/2010/04/powershell-wireless-network-scan-script.html)
that was close to what I needed, then started hacking it up.

## Usage

_Parameters_
* _-ifname_ - interface name to scan (see `Get-NetAdapter | Select-Object Name`)
* _-testInput_ - parse saved `netsh wlan show network mode=bssid` output from a file instead

### Test mode

If somehow you're in a place with no APs or just a few and you want to hack up this script, use the files in the
./testInputs subdirectory.

For example:
```powershell
.\wlanscan.ps1 -testInput .\testInputs\output.txt | Measure-Object
```

will parse 80 different access points:
```none
Count    : 80
Average  :
Sum      :
Maximum  :
Minimum  :
Property :
```

## Ideas for future hacks
1. Site Survey
 -  Map channel numbers to frequencies
 - Build an estimated histogram of signal strength based on channel and strength so you can visually see gaps
 - Do a real measurement and compare estimated vs actual, refine #2
 - Implement `-FindFreeChannels` based on estimated spectrum Usage
2. Find a way to manually associate with a specific AP
3. Write `IsThisNetworkGood` function
4. Iterate 1/2/3 to go through networks and find something that works