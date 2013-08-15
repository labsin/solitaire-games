import QtQuick 2.0

Item {
    id: stack
    property bool goDown: false
    property bool goRight: false
    property bool goUpZ: false
    property bool showHidden: true
    property real cardWidth: width
    property real cardHeight: height
    property real dealingPositionX: 0
    property real dealingPositionY: 0
    property Card lastCard: count > 0 ? repeater.itemAt(count - 1) : back
    property bool cardsMoveable: false
    property bool cardsDropable: false

    property int count: repeater.count
    property int cardsVisible: goUpZ ? 3 : count
    property int cardsShown: 0

    property int placeholderSuit: 0
    property int placeholderCard: 0

    property int highlightFrom: -1

    property alias model: deck.model
    property alias repeater: repeater

    objectName: "stack"

    width: childrenRect.width
    height: childrenRect.height

    Deck {
        id: deck
    }

    Card {
        id: back
        outline: true
        width: cardWidth
        height: cardHeight
        z: 0

        moveable: false
        card: placeholderCard
        suit: placeholderSuit
    }

    Repeater {
        id: repeater
        model: deck.model
        delegate: Card {
            id: cardObj
            width: cardWidth
            height: cardHeight
            x: dealingPositionX
            y: dealingPositionY
            card: thisCard
            suit: thisSuit
            up: thisUp
            highlighted: highlightFrom > -1
                         && index >= highlightFrom ? true : false
            visible: animating ? true : getVisible(index)

            moveable: cardsMoveable

            Component.onCompleted: {
                cardObj.x = Qt.binding(function () {
                    return getX(index)
                })
                cardObj.y = Qt.binding(function () {
                    return getY(index)
                })
            }

            onUpChanged: repeater.checkUpCards()

            function getVisible(index) {
                var offset = index - count + cardsVisible + 1
                if (offset > 0)
                    return true
                else
                    return false
            }

            function getX(index) {
                var offset
                if (goUpZ) {
                    offset = index - count + cardsVisible
                    if (offset > 0)
                        return offset * cardMarginX / 2
                    else
                        return 0
                }
                if (goRight) {
                    offset = index - count + cardsVisible
                    if (offset > 0)
                        return offset * cardMarginX * 3
                    else
                        return 0
                }
                return 0.0
            }

            function getY(index) {
                if (goUpZ) {
                    var offset = index - count + cardsVisible
                    if (offset > 0)
                        return offset * cardMarginY / 4
                    else
                        return 0
                }
                if (goDown) {
                    return index * cardMarginY
                }
                return 0.0
            }
        }
        onItemRemoved: checkUpCards()

        function checkUpCards() {
            var tmpCardsShown = 0
            for (var iii = 0; iii < count; iii++) {
                if (itemAt(iii) && itemAt(iii).up)
                    tmpCardsShown++
            }
            cardsShown = tmpCardsShown
        }
    }

    function indexOf(item) {
        for (var iii = 0; iii < count; iii++) {
            if (repeater.itemAt(iii) === item)
                return iii
        }
        return
    }
}
