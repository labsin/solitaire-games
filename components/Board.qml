import QtQuick 2.0
import Ubuntu.Components 0.1
import "history.js" as History

Item {
    property bool _dealt: true
    property bool _redoing: false
    property bool _moving: _amoutMoving>0
    property bool _saved: false
    property int _dealIndex: 0
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

    property double gameSeed

    property int _amoutMoving: 0
    property int _mouseSingleClickDelay: 150

    property bool saveGameOnQuit: true

    property alias decks: dealingStack.decks
    property alias suits: dealingStack.suits
    property alias dealingTimder: dealingTimder

    signal singelPress(Card card, Stack stack)
    signal startMove()
    signal endMove()
    signal loaded()

    signal undo()
    signal redo()

    property int historyIndex: 0
    property int historyLength: 0
    property bool hasPreviousMove: historyIndex>1
    property bool hasNextMove: historyIndex<historyLength
    property variant toRemoveAfterRedoing

    signal end(bool won)
    signal init(variant savedGame, int savedGameIndex, double savedSeed)

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
        print("onUndo")
        if(!hasPreviousMove || _amoutMoving!=0)
            return;
        undoOne()
    }

    function undoOne() {
        print("undoOne")
        var argsList = History.history.goBackAndReturn();
        if(!argsList)
            return
        var newArgsList = sortUndoList(argsList)
        var count = newArgsList.length

        for(var iii=0; iii<count; iii++) {
            var args = newArgsList[iii]
            print("undo: "+args.toIndex+" "+args.toStack+" "+args.fromIndex+" "+args.fromStack+" "+args.fromUp + " " + args.flipZ)
            moveCard(args.toIndex, indexToStack(args.toStack), indexToStack(args.fromStack), args.fromUp, args.flipZ)
        }
    }

    function sortUndoList(undoList) {
        var count = undoList.length
        var newList = []

        for(var iii=0; iii<count; iii++) {
            var count2 = newList.length
            var foundStack = false
            var done = false
            for(var jjj=0; jjj<count2 && !done; jjj++) {
                if(newList[jjj].fromStack===undoList[iii].fromStack) {
                    foundStack = true
                    if(newList[jjj].fromIndex>undoList[iii].fromIndex) {
                        newList.splice(jjj, 0, undoList[iii])
                        done = true
                    }
                }
                else if(foundStack) {
                    newList.splice(jjj, 0, undoList[iii])
                    done = true
                }
            }
            if(!done)
                newList[count2] = undoList[iii]
        }
        return newList
    }

    onRedo: {
        print("onRedo")
        if(!hasNextMove || _amoutMoving!=0)
            return;
        redoOne()
    }

    function redoOne() {
        print("redoOne::"+historyIndex+"/"+historyLength)
        var argsList = History.history.returnAndGoForward();
        if(!argsList) {
            print("returnAndGoForward failed")
            return false
        }
        //var newArgsList = sortRedoList(argsList)
        var newArgsList = argsList
        var count = newArgsList.length

        for(var iii=0; iii<count; iii++) {
            var args = newArgsList[iii]
            print("redo: "+args.fromIndex+" "+args.fromStack+" "+args.toIndex+" "+args.toStack+" "+args.toUp + " " + args.flipZ)
            moveCard(args.fromIndex, indexToStack(args.fromStack), indexToStack(args.toStack), args.toUp, args.flipZ)
        }
        return true
    }

    function sortRedoList(redoList) {
        var count = redoList.length
        var newList = []

        for(var iii=0; iii<count; iii++) {
            var count2 = newList.length
            var foundStack = false
            var done = false
            for(var jjj=0; jjj<count2 && !done; jjj++) {
                if(newList[jjj].toStack===redoList[iii].toStack) {
                    foundStack = true
                    if(newList[jjj].toIndex>redoList[iii].toIndex) {
                        newList.splice(jjj, 0, redoList[iii])
                        done = true
                    }
                }
                else if(foundStack) {
                    newList.splice(jjj, 0, redoList[iii])
                    done = true
                }
            }
            if(!done)
                newList[count2] = redoList[iii]
        }
        return newList
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
        print("onInit::"+savedSeed)
        History.init(savedGame)
        gameSeed = savedSeed

        toRemoveAfterRedoing = []

        var iii = 0;
        while(main.children[iii]) {
            if(main.children[iii].objectName === "stack") {
                main.children[iii].model.clear()
                main.children[iii].init()
            }
            iii++
        }

        dealingStack.deck.fillRandom(false, gameSeed)
        gameSeed = dealingStack.deck.getSeed()

        _dealIndex = 0
        _amoutMoving = 0

        if(savedGameIndex>0) {
            print("onInit: redo previousGame")
            _redoing = true
            while(historyIndex<savedGameIndex) {
                if(!redoOne()) {
                    print("onInit: redo failed")
                    break;
                }
                else {
                    print("onInit: redid one")
                    try {
                        var tmpList = toRemoveAfterRedoing;
                        for(var toRemove in tmpList) {
                            tmpList[toRemove].fromStack.model.remove(tmpList[toRemove].index)
                        }
                    }
                    catch (error) {
                        print("onInit: Error "+error)
                    }
                    toRemoveAfterRedoing = []
                }
            }
            _redoing = false
        }
        else {
            print("onInit: init new game")

            _dealt = false
        }
    }

    Timer {
        id: runOnesTimer
        repeat: false
        running: false
        interval: 1
        onTriggered: {
            gamePage.initGame()
        }
    }

    Component.onDestruction: {
        print("onDestruction")
        saveGame()
    }

    function saveGame() {
        print("saveGame: "+saveGameOnQuit+" "+_saved)
        if(_saved)
            return;
        if(!saveGameOnQuit) {
            gamePage.removeState()
            return
        }
        var json = []
        var saveIndex = 0
        var saveSeed = gameSeed
        if(hasPreviousMove) {
            json = History.history.json
            saveIndex = historyIndex
        }
        gamePage.saveState(json, saveIndex, saveSeed)
        _saved = true
    }

    function preEnd(saveOnQuit) {
        print("preEnd: "+ saveOnQuit)
        saveGameOnQuit = saveOnQuit
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
        interval: fillDuration
        repeat: true
        running: !_dealt && dealingStack.amountComming==0
        triggeredOnStart: false

        onTriggered: {
            if(_dealIndex==0) {
                History.history.startMove()
            }
            if(dealingModel[_dealIndex]) {
                var iii = dealingStack.count
                var card
                do {
                    iii--
                    card = dealingStack.repeater.itemAt(iii)
                } while((!card || card.animating) && iii>=0)

                if(iii==-1) {
                    print("Failed to get "+_dealIndex+" out of dealingStack")
                    _dealt = true
                    return
                }

                moveCard(iii, dealingStack, dealingModel[_dealIndex].stackId, dealingModel[_dealIndex].isUp)
                _dealIndex++
            }
            else {
                if(typeof stockStack === 'undefined') {
                    stop()
                    _dealt = true
                    History.history.endMove()
                    return
                }
                if(dealingStack.count==0) {
                    stop()
                    _dealt = true
                    History.history.endMove()
                    return
                }

                var jjj = dealingStack.count
                var card2
                do {
                    jjj--
                    card2 = dealingStack.repeater.itemAt(jjj)
                } while(card2 && card2.animating)

                if(!card2) {
                    stop()
                    _dealt = true
                    History.history.endMove()
                    return
                }

                moveCard(jjj, dealingStack, stockStack, false)
            }
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

        property int _floatingChangeDuration: UbuntuAnimation.SnapDuration

        z:10

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
                    id: parallelAnim
                    UbuntuNumberAnimation {
                        id: numberAnimationX
                        properties: "x"; duration: floatingCard._floatingChangeDuration;
                    }
                    UbuntuNumberAnimation {
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

    function flipCard(index, stack, up, record) {
        print("flipCard: "+index+" "+stack+" "+up)
        var card = stack.repeater.itemAt(index);
        if(typeof up === 'undefined')
            up = !card.up
        if(typeof record === 'undefined')
            record = true
        if(card.up === up )
            return
        card.up = up
        if(record)
            History.history.addToHistory(index,stackToIndex(stack),!up,index,stackToIndex(stack),up, false)
    }

    function moveCard(index, fromStack, toStack, up, flipZ, animating) {
        print("moveCard: "+index+" "+fromStack+" "+toStack+" "+up+" "+flipZ)
        if(!fromStack) {
            print("No fromStack")
            return
        }
        if(!toStack) {
            print("No toStack")
            return
        }
        var cardVar = fromStack.model.get(index)
        if(!cardVar) {
            print("No card at index in stack")
            return false
        }
        var fromCard = fromStack.repeater.itemAt(index)
        if(!fromCard) {
            print("No card at index in stack")
            return
        }

        var fromUp = fromCard.up
        if(typeof flipZ === 'undefined')
            flipZ = false
        if(flipZ)
            fromStack.flipZ = flipZ
        if(typeof up === 'undefined')
            up = fromUp
        if(typeof animating == 'undefined')
            animating = !_redoing
        if(fromStack===toStack) {
            if(!fromCard) {
                print("Moving to the same stack")
            }
            if(fromCard) {
                flipCard(index, fromStack, up)
            }
        }
        else {
            fromStack.amountGoing++
            toStack.amountComming++
            if(animating) {
                _amoutMoving++
                fromCard.afterAnimation.connect(function() {
                    toStack.model.addFromCard(fromCard)
                    fromStack.model.remove(fromCard.stackIndex)
                    _amoutMoving--
                    if(_dealt && !_moving && !_redoing)
                        board.checkGame()
                })
                var mapPoint = toStack.mapToItemFromIndex(fromStack,toStack.count-1+toStack.amountComming)
                fromCard.x = mapPoint.x
                fromCard.y = mapPoint.y
                print("moveCard: card:"+fromCard.card+"/"+fromCard.suit+" to "+(toStack.count-1+toStack.amountComming))
                if(fromCard.up !== up)
                    flipCard(index, fromStack, up, false)
            }
            else {
                print("moveCard: card:"+fromCard.card+"/"+fromCard.suit+" to "+(toStack.count-1+toStack.amountComming))
                if(fromCard.up !== up)
                    flipCard(index, fromStack, up, false)
                toStack.model.addFromCard(fromCard)
                if(_redoing) {
                    var tmpList = toRemoveAfterRedoing;
                    tmpList.push({"fromStack":fromStack,"index":fromCard.stackIndex})
                    toRemoveAfterRedoing = tmpList
                }
                else {
                    fromStack.model.remove(fromCard.stackIndex)
                }
                if(_dealt && !_moving && !_redoing)
                    board.checkGame()
            }
        }
        History.history.addToHistory(index,stackToIndex(fromStack),fromUp,toStack.count-1+toStack.amountComming,stackToIndex(toStack),up, flipZ)
        return true
    }

    function moveCardAndFlip(index, fromStack, toStack, up) {
        print("moveCardAndFlip: "+index+" "+fromStack+" "+toStack+" "+up)
        var count = fromStack.count
        print(count)
        if (count >= 2) {
            if (fromStack.repeater.itemAt(index-1) && !fromStack.repeater.itemAt(index-1).up)
                flipCard(index-1,fromStack, true)
        }
        moveCard(index, fromStack, toStack, up)
    }

    function highlightFrom(index) {
        if(!selectedStack)
            return
        selectedStack.highlightFrom = index
        if(floatingCard.front)
            floatingCard.front.lighter = true
    }

    function stopHighlight() {
        if(selectedStack)
            selectedStack.highlightFrom = -1
        if(previousSelectedStack)
            previousSelectedStack.highlightFrom = -1
        if(floatingCard.front)
            floatingCard.front.lighter = false
    }

    property variant stackList: []

    function stackToIndex(stack) {
        print("stackToIndex")
        var stackIndex = -1
        var boardIndex = -1
        var tmpList = stackList
        if(tmpList) {
            stackIndex = tmpList.indexOf(stack)
            if(stackIndex!==-1) {
                print("stackToIndex::found in stackList "+stackIndex)
                return stackIndex
            }
        }
        var child
        do {
            boardIndex++
            child = board.children[boardIndex]
            if(child.objectName === "stack") {
                stackIndex++
            }
            if(stack===child) {
                print("stackToIndex::found in children "+stackIndex)
                tmpList[stackIndex] = stack
                stackList = tmpList
                return stackIndex
            }
        } while(boardIndex<board.children.length-1)
        print("stackToIndex::Not found")
        return -1
    }

    function indexToStack(index) {
        print("indexToStack")
        if(stackList[index]) {
            print("indexToStack::found in stackList "+index)
            return stackList[index]
        }
        var tmpList = stackList
        var stackIndex = -1
        var boardIndex = -1
        var stack
        do {
            boardIndex++
            stack = board.children[boardIndex]
            if(stack.objectName === "stack") {
                stackIndex++
            }
            if(stackIndex===index) {
                print("indexToStack::found in children "+index)
                tmpList[stackIndex] = stack
                stackList = tmpList
                return stack
            }
        } while(boardIndex<board.children.length-1)
        print("indexToStack::Not found")
    }
}
