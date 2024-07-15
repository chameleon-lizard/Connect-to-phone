# Connect-to-phone

MacOS's Switch Control for linux.

# Requirements

```
scrcpy
adb
```

Regular scrcpy does not cut it as the packaged version might be too old, so you'll need to [compile it yourself](https://github.com/Genymobile/scrcpy/blob/master/doc/linux.md#latest-version).

# Usage

After cloning the repo, enable wireless debugging on your Android smartphone and replace sample mac address in the script with the mac address of your device.

After that, run it with:

```
./connect_to_phone.sh
```
