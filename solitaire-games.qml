import QtQuick 2.0
import Ubuntu.Components 0.1
import U1db 1.0 as U1db
import QtQuick.XmlListModel 2.0
import org.nemomobile.folderlistmodel 1.0
import "layout"

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

    headerColor: "#092200"
    backgroundColor: "#144E00"
    footerColor: "#1D7300"
    
    width: units.gu(100)
    height: units.gu(80)

    id: mainView

    property int selectedGameIndex:-1
    property string selectedGameTitle: selectedGameIndex<0?"":gamesModel.get(selectedGameIndex).title
    property string selectedGameDbName: selectedGameIndex<0?"":gamesModel.get(selectedGameIndex).dbName

    XmlListModel {
        id: gamesModel
        source: "games/games.xml"
        query: "/games/game"
        XmlRole { name: "title";   query: "title/string()"}
        XmlRole { name: "path";    query: "path/string()"}
        XmlRole { name: "dbName";    query: "db-name/string()"}
        XmlRole { name: "rules";    query: "rules/string()"}
        XmlRole { name: "info";    query: "info/string()"}
    }
    
    Tabs {
        id: tabs
        anchors.fill: parent

        Tab {
            anchors.fill: parent
            title: i18n.tr("Games")
            page: GamesPage {
                id: gamesPage

            }
        }

        Tab {
            anchors.fill: parent
            title: i18n.tr("Game")
            page: GamePage {
                id: gamePage

            }
        }

        Tab {
            anchors.fill: parent
            title: i18n.tr("Stats")
            page: StatsPage {
                id: statsPage

            }
        }
    }

    Repeater {
        model: gamesModel
        delegate: Item {
            Component.onCompleted: {
                initDbForGame(dbName)
            }
        }
    }

    function newGame() {
        tabs.selectedTabIndex=0
        if(gamePage.loader.item)
            gamePage.loader.item.preEnd(false)
        gamePage.loader.source = ""
        setStats(selectedGameDbName, false)
    }

    function restartGame() {
        gamePage.loader.item.init([], 0, gamePage.loader.item.gameSeed)
        setStats(selectedGameDbName, false)
    }

    function setStats(dbName, won) {
        initDbForGame(dbName)
        var tempContents = {};
        tempContents = statsDoc.contents
        if(won) {
            tempContents[dbName]["won"]++
        }
        else {
            tempContents[dbName]["lost"]++
        }
        statsDoc.contents = tempContents
    }

    function getStats(dbName) {
        return statsDoc.contents[dbName]
    }

    function removeSaveState(dbName) {
        print("removeSaveState")
        setSaveState(dbName, [], 0, -1)
    }

    function setSaveState(dbName, json, index, savedSeed) {
        print("setSaveState:"+dbName+" "+index+" "+savedSeed)
        var tmpContents = {};
        tmpContents = savesDoc.contents
        tmpContents[dbName]["saveState"] = json
        tmpContents[dbName]["savedHistoryIndex"] = index
        tmpContents[dbName]["savedSeed"] = savedSeed
        savesDoc.contents = tmpContents
    }

    function getSaveState(dbName) {
        return savesDoc.contents[dbName]["saveState"]
    }

    function getSaveStateIndex(dbName) {
        print("getSaveStateIndex::"+savesDoc.contents[dbName]["savedHistoryIndex"])
        return savesDoc.contents[dbName]["savedHistoryIndex"]
    }

    function getSaveStateSeed(dbName) {
        print("getSaveStateSeed::"+savesDoc.contents[dbName]["savedSeed"])
        return savesDoc.contents[dbName]["savedSeed"]
    }


    function initDbForGame(dbName) {
        print("initDbForGame: "+dbName)
        var tempStats = {};
        if(statsDoc.contents) {
            tempStats = statsDoc.contents
        }

        if(!tempStats[dbName]) {
            tempStats[dbName] = {}
            tempStats[dbName]["won"] = 0
            tempStats[dbName]["lost"] = 0
        }

        statsDoc.contents = tempStats

        var tempSaves = {}
        if(savesDoc.contents) {
            tempSaves = savesDoc.contents
        }

        if(!tempSaves[dbName]) {
            tempSaves[dbName] = {}
            tempSaves[dbName]["saveState"] = []
            tempSaves[dbName]["savedHistoryIndex"] = 0
            tempSaves[dbName]["savedSeed"] = -1
        }

        savesDoc.contents = tempSaves
    }

    U1db.Database {
        id: mainDb
        path: folderModel.getLocalFolder()+"/solitaireDb"
    }

    U1db.Document {
        id: statsDoc
        database: mainDb
        docId: 'stats'
        create: true
        defaults: {}
    }

    U1db.Document {
        id: savesDoc
        database: mainDb
        docId: 'saveStates'
        create: true
        defaults: {}
    }

    FolderListModel {
        id: folderModel
        function getLocalFolder() {
            // TODO: first check before making
            folderModel.mkdir(folderModel.homePath()+"/.local/share/be.samsegers.solitaire-games")
            return folderModel.homePath()+"/.local/share/be.samsegers.solitaire-games"
        }
    }
}
