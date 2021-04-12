# *************************************************************************
#
# Copyright 2020 Xilinx, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# *************************************************************************
#! /bin/bash

if [ $# -eq 0 ]; then
    echo "Usage: checkout.sh ROOTDIR [VERSION]"
    echo ""
    echo "    ROOTDIR    PATH"
    echo "               Directory for checking out."
    echo "    VERSION    X.Y"
    echo "               Version number of OpenNIC."
    exit 1
fi

ROOTDIR=$1
ORGDIR="${ROOTDIR}/github.com/Xilinx"

VERSION_FILE="version.yaml"
VERSION=$(head -n 1 $VERSION_FILE | cut -d ":" -f 1)
if [ $# -gt 1 ]; then
    VERSION=$2
fi

REPO_TAG_LINES=$(grep -w "${VERSION}:" --after-context=2 ${VERSION_FILE} | tail -n +2)

if [ -z "$REPO_TAG_LINES" ]; then
    echo "Cannot find OpenNIC version $VERSION"
    exit 1
fi

echo "Checking out OpenNIC version $VERSION..."
while IFS=" :" read -r REPO TAG
do
    if [ ! -e ${ORGDIR}/${REPO} ]; then
        mkdir -p ${ORGDIR}
        echo "Cloning $REPO into $(realpath --relative-base=. ${ORGDIR}/${REPO})..."
        git clone -q https://github.com/Xilinx/${REPO} ${ORGDIR}/${REPO}
    else
        echo "Found $REPO at $(realpath --relative-base=. ${ORGDIR}/${REPO})"
    fi

    echo "Checking out $REPO @ $TAG"
    pushd ${ORGDIR}/${REPO} > /dev/null
    git checkout -q $TAG
    popd > /dev/null
done <<< "$REPO_TAG_LINES"
echo "OpenNIC version $VERSION checked out"
