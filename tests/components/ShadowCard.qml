import QtQuick 2.0
import Ubuntu.Components 0.1

Item {
    property real ocap: 0.5
    property bool shadowed: true
    UbuntuShape {
        anchors.fill: parent
        Suit {
            anchors.centerIn: parent
            suit: cardObj.suit
            width: parent.width/3
            height: width
            opacity: ocap
        }
    }
    UbuntuShape {
        anchors.fill: parent
        color: "black"
        opacity: 0.5
        visible: shadowed
    }
}
