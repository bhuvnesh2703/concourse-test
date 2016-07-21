#!/bin/bash
pushd ambari &&
mvn versions:set -DnewVersion=${AMBARI_BUILD_VERSION} &&
pushd ambari-metrics &&
mvn versions:set -DnewVersion=${AMBARI_BUILD_VERSION} &&
popd &&

# Use below url to download phantomjs, sometimes the original link https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-1.9.8-linux-x86_64.tar.bz2 does not work
#export PHANTOMJS_CDNURL=https://bitbucket.org/ariya/phantomjs/downloads &&

# build-rpm is to let ambari-metrics-assembly generate rpms.  See ambari-metrics/ambari-metrics-assembly/pom.xml
# rpm:rpm is to let ambari-server etc. generate rpms. See ambari-server/pom.xml
# python.ver does nothing to do with python version at build time but sets a rpm dependency. See ./ambari-server/pom.xml
mvn -B -e clean install package rpm:rpm -Dbuild-rpm ${SKIP_TEST} ${SKIP_RAT_TEST} -Dpython.ver='python >= 2.6' -Dstack.distribution=HDP &&
popd &&

# Copy the generated rpms to target output folder
mkdir -p ${AMBARI_RPM_FOLDER} &&
cp ambari/ambari-server/target/rpm/ambari-server/RPMS/x86_64/ambari-server-*.rpm ${AMBARI_RPM_FOLDER}/ &&
cp ambari/ambari-agent/target/rpm/ambari-agent/RPMS/x86_64/ambari-agent-*.rpm ${AMBARI_RPM_FOLDER}/ &&
cp ambari/ambari-metrics/ambari-metrics-assembly/target/rpm/ambari-metrics-assembly/RPMS/x86_64/ambari-metrics-assembly-*.rpm ${AMBARI_RPM_FOLDER}/ &&
cp ambari/ambari-metrics/ambari-metrics-assembly/target/rpm/ambari-metrics-collector/RPMS/x86_64/ambari-metrics-collector-*.rpm ${AMBARI_RPM_FOLDER}/ &&
cp ambari/ambari-metrics/ambari-metrics-assembly/target/rpm/ambari-metrics-grafana/RPMS/x86_64/ambari-metrics-grafana-*.rpm ${AMBARI_RPM_FOLDER}/ &&
cp ambari/ambari-metrics/ambari-metrics-assembly/target/rpm/ambari-metrics-hadoop-sink/RPMS/x86_64/ambari-metrics-hadoop-sink-*.rpm ${AMBARI_RPM_FOLDER}/ &&
cp ambari/ambari-metrics/ambari-metrics-assembly/target/rpm/ambari-metrics-monitor/RPMS/x86_64/ambari-metrics-monitor-*.rpm ${AMBARI_RPM_FOLDER}/ 

# Copy setup_repo.sh and generate the tarball
cp phd-ci/setup_repo.sh ${AMBARI_RPM_FOLDER} &&
chown -R root:root ${AMBARI_RPM_FOLDER} &&
createrepo ${AMBARI_RPM_FOLDER} &&
tar cvzf ${AMBARI_RPM_FOLDER}.tar.gz ${AMBARI_RPM_FOLDER}
