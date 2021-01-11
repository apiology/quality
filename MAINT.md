# Maintainer's guide

## Publishing a new version

Before this:

* Check if there's a newer RuboCop version.  If so:
  * Bump major version of quality and change quality.gemspec to point to it:
    * [releases](https://github.com/rubocop-hq/rubocop/releases)
    * [example](https://github.com/apiology/quality/blob/master/quality.gemspec#L45)
  * bundle update
  * bundle exec rubocop -a
  * bundle exec rake quality # make fixes/bumps as needed
* Upgrade version of OpenJDK in Dockerfile
* Note last version here:
  * [releases](https://github.com/apiology/quality/releases)
* Make sure version is bumped in lib/quality/version.rb
* Make a feature branch
* Check in changes
* Run diff like this: git log vA.B.C...
* Check Changelog.md against actual checkins; add any missing content.
* Update .travis.yml with latest supported ruby Versions:
  * [downloads](https://www.ruby-lang.org/en/downloads/)
* Drop any Ruby versions that are eol in .travis.yml
  * [branches](https://www.ruby-lang.org/en/downloads/branches/)
* Update .rubocop.yml#AllCops.TargetRubyVersion to the earliest supported
  version
* Check in any final changes
* Merge PR
* git checkout master && git pull
* bundle update && bundle exec rake publish_all

After this:

* Verify Docker image sizes with `docker images apiology/quality` and update
  DOCKER.md with new numbers
* Verify Travis is building

## Maintaining Docker image size

Look at the output of: `docker images apiology/quality`.

For each one to optimize:

```sh
docker run --entrypoint /bin/sh -it apiology/quality:${target_tag:?}
apk add file # so you can tell whether shared libraries are stripped
cd /
alias d='du -s -k $(find . -maxdepth 1 | grep -v \^\.\$) | sort -n 2>/dev/null'
```

You can now recurse and see if you can identify files that shouldn't
exist, then modify Dockerfile to purge those before they get commited
to a layer.
