# Using Docker with quality

```bash
docker run -v `pwd`:/usr/app apiology/quality:latest
```

If you'd like to customize, you can link in your own Rakefile like this:

```bash
docker run -v `pwd`:/usr/app -v `pwd`/Rakefile.quality:/usr/quality/Rakefile apiology/quality:latest
```

The default 'latest' tag contains the Ruby tools in a relatively small
image.  Likewise, you can point to individual versions (as `x.y.z`,
`x.y`, or `x` with Docker tags).

You can also get additional tools (see `Rockerfile` in
this directory) by using the tag `prefix-`(version) (e.g.,
`prefix-latest`, `prefix-x.y.z`, etc).

Supported images:

* (default): Ruby support (152MB)
* `python-<version>`: Plus support for Python tools (198MB)
* `shellcheck-<version>`: Plus support for running shellcheck against
  shell scripts (207MB)
* `jumbo-<version>`: Plus support for scalastyle. (574MB)

To run an individual tool, you can run like this:

```bash
docker run -v `pwd`:/usr/app apiology/quality:latest rubocop
```
