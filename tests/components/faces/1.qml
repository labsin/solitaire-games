import QtQuick 2.0
import ".."

Rectangle {
    property int suit
    property real suitSize

    anchors.fill: parent
    id: face

    Suit {
        anchors.centerIn: parent
        width: suitSize
        height: suitSize
        suit: face.suit
    }
}
