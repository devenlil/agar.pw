function SendAudio(audioId) {
	this.audioId = audioId;
	/*
	* 1: Swoosh
	* 2: Eject
	* 3: BlobEat
	* 4: Eat
	*/
}

module.exports = SendAudio;

SendAudio.prototype.build = function() {
    var buf = new ArrayBuffer(2);
    var view = new DataView(buf);

    view.setUint8(0, 55, true);
	view.setUint8(1, this.audioId, true);
    return buf;
};

