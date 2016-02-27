var Packet = require('./packet');
var mysql = require('mysql');

function PacketHandler(gameServer, socket) {
    this.gameServer = gameServer;
    this.socket = socket;
    // Detect protocol version - we can do something about it later
    this.protocol = 0;

    this.pressQ = false;
    this.pressW = false;
    this.pressSpace = false;
}

module.exports = PacketHandler;

PacketHandler.prototype.handleMessage = function(message) {
    function stobuf(buf) {
        var length = buf.length;
        var arrayBuf = new ArrayBuffer(length);
        var view = new Uint8Array(arrayBuf);

        for (var i = 0; i < length; i++) {
            view[i] = buf[i];
        }

        return view.buffer;
    }

    // Discard empty messages
    if (message.length == 0) {
        return;
    }

    var buffer = stobuf(message);
    var view = new DataView(buffer);
    var packetId = view.getUint8(0, true);

    switch (packetId) {
        case 0:
            // Check for invalid packets
            if ((view.byteLength + 1) % 2 == 1) {
                break;
            }

            // Set Nickname
            var nick = "";
            var maxLen = this.gameServer.config.playerMaxNickLength * 2; // 2 bytes per char
            for (var i = 1; i < view.byteLength && i <= maxLen; i += 2) {
                var charCode = view.getUint16(i, true);
                if (charCode == 0) {
                    break;
                }

                nick += String.fromCharCode(charCode);
            }
			
			// Set Skin
			var skin = "";
			for (var b = 1; b < view.byteLength && b <= (50 * 2); b += 2) {
				var charCode;
				try {
					charCode = view.getUint16(b + i, false);
				} catch(error) {
					console.log("ERROR: " + error.message);
					charCode = view.getUint16(b + i, true);
				}
				if (charCode == 0) {
					break;
				}
				
				skin += String.fromCharCode(charCode);
			}
			if (skin.length > 0) {
				// MySQL CONFIGURATION (for skins)
				var sqlconn = mysql.createConnection({
					host: 'localhost',
					user: 'root',
					password: '',
					database: 'agarpw'
				});
				sqlconn.on('error', function(err) {
					console.log('mysql error [005] : ' + err);
				});
				sqlconn.connect();
				sqlconn.query("SELECT url FROM `skins` WHERE FIND_IN_SET('" +  skin + "', tags)", function(err, rows, fields) {
					console.log(rows);
					if (rows != null && rows.length == 1) {
						this.setNicknameAndSkin(nick, rows[0]['url']);
						return;
					} else {
						this.setNicknameAndSkin(nick, "");
						return;
					}
				}.bind(this));
				sqlconn.end();
			} else {
				this.setNicknameAndSkin(nick, "");
				break;
			}
            break;
        case 1:
            // Spectate mode
            if (this.socket.playerTracker.cells.length <= 0) {
                // Make sure client has no cells
                this.gameServer.switchSpectator(this.socket.playerTracker);
                this.socket.playerTracker.spectate = true;
            }
            break;
        case 16:
            // Set Target
            if (view.byteLength == 13) {
                var client = this.socket.playerTracker;
                client.mouse.x = view.getInt32(1, true);
                client.mouse.y = view.getInt32(5, true);
            }
            break;
        case 17:
            // Space Press - Split cell
            this.pressSpace = true;
            break;
        case 18:
            // Q Key Pressed
            this.pressQ = true;
            break;
        case 19:
            // Q Key Released
            break;
        case 21:
            // W Press - Eject mass
            this.pressW = true;
            break;
        case 255:
            // Connection Start 
            if (view.byteLength == 5) {
                this.protocol = view.getUint32(1, true);
                // Send SetBorder packet first
                var c = this.gameServer.config;
                this.socket.sendPacket(new Packet.SetBorder(c.borderLeft, c.borderRight, c.borderTop, c.borderBottom));
            }
            break;
        default:
            break;
    }
};

PacketHandler.prototype.setNicknameAndSkin = function(newNick, newSkin) {
    var client = this.socket.playerTracker;
    if (client.cells.length < 1) {
        // Set name first
        client.setName(newNick); 
		
	// Set skin
	client.setSkin(newSkin);

        // If client has no cells... then spawn a player
        this.gameServer.gameMode.onPlayerSpawn(this.gameServer,client);

        // Turn off spectate mode
        client.spectate = false;
    }
};

