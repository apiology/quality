#!/bin/sh -e

gem update --no-document brakeman
bundle-audit update
rake -f /usr/quality/Rakefile quality
