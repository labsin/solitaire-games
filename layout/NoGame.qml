import QtQuick 2.0
import Ubuntu.Components 0.1

Item {
    anchors.fill: parent
    property bool loading: false
    Label {
        anchors.centerIn: parent
        text: loading?"Loading...":"Select a game to begin"
        fontSize: "x-large"
    }
}
