#HashCalc -- A File Hash Calculator for Win32, Win64 and OS X

This is an experimental project using Embarcadero Delphi XE7. It also uses the [DCPCrypt](https://github.com/StephenGenusa/DCPCrypt) library for the hash functions.

It will currently calculate file hashes for MD4, MD5, RIPEMD-128, RIPEMD-160, SHA1, SHA256, SHA384, SHA512, Tiger and Haval.

You can drag-and-drop any file on the drop target of the form or you can give a single command-line parameter which is the path/filename. On OS X you'd probably want to create a link file pointing to /Applications/HashCalc.app/Contents/MacOS/HashCalc so that you can type hashcalc path/file

There is also a Base64 text encoder and decoder on the second tab as a convenience tool.

[Binaries](https://github.com/StephenGenusa/HashCalc/releases) are available for download.

![HashCalc OS X](https://raw.github.com/StephenGenusa/HashCalc/master/OSX_SS.png)
<br />HashCalc on OS X

![HashCalc Windows](https://raw.github.com/StephenGenusa/HashCalc/master/Win64_SS.png)
<br />HashCalc on Windows
