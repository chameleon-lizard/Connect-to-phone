# Connect-to-phone

MacOS's Switch Control for Android devices. Tested on Linux, but probably works on MacOS and Windows too!

# Requirements

```
scrcpy
adb
```

Regular scrcpy does not cut it as the packaged version might be too old, so you'll need to [compile it yourself](https://github.com/Genymobile/scrcpy/blob/master/doc/linux.md#latest-version).

# Usage

After cloning the repo, enable wireless debugging on your Android smartphone and replace sample mac address in the script with the mac address of your device. Also, you need to pair your PC with your smartphone via `adb pair`.

After that, run it with:

```
./connect_to_phone.sh
```

After successful connection, it writes the credentials used for previous connect to the file at `$HOME/.previous_phone_connect`. To connect to phone faster, you can use the following command:

```
./connect_to_phone.sh -p $HOME/.previous_phone_connect
```
