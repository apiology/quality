import subprocess


def ensure_main_branch_and_clean_checkout():
    current_branch = subprocess.check_output(["git",
                                              "rev-parse",
                                              "--abbrev-ref",
                                              "HEAD"]).rstrip("\r\n")

    if (current_branch != "main"):
        print("Please change to main branch from [" + current_branch + "]")
        exit(1)

    git_changes = subprocess.check_output(["git",
                                           "diff",
                                           "--shortstat"])

    if git_changes != "":
        print("Please clean git directory")
        exit(1)
    else:
        print("git_changes is " + git_changes)


def force_create_branch():
    branch_name = "automated_upgrade_quality_gem"
    args = ["git",
            "branch",
            "-D",
            branch_name]
    # OK if this doesn't exist
    subprocess.call(args)

    args = ["git",
            "checkout",
            "-b",
            branch_name]
    output = subprocess.check_output(args)
    print("output is " + output)
