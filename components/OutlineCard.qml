import QtQuick 2.0
import Ubuntu.Components 0.1

Item {
    UbuntuShape {
        anchors.fill: parent
        Suit {
            anchors.centerIn: parent
            suit: cardObj.suit
            width: parent.width/3
            height: width
        }
    }
}
