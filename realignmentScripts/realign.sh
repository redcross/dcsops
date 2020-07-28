#!/bin/bash

# Requires xlsx2csv
command -v xlsx2csv 2>&1 || { echo >&2 "xls2csv required but it's not available.  Aborting."; exit 1; }

BASE_DIR=`dirname "${0}"`
REGION_DIR=$BASE_DIR/illinois
XLS="Illinois DCSOps Configurations.xlsx"
CSV_BASE=${XLS/.xlsx/}

xlsx2csv "$REGION_DIR/$XLS" -n Shifts > "$REGION_DIR/$CSV_BASE - Shifts.csv"
xlsx2csv "$REGION_DIR/$XLS" -n "Dispatch Configurations" > "$REGION_DIR/$CSV_BASE - Dispatch Configuration.csv"
xlsx2csv "$REGION_DIR/$XLS" -n "Response Territories" > "$REGION_DIR/$CSV_BASE - Response Territories.csv"
xlsx2csv "$REGION_DIR/$XLS" -n "Shift Territories" > "$REGION_DIR/$CSV_BASE - Shift Territories.csv"
xlsx2csv "$REGION_DIR/$XLS" -n "Shift Times" > "$REGION_DIR/$CSV_BASE - Shift Times.csv"
xlsx2csv "$REGION_DIR/$XLS" -n "DCSOps Positions" > "$REGION_DIR/$CSV_BASE - DCSOps Positions.csv"
xlsx2csv "$REGION_DIR/$XLS" -n "Volunteer Connection Positions" > "$REGION_DIR/$CSV_BASE - Volunteer Connection Positions.csv"
xlsx2csv "$REGION_DIR/$XLS" -n "Notifications" > "$REGION_DIR/$CSV_BASE - Notifications.csv"

rails r $BASE_DIR/realign.rb
