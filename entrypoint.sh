#!/bin/sh -e

gem update brakeman
bundle-audit update
rake -f /usr/quality/Rakefile quality
