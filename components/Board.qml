import QtQuick 2.0
import Ubuntu.Components 0.1
import "history.js" as History

Item {
    property bool _dealt: false
    property real dealingPositionX: width
    property real dealingPositionY: height
    property real columnWidth: calcColumnWidth()
    function calcColumnWidth() {
        var columnWidthWithVarMargin1 = (width-cardXStacks*cardMarginX)/columns/(1+columnSpaces/2.5/columns)
        if(columnWidthWithVarMargin1/2.5<units.gu(2)) {
            columnWidthWithVarMargin1 = (width-columnSpaces*units.gu(2)-cardXStacks*cardMarginX)/columns
        }
        var columnWidthWithVarMargin2 = (height-cardYStacks*cardMarginY)/rows*8/13/(1+rowSpaces*8/2.5/rows/13)
        if(columnWidthWithVarMargin2/2.5 < units.gu(2)) {
            columnWidthWithVarMargin2 = (height-rowSpaces*units.gu(2)-cardYStacks*cardMarginY)/rows*8/13
        }
        return Math.max(Math.min(columnWidthWithVarMargin1, columnWidthWithVarMargin2, units.gu(14)), minimumColumnWidth)
    }
    property real minimumColumnWidth: cardMarginX*2
    property bool toSmallWidth: width<minimumWidth
    property bool toSmallY: height<minimumHeight
    property real minimumWidth: columnSpaces*units.gu(2)+cardXStacks*cardMarginX + columns * minimumColumnWidth
    property real minimumHeight: rowSpaces*units.gu(2)+cardYStacks*cardMarginY+rows*13/8*minimumColumnWidth

    property real columnHeight: columnWidth*13/8
    property int columns: 0
    property int columnSpaces: 0
    property int rows: 0
    property int rowSpaces: 0
    property int cardYStacks: 0
    property int cardXStacks: 0
    property real cardMarginX: units.gu(2)
    property real cardMarginY: units.gu(3)
    property real columnMargin: columnWidth/2.5<units.gu(2)?units.gu(2):columnWidth/2.5
    property real parentWidth
    property real parentHeight

    property Stack selectedStack
    property Card selectedCard
    property Stack previousSelectedStack
    property Card previousSelectedCard
    property int selectedCardX
    property int selectedCardY
    property Stack hoverStack
    property Card hoverCard
    property bool floating: false

    property int gameSeed

    property int _amoutMoving: 0
    property int _mouseSingleClickDelay: 150

    property alias decks: dealingStack.decks
    property alias suits: dealingStack.suits
    property alias dealingTimder: dealingTimder

    signal singelPress(Card card, Stack stack)
    signal startMove
    signal endMove

    signal undo
    signal redo
    property bool hasPreviousMove: false
    property bool hasNextMove: false

    signal end(bool won)
    signal init()

    id: main

    width: parentWidth>minimumWidth?parentWidth:minimumWidth
    height: parentHeight>minimumHeight?parentHeight:minimumHeight

    onParentWidthChanged: print("ParentWidth:" + parentWidth)
    onMinimumWidthChanged: print("MinimumWidth:" + minimumWidth)
    onColumnWidthChanged: print("columnWidth:"+columnWidth)
    onWidthChanged: print("width"+width)

    onStartMove: {
        History.history.startMove()
    }

    onEndMove: {
        History.history.endMove()
    }

    onUndo: {
        var argsList = History.history.goBackAndReturn();
        if(!argsList)
            return
        for(var iii=argsList.length-1; iii>=0; iii--) {
            var args = argsList[iii]
            print("undo: "+args.toIndex+" "+args.toStack+" "+args.fromStack+" "+args.fromUp)
            moveCard(args.toIndex, args.toStack, args.fromStack,args.fromUp)
        }
    }

    onRedo: {
        var argsList = History.history.returnAndGoForward();
        if(!argsList)
            return
        for (var iii=argsList.length-1; iii>=0; iii--) {
            var args = argsList[iii]
            print("redo: "+args.fromIndex+" "+args.fromStack+" "+args.toStack+" "+args.toUp)
            moveCard(args.fromIndex, args.fromStack, args.toStack,args.toUp)
        }
    }

    onSelectedStackChanged: {
        if(selectedStack) {
            var selectedCardPoint
            if(selectedCard && selectedCard.moveable) {
                selectedCardPoint = main.mapFromItem(selectedStack,selectedCard.x,selectedCard.y)
            }
            else {
                selectedCardPoint = main.mapFromItem(selectedStack,selectedStack.lastCard.x,selectedStack.lastCard.y)
            }
            selectedCardX = selectedCardPoint.x
            selectedCardY = selectedCardPoint.y

            if(selectedStack.cardsMoveable && selectedStack.count !=0) {
                floatingTimer.start()
                return
            }
        }
        floatingTimer.stop()
        floating = false
    }

    onInit: {
        _dealt = false
        History.init()
        dealingTimder.stop()

        var iii = 0;
        while(main.children[iii]) {
            if(main.children[iii].objectName === "stack") {
                main.children[iii].model.clear()
            }
            iii++
        }

        dealingStack.deck.fillRandom(false, gameSeed)
    }

    Component.onCompleted: {
        init()
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        enabled: _dealt && _amoutMoving==0
        hoverEnabled: true
        property double latestTime: 0
        onReleased: {
            if((Date.now()-latestTime)<_mouseSingleClickDelay) {
                singelPress(selectedCard, selectedStack)
                selectedCard = null
                selectedStack = null

                previousSelectedCard = null
                previousSelectedStack = null
                return
            }

            previousSelectedCard = selectedCard
            previousSelectedStack = selectedStack
            selectedCard = null
            selectedStack = null
        }
        onPressed: {
            print("onPressed:"+mouse.x+", "+mouse.y)
            latestTime = Date.now()
            previousSelectedCard = selectedCard
            previousSelectedStack = selectedStack
            selectedCard = locateObject(main, mouse.x, mouse.y, "card")
            selectedStack = locateObject(main, mouse.x, mouse.y, "stack")
            print(selectedStack)
            print(selectedCard)
        }
        onMouseXChanged: mousePositionChanged(mouse)
        onMouseYChanged: mousePositionChanged(mouse)
        function mousePositionChanged(mouse) {
            hoverCard = locateObject(main, mouse.x, mouse.y, "card")
            hoverStack = locateObject(main, mouse.x, mouse.y, "stack")
        }
        function locateObject(object, x, y, name) {
            var nxtObj = object.childAt(x,y)
            if(!nxtObj)
                return nxtObj
            if(nxtObj.objectName === name ) {
                return nxtObj
            }
            var newPoint = nxtObj.mapFromItem(object, x, y )
            var newX = newPoint.x
            var newY = newPoint.y
            return nxtObj = locateObject(nxtObj, newX, newY, name )
        }
    }

    Stack {
        id: dealingStack
        width: columnWidth
        height: columnHeight
        x: dealingPositionX
        y: dealingPositionY
        visible: true
    }

    property int fillDuration: 50
    property list<QtObject> dealingModel

    Timer {
        id: dealingTimder
        property int index: 0
        interval: fillDuration
        repeat: true
        triggeredOnStart: false
        onTriggered: {
            if(dealingModel[index]) {
                var iii = dealingStack.count
                do {
                    iii--
                    var card = dealingStack.repeater.itemAt(iii)
                } while(card && card.animating)


                moveCard(iii, dealingStack, dealingModel[index].stackId, dealingModel[index].isUp)
                index++
            }
            else {
                if(!deckStack) {
                    stop()
                    _dealt = true
                    return
                }
                if(dealingStack.count==0) {
                    stop()
                    _dealt = true
                    return
                }

                var jjj = dealingStack.count
                do {
                    jjj--
                    var card2 = dealingStack.repeater.itemAt(jjj)
                } while(card2 && card2.animating)

                if(!card2) {
                    stop()
                    _dealt = true
                    return
                }

                moveCard(jjj, dealingStack, deckStack, false)
            }
        }

        onRunningChanged: {
            if(!running)
                index = 0
        }
    }

    Timer {
        id: floatingTimer
        interval: _mouseSingleClickDelay
        repeat: false
        onTriggered: {
            floating = true
        }
    }


    Card {
        id: floatingCard
        visible: floating
        shadow: true
        width: columnWidth
        height: columnHeight
        animated: false
        opacity: 0.9

        property int _floatingChangeDuration: 75

        z:2

        states: [
            State {
                id: hiddenState
                name: "hidden"
                when: !floating
                PropertyChanges { target: floatingCard; x: selectedCardX}
                PropertyChanges { target: floatingCard; y: selectedCardY}
            },
            State {
                id: floatingState
                name: "floating"
                when: floating
                PropertyChanges { target: floatingCard; x: mouseArea.mouseX - width/2}
                PropertyChanges { target: floatingCard; y: mouseArea.mouseY - height}
            }
        ]

        transitions: [
            Transition {
                id: stateTransition
                from: "hidden"; to: "floating"
                ParallelAnimation {
                    NumberAnimation {
                        id: numberAnimationX
                        properties: "x"; duration: floatingCard._floatingChangeDuration;
                    }
                    NumberAnimation {
                        id: numberAnimationY
                        properties: "y"; duration: floatingCard._floatingChangeDuration;
                    }
                }
            }
        ]
    }

    function forEachFromSelected(fnct) {
        if(selectedStack) {
            var startIndex
            if(selectedCard) {
                startIndex = selectedStack.indexOf(selectedCard)
            }
            if(!startIndex)
                startIndex = selectedStack.count-1

            var iii = 0
            var index
            var alternate = true
            var up
            while(1) {
                if(alternate) {
                    index = startIndex + Math.floor((iii+1)/2)*Math.pow(-1,iii)
                    if(index>selectedStack.count-1) {
                        up = false
                        alternate = false
                        index = startIndex + Math.floor((iii+2)/2)*Math.pow(-1,iii+1)
                        if(index<0)
                            break
                    }
                    else if(index<0) {
                        up = true
                        alternate = false
                        index = startIndex + Math.floor((iii+2)/2)*Math.pow(-1,iii+1)
                        if(index>selectedStack.count-1)
                            break
                    }
                }
                else {
                    if(up)
                        index++
                    else
                        index--
                    if(index<0 || index>selectedStack.count-1)
                        break
                }
                if(fnct(index,selectedStack.repeater.itemAt(index)))
                    break
                iii++
            }
        }
    }

    function forEachFromHovered(fnct) {
        if(!hoverStack)
            return
        var count = hoverStack.count-1
        for(var index=count; index>=0; index--) {
            fnct(index,hoverStack.repeater.itemAt(index))
        }
    }

    function moveCard(index, fromStack, toStack, up) {
        print("moveCard: "+index+" "+fromStack+" "+toStack+" "+up)
        var cardVar = fromStack.model.get(index)
        if(!cardVar)
            return false
        var fromCard = fromStack.repeater.itemAt(index)
        if(!fromCard) {
            print("No card at index in stack")
            return
        }
        var fromUp = fromCard.up
        if(typeof up === 'undefined')
            up = fromUp
        if(fromStack===toStack) {
            if(!fromCard) {
                print("Moving to the same stack")
            }
            if(fromCard) {
                flipCard(index, fromStack, up)
            }
        }
        else {
            _amoutMoving++
            fromStack.amountGoing++
            toStack.amountComming++
            fromCard.afterAnimation.connect(function() {
                toStack.model.addFromCard(fromCard)
                fromStack.model.remove(fromCard.stackIndex)
                _amoutMoving--
            })
            var mapPoint = toStack.mapToItemFromIndex(fromStack,toStack.count-1+toStack.amountComming)
            fromCard.x = mapPoint.x
            fromCard.y = mapPoint.y
            if(fromCard.up !== up)
                flipCard(index, fromStack, up)
        }
        if(_dealt)
            History.history.addToHistory(index,fromStack,fromUp,toStack.count-1+toStack.amountComming,toStack,up)
        return true
    }

    function flipCard(index, stack, up) {
        print("flipCard: "+index+" "+stack+" "+up)
        var card = stack.repeater.itemAt(index);
        if(typeof up === 'undefined')
            up = !card.up
        if(card.up === up )
            return
        card.up = up
        if(_dealt)
            History.history.addToHistory(index,stack,!up,index,stack,up)
    }

    function moveCardAndFlip(index, fromStack, toStack, up) {
        print("moveCardAndFlip: "+index+" "+fromStack+" "+toStack+" "+up)
        var count = fromStack.count
        print(count)
        if (count >= 2) {
            if (!fromStack.repeater.itemAt(index-1).up)
                flipCard(index-1,fromStack, true)
        }
        moveCard(index, fromStack, toStack, up)
    }

    function highlightFrom(index) {
        if(!selectedStack)
            return
        selectedStack.highlightFrom = index
        if(floatingCard.front)
            floatingCard.front.shadowed = false
    }

    function stopHighlight() {
        if(selectedStack)
            selectedStack.highlightFrom = -1
        if(previousSelectedStack)
            previousSelectedStack.highlightFrom = -1
        if(floatingCard.front)
            floatingCard.front.shadowed = true
    }
}
