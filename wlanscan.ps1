# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=
#          Name: wlanscan
#        Author: Kris Cieslak (defaultset.blogspot.com)
#          Date: 2010-04-03
#   Description: Simple script that uses netsh to show wireless networks.
#
#    Parameters: wireless interface name (optional,but recommended if you have
#                more than one card)
#        Result: $ActiveNetworks
# Usage example: wlanscan WiFi
#
# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-
PARAM ($ifname = "")

# Windows Vista/2008/7
if  ((gwmi win32_operatingsystem).Version.Split(".")[0] -gt 6) {
	throw "This script works on Windows Vista or higher."
}
if ((gsv "wlansvc").Status -ne "Running" ) {
	throw "WLAN AutoConfig service must be running."
}
$ActiveNetworks = @();
$CurrentIfName = "";	
$n = -1;
$iftest = $false;

netsh wlan show network mode=bssid | % {
	if ( $_ -match "Interface") {
		$CurrentIfName = [regex]::match($_.Replace("Interface name : ","")
			                            ,"\w{1,}").ToString();
	    if (($CurrentIfName.ToLower() -eq $ifname.ToLower()) -or ($ifname.length -eq 0)) {
		    $iftest=$true;
		} else { $iftest=$false }
	}	 
	
	$buf = [regex]::replace($_,"[ ]","");
	if ([regex]::IsMatch($buf,"^SSID\d{1,}(.)*") -and $iftest) {
	   	$item = "" | Select-Object SSID,NetType,Auth,Encryption,BSSID,Signal,Radiotype,Channel;
		$n+=1;
       	$item.SSID = [regex]::Replace($buf,"^SSID\d{1,}:","");
		$ActiveNetworks+=$item;
	}
  	if ([regex]::IsMatch($buf,"Networktype") -and $iftest) {
	   	$ActiveNetworks[$n].NetType=$buf.Replace("Networktype:","");
	}
	if ([regex]::IsMatch($buf,"Authentication") -and $iftest) {
	   	$ActiveNetworks[$n].Auth=$buf.Replace("Authentication:","");
	}
	if ([regex]::IsMatch($buf,"Encryption") -and $iftest) {
	   	$ActiveNetworks[$n].Encryption=$buf.Replace("Encryption:","");
	 	}
        if ([regex]::IsMatch($buf,"BSSID\d") -and $iftest) {
	   	$ActiveNetworks[$n].BSSID=[regex]::Replace($buf,"BSSID\d{1,}:","");
	}
	if ([regex]::IsMatch($buf,"Signal") -and $iftest) {
	   	$ActiveNetworks[$n].Signal=[int]::Parse([regex]::Match($buf.Replace("Signal:",""), "\d+")) / 100;
	}
	if ([regex]::IsMatch($buf,"Radiotype") -and $iftest) {
	   	$ActiveNetworks[$n].Radiotype=$buf.Replace("Radiotype:","");
	}
	if ([regex]::IsMatch($buf,"Channel") -and $iftest) {
	  	$ActiveNetworks[$n].Channel=$buf.Replace("Channel:","");
	}
}

$ActiveNetworks