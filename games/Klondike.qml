import QtQuick 2.0
import Ubuntu.Components 0.1
import "../components"

Board {
    id: board
    anchors.fill: parent
    columnWidth: Math.min((width - 8 * columnMargin) / 7, (height - 3*columnMargin - 12*cardMarginY)/1.5*160/258)
    columnHeight: columnWidth * 258 / 160

    onInit: {
        dealingTimder.initAndStart()
    }

    onSingelPress: {
        if (!card || !stack)
            return
        if (stack === deckStack) {
            var tmp
            deckStack.dealingPositionX = 0
            deckStack.dealingPositionY = 0
            for (var iii = 0; iii < 3; iii++) {
                tmp = deckStack.model.pop()
                if (tmp) {
                    tmp.thisUp = true
                    takeStack.model.append(tmp)
                }
            }
            if (!tmp) {
                var count = takeStack.model.count
                for (var jjj = 0; jjj < count; jjj++) {
                    var tmpVal = takeStack.model.pop()
                    if (tmpVal) {
                        tmpVal.thisUp = false
                        deckStack.model.append(tmpVal)
                    }
                }
            }
        }
        if (stack.indexOf(card) === stack.count - 1) {
            var suit = card.suit
            var cardNr = card.card
            switch (suit) {
            case 1:
                if (putStack1.lastCard.card + 1 === cardNr) {
                    moveCardAndFlip(stack.count - 1, stack, putStack1)
                }
                break
            case 2:
                if (putStack2.lastCard.card + 1 === cardNr) {
                    moveCardAndFlip(stack.count - 1, stack, putStack2)
                }
                break
            case 3:
                if (putStack3.lastCard.card + 1 === cardNr) {
                    moveCardAndFlip(stack.count - 1, stack, putStack3)
                }
                break
            case 4:
                if (putStack4.lastCard.card + 1 === cardNr) {
                    moveCardAndFlip(stack.count - 1, stack, putStack4)
                }
                break
            }
        }
    }

    onSelectedStackChanged: {
        if (previousSelectedStack) {
            if (!selectedStack) {
                if (hoverStack) {
                    if (previousSelectedStack.highlightFrom !== -1) {
                        var countMoving = previousSelectedStack.count
                                - previousSelectedStack.highlightFrom
                        for (var iii = 0; iii < countMoving; iii++) {
                            moveCardAndFlip(
                                        previousSelectedStack.highlightFrom,
                                        previousSelectedStack, hoverStack)
                        }
                    }
                }
                stopHighlight()
            }
        }
    }

    onHoverStackChanged: {
        if (!hoverStack) {
            if (selectedStack) {
                stopHighlight()
            }
        } else if (!hoverStack.cardsDropable) {
            if (selectedStack) {
                stopHighlight()
            }
        } else if (selectedStack) {
            var checkNextNumberSameSuit = function (card) {
                if (!card.up)
                    return
                var topCard = hoverStack.lastCard
                if (topCard && topCard.card + 1 === card.card
                        && topCard.suit === card.suit) {
                    highlightFrom(selectedStack.count - 1)
                }
            }

            var checkDiffColor = function (index, card) {
                if (!card.up)
                    return
                var topCard = hoverStack.lastCard
                if (topCard && (!topCard.sameColor(card) || topCard.suit === 0)
                        && topCard.card === card.card + 1) {
                    highlightFrom(index)
                    return true
                }
                return false
            }

            if (hoverStack === putStack1 || hoverStack === putStack2
                    || hoverStack === putStack3 || hoverStack === putStack4) {
                checkNextNumberSameSuit(selectedCard)
            } else if (selectedStack === takeStack) {
                checkDiffColor(takeStack.count - 1,
                               takeStack.repeater.itemAt(takeStack.count - 1))
            } else {
                if (selectedStack === hoverStack)
                    return
                forEachFromSelected(checkDiffColor)
            }
        }
    }

    function moveCardAndFlip(index, fromStack, toStack) {
        moveCard(index, fromStack, toStack)
        if (fromStack.cardsShown === 0) {
            if (fromStack.count !== 0)
                fromStack.lastCard.up = true
        }
        checkGame()
    }

    function checkGame() {
        if (moveStack1.count === 0 && moveStack2.count === 0
                && moveStack3.count === 0 && moveStack4.count === 0
                && moveStack5.count === 0 && moveStack6.count === 0
                && moveStack7.count === 0) {
            end(true)
        }
    }

    property int yCardSpace: (height - 1.5*columnHeight - 3*columnMargin)/cardMarginY
    onYCardSpaceChanged: {
        print("Room for "+yCardSpace+" cards")
    }

    Stack {
        id: moveStack7
        x: moveStack6.x + board.columnWidth + board.columnMargin
        y: board.columnHeight + board.columnMargin * 2
        cardWidth: board.columnWidth
        cardHeight: board.columnHeight
        height: board.height - y
        goDown: true

        dealingPositionX: board.dealingPositionX
        dealingPositionY: board.dealingPositionY

        cardsVisible: yCardSpace
        placeholderCard: 14

        cardsMoveable: true
        cardsDropable: true
    }

    Stack {
        id: moveStack6
        x: moveStack5.x + board.columnWidth + board.columnMargin
        y: board.columnHeight + board.columnMargin * 2
        cardWidth: board.columnWidth
        cardHeight: board.columnHeight
        height: board.height - y
        goDown: true

        dealingPositionX: board.dealingPositionX
        dealingPositionY: board.dealingPositionY

        cardsVisible: yCardSpace
        placeholderCard: 14

        cardsMoveable: true
        cardsDropable: true
    }

    Stack {
        id: moveStack5
        x: moveStack4.x + board.columnWidth + board.columnMargin
        y: board.columnHeight + board.columnMargin * 2
        cardWidth: board.columnWidth
        cardHeight: board.columnHeight
        height: board.height - y
        goDown: true

        dealingPositionX: board.dealingPositionX
        dealingPositionY: board.dealingPositionY

        cardsVisible: yCardSpace
        placeholderCard: 14

        cardsMoveable: true
        cardsDropable: true
    }

    Stack {
        id: moveStack4
        x: moveStack3.x + board.columnWidth + board.columnMargin
        y: board.columnHeight + board.columnMargin * 2
        cardWidth: board.columnWidth
        cardHeight: board.columnHeight
        height: board.height - y
        goDown: true

        dealingPositionX: board.dealingPositionX
        dealingPositionY: board.dealingPositionY

        cardsVisible: yCardSpace
        placeholderCard: 14

        cardsMoveable: true
        cardsDropable: true
    }

    Stack {
        id: moveStack3
        x: moveStack2.x + board.columnWidth + board.columnMargin
        y: board.columnHeight + board.columnMargin * 2
        cardWidth: board.columnWidth
        cardHeight: board.columnHeight
        height: board.height - y
        goDown: true

        dealingPositionX: board.dealingPositionX
        dealingPositionY: board.dealingPositionY

        cardsVisible: yCardSpace
        placeholderCard: 14

        cardsMoveable: true
        cardsDropable: true
    }

    Stack {
        id: moveStack2
        x: moveStack1.x + board.columnWidth + board.columnMargin
        y: board.columnHeight + board.columnMargin * 2
        cardWidth: board.columnWidth
        cardHeight: board.columnHeight
        height: board.height - y
        goDown: true

        dealingPositionX: board.dealingPositionX
        dealingPositionY: board.dealingPositionY

        cardsVisible: yCardSpace
        placeholderCard: 14

        cardsMoveable: true
        cardsDropable: true
    }

    Stack {
        id: moveStack1
        x: board.columnMargin
        y: board.columnHeight + board.columnMargin * 2
        width: board.columnWidth
        cardHeight: board.columnHeight
        height: board.height - y
        goDown: true

        dealingPositionX: board.dealingPositionX
        dealingPositionY: board.dealingPositionY

        cardsVisible: yCardSpace
        placeholderCard: 14

        cardsMoveable: true
        cardsDropable: true
    }

    Stack {
        id: putStack4
        x: putStack3.x + board.columnWidth + board.columnMargin
        y: board.columnMargin
        width: board.columnWidth
        cardHeight: board.columnHeight
        showHidden: false

        placeholderSuit: 4

        cardsDropable: true
    }

    Stack {
        id: putStack3
        x: putStack2.x + board.columnWidth + board.columnMargin
        y: board.columnMargin
        width: board.columnWidth
        cardHeight: board.columnHeight
        showHidden: false

        placeholderSuit: 3

        cardsDropable: true
    }

    Stack {
        id: putStack2
        x: putStack1.x + board.columnWidth + board.columnMargin
        y: board.columnMargin
        width: board.columnWidth
        cardHeight: board.columnHeight
        showHidden: false

        placeholderSuit: 2

        cardsDropable: true
    }

    Stack {
        id: putStack1
        x: takeStack.x + board.columnWidth * 2 + board.columnMargin * 2
        y: board.columnMargin
        width: board.columnWidth
        cardHeight: board.columnHeight
        showHidden: false

        placeholderSuit: 1

        cardsDropable: true
    }

    Stack {
        id: takeStack
        x: deckStack.x + board.columnWidth + board.columnMargin
        y: board.columnMargin
        cardWidth: board.columnWidth
        cardHeight: board.columnHeight
        goRight: true
        showHidden: false

        cardsMoveable: true
        cardsVisible: 3
    }

    Stack {
        id: deckStack
        x: board.columnMargin
        y: board.columnMargin
        cardWidth: board.columnWidth
        cardHeight: board.columnHeight
        goUpZ: true

        dealingPositionX: board.dealingPositionX
        dealingPositionY: board.dealingPositionY
    }

    dealingModel: [
        QtObject {
            property Stack stackId: moveStack1
            property bool isUp: true
        },
        QtObject {
            property Stack stackId: moveStack2
            property bool isUp: false
        },
        QtObject {
            property Stack stackId: moveStack3
            property bool isUp: false
        },
        QtObject {
            property Stack stackId: moveStack4
            property bool isUp: false
        },
        QtObject {
            property Stack stackId: moveStack5
            property bool isUp: false
        },
        QtObject {
            property Stack stackId: moveStack6
            property bool isUp: false
        },
        QtObject {
            property Stack stackId: moveStack7
            property bool isUp: false
        },
        QtObject {
            property Stack stackId: moveStack2
            property bool isUp: true
        },
        QtObject {
            property Stack stackId: moveStack3
            property bool isUp: false
        },
        QtObject {
            property Stack stackId: moveStack4
            property bool isUp: false
        },
        QtObject {
            property Stack stackId: moveStack5
            property bool isUp: false
        },
        QtObject {
            property Stack stackId: moveStack6
            property bool isUp: false
        },
        QtObject {
            property Stack stackId: moveStack7
            property bool isUp: false
        },
        QtObject {
            property Stack stackId: moveStack3
            property bool isUp: true
        },
        QtObject {
            property Stack stackId: moveStack4
            property bool isUp: false
        },
        QtObject {
            property Stack stackId: moveStack5
            property bool isUp: false
        },
        QtObject {
            property Stack stackId: moveStack6
            property bool isUp: false
        },
        QtObject {
            property Stack stackId: moveStack7
            property bool isUp: false
        },
        QtObject {
            property Stack stackId: moveStack4
            property bool isUp: true
        },
        QtObject {
            property Stack stackId: moveStack5
            property bool isUp: false
        },
        QtObject {
            property Stack stackId: moveStack6
            property bool isUp: false
        },
        QtObject {
            property Stack stackId: moveStack7
            property bool isUp: false
        },
        QtObject {
            property Stack stackId: moveStack5
            property bool isUp: true
        },
        QtObject {
            property Stack stackId: moveStack6
            property bool isUp: false
        },
        QtObject {
            property Stack stackId: moveStack7
            property bool isUp: false
        },
        QtObject {
            property Stack stackId: moveStack6
            property bool isUp: true
        },
        QtObject {
            property Stack stackId: moveStack7
            property bool isUp: false
        },
        QtObject {
            property Stack stackId: moveStack7
            property bool isUp: true
        }
    ]
}
