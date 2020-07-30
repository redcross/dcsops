#!/bin/bash

# This script depends on having access to private information
# mainly for OTS developers.  If you need the xlsx and csv files,
# reach out to redcross or OTS to see them.

# Requires xlsx2csv
command -v xlsx2csv 2>&1 >> /dev/null || { echo >&2 "xls2csv required but it's not available.  Aborting."; exit 1; }

BASE_DATA_DIR="${1}"

if [ "${BASE_DATA_DIR}" = "" ]; then
  echo "ERROR: BASE_DATA_DIRECTORY argument required."
  echo ""
  echo "Usage: '${0} BASE_DATA_DIRECTORY'"
  echo ""
  echo "All the work is done in the data dir"
  echo ""
  exit 1
fi

if [ "${OTSDIR}" = "" ] ; then
  echo "ERROR: \$OTSDIR is not set up"
  echo ""
  echo "See bureaucracy/onboarding about setting the OTSDIR environment variable up"
  exit 1
fi

BASE_DIR=`dirname "${0}"`
SHEET_DIR=$OTSDIR/clients/red-cross/dcsops/data/realignmentSheets

run_for_region() {
  XLS=$1; shift
  CSV_BASE=${XLS/.xlsx/}
  echo "Doing $XLS"
  xlsx2csv "$SHEET_DIR/$XLS" -n "Shifts" > "$BASE_DATA_DIR/$CSV_BASE - Shifts.csv"
  xlsx2csv "$SHEET_DIR/$XLS" -n "Dispatch Configurations" > "$BASE_DATA_DIR/$CSV_BASE - Dispatch Configuration.csv"
  xlsx2csv "$SHEET_DIR/$XLS" -n "Response Territories" > "$BASE_DATA_DIR/$CSV_BASE - Response Territories.csv"
  xlsx2csv "$SHEET_DIR/$XLS" -n "Shift Territories" > "$BASE_DATA_DIR/$CSV_BASE - Shift Territories.csv"
  xlsx2csv "$SHEET_DIR/$XLS" -n "Shift Times" > "$BASE_DATA_DIR/$CSV_BASE - Shift Times.csv"
  xlsx2csv "$SHEET_DIR/$XLS" -n "DCSOps Positions" > "$BASE_DATA_DIR/$CSV_BASE - DCSOps Positions.csv"
  xlsx2csv "$SHEET_DIR/$XLS" -n "Volunteer Connection Positions" > "$BASE_DATA_DIR/$CSV_BASE - Volunteer Connection Positions.csv"
  xlsx2csv "$SHEET_DIR/$XLS" -n "Notifications" > "$BASE_DATA_DIR/$CSV_BASE - Notifications.csv"
  rails r $BASE_DIR/realign.rb "$BASE_DATA_DIR" "$CSV_BASE" $@
  echo "Done with $XLS."
  echo "---------------------------------"
}

rails r $BASE_DIR/pre_realign.rb

run_for_region "Illinois DCSOps Configurations.xlsx" cni cni central_illinois
run_for_region "California Gold Country DCSOps Configurations.xlsx" gold_country gold_country gsr
run_for_region "Cascades DCSOps Configurations.xlsx" cascades cascades
run_for_region "Greater New York DCSOps Configurations.xlsx" gny gny
run_for_region "Idaho and Montana DCSOps Configurations.xlsx" idaho_montana idaho_montana
run_for_region "Kansas DCSOps Configurations.xlsx" kansas kansas
run_for_region "Minnesota and Dakotas DCSOps Configurations.xlsx" southern_minnesota southern_minnesota
run_for_region "Nebraska DCSOps Configurations.xlsx" nebraska nebraska
run_for_region "New Jersey DCSOps Configurations.xlsx" newjersey newjersey
run_for_region "Northern California Coastal DCSOps Configurations.xlsx" gsr gsr

rails r $BASE_DIR/post_realign.rb "$SHEET_DIR/admins.csv"
