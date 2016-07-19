#!/bin/bash

cp phd-misc-peacock/stack-utils/setup_repo.sh build-ambari-rpms/ &&
chown -R root:root build-ambari-rpms &&
createrepo build-ambari-rpms/ &&
tar cvzf AMBARI-OUTPUT.tar.gz build-ambari-rpms &&
