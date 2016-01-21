# SFS Technology Version 1.0 beta #

The version 1.0 beta of SFS Technology provide a Daemon that mount the sfs packages
and a software sfslauncher (that works in user mode) that launch and handle the application
contained into the package. All this is done in a completely transparent way!
The sfstechnology is designed for be compiled on x86,AMD64/EM64T(64Bit like platforms),ARM architectures.
# Details #

Into the package you will find:

--The sfslauncher sources (Free Pascal code).

--The sfslauncher i386 binary file.

--The daemon sources (Free Pascal code).

--The daemon i386 binary file.

# How to use this beta version #

To use it you must:
1) copy the file called MAKEloop into the "/usr/sbin/sfs" directory,
2)then  you must run this command:

sudo daemon

3)from the user mode console (don't use sudo or switch user) type:

sfslauncher "put here a file sfs"

You can use the SFS version of Google Earth5 from here:
http://www.unixteam.net/index.php?mod=none_Fdplus&fdaction=download&url=sections/Download/Sfs_Applications_Directory_Download/Internet/GoogleEarth5.sfs

Or you can download a sfs file from here: http://www.unixteam.net/index.php?mod=Download/Sfs_Applications_Directory_Download

Make sure to have a kernel that support the squashfs module! Otherwise it doesn't work!