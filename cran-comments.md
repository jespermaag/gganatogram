## Test environments
* Local OS X install, R 3.5.0
* Ubuntu 14.04, R 3.5.1
* Windows

## R CMD check results

* Local OS X install
There were no ERRORs or WARNINGs. 

There was 1 NOTE:
Warning message:
Version of roxygen2 last used with this package is 6.1.0.9000.  You only have version 6.0.1 


* Ubuntu 14.04 (on travis-ci)

There was 1 NOTE:
Warning message:
See
  ‘/home/travis/build/jespermaag/gganatogram/gganatogram.Rcheck/00check.log’
for details.

* win-builder

There was 1 WARNING and 3 NOTE:

checking top-level files ... WARNING
Conversion of 'README.md' failed:
pandoc.exe: Could not fetch figure/AllSpeciesCellPlotValueTop-1.svg
figure/AllSpeciesCellPlotValueTop-1.svg: openBinaryFile: does not exist (No such file or directory)

checking CRAN incoming feasibility ... NOTE

running examples for arch 'i386' ... [29s] NOTE
Examples with CPU or elapsed time > 10s
             user system elapsed
gganatogram 17.96   0.05   18.19
running examples for arch 'x64' ... [33s] NOTE
Examples with CPU or elapsed time > 10s
             user system elapsed