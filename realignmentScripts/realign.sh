#!/bin/bash

# Requires xlsx2csv
command -v xlsx2csv 2>&1 >> /dev/null || { echo >&2 "xls2csv required but it's not available.  Aborting."; exit 1; }

BASE_DIR=`dirname "${0}"`
SHEET_DIR=$BASE_DIR/sheets

run_for_region() {
  XLS=$1; shift
  CSV_BASE=${XLS/.xlsx/}
  xlsx2csv "$SHEET_DIR/$XLS" -n Shifts > "$SHEET_DIR/$CSV_BASE - Shifts.csv"
  xlsx2csv "$SHEET_DIR/$XLS" -n "Dispatch Configurations" > "$SHEET_DIR/$CSV_BASE - Dispatch Configuration.csv"
  xlsx2csv "$SHEET_DIR/$XLS" -n "Response Territories" > "$SHEET_DIR/$CSV_BASE - Response Territories.csv"
  xlsx2csv "$SHEET_DIR/$XLS" -n "Shift Territories" > "$SHEET_DIR/$CSV_BASE - Shift Territories.csv"
  xlsx2csv "$SHEET_DIR/$XLS" -n "Shift Times" > "$SHEET_DIR/$CSV_BASE - Shift Times.csv"
  xlsx2csv "$SHEET_DIR/$XLS" -n "DCSOps Positions" > "$SHEET_DIR/$CSV_BASE - DCSOps Positions.csv"
  xlsx2csv "$SHEET_DIR/$XLS" -n "Volunteer Connection Positions" > "$SHEET_DIR/$CSV_BASE - Volunteer Connection Positions.csv"
  xlsx2csv "$SHEET_DIR/$XLS" -n "Notifications" > "$SHEET_DIR/$CSV_BASE - Notifications.csv"
  rails r $BASE_DIR/realign.rb "$SHEET_DIR" "$CSV_BASE" $@
}

run_for_region "Illinois DCSOps Configurations.xlsx" cni cni central_illinois
