import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem

Page {
    id: page

    ListView {
        id: listView
        anchors.fill: parent
        model: gamesModel
        delegate: statsDelegate
    }

    Component {
        id: statsDelegate

        Column {
            property int nrWins: getStats(dbName)["won"]
            property int nrLost: getStats(dbName)["lost"]
            visible: true || nrWins>0 || nrLost>0
            width: parent.width

            ListItem.Header {
                text: title
                width: parent.width
            }

            ListItem.Standard {
                text: "won: "+nrWins
            }

            ListItem.Standard {
                text: "lost: "+nrLost
            }
        }
    }
}
