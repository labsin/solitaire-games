var history

var History = function() {
    this.index = 0
    this.marking = false
    this.json = []
}

History.prototype.addToHistory = function (fromIndex, fromStack, fromUp, toIndex, toStack, toUp, flipZ) {
    if(!this.marking)
        return
    if(!this.json[this.index])
        this.json[this.index] = []
    this.json[this.index][this.json[this.index].length] = {"fromIndex": fromIndex, "fromStack": fromStack,"fromUp": fromUp, "toIndex":toIndex, "toStack":toStack, "toUp":toUp, "flipZ":flipZ}
}

History.prototype.startMove = function () {
    this.marking = true
    var iii = 0
    while(this.json[this.index+iii]) {
        this.json[this.index+iii].length = 0
        this.json.length--
        iii++
    }
}

History.prototype.endMove = function () {
    if(this.json[this.index] && this.json[this.index].length>0) {
        this.index++
        hasNextMove=false
        hasPreviousMove=true
    }
    this.marking = false
}

History.prototype.goBackAndReturn = function () {
    var tmp
    if(this.index>0) {
        this.index--
        hasNextMove = true
        tmp = this.json[this.index]
    }
    if (this.index<=0) {
        hasPreviousMove = false
    }

    return tmp
}

History.prototype.returnAndGoForward = function () {
    var tmp
    if(this.index<this.json.length) {
        tmp = this.json[this.index]
        this.index++
        hasPreviousMove = true
    }
    if(this.index>=this.json.length) {
        hasNextMove = false
    }
    return tmp
}

function init() {
    history = new History()
}
