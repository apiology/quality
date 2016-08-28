#!/bin/bash -e

export QUALITY_GEM_VERSION=$(gem search quality | grep ^'quality ' | cut -d'(' -f2 | cut -d')' -f1)

./publish-skinny-image.sh

./publish-jumbo-image.sh
