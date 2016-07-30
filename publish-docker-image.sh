#!/bin/bash -e

QUALITY_GEM_VERSION=$(gem search quality | grep ^'quality ' | cut -d'(' -f2 | cut -d')' -f1)
docker build -t apiology/quality:${QUALITY_GEM_VERSION} .
docker tag apiology/quality:${QUALITY_GEM_VERSION} apiology/quality:latest
docker push apiology/quality:${QUALITY_GEM_VERSION}
docker push apiology/quality:latest
