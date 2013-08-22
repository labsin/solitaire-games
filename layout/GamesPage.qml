import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem

Page {
    id: page

    property bool _small: page.width<_smallListWidth+_minInfoWidth
    property real _smallListWidth: units.gu(25)
    property real _minInfoWidth: units.gu(60)

    ListView {
        id: gameListView
        model: gamesModel
        delegate: gameDelegate

        anchors.top: page.top
        anchors.bottom: page.bottom
        anchors.left: page.left

    }

    Component {
        id: gameDelegate

        ListItem.Standard {
            text: title
            onClicked: {
                gamePage.setSource(Qt.resolvedUrl("../games/"+path))
                selectedGameIndex = index
                tabs.selectedTabIndex = 1
            }
        }
    }

    Item {
        id: moreInfoItem
        anchors.top: page.top
        anchors.left: gameListView.right
        anchors.bottom: page.bottom
        anchors.right: page.right
    }

    states: [
        State {
            name: "small"
            when: _small

            PropertyChanges {
                target: moreInfoItem
                visible: false
            }
            PropertyChanges {
                target: gameListView
                width: page.width
            }

        }, State {
            name: "wide"
            when: !_small

            PropertyChanges {
                target: moreInfoItem
                visible: true
            }
            PropertyChanges {
                target: gameListView
                width: _smallListWidth
            }
        }
    ]
}
