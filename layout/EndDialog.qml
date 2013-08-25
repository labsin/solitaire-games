import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1

Dialog {
    property bool won: false
    id: endDialog
    title: won?"Won!":"Lost..."
    text: won?"What's next?":"... What's next?"
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
        visible: !won
        onClicked: {
            PopupUtils.close(endDialog)
            restartGame()
        }
    }
    Button {
        text: "redeal"
        visible: won
        onClicked: {
            PopupUtils.close(endDialog)
            redealGame()
        }
    }
    Button {
        text: "new game"
        onClicked: {
            PopupUtils.close(endDialog)
            newGame()
        }
    }
}
