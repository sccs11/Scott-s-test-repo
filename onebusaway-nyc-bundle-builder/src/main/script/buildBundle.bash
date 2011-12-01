#!/bin/bash 

# Script created by Scott Clark to begin to script the bundle building process.
BUNDLE_DATA_DIR=bundle_data
B63_ROUTESTXT_WITH_COLORS_FILENAME=routes_b63_with_colors.txt
SI_ROUTESTXT_WITH_COLORS_FILENAME=routes_si_with_colors.txt

GTFS_DOWNLOAD_LOC=http://www.mta.info/developers/data/nyct/bus/
GTFS_STATEN_ISLAND=google_transit_staten_island
GTFS_BROOKLYN=google_transit_brooklyn
GTFS_B63=gtfs-b63

downloadFile () {
  file=$1
  if [ -z "$file" ] 
  then
    echo downloadFile requires one argument.
    return 1
  fi

  echo Downloading File $file with wget:
  wget -nv $file
}

zipUpGtfs () {
  gtfsName=$1

  if [ ! -d $gtfsName ]
  then
    echo zipUpGtfs requires one argument, the directory of gtfs files to zip up.
    return 1
  fi

  cd $gtfsName
  zip -q ../${gtfsName}.zip *.txt && cd ..
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

echo
echo "Modify Staten Island GTFS"

echo "Unzip staten island gtfs and replace routes.txt"
mkdir $GTFS_STATEN_ISLAND
cd $GTFS_STATEN_ISLAND

unzip -LL -q ../../$GTFS_STATEN_ISLAND.zip.original_from_mta

mv routes.txt ../routes_si_from_original_gtfs.txt
cp ../../$SI_ROUTESTXT_WITH_COLORS_FILENAME routes.txt

echo "zip up new Staten Island GTFS"

cd ..

zipUpGtfs $GTFS_STATEN_ISLAND
rm $GTFS_STATEN_ISLAND/*
rmdir $GTFS_STATEN_ISLAND

echo "Done modifying Staten Island GTFS"

echo
echo "Turn Brooklyn GTFS -> B63 GTFS"
echo "Running onebusaway-gtfs-transformer-cli "
java -Xmx2G -jar ../lib/onebusaway-gtfs-transformer-cli-1.2.5.jar --transform=../gtfs_transformer_modifications.txt ../$GTFS_BROOKLYN.zip.original_from_mta ./$GTFS_BROOKLYN

echo 
echo "Update the routes file in brooklyn->b63 GTFS"
cd $GTFS_BROOKLYN 
mv routes.txt ../routes_b63_from_original_reduced_gtfs.txt
cp ../../$B63_ROUTESTXT_WITH_COLORS_FILENAME routes.txt
cd ..

echo "Zipping up B63 GTFS reduced from the Brooklyn GTFS"
zipUpGtfs $GTFS_BROOKLYN
rm $GTFS_BROOKLYN/*
rmdir $GTFS_BROOKLYN

mv $GTFS_BROOKLYN.zip $GTFS_B63.zip

echo "Done modifying the B63 GTFS"

echo 
echo "Script finished, however I didnt do any of the following:"
echo "->Combine Staten Island and Brooklyn STIF files."
echo "->Run python script on combined STIFs"
echo "->Build bundle"
echo "->Add BaseLocations.txt"
echo "->Generate BundleMetadata.json file"
