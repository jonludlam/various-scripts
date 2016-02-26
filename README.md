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

## check_updates.sh
The goal of this script is to periodically check the central XenServer update server to determine if any hotfixes exist for the current XenServer host and the version of software running on that host. If an update is found, the update and associated knowledge base article location will be written to syslog. If no updates are found, then nothing is written. If any updates are found, then all potential updates are listed. If a hotfix is applied, then it or any dependencies, will be removed from the list of potential fixes.

### Requirements

    1. A valid network route must exist to the YQL service from Yahoo. The full url is listed in the script
    2. The script should be launched once at system startup either via a startup cron job, or other means.
    
Note: This script is configured to run as a daemon, and will not output to stdout. All output will be present in syslog. Since it is designed to run as a daemon, it will detect running instances and exit should it be determined that one copy is already running. Should you wish to locate it in the process list, note that you will see two entries. The first is for the main script, and the second is for the sub-shell created for the main work.

### Execution time
Since there are literally many hundreds of thousands of XenServer hosts running in the world, it would be a bad idea for them all to wake up and check for an update at the same time. The daemon runs once at startup, and then will run daily at a predefined time which is host specific. DO NOT CHANGE THIS!!!!
