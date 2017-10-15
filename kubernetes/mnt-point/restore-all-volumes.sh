#!/bin/bash
$(pwd)/restore-volume-to.sh samples_nexus3_data nexus3
$(pwd)/restore-volume-to.sh samples_sonarqube_data sonarqube
$(pwd)/restore-volume-to.sh samples_sonarqube_db_data sonardb
