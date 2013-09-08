import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1

Page {
    id: gamePage
    property alias loader: gameLoader
    property alias item: gameLoader.item
    flickable: null

    NoGame {
        anchors.fill: flickable
        visible: gameLoader.status !== Loader.Ready
        loading: gameLoader.status === Loader.Loading
    }

    Flickable {
        id: flickable
        anchors.fill: parent
        contentWidth: item?item.width:0
        contentHeight: item?item.height:0
        clip: true
        interactive: item?item.shouldFlick:false
        boundsBehavior: Flickable.StopAtBounds

        Loader {
            x: 0
            y: 0
            id: gameLoader
            source: ""
            asynchronous: true
            visible: status == Loader.Ready
//            onStatusChanged: {
//                if(status === Loader.Ready) {
//                    initGame()
//                }
//            }
        }

        Binding {
            target: gameLoader.item
            property: "parentWidth"
            value: flickable.width
        }

        Binding {
            target: gameLoader.item
            property: "parentHeight"
            value: flickable.height
        }

        Binding {
            target: gameLoader.item
            property: "flickable"
            value: flickable
        }

        Connections {
            target: gameLoader.item
            onEnd: {
                setStats(selectedGameDbName, won)
                PopupUtils.open(Qt.resolvedUrl("EndDialog.qml"), gamePage, {"won":won})
            }
        }
    }
    Scrollbar {
        flickableItem: flickable
        align: Qt.AlignTrailing
        anchors.right: flickable.right
    }

    function initGame() {
        print("initGame:"+selectedGameDbName)
        var savedGame = getSaveState(selectedGameDbName)
        var savedGameIndex = getSaveStateIndex(selectedGameDbName)
        var savedSeed = getSaveStateSeed(selectedGameDbName)
        gameLoader.item.init(savedGame, savedGameIndex, savedSeed)
    }

    function saveState(saveState, savedIndex, savedSeed) {
        setSaveState(selectedGameDbName, saveState, savedIndex, savedSeed)
    }

    function removeState() {
        removeSaveState(selectedGameDbName)
    }

    function setSource(path, json) {
        if(gameLoader.source!=="") {
            if(gameLoader.item) {
                gameLoader.item.saveGame()
            }
        }
        if(typeof json !== 'undefined')
            gameLoader.setSource(path, json)
        else
            gameLoader.setSource(path)
    }

    tools: ToolbarItems {
        ToolbarButton {
            text: i18n.tr("undo")
            enabled: gameLoader.item?gameLoader.item.hasPreviousMove:false
            onTriggered: {
                gameLoader.item.undo()
            }
        }
        ToolbarButton {
            text: i18n.tr("redo")
            enabled: gameLoader.item?gameLoader.item.hasNextMove:false
            onTriggered: {
                gameLoader.item.redo()
            }
        }
        ToolbarButton {
            text: i18n.tr("new game")
            onTriggered: {
                newGame()
                setStats(selectedGameDbName, false)
            }
        }
        ToolbarButton {
            text: i18n.tr("redeal")
            onTriggered: {
                redealGame()
                setStats(selectedGameDbName, false)
            }
        }
        ToolbarButton {
            text: i18n.tr("restart")
            onTriggered: {
                restartGame()
                setStats(selectedGameDbName, false)
            }
        }
        opened: mainView.small?false:true
        locked: mainView.small?false:true
        onLockedChanged: {
            if(!mainView.small)
                opened = true
            else
                opened = false
        }
    }
}
