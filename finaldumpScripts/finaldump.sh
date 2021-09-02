#!/bin/bash

# This is a script to get the needed csvs out of the dcsops database
# before turning it off.  There are two csvs requestsed:
#
# 1. Incidents, with one incident per row, with all fields in incident and dat_incident
# 2. Assignments, with one incident per row

BASE_DIR=`dirname "${0}"`
BASE_DATA_DIR="${1}"

mkdir -p $BASE_DATA_DIR/incidents
mkdir -p $BASE_DATA_DIR/assignments

rails r $BASE_DIR/create_incident_sheets.rb $BASE_DATA_DIR/incidents
rails r $BASE_DIR/create_assignment_sheets.rb $BASE_DATA_DIR/assignments
