import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem

Page {
    id: page

    property real _smallListWidth: units.gu(25)
    property real _minInfoWidth: units.gu(60)

    property alias currentIndex: gameListView.currentIndex

    flickable: mainView.small ? gameListView : null

    ListView {
        id: gameListView
        model: gamesModel
        delegate: gameDelegate

        anchors.top: page.top
        anchors.bottom: page.bottom
        anchors.left: page.left
        currentIndex: -1

        clip: true
    }

    Rectangle {
        anchors.fill: gameListView
        visible: !mainView.small
        color: Theme.palette.normal.foreground
        z: -1
    }

    Component {
        id: gameDelegate

        ListItem.Standard {
            id: thisItem
            text: gamesRepeater.itemAt(index).title
            onClicked: {
                currentIndex = index
                if(mainView.small) {
                    startGame(index)
                }
            }
            onPressAndHold: {
                if(mainView.small)
                    PopupUtils.open(infoPopoverComp, thisItem, {"index":index} )
            }
            selected: gameListView.currentItem === thisItem
        }
    }

    Component {
        id: infoPopoverComp

        ActionSelectionPopover {
            property int index: -1
            property string gameTitle: index==-1?i18n.tr("Select a game"):gamesRepeater.itemAt(index).title
            property string gameRules: index==-1?"":gamesRepeater.itemAt(index).rules
            property string gameInfo: index==-1?"":gamesRepeater.itemAt(index).info


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
            Flickable {
            anchors.fill: parent
            contentHeight: label.height
                Label {
                    color: Theme.palette.normal.overlayText
                    id: label
                    width: parent.width
                    text: mainText
                    wrapMode: Text.WordWrap
                }
                clip: true
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

        Item {
            id: container
            width: parent.width
            property real contentHeight: innerContainer.height + innerContainer.anchors.topMargin + innerContainer.anchors.bottomMargin
                                         + startButton.height + startButton.anchors.topMargin + startButton.anchors.bottomMargin
            height: contentHeight < moreInfoFlickable.height?moreInfoFlickable.height:contentHeight


            property string gameTitle: currentIndex==-1?i18n.tr("Select a game"):gamesRepeater.itemAt(currentIndex).title
            property string gameRules: currentIndex==-1?"":gamesRepeater.itemAt(currentIndex).rules
            property string gameInfo: currentIndex==-1?"":gamesRepeater.itemAt(currentIndex).info

            Column {
                id: innerContainer
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.left: parent.left
                anchors.topMargin: units.gu(4)
                spacing: units.gu(2)

                Label {
                    id: titleLabel
                    color: Theme.palette.normal.baseText
                    anchors.left: parent.left
                    anchors.leftMargin: units.gu(8)
                    text: container.gameTitle
                    fontSize: "x-large"
                }

                Label {
                    id: gameInfoHeader
                    color: Theme.palette.normal.baseText
                    anchors.left: parent.left
                    anchors.leftMargin: units.gu(2)
                    text: i18n.tr("Info:")
                    fontSize: "large"
                    visible: gameInfoLabel.text!=""
                }

                Label {
                    id: gameInfoLabel
                    color: Theme.palette.normal.baseText
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: units.gu(4)
                    anchors.rightMargin: units.gu(2)
                    wrapMode: Text.Wrap
                    textFormat: Text.RichText
                    text: container.gameInfo
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
                    color: Theme.palette.normal.baseText
                    anchors.left: parent.left
                    anchors.leftMargin: units.gu(2)
                    text: i18n.tr("Rules:")
                    fontSize: "large"
                    visible: gameRulesLabel.text!=""
                }

                Label {
                    id: gameRulesLabel
                    color: Theme.palette.normal.baseText
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: units.gu(4)
                    anchors.rightMargin: units.gu(2)
                    wrapMode: Text.Wrap
                    textFormat: Text.RichText
                    text: container.gameRules
                    fontSize: "medium"
                }
            }

            Button {
                property bool redeal: currentIndex>=0 && currentIndex === selectedGameIndex

                id: startButton
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.topMargin: units.gu(2)
                anchors.bottomMargin: units.gu(7)
                anchors.rightMargin: units.gu(5)
                text: redeal?i18n.tr("Redeal"):i18n.tr("Start")
                enabled: currentIndex!==-1
                onClicked: {
                    if(redeal)
                        redealGame()
                    else
                        startGame(currentIndex)
                }
            }
        }
    }

    states: [
        State {
            name: "small"
            when: mainView.small

            AnchorChanges {
                target: gameListView
                anchors.right: parent.right
            }

        }, State {
            name: "wide"
            when: !mainView.small

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
