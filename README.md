# Solitaire Games

A set of solitaire card games made for the Ubuntu Touch App Showdown


## Requirements

* Ubuntu SDK

* nemomobile folderlistmodel -

    https://code.launchpad.net/~ajalkane/ubuntu-filemanager-app/qml-folderlistmodel

* U1db - qtdeclarative5-u1db1.0


## Usage

In Ubuntu sdk you can make a click package at >packaging

Next you can issue:

`sudo click install --force-missing-framework --user=$USER ./*.click`

in the directory of the click package.

The app is installed in /opt/click.ubuntu.com/be.samsegers.solitaire-games/current

You can issue `qmlscene $@ solitaire-games.qml` from there to run it.

To build a deb package, copy the source in a new directory and issue `debuild -b` from the source to build the package. Afterwards you can use `sudo dpkg -i` in the parent directory to install it.

## TODO

* Better xml listing of games (with db key and game rules)

* Better layout for mobile (never tested)

* Better scaleability (cards get really small)

* More games

