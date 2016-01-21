The new sfs technology solves software dependencies and installation problems. It consists of a unique file that can be mounted as a normal file-system with all really needed libraries and files of the specific program. When mounted the sfslauncher will start the application stored into it. The procedure is completely transparent to the end user; Just double click on the "program.sfs" and sfslauncher will do the magic. Starting with version 1.0 we improved the integration: the operating system now knows the "sfs" file type as a native executable file.

<table><tr><td><img width='480px' src='http://sfs-technology.googlecode.com/files/sk.png' /></td></tr></table>

## How does it work? ##
(See the video, download link is at bottom of document)
Well, the file "program.sfs" is a squashfs compressed file that can be used as a virtual file system. The .sfs file can be mounted by a daemon in a hidden directory (/.mounted/"SFSprocessID"). Once mounted the file, sfslauncher program will read the executable's name and all the parameters stored into the "parameters" file (a simple text file). Then the sfslauncher will read the description.id file and will execute the executable file. When the user will close the executable (the software into the package) sfslauncher call the daemon and send to him a command called "flush": the daemon will release the thread, unmount the .sfs file and delete the hidden directory.

## What is NOT contained in the sfs file ? ##

The Desktop environment's libraries and other operating system's native libraries as for example KDE libraries, gtk+2, glib, libc6 and many more.

## What will contain the .sfs file ? ##

The sfs file contains just the most necessary libraries to perform a correct software execution.

# These are what we think are the highlight of the SFS Technology: #

1--Ease of use;

2--Ease of software sharing;

3--The base configuration of the operating system remains unaltered;

4--It allows dynamic library linking;

5--It allows using different version of software;

6--The sfs technology preserve the environment: it work in USER MODE;

7--Operates also in 64 Bit environment;

8--Released under the GNU/GPL license;

9--A version for Linux Mobile (ARM processors) is under development

10-- Can run simultaneously max 256 sfs application!!

This project is under develop at page

http://code.google.com/p/sfs-technology/

Ubuntu[Italian](Italian.md) forum discussion :
http://forum.ubuntu-it.org/index.php?topic=283698.0

# NEW VERSION 1.1.0.4 : #
--Automatically Dependency Handling:

This new version allows handling dynamically some dependencies that could not be in a SFS package. If defined, sfslauncher will try to install this not founded dependency by a simple graphical user interface, showing a popup message!

--This new version allows Nautilus to associate the icon contained into the SFS executable file to the correspondent SFS , having the same effect as the executables files do on Windows or Macintosh, where each has its own icon.

--Make Portable Option: This new option allows you to save the configurations of applications in the same folder where resides the SFS executable file. This directory could be situated on a portable device (like a USB pen) or on a normal root's directory.
> This option is not enabled by default.

--SFS Editor: an editor for the SFS Technology Executable files downloadable from (for i386 and amd64 architectures): http://code.google.com/p/sfs-technology/downloads/list

--Some relevant bugs fixed


Video that show the SFS Technology at work !:

http://sfs-technology.googlecode.com/files/SFS_example_video.ogv

Image of some SFS programs:
<table><tr><td><img width='480px' src='http://sfs-technology.googlecode.com/files/Schermata-SFS%20-%20Esplorazione%20file.png' /></td></tr></table>


SFS programs make links in the Main menu under Applications-->Other:
<table><tr><td><img width='392px' src='http://sfs-technology.googlecode.com/files/menu.png' /></td></tr></table>

SFS Settings :

<table><tr><td><img width='421px' src='http://sfs-technology.googlecode.com/files/settings.png' /></td></tr></table>

For more information about SFS Technology please contact me.
This solution is very important to further increase the usability of Linux worldwide.


Vincenzo Dentamaro
vincenzodentamaro@hotmail.com
SFS Technology developer.

Technology published under Ubuntu Brainstorm :
[http://www.unixteam.net/gallery/thumb.php?image=sections/Gallery/1\_by\_vincenzo.png&hw=175](http://brainstorm.ubuntu.com/idea/20108/)

# Installation #
See installation wiki in the wiki page!


# License #
This software is GPL v3 compatible
![http://www.gnu.org/graphics/gplv3-127x51.png](http://www.gnu.org/graphics/gplv3-127x51.png)


## Frequently Asked Questions ##
**Can two SFS executables share their resources?**
The sfs packages contains only some libraries not provided in a standard Ubuntu installation, for example in a SFS package there will never be gtk+ libraries or system libraries, but only those libraries which that particular program needs to run properly and the library that are not in a normal Linux installation.

Furthermore the static and dynamic linking between libraries is guaranteed, because the SFS load the GUI libraries and other important libraries from the standards shared directories (/usr/lib/ for example), rather less common libraries are loaded from the library directory contained in the SFS package, SFS also allow a system for the Dynamic Library Linking,
I try to explain with an example how it works:

I take 2 programs (programA.sfs and programB.sfs) both containing the same library called libraryX1.so. If the libraryX1.so is contained in the package programA.sfs when we launch the programA.sfs it will be loaded into memory, when we run the prgamB.sfs it will first seek the libraryX1.so into the mounted directory of programmA.sfs and if found this searched library, then do not load back into memory the same library, but will focus on the library already present in RAM, thus saving time of loading and space RAM.

So in conclusion, unlike other technologies SFS Technology provides an interaction and a dynamic link between the libraries, does not contain standard libraries already present in a common installation of Ubuntu, is not a replacement for apt, it began as an aid to making using the software easier on Linux.

The motto of Ubuntu is "LINUX for Human Beings"; well I think that the SFS Technology is a solution very close to the "Human Beings".

# Thanks to #

Nicole Monique Angelynn Marquez for the site correction.

HackToLive for have noticed bugs and for suggestions provided.
