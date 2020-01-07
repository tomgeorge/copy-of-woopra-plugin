#!/bin/bash

# Set versions:
# CURRENT_MAJOR
# CURRENT_MINOR
# CURRENT_PATCH
# NEW_VERSION_STRING
CURRENT_VERSION=$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout)
CURRENT_MAJOR=$(echo $CURRENT_VERSION | cut -d . -f1)
CURRENT_MINOR=$(echo $CURRENT_VERSION | cut -d . -f2)
CURRENT_PATCH=$(echo $CURRENT_VERSION | cut -d . -f3)
NEW_PATCH=$((CURRENT_PATCH+1))
NEW_VERSION_STRING="$CURRENT_MAJOR.$CURRENT_MINOR.$NEW_PATCH"

# Run xq (jq for XML) on each pom, replacing the old version strings with the new ones
xq --arg NEW_VERSION_STRING "$NEW_VERSION_STRING" -x '.project.version=$NEW_VERSION_STRING' pom.xml  > new-pom.xml
mv new-pom.xml pom.xml
