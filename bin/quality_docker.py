import os
import subprocess


def parse_tag(tag):
    image_type = None
    version = None
    if "-" not in tag:
        version = tag
    else:
        image_type, version = tag.split("-")
    return image_type, version


def tag_to_version(tag):
    image_type, version = parse_tag(tag)
    return version


def ensure_passes(tag):
    cwd = os.getcwd()
    args = ["docker",
            "run",
            "-v", cwd + ":/usr/app"]
    if os.path.isfile('Rakefile.quality'):
        args += ["-v", cwd + "/Rakefile.quality:/usr/quality/Rakefile"]
    args += ["apiology/quality:" + tag]

    print("About to call " + str(" ".join(args)))
    output = subprocess.check_output(args)
    print("output is " + output)
