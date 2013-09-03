import QtQuick 2.0
import Ubuntu.Components 0.1

OutlineCard {
    property real ocap: 0.5
    property bool lighter: false
    UbuntuShape {
        anchors.fill: parent
        color: lighter?Theme.palette.normal.overlay:Theme.palette.normal.foreground
        opacity: 0.5
    }
}
