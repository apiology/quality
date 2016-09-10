#!/bin/bash -e

docker build -f Dockerfile.jumbo --no-cache ${QUALITY_BUILD_ARGS} -t apiology/quality:jumbo-${QUALITY_GEM_VERSION} .
docker tag apiology/quality:jumbo-${QUALITY_GEM_VERSION} apiology/quality:jumbo-latest
docker tag apiology/quality:jumbo-${QUALITY_GEM_VERSION} apiology/quality:jumbo-${QUALITY_GEM_MAJOR_VERSION}
docker tag apiology/quality:jumbo-${QUALITY_GEM_VERSION} apiology/quality:jumbo-${QUALITY_GEM_MINOR_VERSION}
docker push apiology/quality:jumbo-${QUALITY_GEM_VERSION}
docker push apiology/quality:jumbo-${QUALITY_GEM_MAJOR_VERSION}
docker push apiology/quality:jumbo-${QUALITY_GEM_MINOR_VERSION}
docker push apiology/quality:jumbo-latest

