function SendScore(score) {
	this.score = score;
}

module.exports = SendScore;

SendScore.prototype.build = function() {
    var buf = new ArrayBuffer(5);
    var view = new DataView(buf);

    view.setUint8(0, 34, true);
    view.setUint32(1, this.score, true);
    return buf;
};

