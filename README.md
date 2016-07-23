# concourse-test
YML files to create pipelines to build ambari on concourse

Prereq:
- Concourse
- Required Repo

Deploy the pipeline

1. Pipeline to create a docker image with required dev utils, .npm and .m2 repo
```
fly -t <some-target-name> -p build-ambari-dev-docker -c pipelines/build-ambari-dev-docker-image.yml -l credentials/ambari-pipeline-credentials.yml
```
2. Pipeline to create ambari tarball
```
fly -t <some-target-name> -p build-ambari -c pipelines/build-ambari-tarball.yml -l credentials/ambari-pipeline-credentials.yml
```
Note: 
- credentials/ambari-pipeline-credentials.yml is just for reference purposes, update it with correct credentials before using it.
