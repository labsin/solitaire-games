var history

var History = function(savedGame) {
    var newSavedGame
    if(!savedGame) {
        newSavedGame = []
    }
    else {
        newSavedGame = savedGame
    }

    print("History::"+newSavedGame.toString()+newSavedGame.length)
    this.marking = false
    this.json = newSavedGame
    historyIndex = 0
    if(!this.json.length) {
        historyLength = 0
    }
    else {
        historyLength = this.json.length
    }
}

History.prototype.addToHistory = function (fromIndex, fromStack, fromUp, toIndex, toStack, toUp, flipZ) {
    if(!this.marking)
        return
    if(!this.json[historyIndex])
        this.json[historyIndex] = []
    this.json[historyIndex][this.json[historyIndex].length] = {"fromIndex": fromIndex, "fromStack": fromStack,"fromUp": fromUp, "toIndex":toIndex, "toStack":toStack, "toUp":toUp, "flipZ":flipZ}
}

History.prototype.startMove = function () {
    print("History::startMove "+historyIndex)
    this.marking = true
    var iii = 0
    while(this.json[historyIndex+iii]) {
        this.json[historyIndex+iii].length = 0
        this.json.length--
        iii++
    }
}

History.prototype.endMove = function () {
    print("History::endMove "+historyIndex)
    if(this.json[historyIndex] && this.json[historyIndex].length>0) {
        historyIndex++
        historyLength = this.json.length
    }
    this.marking = false
}

History.prototype.goBackAndReturn = function () {
    var tmp
    if(historyIndex>0) {
        historyIndex--
        tmp = this.json[historyIndex]
    }

    return tmp
}

History.prototype.returnAndGoForward = function () {
    var tmp
    if(historyIndex<this.json.length) {
        tmp = this.json[historyIndex]
        historyIndex++
    }

    return tmp
}

function init(savedGame) {
    if(typeof savedGame == 'undefined')
        savedGame = []
    history = new History(savedGame)
}
