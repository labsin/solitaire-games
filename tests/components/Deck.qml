import QtQuick 2.0

Item {
    property alias model: deckModel

    ListModel {
        id: deckModel

        function pop() {
            var temp = get(count-1)
            if(!temp)
                return temp
            var temp2 = makeArgs(temp.thisSuit, temp.thisCard, temp.thisUp)
            remove(count-1)
            return temp2
        }

        function unShift() {
            var temp = get(0)
            if(!temp)
                return temp
            var temp2 = makeArgs(temp.thisSuit, temp.thisCard, temp.thisUp)
            remove(0)
            return temp2
        }

        function addFromCard(card) {
            deckModel.append({"thisSuit": card.suit, "thisCard": card.card, "thisUp": card.up})
        }
    }

    function pop() {
        return deckModel.pop()
    }

    function fillNonRandom(up) {
        deckModel.clear()
        for(var jjj=0; jjj<52; jjj++) {
            var suit = Math.floor(jjj/13)+1
            var card = jjj%13 + 1
            deckModel.append({"thisSuit": suit, "thisCard": card, "thisUp": up})
        }
    }

    function fillRandom(up) {
        up = up?up:false
        deckModel.clear()
        var tmpArr = new Array
        for(var iii=0; iii<52; iii++)
            tmpArr[iii] = iii;
        for(var jjj=0; jjj<52; jjj++) {
            var rand = tmpArr.splice(getRandomInt(0,51-jjj),1)
            var suit = Math.floor(rand/13)+1
            var card = rand%13 + 1
            deckModel.append(makeArgs(suit, card, up))
        }
    }

    function makeArgs(suit, card, up) {
        return {"thisSuit": suit, "thisCard": card, "thisUp": up}
    }

    /**
     * Returns a random integer between min and max
     * Using Math.round() will give you a non-uniform distribution!
     */
    function getRandomInt (min, max) {
        return Math.floor(Math.random() * (max - min + 1)) + min;
    }
}
