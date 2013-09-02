import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem

Page {
    id: page

    property bool _small: page.width<_smallListWidth+_minInfoWidth
    property real _smallListWidth: units.gu(25)
    property real _minInfoWidth: units.gu(60)

    flickable: _small ? gameListView : null

    ListView {
        id: gameListView
        model: gamesModel
        delegate: gameDelegate

        anchors.top: page.top
        anchors.bottom: page.bottom
        anchors.left: page.left

        clip: true
    }

    Rectangle {
        anchors.fill: gameListView
        visible: !_small
        color: "#071C00"
        z: -1
    }

    Component {
        id: gameDelegate

        ListItem.Standard {
            id: thisItem
            text: gamesRepeater.itemAt(index).title
            onClicked: {
                if(_small) {
                    startGame(path, index)
                }
                else {
                    moreInfoFlickable.gameTitle = gamesRepeater.itemAt(index).title
                    moreInfoFlickable.gameIndex = index
                    moreInfoFlickable.gamePath = path
                    moreInfoFlickable.gameInfo = gamesRepeater.itemAt(index).info
                    moreInfoFlickable.gameRules = gamesRepeater.itemAt(index).rules
                }
            }
            onPressAndHold: {
                if(_small)
                    PopupUtils.open(infoPopoverComp, thisItem, {"index":index,"gameTitle":gamesRepeater.itemAt(index).title,"gameRules":gamesRepeater.itemAt(index).rules,"gameInfo":gamesRepeater.itemAt(index).info})
            }
        }
    }

    Component {
        id: infoPopoverComp

        ActionSelectionPopover {
            property int index: -1
            property string gameTitle: i18n.tr("Select a game")
            property string gameRules
            property string gameInfo

            id: infoPopover
            actions: ActionList {
              Action {
                  text: "Info"
                  onTriggered: {
                      PopupUtils.open(infoOrRulesSheed, parent, {"index":index,"gameTitle":gameTitle,"mainText":gameInfo})
                  }
              }
              Action {
                  text: "Rules"
                  onTriggered: {
                      PopupUtils.open(infoOrRulesSheed, parent, {"index":index,"gameTitle":gameTitle,"mainText":gameRules})
                  }
              }
            }
        }
    }

    Component {
        id: infoOrRulesSheed

        DefaultSheet {
            property string gameTitle
            property string mainText

            id: sheet
            title: "Info on " + gameTitle
            doneButton: false
            Label {
                anchors.fill: parent
                text: mainText
                wrapMode: Text.WordWrap
            }
            onDoneClicked: PopupUtils.close(sheet)
        }
    }


    Flickable {
        id: moreInfoFlickable
        y: gameListView.y
        x: gameListView.x + gameListView.width
        height: gameListView.height
        width: parent.width - gameListView.width
        visible: width>0
        contentHeight: container.height
        clip: true

        property string gameTitle: i18n.tr("Select a game")
        property string gameRules: ""
        property string gamePath: ""
        property string gameInfo: ""
        property int gameIndex: -1

        Item {
            id: container
            width: parent.width
            property real contentHeight: innerContainer.height + innerContainer.anchors.topMargin + innerContainer.anchors.bottomMargin
                                         + startButton.height + startButton.anchors.topMargin + startButton.anchors.bottomMargin
            height: contentHeight < moreInfoFlickable.height?moreInfoFlickable.height:contentHeight

            Column {
                id: innerContainer
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.left: parent.left
                anchors.topMargin: units.gu(4)
                spacing: units.gu(2)

                Label {
                    id: titleLabel
                    anchors.left: parent.left
                    anchors.leftMargin: units.gu(8)
                    text: moreInfoFlickable.gameTitle
                    fontSize: "x-large"
                }

                Label {
                    id: gameInfoHeader
                    anchors.left: parent.left
                    anchors.leftMargin: units.gu(2)
                    text: i18n.tr("Info:")
                    fontSize: "large"
                    visible: gameInfoLabel.text!=""
                }

                Label {
                    id: gameInfoLabel
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: units.gu(4)
                    anchors.rightMargin: units.gu(2)
                    wrapMode: Text.Wrap
                    textFormat: Text.RichText
                    text: moreInfoFlickable.gameInfo
                    fontSize: "medium"
                }

                ListItem.Divider {
                    id: divider
                    anchors.leftMargin: units.gu(1)
                    anchors.rightMargin: units.gu(1)
                    visible: gameInfoLabel.text!="" && gameRulesLabel.text!=""
                }

                Label {
                    id: gameRulesHeader
                    anchors.left: parent.left
                    anchors.leftMargin: units.gu(2)
                    text: i18n.tr("Rules:")
                    fontSize: "large"
                    visible: gameRulesLabel.text!=""
                }

                Label {
                    id: gameRulesLabel
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: units.gu(4)
                    anchors.rightMargin: units.gu(2)
                    wrapMode: Text.Wrap
                    textFormat: Text.RichText
                    text: moreInfoFlickable.gameRules
                    fontSize: "medium"
                }
            }

            Button {
                property bool redeal: moreInfoFlickable.gameIndex>=0 && moreInfoFlickable.gameIndex === selectedGameIndex

                id: startButton
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.topMargin: units.gu(2)
                anchors.bottomMargin: units.gu(7)
                anchors.rightMargin: units.gu(5)
                text: redeal?i18n.tr("Redeal"):i18n.tr("Start")
                enabled: moreInfoFlickable.gameIndex!==-1
                onClicked: {
                    if(redeal)
                        redealGame()
                    else
                        startGame(moreInfoFlickable.gamePath, moreInfoFlickable.gameIndex)
                }
            }
        }
    }

    states: [
        State {
            name: "small"
            when: _small

            AnchorChanges {
                target: gameListView
                anchors.right: parent.right
            }

        }, State {
            name: "wide"
            when: !_small

            AnchorChanges {
                target: gameListView
                anchors.right: ""
                anchors.top: page.top
            }
            PropertyChanges {
                target: gameListView
                width: _smallListWidth
                topMargin: 0
            }
        }
    ]
}
