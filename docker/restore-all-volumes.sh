#!/bin/bash
$(pwd)/restore-volume.sh samples_nexus3_data
$(pwd)/restore-volume.sh samples_sonarqube_data
$(pwd)/restore-volume.sh samples_sonarqube_db_data 

