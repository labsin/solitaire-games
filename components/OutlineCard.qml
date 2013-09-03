import QtQuick 2.0
import Ubuntu.Components 0.1

UbuntuShape {
    color: Theme.palette.normal.base
    Suit {
        anchors.centerIn: parent
        suit: cardObj.suit
        width: parent.width/3
        height: width
    }
}
