# Portworx Cloudsnap Cleanup

This is a script to clean up portworx cloudsnaps. It deletes a cloudsnap if it isn't represented in any velero backup.

The original reason for this script was a migration from ark to velero. Instead of using the migration feature, I ran velero and ark side by side until velero had enough backups, then removed ark, but was left with orphaned cloudsnaps. This script removes the orphaned cloudsnaps.