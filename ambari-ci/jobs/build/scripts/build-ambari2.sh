#!/bin/bash

source ambari-ci/jobs/build/docker/build-docker.sh

set -e -x -u
ps -ef|grep docker

export AMBARI_CODE_DIR=$(pwd)/ambari
export PWD=$(pwd)
export AMBARI_BUILD_VERSION=${AMBARI_VERSION}.${BUILD_NUMBER}-SNAPSHOT
export AMBARI_TAR_NAME=AMBARI-${AMBARI_GIT_BRANCH}
export AMBARI_PATH_NAME=target/${AMBARI_TAR_NAME}

mkdir -p ${PWD}/.m2
chmod 777 ${PWD}/.m2

# If stack PHD is given, build will fail.
if [ $STACK == "None" ] ; then
  stack_distribution_param=""
elif [ $STACK == "PHD" ] ; then
  stack_distribution_param="-Preplaceurl -Ppluggable-stack-definition -Dstack.distribution=${STACK} -DdefaultStackVersion=PHD-${STACK_VERSION}"
else
  stack_distribution_param="-Dstack.distribution=${STACK}"
fi

# Check if test needs to be skipped, default: skip test
if [ $SKIP_TEST == false ] ; then
   skip_test=""
else
   skip_test="-DskipTests"
fi

# Check if rat test needs to be skipped, default: skip rat test
if [ $SKIP_RAT_TEST == false ] ; then
   skip_rat_test=""
else
   skip_rat_test="-Drat.skip"
fi

# Start Build process and copy target rpms
docker run --rm=true \
        -w /home/${USER_NAME} \
        -u ${USER_NAME} \
        -v ${PWD}:/home/${USER_NAME} \
        -v ${PWD}/.m2:/home/${USER_NAME}/.m2 \
        ${IMAGE_NAME}-${USER_NAME} \
        /bin/bash -c "
                      pushd ambari &&
                      mvn versions:set -DnewVersion=${AMBARI_BUILD_VERSION} &&
                      pushd ambari-metrics &&
                      mvn versions:set -DnewVersion=${AMBARI_BUILD_VERSION} &&
                      popd &&

                      # Use below url to download phantomjs, sometimes the original link https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-1.9.8-linux-x86_64.tar.bz2 does not work
                      export PHANTOMJS_CDNURL=http://dist.eng.pivotal.io/dist/packages/phantomjs &&

                      if [ $STACK == 'PHD' ] ; then
                        cp -f ../ambari-ci/jobs/build/logo/logo-white.png ambari-web/app/assets/img/logo-white.png;
                      fi

                      # build-rpm is to let ambari-metrics-assembly generate rpms.  See ambari-metrics/ambari-metrics-assembly/pom.xml
                      # rpm:rpm is to let ambari-server etc. generate rpms. See ambari-server/pom.xml
                      # python.ver does nothing to do with python version at build time but sets a rpm dependency. See ./ambari-server/pom.xml
                      mvn -B -e clean install package rpm:rpm -Dbuild-rpm ${skip_test} ${skip_rat_test} -Dpython.ver='python >= 2.6' ${stack_distribution_param} &&
                      popd &&

                      # Copy the generated rpms to target output folder
                      rm -rf target &&
                      mkdir -p ${AMBARI_PATH_NAME} &&
                      cp ambari/ambari-server/target/rpm/ambari-server/RPMS/x86_64/ambari-server-*.rpm ${AMBARI_PATH_NAME}/ &&
                      cp ambari/ambari-agent/target/rpm/ambari-agent/RPMS/x86_64/ambari-agent-*.rpm ${AMBARI_PATH_NAME}/ &&
                      cp ambari/ambari-metrics/ambari-metrics-assembly/target/rpm/ambari-metrics-assembly/RPMS/x86_64/ambari-metrics-assembly-*.rpm ${AMBARI_PATH_NAME}/ &&
                      cp ambari/ambari-metrics/ambari-metrics-assembly/target/rpm/ambari-metrics-collector/RPMS/x86_64/ambari-metrics-collector-*.rpm ${AMBARI_PATH_NAME}/ &&
                      cp ambari/ambari-metrics/ambari-metrics-assembly/target/rpm/ambari-metrics-grafana/RPMS/x86_64/ambari-metrics-grafana-*.rpm ${AMBARI_PATH_NAME}/ &&
                      cp ambari/ambari-metrics/ambari-metrics-assembly/target/rpm/ambari-metrics-hadoop-sink/RPMS/x86_64/ambari-metrics-hadoop-sink-*.rpm ${AMBARI_PATH_NAME}/ &&
                      cp ambari/ambari-metrics/ambari-metrics-assembly/target/rpm/ambari-metrics-monitor/RPMS/x86_64/ambari-metrics-monitor-*.rpm ${AMBARI_PATH_NAME}/ "


# Create repo
docker run --rm=true \
        -w /home/${USER_NAME} \
        -u "root" \
        -v ${PWD}:/home/${USER_NAME} \
        -v "${PWD}/phd-misc-peacock:/home/${USER_NAME}/phd-misc-peacock" \
        ${IMAGE_NAME}-${USER_NAME} \
        /bin/bash -c "
                      cp phd-misc-peacock/stack-utils/setup_repo.sh ${AMBARI_PATH_NAME}/ &&
                      pushd target &&
                      chown -R root:root ${AMBARI_TAR_NAME} &&
                      createrepo ${AMBARI_TAR_NAME} &&
                      tar cvzf ${AMBARI_TAR_NAME}-${STACK}-${BUILD_NUMBER}.tar.gz ${AMBARI_TAR_NAME} &&
                      
                      # Generate latest tars if GENERATE_LATEST set to true.
                      if $GENERATE_LATEST ; then
                        tar cvzf ${AMBARI_TAR_NAME}-${STACK}-latest.tar.gz ${AMBARI_TAR_NAME};
                      fi
                      
                      chown -R ${USER_NAME}:${GROUP_ID} ${AMBARI_TAR_NAME}"
