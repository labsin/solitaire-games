import QtQuick 2.0
import Ubuntu.Components 0.1

Flipable {
    property int card:0
    property int suit:0
    property bool showAce: true
    property bool up: outline||shadow?false:true
    property bool outline: false
    property bool shadow: false
    property bool animated: true
    property bool animating: xAnimation.running || yAnimation.running
    property bool moveable: false
    property bool highlighted: false

    property int _duration: 300

    property alias front: frontLoader.item

    id: cardObj

    objectName: "card"

    z: animating?1:0

    transform: Rotation {
        id: rot
        origin.x: width/2
        origin.y: height/2
        axis.x: 0; axis.y: 1; axis.z: 0

        angle: up||outline||shadow?0:180

        Behavior on angle {
            animation: ParallelAnimation {
                SequentialAnimation {
                    PropertyAnimation {
                        target: cardObj
                        property: "y"
                        to: cardObj.y - 20
                        duration: _duration
                    }
                    PropertyAnimation {
                        target: cardObj
                        property: "y"
                        to: cardObj.y
                        duration: _duration
                    }
                }
                NumberAnimation { duration: 2*_duration }
            }
        }
    }

    front: Item {
            UbuntuShape {
                id: highlight
                property int _border: 3
                x: - _border
                y: - _border
                width: cardObj.width + 2*_border
                height: cardObj.height + 2*_border
                visible: highlighted

                color: "#daB5F6F7"
            }
            UbuntuShape {
                width: cardObj.width
                height: cardObj.height
                color: "white"
                    Loader {
                        id: frontLoader
                        anchors.fill: parent
                        source: getSource()
                    }
            }
        }

    back: UbuntuShape {
            width: cardObj.width
            height: cardObj.height
            color: "white"
            DownCard {
                width: cardObj.width
                height: cardObj.height
            }
        }

    onUpChanged: {
        if(up) {
            outline = false
            shadow = false
        }
    }

    onOutlineChanged: {
        if(outline) {
            up = false
            shadow = false
        }
    }

    onShadowChanged: {
        if(shadow) {
            up = false
            outline = false
        }
    }

    Behavior on x {
        id: xBehavior
        enabled: animated
        animation: SequentialAnimation {
            id: xAnimation
            PropertyAction {
                target: cardObj
                property: "z"
                value: 1
            }
            NumberAnimation {
                duration: _duration
            }
            PropertyAction {
                target: cardObj
                property: "z"
                value: 0
            }
        }
    }

    Behavior on y {
        id: yBehavior
        enabled: animated
        animation: SequentialAnimation {
            id: yAnimation
            PropertyAction {
                target: cardObj
                property: "z"
                value: 1
            }
            NumberAnimation {
                duration: _duration
            }
            PropertyAction {
                target: cardObj
                property: "z"
                value: 0
            }
        }
    }

    onZChanged: setParentZ()

    function setParentZ() {
        var tmpParent = parent
        if(tmpParent && tmpParent.objectName === "stack") {
            tmpParent.z = z
        }
    }

    function getSource() {
        if(outline)
            return "OutlineCard.qml"
        else if(shadow)
            return "ShadowCard.qml"
        return "UpCard.qml"
    }

    function sameColor(card) {
        if(card.suit == suit || card.suit+suit ==5)
            return true
        return false
    }

    Component.onDestruction: {
        z = 0
    }
}
