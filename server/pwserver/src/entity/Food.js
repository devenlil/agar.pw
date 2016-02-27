var Cell = require('./Cell');
var Packet = require('../packet');

function Food() {
    Cell.apply(this, Array.prototype.slice.call(arguments));

    this.cellType = 1;
    this.size = Math.ceil(Math.sqrt(100 * this.mass));
    this.squareSize = (100 * this.mass) >> 0; // not being decayed -> calculate one time
}

module.exports = Food;
Food.prototype = new Cell();

Food.prototype.getSize = function() {
    return this.size;
};

Food.prototype.getSquareSize = function () {
    return this.squareSize;
};

Food.prototype.calcMove = null; // Food has no need to move

// Main Functions

Food.prototype.sendUpdate = function() {
    // Whether or not to include this cell in the update packet
    if (this.moveEngineTicks == 0) {
        return false;
    }
    return true;
};

Food.prototype.onRemove = function(gameServer) {
    gameServer.currentFood--;
};

Food.prototype.onConsume = function(consumer,gameServer) {
    consumer.addMass(this.mass);
	consumer.owner.socket.sendPacket(new Packet.SendAudio(4));
};

