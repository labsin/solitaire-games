import QtQuick 2.0

Item {
    property bool singleLabel: width<4*lu.width

    CardColumn {
        id: lu
        card: cardObj.card
        suit: cardObj.suit
        showAce: cardObj.showAce

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        width: cardMarginX
    }

    Item {
        id: m
        anchors.left: lu.right
        anchors.right: run.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        Face {
            anchors.centerIn: parent
            width: m.width
            height: m.height - lu.width - run.width
            card: cardObj.card
            suit: cardObj.suit
        }
    }

    CardColumn {
        id: run
        card: cardObj.card
        suit: cardObj.suit
        showAce: cardObj.showAce
        turned: true

        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        visible: !singleLabel
        width: singleLabel?0:lu.width
    }
}
