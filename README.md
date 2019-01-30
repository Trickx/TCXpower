# TCXpower
Read power measurements from Garmin's Training Center XML (TCX) file with Matlab via xml2struct.
parseTCX parses the struct for power (watt) measurements and return power values and timestamps.
The example (/Example/PowerGraph.m)
- reads 4 TCX files recorded at the same time with different powermeter sources
- creates a synchronised timetable from the data 
- plots the results as shown below.
![parseTCX example plot](./Example/Powergraph_AVR3.png?raw=true "Example Plot")
