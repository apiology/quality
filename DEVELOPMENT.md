# Development

## fix.sh

If you want to use rbenv/pyenv/etc to manage versions of tools,
there's a `fix.sh` script which may be what you'd like to install
dependencies.

## Overcommit

This project uses [overcommit](https://github.com/sds/overcommit) for
quality checks.  `bundle exec overcommit --install` will install it.

## direnv

This project uses direnv to manage environment variables used during
development.  See the `.envrc` file for detail.

## Publishing

To publish new version as a maintainer:

* Check if there's a newer RuboCop version.  If so:
  * Bump major version of rubocop and change quality.gemspec to point to it:
    * [releases](https://github.com/rubocop-hq/rubocop/releases)
    * [example](https://github.com/apiology/quality/blob/master/quality.gemspec#L45)
  * bundle update
  * bundle exec rubocop -a
  * bundle exec rake quality # make fixes/bumps as needed
* Upgrade version of OpenJDK in Dockerfile
* Note last version here:
  * [releases](https://rubygems.org/gems/quality)
* Make a feature branch - e.g. `prep_for_release_YYYY`
* Check in changes
* `git log "v$(bump current)..."`
* Check Changelog.md against actual checkins; add any missing content.
* Check in any final changes
* Merge PR
* `git checkout main && git pull`
* `git stash`
* Set `type_of_bump` to patch, minor, or major
* `bump --tag --tag-prefix=v ${type_of_bump:?}`
* `bundle exec rake publish_all`
* `git push --tags`

After this:

* Verify Docker image sizes with `docker images apiology/quality` and update
  DOCKER.md with new numbers
* Verify CircleCI is building

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
