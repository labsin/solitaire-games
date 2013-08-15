import QtQuick 2.0
import Ubuntu.Components 0.1

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

    property alias decks: dealingDeck.decks
    property alias suits: dealingDeck.suits
    property alias dealingTimder: dealingTimder

    signal singelPress(Card card, Stack stack)

    signal end(bool won)
    signal init()

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
        var iii = 0;
        while(main.children[iii]) {
            if(main.children[iii].objectName === "stack") {
                main.children[iii].model.clear()
            }
            iii++
        }

        dealingDeck.fillRandom(false, gameSeed)
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

    Deck {
        id: dealingDeck
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
                tmp = dealingDeck.model.pop()
                tmp['thisUp'] = dealingModel[index].isUp
                dealingModel[index].stackId.model.append(tmp)
                index++
            }
            else {
                if(dealingDeck.model.count==0) {
                    stop()
                    _dealt = true
                    return
                }
                tmp = dealingDeck.model.pop()
                tmp['thisUp'] = false
                deckStack.model.append(tmp)
            }
        }
        function initAndStart() {
            index = 0
            start()
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

    function moveCard(index, fromStack, toStack) {
        var card = fromStack.repeater.itemAt(index)
        print(card + " at "+index)
        var dealingpoint = toStack.mapFromItem(card,0,0)
        toStack.dealingPositionX = dealingpoint.x
        toStack.dealingPositionY = dealingpoint.y
        toStack.model.addFromCard(card)
        fromStack.model.remove(index)
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
