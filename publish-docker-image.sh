#!/bin/bash -e

export QUALITY_GEM_VERSION=$(gem search quality | grep ^'quality ' | cut -d'(' -f2 | cut -d')' -f1)
export QUALITY_GEM_MAJOR_VERSION=$(echo ${QUALITY_GEM_VERSION} | cut -d '.' -f1)
export QUALITY_GEM_MINOR_VERSION=$(echo ${QUALITY_GEM_VERSION} | cut -d '.' -f1-2)

./publish-skinny-image.sh

./publish-jumbo-image.sh
