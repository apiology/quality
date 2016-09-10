#!/bin/bash -e

docker build --no-cache ${QUALITY_BUILD_ARGS} -t apiology/quality:${QUALITY_GEM_VERSION} .
docker tag apiology/quality:${QUALITY_GEM_VERSION} apiology/quality:latest
docker tag apiology/quality:${QUALITY_GEM_VERSION} apiology/quality:${QUALITY_GEM_MAJOR_VERSION}
docker tag apiology/quality:${QUALITY_GEM_VERSION} apiology/quality:${QUALITY_GEM_MINOR_VERSION}
docker push apiology/quality:${QUALITY_GEM_VERSION}
docker push apiology/quality:${QUALITY_GEM_MAJOR_VERSION}
docker push apiology/quality:${QUALITY_GEM_MINOR_VERSION}
docker push apiology/quality:latest
