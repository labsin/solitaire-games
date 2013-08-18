import QtQuick 2.0
import Ubuntu.Components 0.1
import "../components"

Board {
    id: board
    columns: 7
    columnSpaces: 8
    rows: 4
    rowSpaces: 2

    decks: 1

    fillDuration: 50

    onSingelPress: {
        if (!stack)
            return
        if(!checkIfFree(stack))
            return
        startMove()
        if (stack === deckStack) {
            if(deckStack.count!==0) {
                if(deckStack.lastCard.up) {
                    if(deckStack.lastCard.card===13)
                        moveCardAndFlip(
                                    deckStack.count-1,
                                    deckStack, putStack)
                    else {
                        moveCardAndFlip(
                                    deckStack.count-1,
                                    deckStack, takeStack)
                    }
                }
                else {
                    flipCard(deckStack.count-1, deckStack)
                }
            }
        } else {
            if(stack.lastCard.card === 13 )
                moveCard(
                            stack.count-1,
                            stack, putStack)
        }
        endMove()
    }

    onSelectedStackChanged: {
        if (previousSelectedStack) {
            if (!selectedStack) {
                if (hoverStack) {
                    if (previousSelectedStack.highlightFrom !== -1) {
                        startMove()
                        if(previousSelectedStack === deckStack) {
                            moveCardAndFlip(
                                        deckStack.count-1,
                                        deckStack, putStack)
                            moveCard(
                                        hoverStack.count-1,
                                        hoverStack, putStack)
                        }
                        else if(hoverStack === deckStack) {
                            moveCardAndFlip(
                                        deckStack.count-1,
                                        deckStack, putStack)
                            moveCard(
                                        previousSelectedStack.count-1,
                                        previousSelectedStack, putStack)
                        }
                        else {
                            moveCard(
                                        previousSelectedStack.count-1,
                                        previousSelectedStack, putStack)
                            moveCard(
                                        hoverStack.count-1,
                                        hoverStack, putStack)
                        }
                        endMove()
                        checkGame()
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
            else if (!checkIfFree(hoverStack)) {
                stopHighlight()
                return
            }

            var hoverCard = hoverStack.lastCard
            if(!hoverCard) {
                stopHighlight()
                return
            }

            var selectedCard = selectedStack.lastCard
            if(!selectedCard) {
                stopHighlight()
                return
            }

            if(hoverCard.card + selectedCard.card === 13) {
                highlightFrom(selectedStack.count-1)
            }
            else {
                stopHighlight()
                return
            }
        }
    }

    function checkIfFree(stack) {
        if(stack === deckStack || stack === takeStack)
            return true
        var index = getStacksRep.indexOf(stack)
        if(index) {
            if(stack.count===0)
                return true
            if(index===0) {
                return getStacksRep.itemAt(1).count===0 && getStacksRep.itemAt(2).count===0
            }
            else if(index<3) {
                return getStacksRep.itemAt(index+2).count===0 && getStacksRep.itemAt(index+3).count===0
            }
            else if(index<6) {
                return getStacksRep.itemAt(index+3).count===0 && getStacksRep.itemAt(index+4).count===0
            }
            else if(index<10) {
                return getStacksRep.itemAt(index+4).count===0 && getStacksRep.itemAt(index+5).count===0
            }
            else if(index<15) {
                return getStacksRep.itemAt(index+5).count===0 && getStacksRep.itemAt(index+6).count===0
            }
            else if(index<21) {
                return getStacksRep.itemAt(index+6).count===0 && getStacksRep.itemAt(index+7).count===0
            }
            else {
                return true
            }
        }
        return false
    }

    function checkGame() {
        for(var iii = 0; iii<getStacksRep.count; iii++) {
            if(getStacksRep.itemAt(iii).count>0)
                return false
        }
        end(true)
    }

    Stack {
        id: putStack
        x: board.width - board.columnWidth - board.columnMargin
        y: board.columnMargin
        width: board.columnWidth
        cardHeight: board.columnHeight
        showHidden: false

        placeholderSuit: 4

        cardsMoveable: false
        cardsDropable: false
    }

    Stack {
        id: deckStack
        x: board.columnMargin
        y: board.columnMargin
        cardWidth: board.columnWidth
        cardHeight: board.columnHeight
        goUpZ: true

        cardsMoveable: lastCard.up
        cardsDropable: true
    }

    Stack {
        id: takeStack
        x: board.columnMargin*2 + board.columnWidth
        y: board.columnMargin
        cardWidth: board.columnWidth
        cardHeight: board.columnHeight
        goUpZ: true

        cardsMoveable: true
        cardsDropable: true
    }

    Component {
        id: geStacks
        Stack {
            id: thisStack
            width: board.columnWidth
            height: board.columnHeight
            cardWidth: board.columnWidth
            cardHeight: board.columnHeight
            x: getPyramidX(index)
            y: getPyramidY(index)

            transparant: true

            cardsMoveable: false
            cardsDropable: count>0?true:false
            Component.onCompleted: {
                repeater.onItemAdded.connect(getStacksRep.checkAllIfFree)
            }
        }
    }

    Repeater {
        id: getStacksRep
        model: 28
        delegate: geStacks

        function checkAllIfFree() {
            for(var iii=0; iii<count; iii++) {
                if(itemAt(iii).lastCard.card === 13) {
                    itemAt(iii).cardsMoveable = false
                }
                else {
                    itemAt(iii).cardsMoveable = checkIfFree(itemAt(iii))
                }
            }
        }

        function indexOf(item) {
            for (var iii = 0; iii < count; iii++) {
                if (getStacksRep.itemAt(iii) === item)
                    return iii
            }
            return
        }
    }

    function getPyramidX(index) {
        var boardMid = board.width/2
        if(index===0) {
            return boardMid - columnWidth/2
        }
        else if(index<3) {
            return boardMid - columnMargin/2 - columnWidth + (columnWidth + columnMargin)*(index-1)
        }
        else if(index<6) {
            return boardMid - columnWidth/2 - columnWidth - columnMargin + (columnWidth + columnMargin)*(index-3)
        }
        else if(index<10) {
            return boardMid - columnMargin/2 - columnWidth*2 - columnMargin + (columnWidth + columnMargin)*(index-6)
        }
        else if(index<15) {
            return boardMid - columnWidth/2 - (columnWidth + columnMargin)*2 + (columnWidth + columnMargin)*(index-10)
        }
        else if(index<21) {
            return boardMid - columnMargin/2 - columnWidth - (columnWidth + columnMargin)*2 + (columnWidth + columnMargin)*(index-15)
        }
        else {
            return boardMid - columnWidth/2 - (columnWidth + columnMargin)*3 + (columnWidth + columnMargin)*(index-21)
        }
    }

    function getPyramidY(index) {
        if(index===0) {
            return columnMargin
        }
        else if(index<3) {
            return columnMargin + columnHeight*0.5
        }
        else if(index<6) {
            return columnMargin + columnHeight*1
        }
        else if(index<10) {
            return columnMargin + columnHeight*1.5
        }
        else if(index<15) {
            return columnMargin + columnHeight*2
        }
        else if(index<21) {
            return columnMargin + columnHeight*2.5
        }
        else {
            return columnMargin + columnHeight*3
        }
    }

    onInit: {
        var tmpDM = []
        var iii
        for(iii=0;iii<28;iii++) {
            tmpDM[iii] = createDMObjectForIndex(iii)
            tmpDM[iii].isUp = true
        }
        dealingModel = tmpDM;

        // Starting the timer that does the animation
        dealingTimder.start()
    }

    function createDMObjectForIndex(index) {
        return createDMObject(getStacksRep.itemAt(index))
    }

    function createDMObject(stack) {
        var tmp = Qt.createQmlObject("import QtQuick 2.0; import \"../components\"; QtObject { property Stack stackId; property bool isUp;}",stack)
        tmp.stackId = stack
        return tmp
    }
}
