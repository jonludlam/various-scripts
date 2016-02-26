# various-scripts
This project contains various utility scripts. Each script is described below.

## update_xs_yum.sh
The goal of this script is to create a yum repository containing RPMs from the latest development branch of XenServer.

Intended to be run from the root of your repo directory
### Requirements:
    1. a directory named 'daily'
    2. createrepo installed
    3. libcdio installed

This script will download XenServer snapshot ISOs, and extract them. If the script is run more than once per day, any existing daily will be overwritten.

A blog describing its use can be found here: http://xenserver.org/discuss-virtualization/virtualization-blog/entry/a-new-year-a-new-way-to-build-for-xenserver.html

## manifest_patch.sh
The goal of this script is to provide a mechinaism to patch a host to a specific patch level using a manifest file. This way all hosts in a data center can have the same, known, patch level.

### Requirements:

NOTE: The script should be modified prior to use for the local environment.

HOTFIX_LIBRARY - A fully qualified NFS path to a directory containing the manifest and hotfix files
PATCH_SOURCE - The fully qualified manifest file

A blog describing its use can be found here: http://xenserver.org/discuss-virtualization/virtualization-blog/entry/patching-xenserver-at-scale.html

Note that in the blog, manifest_patch.sh is referenced as apply_patch.sh.


