#!/bin/bash -e

HERE=$(dirname $0)


CLOUDSNAPS_FILE=$HERE/zz_cloudsnaps.txt
VELEROS_FILE=$HERE/zz_veleros.txt
DELETES_FILE=$HERE/zz_deletes.txt

zkubectl() {
  kubectl $*
}

zvelero() {
  if [ -f "$HERE/velero" ]; then
    $HERE/velero $*
  else
    velero $*
  fi
}

PX_POD=$(zkubectl get pods -lname=portworx -oname | head -n1)
zpxctl() {
  kubectl -n kube-system exec $PX_POD -- /opt/pwx/bin/pxctl $*
}

echo "Getting all portworx cloudsnaps (get coffee - this takes 5-10 minutes)"
zpxctl cs list | awk '/Done/ { print $3 }' >$CLOUDSNAPS_FILE

echo "Getting all velero snapshot names (Get coffee - this takes a few minutes)"
zvelero describe backup --details | awk '/Snapshot ID:/ { print $3 }' >$VELEROS_FILE

egrep -vif $VELEROS_FILE $CLOUDSNAPS_FILE >$DELETES_FILE || true

NUM_TO_DELETE=$(wc -l <$DELETES_FILE)
echo "There are $NUM_TO_DELETE cloudsnaps to delete."

if (( NUM_TO_DELETE > 0 )); then
  read -p "Type yes to delete $NUM_TO_DELETE cloudsnaps: " -r PROCEED
  
  if [[ "$PROCEED" = "yes" ]]; then
    echo
    echo "Proceeding in 5 seconds."
    sleep 5

    for id in $(cat $DELETES_FILE); do
      echo "Deleting $id"
      pxctl cloudsnap delete -s $id
    done
  fi
fi