#!/bin/sh 
# apply all XenServer patches which have been approved in our manifest

# set -x

# The following variables should be set correctly for this to work
PATCH_SOURCE="/mnt/xshotfixes/manifest6.5"
HOTFIX_LIBRARY="10.192.130.41:/vol/exports/isolibrary/xs-hotfixes"

# Everything past here should never need modification

echo "Running...."
logger -t "Patch Host" -p Notice "Start patch processing"
mkdir /mnt/xshotfixes
mount $HOTFIX_LIBRARY /mnt/xshotfixes

HOSTNAME=$(hostname)
HOSTUUID=$(xe host-list name-label=$HOSTNAME --minimal)

while read PATCH
do 
if [ "$(echo "$PATCH" | head -c 1)" != '#' ]
then 
    PATCHNAME=$(echo "$PATCH" | awk -F: '{ split($1,a,"."); printf ("%s\n", a[1]); }')

    if [ -z "$PATCHNAME" ]
    then
        continue
    fi

    echo "Processing $PATCHNAME" 
    logger -t "Patch Host" -p Notice "Processing $PATCHNAME"

    PATCHUUID=$(xe patch-list name-label=$PATCHNAME hosts=$HOSTUUID --minimal)
    if [ -z "$PATCHUUID" ]
    then
        echo "Patch not yet applied; applying ..." 
        logger -t "Patch Host" -p Notice "Applying hotfix: $PATCHNAME"
        PATCHUUID=$(xe patch-upload file-name=/mnt/xshotfixes/$PATCH)
        if [ -z "$PATCHUUID" ] #empty uuid means patch uploaded, but not applied to this host
        then
            PATCHUUID=$(xe patch-list name-label=$PATCHNAME --minimal)
            if [ -z "$PATCHUUID" ] #empty uuid at this point means patch name invalid or file missing
            then
                echo "Unable to find UUID for hotfix file: '$PATCH'. Verify file exists and attempt manual xe patch-upload." 
                logger -t "Patch Host" -p Notice "Unable to find UUID for hotfix file: '$PATCH'. Verify file exists and attempt manual xe patch-upload."

                continue
            fi
        fi
        #apply the patch to *this* host only
        xe patch-apply uuid=$PATCHUUID host-uuid=$HOSTUUID > ./patch.log
        cat ./patch.log # dump results to stdout
        logger -t "Patch Host" -p Notice -f ./patch.log
        rm -f ./patch.log

        # remove the patch files to avoid running out of disk space in the future
        xe patch-clean uuid=$PATCHUUID 

        #figure out what the patch needs to be fully applied and then do it
        PATCHACTIVITY=$(xe patch-list name-label=$PATCHNAME params=after-apply-guidance | sed -n 's/.*: \([.]*\)/\1/p')
        if [ "$PATCHACTIVITY" == 'restartXAPI' ]
        then
            echo "$PATCHNAME requires XAPI restart, so restart toolstack now!!"
            logger -t "Patch Host" -p Notice "$PATCHNAME requires XAPI restart, so restart toolstack now!"

            xe-toolstack-restart
            # give time for the toolstack to restart before processing any more patches
            sleep 60
        elif [ "$PATCHACTIVITY" == 'restartHost' ]
        then
            # we need to reboot, but we may not be done.
            # need to create a link to our script

            # first find out if we're already being run from a reboot
            MYNAME="`basename \"$0\"`"
            if [ "$MYNAME" == 'manifest_patch.sh' ]
            then
                # I'm the base path so copy myself to the correct location
                cp "$0" /etc/rc3.d/S99zzzzapplypatches  
            fi

            echo "$PATCHNAME requires reboot, so reboot now!"
            logger -t "Patch Host" -p Notice "$PATCHNAME requires reboot, so reboot now!"
            reboot
            exit
        fi

    else
        echo "$PATCHNAME already applied"
        logger -t "Patch Host" -p Notice "$PATCHNAME already applied"
    fi

fi
done < $PATCH_SOURCE

echo "Done patch processing" 
logger -t "Patch Host" -p Notice "Done patch processing"
umount /mnt/xshotfixes
rmdir /mnt/xshotfixes

# lastly if I'm running as part of a reboot; kill the link
rm -f /etc/rc3.d/S99zzzzapplypatches