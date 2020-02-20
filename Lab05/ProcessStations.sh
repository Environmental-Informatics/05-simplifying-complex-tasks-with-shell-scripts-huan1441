#!/bin/bash
# Script to seperate out higher elevation stations from StationData, plot the locatons, and convert figure formats
# Tao Huang (huan1441)  Feb.14,2020

module load gmt

Datadirectory=StationData
Newdirectory=HigherElevation

# Whether the directory -- HigherElevation exist?
if [ ! -d ./$Newdirectory  ]
then
    mkdir $Newdirectory
fi

# identify the file with elevation at or above 200 feet

for file in $Datadirectory/*
do
  filepath=$(awk '/Altitude/ && $NF >=  200 {print FILENAME}' $file)

# if filepath is not null, then copy the file to HigherElevation
  if [ -n "$filepath" ]
  then
     cp  $filepath $Newdirectory
  fi

done

# Obtain the Longitude and Latitude from the files in StationData

awk '/Longitude/ {print -1 * $NF}' $Datadirectory/Station_*.txt > Long.list
awk '/Latitude/ {print  $NF}' $Datadirectory/Station_*.txt > Lat.list

# put the Longitude and Latitude into a new file

paste Long.list Lat.list > AllStations.xy

# Obtain the Longitude and Latitude from the files in HigherElevation

awk '/Longitude/ {print -1 * $NF}' $Newdirectory/Station_*.txt > HELong.list
awk '/Latitude/ {print  $NF}' $Newdirectory/Station_*.txt > HELat.list

# put the Longitude and Latitude into a new file

paste HELong.list HELat.list > HEStations.xy


# drawn blue rivers, blue lakes and orange boundaries with high resolution

gmt pscoast -JU16/4i -R-93/-86/36/43 -B2f0.5 -Dh -Ia/blue -Na/orange -P -Sblue -K -V > SoilMoistureStations.ps

# add small black circles for all station locations

gmt psxy AllStations.xy -J -R -Sc0.15 -Gblack -K -O -V >> SoilMoistureStations.ps

# add smaller red circles for all higher elevation stations

gmt psxy HEStations.xy -J -R -Sc0.08 -Gred -O -V >> SoilMoistureStations.ps

# convert the PS file into EPSI file

ps2epsi SoilMoistureStations.ps SoilMoistureStations.epsi

# convert the EPSI file into TIF file with 150 dpi

convert -density 150 SoilMoistureStations.epsi SoilMoistureStations.tif

echo "Congratulations! The work is done!"
