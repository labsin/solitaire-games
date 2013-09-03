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
    property string selectedGameTitle: selectedGameIndex<0?"":gamesRepeater.itemAt(selectedGameIndex).title
    property string selectedGameDbName: selectedGameIndex<0?"":gamesModel.get(selectedGameIndex).dbName

    XmlListModel {
        id: gamesModel
        source: "games/list/games.xml"
        query: "/games/game"
        XmlRole { name: "title";   query: "title/string()"}
        XmlRole { name: "path";    query: "path/string()"}
        XmlRole { name: "dbName";    query: "db-name/string()"}
        XmlRole { name: "rules";    query: "rules/string()"}
        XmlRole { name: "info";    query: "info/string()"}
    }

    Component.onCompleted: {
        print("Select language: "+Qt.locale().name.substring(0,2))
        gamesModelTranslation.source = "games/list/games_"+Qt.locale().name.substring(0,2)+".xml"

        print("Set colors")
        Theme.palette.normal.foreground = headerColor
        Theme.palette.normal.background = backgroundColor
    }

    XmlListModel {
        id: gamesModelTranslation
        query: "/games/game"
        XmlRole { name: "title";   query: "title/string()"}
        XmlRole { name: "path";    query: "path/string()"}
        XmlRole { name: "dbName";    query: "db-name/string()"}
        XmlRole { name: "rules";    query: "rules/string()"}
        XmlRole { name: "info";    query: "info/string()"}
        function getIdByDbName(dbName) {
            for(var index=0; index<gamesModelTranslation.count; index++) {
                if(gamesModelTranslation.get(index)["dbName"]===dbName)
                    return index
            }
            return -1
        }
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
            title: selectedGameIndex===-1?i18n.tr("Game"):selectedGameTitle
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
        id: gamesRepeater
        model: gamesModel
        delegate: Item {
            property int languageId: gamesModelTranslation.getIdByDbName(dbName)
            property string title: languageId!=-1 && gamesModelTranslation.get(languageId)["title"]?gamesModelTranslation.get(languageId)["title"]:title
            property string rules: languageId!=-1 && gamesModelTranslation.get(languageId)["rules"]?gamesModelTranslation.get(languageId)["rules"]:rules
            property string info: languageId!=-1 && gamesModelTranslation.get(languageId)["info"]?gamesModelTranslation.get(languageId)["info"]:info
            Component.onCompleted: {
                print("Try "+dbName)
                initDbForGame(dbName)
            }
        }
    }

    function newGame() {
        tabs.selectedTabIndex=0
        if(gamePage.loader.item)
            gamePage.loader.item.preEnd(false)
        gamePage.setSource("")
        selectedGameIndex = -1
    }

    function startGame(index) {
        if(gamePage.loader.item) {
            if(index===selectedGameIndex) {
                tabs.selectedTabIndex = 1
                return
            }
            else
                gamePage.loader.item.preEnd(true)
        }
        selectedGameIndex = index
        gamePage.setSource(Qt.resolvedUrl("games/"+gamesModel.get(selectedGameIndex)["path"]))
        tabs.selectedTabIndex = 1
    }

    function restartGame() {
        gamePage.loader.item.init([], 0, gamePage.loader.item.gameSeed)
        tabs.selectedTabIndex = 1
    }

    function redealGame() {
        gamePage.loader.item.init([], 0, -1)
        tabs.selectedTabIndex = 1
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
            folderModel.mkdir(folderModel.homePath()+"/.local/share/com.ubuntu.developer.labsin.solitaire-games")
            return folderModel.homePath()+"/.local/share/com.ubuntu.developer.labsin.solitaire-games"
        }
    }
}
