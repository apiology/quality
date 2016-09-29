def version_component_newer_than(a, b):
    if a is None and b is None:
        return False

    if a is None:
        # b != -1, so a will float upwards - prefer it
        return True

    if b is None:
        # a != -1, so b will float upwards - prefer it
        return False

    # neither a nor b are -1
    return int(a) > int(b)


def parse_version(version):
    major, minor, patch = None, None, None
    if "." in version:
        major, minor, patch = version.split(".")
    else:
        major = version

    return (major, minor, patch)


def version_newer_than(version_a, version_b):
    a_major, a_minor, a_patch = parse_version(version_a)
    b_major, b_minor, b_patch = parse_version(version_b)

    if version_component_newer_than(a_major, b_major):
        return True

    if version_component_newer_than(b_major, a_major):
        return False

    if version_component_newer_than(a_minor, b_minor):
        return True

    if version_component_newer_than(b_minor, a_minor):
        return False

    if version_component_newer_than(a_patch, b_patch):
        return True

    if version_component_newer_than(b_patch, a_patch):
        return False

    # Same, so not newer
    return False
