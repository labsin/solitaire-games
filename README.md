# Solitaire Games

A set of solitaire card games made for the Ubuntu Touch App Showdown

For more info and download links, check the wiki at: https://github.com/labsin/solitaire-games/wiki


## Requirements

* Ubuntu SDK

* nemomobile folderlistmodel -

    https://code.launchpad.net/~ajalkane/ubuntu-filemanager-app/qml-folderlistmodel

* U1db - qtdeclarative5-u1db1.0


## Usage

In Ubuntu sdk you can make a click package at >packaging. You will first need to remove the
/.git, /debian and /desktop because they have write protection or are unneded.
You can also issue `click build <folder-name>` to build the package.

Next you can issue:
`sudo click install --force-missing-framework --user=$USER ./*.click`
in the directory of the click package.

The app is installed in /opt/click.ubuntu.com/be.samsegers.solitaire-games/current

You can issue `qmlscene $@ solitaire-games.qml` from there to run it.

To build a deb package, copy the source in a new directory and issue
`debuild -b` from the source folder to build the package.
Afterwards you can use `sudo dpkg -i ./*.deb` in the parent directory to install it.

## TODO

* Better layout for mobile (never tested)

* Check app in confinement

* More games

