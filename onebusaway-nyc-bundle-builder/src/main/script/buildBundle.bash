#!/bin/bash

# Script created by Scott Clark to begin to script the bundle building process.
BUNDLE_DATA_DIR=bundle_data
ROUTESTXT_WITH_COLORS_FILENAME=si_routes_with_colors.txt

GTFS_DOWNLOAD_LOC=http://www.mta.info/developers/data/nyct/bus/
GTFS_STATEN_ISLAND=google_transit_staten_island
GTFS_BROOKLYN=google_transit_brooklyn

downloadFile () {
  file=$1
  if [ -z "$file" ] 
  then
    echo downloadFile requires one argument.
    return -1
  fi

  echo Downloading File $file with wget:
  wget -nv $file
}

echo "Starting Bundle Builder script."
rm -rfv $BUNDLE_DATA_DIR
mkdir $BUNDLE_DATA_DIR
cd $BUNDLE_DATA_DIR

echo "Downloading Staten Island GTFS"
downloadFile $GTFS_DOWNLOAD_LOC$GTFS_STATEN_ISLAND.zip || exit 1

echo "Downloading Brooklyn GTFS"
downloadFile $GTFS_DOWNLOAD_LOC$GTFS_BROOKLYN.zip || exit 1

echo "Modify Staten Island GTFS"
cp $GTFS_STATEN_ISLAND.zip $GTFS_STATEN_ISLAND.zip.original_from_mta
mkdir $GTFS_STATEN_ISLAND
cd $GTFS_STATEN_ISLAND

unzip -LL -q ../$GTFS_STATEN_ISLAND.zip

mv routes.txt ../si_routes_from_original_gtfs.txt
cp ../../$ROUTESTXT_WITH_COLORS_FILENAME routes.txt
