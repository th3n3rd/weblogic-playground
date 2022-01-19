#!/bin/bash

set -e

SCRIPTS_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
TMP_DIR="$PWD/auxiliary-model-$RANDOM"

cd "$SCRIPTS_DIR/.."

trap "rm -rf $TMP_DIR" EXIT

echo "Building the application war"
./mvnw clean package -DskipTests

echo "Creating temporary staging directory"
mkdir $TMP_DIR

echo "Extracting WebLogic deploy tool content"
unzip deployment/tools/weblogic-deploy.zip -d $TMP_DIR
rm $TMP_DIR/weblogic-deploy/bin/*.cmd

echo "Prepare WebLogic models"
mkdir $TMP_DIR/models
cp -r deployment/models $TMP_DIR

echo "Prepare application archive"
mkdir -p target/wlsdeploy/applications
cp target/sample-app-0.0.1-SNAPSHOT.war target/wlsdeploy/applications
(cd target && zip -r $TMP_DIR/models/sample-app.zip wlsdeploy)

echo "Building auxiliary container image"
docker build -f deployment/Dockerfile --tag sample-app:0.0.1-SNAPSHOT-wls-aux $TMP_DIR

echo "Cleanup temporary staging directory"
rm -rf $TMP_DIR
