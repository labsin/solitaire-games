import QtQuick 2.0
import Ubuntu.Components 0.1
import "history.js" as History

Item {
    property bool _dealt: false
    property real dealingPositionX: width
    property real dealingPositionY: height
    property real columnWidth
    property real columnHeight
    property real cardMarginX: Math.min(columnWidth*2/9,units.gu(2))
    property real cardMarginY: units.gu(3)
    property real columnMargin: cardMarginY
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
        for (var iii=argsList.length-1; iii>=0; iii--) {
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
                floating = true
                return
            }
        }
        floating = false
    }

    onInit: {
        _dealt = false
        History.init()

        var iii = 0;
        while(main.children[iii]) {
            if(main.children[iii].objectName === "stack") {
                main.children[iii].model.clear()
                main.children[iii].dealingPositionX = board.dealingPositionX
                main.children[iii].dealingPositionY = board.dealingPositionY
            }
            iii++
        }

        dealingStack.deck.fillRandom(false, gameSeed)
    }

    Component.onCompleted: {
        init()
    }

    id: main
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        enabled: _dealt
        hoverEnabled: true
        property double latestTime: 0
        onReleased: {
            if((Date.now()-latestTime)<200) {
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
        visible: false
    }

    property int fillDuration: 50
    property list<QtObject> dealingModel

    Timer {
        id: dealingTimder
        property int index: 0
        interval: fillDuration
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            var tmp
            if(dealingModel[index]) {
                moveCard(dealingStack.count-1, dealingStack, dealingModel[index].stackId, dealingModel[index].isUp)
                index++
            }
            else {
                if(dealingStack.count==0) {
                    stop()
                    _dealt = true
                    return
                }
                moveCard(dealingStack.count-1, dealingStack, deckStack, false)
            }
        }
        onRunningChanged: {
            if(!running)
                index = 0
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
        if(typeof up === 'undefined')
            up = true
        print("moveCard: "+index+" "+fromStack+" "+toStack+" "+up)
        var cardVar = fromStack.model.get(index)
        if(!cardVar)
            return false
        var card = fromStack.repeater.itemAt(index)
        var dealingpoint
        var fromUp = false
        if(card) {
            print("card: "+card)
            dealingpoint = toStack.mapFromItem(fromStack,card.x,card.y)
            fromUp = card.up
            print("fromUp: "+fromUp)
        }
        else
            dealingpoint = toStack.mapFromItem(fromStack,0,0)
        if(fromStack===toStack) {
            if(card) {
                card.up = up
            }
        }
        else {
            toStack.dealingPositionX = dealingpoint.x
            toStack.dealingPositionY = dealingpoint.y
            cardVar["thisUp"] = up
            toStack.model.append(cardVar)
            fromStack.model.remove(index)
        }
        if(_dealt)
            History.history.addToHistory(index,fromStack,fromUp,toStack.count-1,toStack,up)
        return true
    }

    function flipCard(index, stack, up) {
        var card = stack.repeater.itemAt(index);
        if(typeof up === 'undefined')
            up = !card.up
        if(card.up === up )
            return
        card.up = up
        if(_dealt)
            History.history.addToHistory(index,stack,!up,index,stack,up)
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
