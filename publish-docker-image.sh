#!/bin/bash -e

quality_gem_version=$(gem search quality | grep ^'quality ' | cut -d'(' -f2 | cut -d')' -f1)
quality_gem_major_version=$(echo "${quality_gem_version:?}" | cut -d '.' -f1)
quality_gem_minor_version=$(echo "${quality_gem_version:?}" | cut -d '.' -f1-2)

docker build \
       -t "apiology/quality:${quality_gem_version:?}" \
       -t "apiology/quality:${quality_gem_minor_version:?}" \
       -t "apiology/quality:${quality_gem_major_version:?}" \
       -t apiology/quality:latest \
       --build-arg quality_gem_version="${quality_gem_version:?}" \
       --target latest \
       ${QUALITY_BUILD_ARGS} \
       .

docker build \
       -t "apiology/quality:jumbo-${quality_gem_version:?}" \
       -t "apiology/quality:jumbo-${quality_gem_minor_version:?}" \
       -t "apiology/quality:jumbo-${quality_gem_major_version:?}" \
       -t apiology/quality:jumbo-latest \
       --build-arg quality_gem_version="${quality_gem_version:?}" \
       --target jumbo \
       ${QUALITY_BUILD_ARGS} \
       .

for tag in ${quality_gem_version:?} \
           ${quality_gem_minor_version:?} \
           ${quality_gem_major_version:?} \
           latest \
           jumbo-${quality_gem_version:?} \
           jumbo-${quality_gem_minor_version:?} \
           jumbo-${quality_gem_major_version:?} \
           jumbo-latest
do
  docker push "apiology/quality:${tag:?}"
done
