```none
     ____      ____  _  __        ___  __ _
    |  _ \ ___/ ___|| |_\ \      / (_)/ _(_)
    | |_) / _ \___ \| '_ \ \ /\ / /| | |_| |
    |  __/ (_) |__) | | | \ V  V / | |  _| |
    |_|   \___/____/|_| |_|\_/\_/  |_|_| |_|
```

I was troubleshooting wifi performance on a colleague's laptop, which was quite painful on an expo floor with 80 (yes 80)
access points flooding the specrum. After spending lots fo time scrolling through `netsh` output, I realized that I really
should script this process.

The first step is to parse the text output of `netsh wlan show network mode=bssid` to get details of all APs,
then parse it into objects. Reading through a long list of text isn't efficient, especially when there could
be 50+ APs clogging up the limited wifi spectrum on an expo floor.

I found an existing script from Kris Cieslak on his blog
[./defaultset](http://defaultset.blogspot.ca/2010/04/powershell-wireless-network-scan-script.html)
that was close to what I needed, so I created a git repo then started hacking it up.

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
5. Vendor lookup by MAC

## Interesting Tricks

Why would there be multiple BSSID's with the same channel and signal level? My guess is it's one physical AP
broadcasting on multiple SSIDs.

```none
PS C:\Users\Patrick\Source\poshwifi> .\wlanscan.ps1 -testInput .\testInputs\output2.txt | Group-Object Signal, Channel

Count Name                      Group
----- ----                      -----
    1 0.53, 11                  {NetworkListEntry}
    1 0.81, 1                   {NetworkListEntry}
    3 0.45, 157                 {NetworkListEntry, NetworkListEntry, NetworkListEntry}
    1 0.99, 153                 {NetworkListEntry}
    3 0.63, 108                 {NetworkListEntry, NetworkListEntry, NetworkListEntry}
    1 0.55, 100                 {NetworkListEntry}
    3 0.36, 64                  {NetworkListEntry, NetworkListEntry, NetworkListEntry}
    1 0.31, 56                  {NetworkListEntry}
    1 0.46, 36                  {NetworkListEntry}
...
```
