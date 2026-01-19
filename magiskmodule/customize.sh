#!/system/bin/sh

exec 2>&1

[ "$BOOTMODE" != "true" ] && abort "Please install this module within the Magisk app."

# path to already installed module
INSTALLEDMODPATH=/data/adb/modules/MagicalProtection

[ ! -d "$INSTALLEDMODPATH" ] && return 0
[ ! -w /system/etc/hosts ] && return 0

ui_print "- Performing in-place update"

cp -v -r -f "$MODPATH"/* "$INSTALLEDMODPATH"
cp -v -f "$MODPATH"/system/etc/hosts /system/etc/hosts

rm -v -r "$MODPATH"

exit 0
