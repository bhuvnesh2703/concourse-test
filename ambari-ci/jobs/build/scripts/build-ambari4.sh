#!/bin/bash
set -x -e

# Copy the generated rpms to target output folder
mkdir -p ambari_artifacts
OUTPUT_FOLDER=ambari_artifacts/${AMBARI_RPM_FOLDER}
mkdir -p ${OUTPUT_FOLDER} &&

cp phd-ci/setup_repo.sh ${OUTPUT_FOLDER} &&
chown -R root:root ${OUTPUT_FOLDER} &&
pushd ambari_artifacts &&
createrepo ${AMBARI_RPM_FOLDER} &&
tar cvzf ${AMBARI_RPM_FOLDER}.tar.gz ${AMBARI_RPM_FOLDER} &&
popd
