#!/bin/bash

# This script checks the official Citrix update server for potential updates
# specific to this host. A potential update is one which matches the version
# of XenServer running on this host, and has not already been applied.
# Since a hotfix may exist for a given service pack and also for hosts
# which have yet to apply the service pack, its not uncommon for both to be
# listed. Once the service pack has been applied, these "non-service pack"
# hot fixes will no longer show in the listing.

# IMPORTANT - THIS SCRIPT RUNS AS A DAEMON. 
# IT SHOULD BE CONFIGURED AS A STARTUP JOB, OR RUN ONCE.
# DO NOT CONFIGURE AS A RECURRING CRON JOB OR MULTIPLE INSTANCES COULD RUN

# Prevent the initial attempt at multiple runs
(
    flock -x -n 200 || { logger -t "XenServer Updates" -p Error "Multiple instances of check_updates can not run. Exiting."; exit 1 ; }  >&2
    exit 0
) 200>/var/lock/.check_updates.exclusivelock

if [ $? = 1 ] ; then 
    echo "Multiple instances not allowed"
    exit 1
fi

trap process_USR1 SIGUSR1

process_USR1() {
    logger -t "XenServer Updates" -p Warning "Exit due to signal USR1'"
    exit 0
}

#set -e
#set -x

# The following is stuff we need to do to make this a deamon.
# Reference: http://www.faqs.org/faqs/unix-faq/programmer/faq/

# not that BASH_SOURCE doesn't behave correctly if we're run using a symlink
# so Please Don't Run This With a Symlink!!!!!
LAUNCH_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# I could hard code this, but someone is likely to get cute and rename
# things, so let's just get it the right way
LAUNCH_FILE=$(basename $0)

# ensure we won't lock any directory thereby preventing umount errors
cd /

# We need to duoble fork oursleves to ensure we correctly detach 
# from terminal, don't create a zombie, and transfer ownwership to init

# Start with testing if we've been forked yet (makes logic easier)
if [ "$1" = "child" ] ; then   
    shift
    
    #make certain we have the correct privs
    umask 0
    
    # Make certain we have the correct group leader role, and take care 
    # of inherited std pipes as part of the exec
    
    logger -t "XenServer Updates" -p Notice "Starting check for updates daemon."
    exec setsid $LAUNCH_DIR/$LAUNCH_FILE daemon "$@" </dev/null >/dev/null 2>/dev/null &
    exit 0
fi

# If anyhing other than deamon is persent, then we are the original and 
# need to create a child
if [ "$1" != "daemon" ] ; then 
    logger -t "XenServer Updates" -p Notice "Starting check for updates child."
    exec $LAUNCH_DIR/$LAUNCH_FILE child "$@" &
    exit 0
fi

# Redirect pipes
exec >/tmp/.check_updates.outfile
exec 2>/tmp/.check_updates.errfile
exec 0</dev/null

logger -t "XenServer Updates" -p Notice "Started check for updates daemon."

shift

cd /tmp

# We have been properly daemonized, so lets do some work
(
    # Running multiple instances will cause no end of grief so locks are required
    # It might be tempting to try and report this error to the shell, but remember we're daemonized
    flock -x -n 200 || { logger -t "XenServer Updates" -p Error "Multiple instances of check_updates can not run. Exiting."; exit 1 ; } >&2 

    while true; do
        HOSTNAME=$(hostname) 
        HOSTUUID=$(xe host-list name-label="$HOSTNAME" --minimal)
        PRODUCT_VERSION=$(xe host-param-get uuid=$HOSTUUID param-name=software-version param-key=product_version)
        INSTALLED_PATCHES=$(xe patch-list hosts=$HOSTUUID --minimal)

        # Use YQL to get the patch list which applies to this host, and which aren't already present
        YQL_QUERY="select patches.patch.url, patches.patch.name-label, patches.patch.conflictingpatches, patches.patch.uuid from xml where url = 'http://updates.xensource.com/XenServer/updates.xml?host=$HOSTUUID&ver=$PRODUCT_VERSION' and patches.patch.uuid in ( select serverversions.version.patch.uuid from xml where url = 'http://updates.xensource.com/XenServer/updates.xml' and serverversions.version.value = '$PRODUCT_VERSION') and patches.patch.uuid not in ('$INSTALLED_PATCHES') and patches.patch.conflictingpatches.uuid not in ('$INSTALLED_PATCHES')"
        YQL_QS=$(python -c "import urllib; print urllib.quote('''$YQL_QUERY''')")
        YQL_URL="https://query.yahooapis.com/v1/public/yql?q="$YQL_QS

        rm -f ./update.txt
        rm -f ./patches.txt

        # Ignore cert errors since Yahoo apparently does overloaded certs
        wget $YQL_URL -O ./update.txt --no-check-certificate --quiet

        FLATEN=$(printf "from xml.dom import minidom; xmldoc = minidom.parse('update.txt'); itemlist = xmldoc.getElementsByTagName('patch');\nfor s in itemlist :\n\tprint 'Hotfix ' + s.attributes['name-label'].value + ' has details available at: ' + s.attributes['url'].value\n")
        python -c "$FLATEN" > ./patches.txt

        # Find out how many patches we might be behind on
        CANDIDATE_PATCHES=$(wc -l < ./patches.txt)

        if [[ ($CANDIDATE_PATCHES > 0) ]]; then
            logger -t "XenServer Updates" -p Notice "This host has $CANDIDATE_PATCHES potential hotfixes available to it. Hotfix list follows..."
            logger -t "XenServer Updates" -p Notice -f ./patches.txt
            logger -t "XenServer Updates" -p Notice "End of hotfix list."
        fi

        rm -f ./patches.txt
        rm -f ./update.txt

        # We only want to run once per day, and have it randomized, and be consistent

        # Start by sleeping until midnight
        MINUTES_UNTIL_MIDNIGHT="$((($(date -d 'tomorrow 00:00:00' +%s) - $(date +%s))/60))m"
        sleep $MINUTES_UNTIL_MIDNIGHT

        # Now have consistent "random" offset based on hostuuid
        SECONDS_OFFSET="${HOSTUUID:0:5}"
        SECONDS_S=$(printf "%ld" "0x$SECONDS_OFFSET")
        sleep $(( SECONDS_S % 86400 ))

    done

) 200>/var/lock/.check_updates.exclusivelock

exit # That's all folks!