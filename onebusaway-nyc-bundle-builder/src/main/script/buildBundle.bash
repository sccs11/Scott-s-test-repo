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

echo "Cleaning up previous run data"
rm -v $BUNDLE_DATA_DIR/*
rmdir $BUNDLE_DATA_DIR

mkdir $BUNDLE_DATA_DIR

echo

if [ -e $GTFS_STATEN_ISLAND.zip.original_from_mta ]
then
 echo "Found Staten Island GTFS, wont download."
else
  echo "Downloading Staten Island GTFS"
  downloadFile $GTFS_DOWNLOAD_LOC$GTFS_STATEN_ISLAND.zip || exit 1
  cp $GTFS_STATEN_ISLAND.zip $GTFS_STATEN_ISLAND.zip.original_from_mta
  rm $GTFS_STATEN_ISLAND.zip
fi

if [ -e $GTFS_BROOKLYN.zip.original_from_mta ]
then
  echo "Found brooklyn GTFS, wont download"
else 
  echo "Downloading Brooklyn GTFS"
  downloadFile $GTFS_DOWNLOAD_LOC$GTFS_BROOKLYN.zip || exit 1
  cp $GTFS_BROOKLYN.zip $GTFS_BROOKLYN.zip.original_from_mta
  rm $GTFS_BROOKLYN.zip
fi

cd $BUNDLE_DATA_DIR

echo "Modify Staten Island GTFS"

echo "Unzip staten island gtfs and replace routes.txt"
mkdir $GTFS_STATEN_ISLAND
cd $GTFS_STATEN_ISLAND

unzip -LL -q ../../$GTFS_STATEN_ISLAND.zip.original_from_mta

mv routes.txt ../si_routes_from_original_gtfs.txt
cp ../../$ROUTESTXT_WITH_COLORS_FILENAME routes.txt

echo "zip up new Staten Island GTFS"

cd ..

zip -q $GTFS_STATEN_ISLAND.zip $GTFS_STATEN_ISLAND/*.txt
rm $GTFS_STATEN_ISLAND/*
rmdir $GTFS_STATEN_ISLAND

echo "Done modifying Staten Island GTFS"

echo "Turn Brooklyn GTFS -> B63 GTFS"
echo "Running onebusaway-gtfs-transformer-cli "
java -Xmx2G -jar ../lib/onebusaway-gtfs-transformer-cli-1.2.5.jar --transform=../transformer_modifications.txt ../$GTFS_BROOKLYN.zip.original_from_mta ./$GTFS_BROOKLYN

echo 
echo "Script finished, however I didnt do any of the following:"
echo "->Reduce Brooklyn GTFS to just B63 GTFS"
echo "->Insert color code into B63 GTFS routes.txt or replace routes.txt with b63_with_colors_routes.txt"
echo "->Combine Staten Island and Brooklyn STIF files."
echo "->Run python script on combined STIFs"
echo "->Build bundle"
echo "->Add BaseLocations.txt"
echo "->Generate BundleMetadata.json file"
