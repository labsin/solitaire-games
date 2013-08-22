import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1

Page {
    id: gamePage
    property alias loader: gameLoader

    NoGame {
        anchors.fill: parent
        visible: gameLoader.status !== Loader.Ready
        loading: gameLoader.status === Loader.Loading
    }

    Loader {
        x: 0
        y: 0
        id: gameLoader
        source: ""
        asynchronous: true
        visible: status == Loader.Ready
        onStatusChanged: {
            if(status === Loader.Ready) {
                initGame()
            }
        }
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
            PopupUtils.open("EndDialog.qml", gamePage, {"won":won})
        }
    }

    function initGame() {
        print("initGame")
        var savedGame = getSaveState(gamesModel.get(selectedGameIndex).dbName)
        var savedGameIndex = getSaveStateIndex(gamesModel.get(selectedGameIndex).dbName)
        var savedSeed = getSaveStateSeed(gamesModel.get(selectedGameIndex).dbName)
        gameLoader.item.init(savedGame, savedGameIndex, savedSeed)
    }

    function saveState(saveState, savedIndex, savedSeed) {
        setSaveState(gamesModel.get(selectedGameIndex).dbName, saveState, savedIndex, savedSeed)
    }

    function removeState() {
        removeSaveState(gamesModel.get(selectedGameIndex).dbName)
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
