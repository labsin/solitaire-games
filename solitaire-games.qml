import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import Ubuntu.Components.Popups 0.1
import U1db 1.0 as U1db
import QtQuick.XmlListModel 2.0
import "components"
import "games"

/*!
    \brief MainView with a Label and Button elements.
*/
MainView {
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"
    
    // Note! applicationName needs to match the .desktop filename
    applicationName: "solitaire-games"
    
    /* 
     This property enables the application to change orientation 
     when the device is rotated. The default is false.
    */
    automaticOrientation: true

    headerColor: "DarkGreen"
    backgroundColor: "Green"
    footerColor: "Green"
    
    width: units.gu(100)
    height: units.gu(75)

    property int selectedGameIndex:-1
    property string selectedGameTitle: selectedGameIndex<0?"":gamesModel.get(selectedGameIndex).title

    XmlListModel {
        id: gamesModel
        source: "games/games.xml"
        query: "/games/game"
        XmlRole { name: "title";   query: "title/string()"}
        XmlRole { name: "path";    query: "path/string()"}
        XmlRole { name: "dbName";    query: "db-name/string()"}
    }
    
    Tabs {
        id: tabs
        anchors.fill: parent

        Tab {
            anchors.fill: parent
            title: i18n.tr("Games")
            page: Page {
                Column {
                    width: parent.width

                    Repeater {
                        model: gamesModel
                        delegate: gameDelegate
                    }
                }
                Component {
                    id: gameDelegate
                    ListItem.Standard {
                        text: title
                        onClicked: {
                            selectedGameIndex = index
                            gameLoader.source = "games/"+path
                            tabs.selectedTabIndex = 1
                        }
                    }
                }
            }
        }

        Tab {
            anchors.fill: parent
            title: i18n.tr("Game")
            page: Page {
                id: gamePage
                NoGame {
                    anchors.fill: parent
                    visible: gameLoader.status !== Loader.Ready
                }

                Loader {
                    x: 0
                    y: 0
                    id: gameLoader
                    source: ""
                }
                Binding {
                    target: gameLoader.item
                    property: "parentWidth"
                    value: width
                }
                Binding {
                    target: gameLoader.item
                    property: "parentHeight"
                    value: height
                }

                Connections {
                    target: gameLoader.item
                    onEnd: {
                        setStats(gamesModel.get(selectedGameIndex).dbName, won)
                        PopupUtils.open(endDialComp, gamePage, {"won":won})
                    }
                }
                tools: ToolbarItems {
                    ToolbarButton {
                        text: "undo"
                        enabled: gameLoader.item?gameLoader.item.hasPreviousMove:false
                        onTriggered: {
                            gameLoader.item.undo()
                        }
                    }
                    ToolbarButton {
                        text: "redo"
                        enabled: gameLoader.item?gameLoader.item.hasNextMove:false
                        onTriggered: {
                            gameLoader.item.redo()
                        }
                    }
                    ToolbarButton {
                        text: "new game"
                        onTriggered: {
                            newGame()
                        }
                    }
                    ToolbarButton {
                        text: "restart"
                        onTriggered: {
                            restartGame()
                        }
                    }
                }
            }
        }

        Tab {
            anchors.fill: parent
            title: i18n.tr("Stats")
            page: Page {
                id: statsPage
                Column {
                    width: parent.width

                    Repeater {
                        model: gamesModel
                        delegate: statsDelegate
                    }
                }
                Component {
                    id: statsDelegate
                    Column {
                        property int nrWins: statsDoc.contents[title]["won"]
                        property int nrLost: statsDoc.contents[title]["lost"]
                        visible: nrWins>0||nrLost>0
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
        }
    }

    Component {
        id: endDialComp
        Dialog {
            property bool won: false
            id: endDialog
            title: won?"Won!":"Lost..."
            text: won?"What's next?":"You lost... What's next?"
            Button {
                text: "nothing"
                gradient: UbuntuColors.greyGradient
                onClicked: {
                    PopupUtils.close(endDialog)
                }
            }
            Button {
                text: "stats"
                onClicked: {
                    tabs.selectedTabIndex=2
                    PopupUtils.close(endDialog)
                }
            }
            Button {
                text: "try again"
                onClicked: {
                    PopupUtils.close(endDialog)
                    restartGame()
                }
            }
            Button {
                text: "new game"
                onClicked: {
                    newGame()
                    PopupUtils.close(endDialog)
                }
            }
        }
    }

    Repeater {
        model: gamesModel
        delegate: Item {
            Component.onCompleted: {
                initForTitle(title)
            }
        }
    }

    function newGame() {
        tabs.selectedTabIndex=0
        gameLoader.source = ""
        setStats(gamesModel.get(selectedGameIndex).dbName, false)
    }

    function restartGame() {
        gameLoader.item.init()
        setStats(gamesModel.get(selectedGameIndex).dbName, false)
    }

    function setStats(title, won) {
        initForTitle(title)
        var tempContents = {};
        tempContents = statsDoc.contents
        if(won) {
            tempContents[title]["won"]++
        }
        else {
            tempContents[title]["lost"]++
        }
        statsDoc.contents = tempContents
    }

    function initForTitle(title) {
        if(!statsDoc.contents) {
            var tempContents = {};
        }
        else {
            tempContents = statsDoc.contents
        }

        if(!tempContents[title]) {
            tempContents[title] = {"won":0,"lost":0}
        }
        statsDoc.contents = tempContents
    }


    U1db.Database {
        id: mainDb
        path: "solitaireDb"
    }

    U1db.Document {
        id: statsDoc
        database: mainDb
        docId: 'stats'
        create: true
        defaults: {}
    }
}
