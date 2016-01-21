# Introduction #
List of new features in the version 1.1.0.4
# Details #


## NEW: ##

**Automatically Dependency Handling**:
> This new version allows to handle dinamically some dependencies that
> could not be in a SFS package.

If defined, sfslauncher will try to install this not founded dependency by
a simple graphical user interface, showing a popup message!
For example if you want to use the SFS version of Rosegarden, you must have
installed KDE, jack daemons and some other dependencies that are not contained in
a SFS package. This new SFS Technology version will download all the necessary
dependency (jackd and KDE GUI) and it will execute Rosegarden!

**Some relevant bugs fixed**

Version 1.1.0.3
--This new version allows Nautilus to associate the icon contained into the SFS executable file to the correspondent SFS , having the same effect as the executables files do on Windows or Macintosh, where each has its own icon.

--Make Protable Option: This new option allows you to save the configurations of applications in the same folder where resides the SFS executable file. This directory could be situated on a portable device (like a USB pen) or on a normal root's directory.
This option is not enabled by default.

--SFS Editor: an editor for the SFS Technology Executable file downloadable from (for i386 and amd64 architectures):
http://code.google.com/p/sfs-technology/downloads/list