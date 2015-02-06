This script is to simplify the installation of the [FlightRadar24 Feeder](http://forum.flightradar24.com/threads/4270-Linux-feeder-software-for-Flightradar24) software on [PiAware](http://flightaware.com/adsb/piaware/).

The first time it is run, it will ask you for your station key. The key will be written to a file, so that it's remembered for subsequent runs. This is useful for reinstalling or upgrading the software.

No scripting or programming experience is required.


# usage:
* Log into your PiAware device.
* Run:`wget -q -O - https://raw.githubusercontent.com/palmerit/piaware-flightradar24/master/install.sh | sudo bash`
* wait for the script to finish

Running the above command multiple times will cleanup and reinstall the feeder software. I will keep the script updated for the latest versions, so the above command is also useful to perform upgrades.

Please report any bugs [using the issue tracker](https://github.com/palmerit/piaware-flightradar24/issues).
