import QtQuick 2.0
import Ubuntu.Components 0.1
import "../components"

Board {
    id: board
    anchors.fill: parent
    columns: 10
    columnSpaces: 11
    rows: 2
    rowSpaces: 3
    cardYStacks: 12

    decks: 2

    fillDuration: 20

    onSingelPress: {
        if (!card || !stack)
            return
        startMove()
        if (stack === deckStack) {
            if(deckReadyForNew()) {
                var count = deckStack.count
                for (var iii = 1; iii <= 10; iii++) {
                    moveCard(count-iii, deckStack, moveStackList[iii-1], true)
                }
            }
        }
        endMove()
    }

    function deckReadyForNew() {
        for(var iii=0; iii<10; iii++) {
            if(moveStackList[iii].count===0) {
                return false
            }
        }
        return true
    }

    onSelectedStackChanged: {
        if (previousSelectedStack) {
            if (!selectedStack) {
                if (hoverStack) {
                    if (previousSelectedStack.highlightFrom !== -1) {
                        startMove()
                        var countMoving = previousSelectedStack.count
                                - previousSelectedStack.highlightFrom
                        for (var iii = 0; iii < countMoving; iii++) {
                            moveCardAndFlip(
                                        previousSelectedStack.highlightFrom+iii,
                                        previousSelectedStack, hoverStack)
                        }
                        checkStack(hoverStack)
                        endMove()
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
            var checkSpider = function (index, card) {
                if (!card.up)
                    return
                var topHoverCard = hoverStack.lastCard
                if (!topHoverCard)
                    return
                if(card === selectedStack.lastCard && (topHoverCard.card === card.card + 1 || topHoverCard.card == 0)) {
                    highlightFrom(index)
                    return true
                }
                if(topHoverCard.card === card.card + 1 || topHoverCard.card == 0) {
                    var found = false
                    var cardNr = card.card
                    var cardIndex = selectedStack.indexOf(card)
                    for(var iii=cardIndex;iii<selectedStack.count;iii++) {
                        if(card.suit!==selectedStack.repeater.itemAt(iii).suit || cardNr - (iii-cardIndex) !==  selectedStack.repeater.itemAt(iii).card ) {
                            found = true
                            break
                        }
                    }
                    if(!found) {
                        highlightFrom(index)
                        return true
                    }

                    return false
                }
            }

            if (selectedStack === hoverStack)
                return
            forEachFromSelected(checkSpider)
        }
    }

    function checkGame() {
        if (moveStack1.count === 0 && moveStack2.count === 0
                && moveStack3.count === 0 && moveStack4.count === 0
                && moveStack5.count === 0 && moveStack6.count === 0
                && moveStack7.count === 0 && moveStack8.count === 0
                && moveStack9.count === 0 && moveStack10.count === 0) {
            end(true)
        }
    }

    function checkStack(stack) {
        if(stack.count<13)
            return
        var suit = stack.lastCard.suit
        var success = true
        for(var index=stack.count-1;index>=stack.count-13;index--) {
            if(stack.repeater.itemAt(index).card !== stack.count-index || stack.repeater.itemAt(index).suit !==suit) {
                success = false
                break
            }
        }
        if(success) {
            storeStack(stack)
        }
    }
    function storeStack(stack) {
        var toStack
        var suit = stack.lastCard.suit
        if(putStack1.count===0)
            toStack = putStack1
        else if(putStack2.count===0)
            toStack = putStack2
        else if(putStack3.count===0)
            toStack = putStack3
        else if(putStack4.count===0)
            toStack = putStack4
        else if(putStack5.count===0)
            toStack = putStack5
        else if(putStack6.count===0)
            toStack = putStack6
        else if(putStack7.count===0)
            toStack = putStack7
        else if(putStack8.count===0)
            toStack = putStack8

        var firstMove = stack.count - 13
        for (var iii = 0; iii < 13; iii++) {
            moveCardAndFlip(
                        firstMove+iii,
                        stack, toStack)
        }
        checkGame()
    }

    property int yCardSpace: (height - 1.5*columnHeight - 3*columnMargin)/cardMarginY

    Stack {
        id: moveStack10
        x: moveStack9.x + board.columnWidth + board.columnMargin
        y: board.columnHeight + board.columnMargin * 2
        cardWidth: board.columnWidth
        cardHeight: board.columnHeight
        height: board.height - y
        goDown: true

        cardsVisible: yCardSpace

        cardsMoveable: true
        cardsDropable: true
    }

    Stack {
        id: moveStack9
        x: moveStack8.x + board.columnWidth + board.columnMargin
        y: board.columnHeight + board.columnMargin * 2
        cardWidth: board.columnWidth
        cardHeight: board.columnHeight
        height: board.height - y
        goDown: true

        cardsVisible: yCardSpace

        cardsMoveable: true
        cardsDropable: true
    }

    Stack {
        id: moveStack8
        x: moveStack7.x + board.columnWidth + board.columnMargin
        y: board.columnHeight + board.columnMargin * 2
        cardWidth: board.columnWidth
        cardHeight: board.columnHeight
        height: board.height - y
        goDown: true

        cardsVisible: yCardSpace

        cardsMoveable: true
        cardsDropable: true
    }

    Stack {
        id: moveStack7
        x: moveStack6.x + board.columnWidth + board.columnMargin
        y: board.columnHeight + board.columnMargin * 2
        cardWidth: board.columnWidth
        cardHeight: board.columnHeight
        height: board.height - y
        goDown: true

        cardsVisible: yCardSpace

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

        cardsVisible: yCardSpace

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

        cardsVisible: yCardSpace

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

        cardsVisible: yCardSpace

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

        cardsVisible: yCardSpace

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

        cardsVisible: yCardSpace

        cardsMoveable: true
        cardsDropable: true
    }

    Stack {
        id: moveStack1
        x: board.columnMargin
        y: board.columnHeight + board.columnMargin * 2
        cardWidth: board.columnWidth
        cardHeight: board.columnHeight
        height: board.height - y
        goDown: true

        cardsVisible: yCardSpace

        cardsMoveable: true
        cardsDropable: true
    }

    property list<Stack> moveStackList

    Stack {
        id: putStack8
        x: board.width - board.columnWidth - board.columnMargin
        y: board.columnMargin
        width: board.columnWidth
        cardHeight: board.columnHeight
        showHidden: false

        placeholderSuit: 4

        cardsDropable: true
    }

    Stack {
        id: putStack7
        x: putStack8.x - board.columnWidth - board.columnMargin
        y: board.columnMargin
        width: board.columnWidth
        cardHeight: board.columnHeight
        showHidden: false

        placeholderSuit: 3

        cardsDropable: true
    }

    Stack {
        id: putStack6
        x: putStack7.x - board.columnWidth - board.columnMargin
        y: board.columnMargin
        width: board.columnWidth
        cardHeight: board.columnHeight
        showHidden: false

        placeholderSuit: 2

        cardsDropable: true
    }

    Stack {
        id: putStack5
        x: putStack6.x - board.columnWidth - board.columnMargin
        y: board.columnMargin
        width: board.columnWidth
        cardHeight: board.columnHeight
        showHidden: false

        placeholderSuit: 1

        cardsDropable: true
    }

    Stack {
        id: putStack4
        x: putStack5.x - board.columnWidth - board.columnMargin
        y: board.columnMargin
        width: board.columnWidth
        cardHeight: board.columnHeight
        showHidden: false

        placeholderSuit: 4

        cardsDropable: true
    }

    Stack {
        id: putStack3
        x: putStack4.x - board.columnWidth - board.columnMargin
        y: board.columnMargin
        width: board.columnWidth
        cardHeight: board.columnHeight
        showHidden: false

        placeholderSuit: 3

        cardsDropable: true
    }

    Stack {
        id: putStack2
        x: putStack3.x - board.columnWidth - board.columnMargin
        y: board.columnMargin
        width: board.columnWidth
        cardHeight: board.columnHeight
        showHidden: false

        placeholderSuit: 2

        cardsDropable: true
    }

    Stack {
        id: putStack1
        x: putStack2.x - board.columnWidth - board.columnMargin
        y: board.columnMargin
        width: board.columnWidth
        cardHeight: board.columnHeight
        showHidden: false

        placeholderSuit: 1

        cardsDropable: true
    }

    Stack {
        id: deckStack
        x: board.columnMargin
        y: board.columnMargin
        cardWidth: board.columnWidth
        cardHeight: board.columnHeight
        goUpZ: true
    }

    onInit: {
        // Setting up the moveStackList
        var tmpMSL = [moveStack1,moveStack2,moveStack3,
                moveStack4,moveStack5,moveStack6,
                moveStack7,moveStack8,moveStack9,
                moveStack10]
        moveStackList = tmpMSL
        var tmpDM = []
        for(var iii=0;iii<44;iii++) {
            tmpDM[iii] = createDMObjectForIndex(iii)
            tmpDM[iii].isUp = false
        }
        for(;iii<54;iii++) {
            tmpDM[iii] = createDMObjectForIndex(iii)
            tmpDM[iii].isUp = true
        }
        dealingModel = tmpDM;

        // Starting the timer that does the animation
        dealingTimder.start()
    }
    function createDMObjectForIndex(index) {
        switch(index%10) {
        case 0:
            return createDMObject(moveStack1)
        case 1:
            return createDMObject(moveStack2)
        case 2:
            return createDMObject(moveStack3)
        case 3:
            return createDMObject(moveStack4)
        case 4:
            return createDMObject(moveStack5)
        case 5:
            return createDMObject(moveStack6)
        case 6:
            return createDMObject(moveStack7)
        case 7:
            return createDMObject(moveStack8)
        case 8:
            return createDMObject(moveStack9)
        case 9:
            return createDMObject(moveStack10)
        }
    }

    function createDMObject(stack) {
        var tmp = Qt.createQmlObject("import QtQuick 2.0; import \"../components\"; QtObject { property Stack stackId; property bool isUp;}",stack)
        tmp.stackId = stack
        return tmp
    }
}
