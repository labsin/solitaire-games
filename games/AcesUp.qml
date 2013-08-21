import QtQuick 2.0
import Ubuntu.Components 0.1
import "../components"

Board {
    id: board
    columns: 6
    columnSpaces: 8
    rows: 1
    rowSpaces: 2
    cardYStacks: 13

    decks: 1

    fillDuration: 50

    onSingelPress: {
        if (!stack)
            return
        startMove()
        print(getStackList[0])
        if (stack === deckStack) {
            if(deckStack.count>0) {
                var count = deckStack.count
                for(var iii=1; iii<=4; iii++) {
                    moveCard(
                                deckStack.count-iii,
                                deckStack, getStackList[iii-1],
                                true)
                }
            }
        } else if(stack !== putStack ){
            var lastCard = stack.lastCard
            if(lastCard && lastCard.card!==1) {
                var success = true
                var foundSuit = false
                for(var key in getStackList ) {
                    var tmpStack = getStackList[key]
                    if(stack === tmpStack)
                        continue
                    if(tmpStack.lastCard) {
                        if(tmpStack.lastCard.suit === lastCard.suit) {
                            foundSuit = true
                            if(tmpStack.lastCard.card!==1 && tmpStack.lastCard.card < lastCard.card) {
                                success = false
                            }
                        }
                    }
                }
                if(success && foundSuit) {
                    moveCard(
                                stack.count-1,
                                stack, putStack)
                }
            }
        }
        endMove()
    }

    onSelectedStackChanged: {
        if (previousSelectedStack) {
            if (!selectedStack) {
                if (hoverStack) {
                    if (previousSelectedStack.highlightFrom !== -1) {
                        startMove()
                        moveCard(
                                    previousSelectedStack.count-1,
                                    previousSelectedStack, hoverStack)
                        endMove()
                    }
                }
                stopHighlight()
            }
        }
    }

    onHoverStackChanged: {
        if (selectedStack) {
            if (!hoverStack) {
                stopHighlight()
                return
            } else if (!hoverStack.cardsDropable) {
                stopHighlight()
                return
            }
            else if (selectedStack === hoverStack) {
                stopHighlight()
                return
            }
            highlightFrom(selectedStack.count-1)
        }
    }

    function checkGame() {
        for(var iii = 0; iii<getStackList.length; iii++) {
            if(getStackList[iii].count>0)
                return false
        }
        end(true)
    }

    Stack {
        id: putStack
        x: board.width - board.columnWidth - board.columnMargin
        y: board.columnMargin
        cardWidth: board.columnWidth
        cardHeight: board.columnHeight
        showHidden: false

        cardsMoveable: false
        nrCardsMoveable: 1

        cardsDropable: false
    }

    Stack {
        id: deckStack
        x: board.columnMargin
        y: board.columnMargin
        cardWidth: board.columnWidth
        cardHeight: board.columnHeight
        goUpZ: true

        cardsMoveable: true
        nrCardsMoveable: 1

        goDown: true

        cardsDropable: false
    }

    Stack {
        id: getStack1
        cardWidth: board.columnWidth
        cardHeight: board.columnHeight
        x: deckStack.x+columnMargin+columnWidth
        y: columnMargin

        cardsMoveable: true
        nrCardsMoveable: 1

        goDown: true

        cardsDropable: count===0
    }

    Stack {
        id: getStack2
        cardWidth: board.columnWidth
        cardHeight: board.columnHeight
        x: getStack1.x+columnMargin+columnWidth
        y: columnMargin

        cardsMoveable: true
        nrCardsMoveable: 1

        goDown: true

        cardsDropable: count===0
    }

    Stack {
        id: getStack3
        cardWidth: board.columnWidth
        cardHeight: board.columnHeight
        x: getStack2.x+columnMargin+columnWidth
        y: columnMargin

        cardsMoveable: true
        nrCardsMoveable: 1

        goDown: true

        cardsDropable: count===0
    }

    Stack {
        id: getStack4
        cardWidth: board.columnWidth
        cardHeight: board.columnHeight
        x: getStack3.x+columnMargin+columnWidth
        y: columnMargin

        cardsMoveable: true
        nrCardsMoveable: 1

        goDown: true

        cardsDropable: count===0
    }

    dealingModel: [
        QtObject { property Stack stackId: getStack1; property bool isUp:true;},
        QtObject { property Stack stackId: getStack2; property bool isUp:true;},
        QtObject { property Stack stackId: getStack3; property bool isUp:true;},
        QtObject { property Stack stackId: getStack4; property bool isUp:true;}
    ]

    property list<Stack> getStackList

    onInit: {
        var tmpGSL = [getStack1, getStack2, getStack3, getStack4]
        getStackList = tmpGSL;
    }
}
