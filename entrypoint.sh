#!/bin/sh -e

set -o pipefail

gem update --no-document brakeman
bundle-audit update
# drop absolute paths from tool output
stdbuf -oL -eL rake -f /usr/quality/Rakefile "$@" 2>&1 | stdbuf -oL -eL sed -e 's@^/usr/app/@@g'
