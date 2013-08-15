import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1
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
    //automaticOrientation: true
    
    width: units.gu(100)
    height: units.gu(75)
    
    Tabs {
        anchors.fill: parent

        Tab {
            anchors.fill: parent
            title: i18n.tr("Games")
            page: Page {
                XmlListModel {
                             id: gamesModel
                             source: "games/games.xml"
                             query: "/games/game"
                             XmlRole { name: "title";   query: "title/string()"}
                             XmlRole { name: "path";    query: "path/string()"}
                         }
                Column {
                    width: parent.width

                    Repeater {
                        model: gamesModel
                        delegate: gameDelegate
                    }
                }
                Component {
                    id: gameDelegate
                    Standard {
                        text: title
                        onClicked: fullscreen.source = "games/"+path
                    }
                }
            }
        }
    }
    Page {
        z:100
        visible: fullscreen.status == Loader.Ready
        title: i18n.tr("Game")
        Rectangle {
            anchors.fill: parent
        }

        Loader {
            id: fullscreen
            anchors.fill: parent
        }
    }
}
