#!/bin/bash -e

QUALITY_GEM_VERSION=$(gem search quality | grep ^'quality ' | cut -d'(' -f2 | cut -d')' -f1)
QUALITY_GEM_MAJOR_VERSION=$(echo "${QUALITY_GEM_VERSION}" | cut -d '.' -f1)
QUALITY_GEM_MINOR_VERSION=$(echo "${QUALITY_GEM_VERSION}" | cut -d '.' -f1-2)

rocker build \
       -var "quality_gem_version=${QUALITY_GEM_VERSION:?}" \
       -var "quality_gem_major_version=${QUALITY_GEM_MAJOR_VERSION:?}" \
       -var "quality_gem_minor_version=${QUALITY_GEM_MINOR_VERSION:?}" \
       --push \
       ${QUALITY_BUILD_ARGS} \
