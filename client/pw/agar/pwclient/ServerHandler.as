package pw.agar.pwclient
{
	import flash.display.DisplayObject;
	import flash.external.ExternalInterface;
	import flash.system.Security;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import com.worlize.websocket.WebSocket;
	import com.worlize.websocket.WebSocketEvent;
	import com.worlize.websocket.WebSocketErrorEvent;
	import com.worlize.websocket.WebSocketMessage;
	
	import pw.agar.pwclient.Canvas;
	import flash.events.IOErrorEvent;
	
	public class ServerHandler
	{
		
		private var ws:WebSocket;
		private var isSFX:Boolean;
		
		public function ServerHandler()
		{
			
		}
		
		public function openConnection(ip:String, port:int, sfx:Boolean)
		{			
			// Connect
			if (ExternalInterface.available) {
				ExternalInterface.call("console.log", "request to connect to " + ip + ":" + port);
			}
			Security.loadPolicyFile("xmlsocket://" + ip + ":843");
			ws = new WebSocket("ws://" + ip + ":" + port, "*");
			ws.addEventListener(WebSocketEvent.OPEN, handleWebSocketOpen);
			ws.addEventListener(WebSocketEvent.MESSAGE, handleWebSocketMessage);
			ws.addEventListener(WebSocketEvent.CLOSED, handleWebSocketClosed);
			ws.addEventListener(WebSocketErrorEvent.CONNECTION_FAIL, handleConnectionFail);
			this.isSFX = sfx;
			ws.connect();
		}
		
		public function closeConnection(callback:*)
		{
			if (ws != null && ws.connected) {
				ws.close(false);
			}
			callback();
		}
		
		public function sendBytes(buffer:ByteArray):Boolean
		{
			if (ws != null && ws.readyState == 1) {
				ws.sendBytes(buffer);
				return true;
			}
			return false;
		}
		
		protected function handleWebSocketOpen(event:WebSocketEvent):void
		{
			
			// Clear map
			var nodes:Array = new Array();
			var canvasChild:DisplayObject;
			var cellId:Number;
			for (var i:Number = 0; i < Main.getCanvas().mapholder.map.numChildren; i++) {
				canvasChild = Main.getCanvas().mapholder.map.getChildAt(i);
				try {
					cellId = Cell(canvasChild).getCellId();
					if (cellId.toString().length > 0) {
						nodes.push(cellId);
					}
				} catch(error:Error) {
					trace('WebSocketOpened - Not a cell error (' + canvasChild.name + '): ' + error.message);
				}
			}
			Main.getCanvas().removeNodes(nodes);
			
			trace("Socket opened");
			if (ExternalInterface.available) {
				ExternalInterface.call("console.log", "Socket opened");
			}
			
			Main.getSidebar().hideAlert();
			
			var buffer:ByteArray = new ByteArray();
			
			buffer.endian = Endian.LITTLE_ENDIAN;
			buffer.writeByte(254);
			buffer.writeUnsignedInt(5);
			ws.sendBytes(buffer);
			
			// reset bytearray
			buffer = new ByteArray();
			buffer.position = 0;
			
			buffer.endian = Endian.LITTLE_ENDIAN;
			buffer.writeByte(255);
			buffer.writeUnsignedInt(154669603);
			ws.sendBytes(buffer);
		}
		
		protected function handleWebSocketMessage(event:WebSocketEvent):void
		{
			// initialize multiple used vars
			var i:Number;
			var nodeId:Number;
			var nodeName:String;
			var charCode:Number;
			
			if (event.message.type != WebSocketMessage.TYPE_BINARY) {
				return;
			}
			
			event.message.binaryData.endian = Endian.LITTLE_ENDIAN;
			var buffer:ByteArray = event.message.binaryData;
			var packetId:Number = buffer.readUnsignedByte();
			buffer.position = 1;
			
			switch (packetId) {
				case 16: // world update
					var numEatenNodes:Number = buffer.readUnsignedShort();
					var swallowNodes:Array = new Array();
					var swallowVictims:Array = new Array();
					for (i = 0; i < numEatenNodes; i++) {
						var killerId:Number = buffer.readUnsignedInt();
						var victimId:Number = buffer.readUnsignedInt();
						swallowNodes.push({"killerId": killerId, "victimId": victimId});
						swallowVictims.push(victimId);
					}
					// update loop
					var updates:Array = new Array();
					
					// Initialize Sound Activators
					var swooshSound:Boolean = false;
					var ejectSound:Boolean = false;
					for (;;) {
						var playerId:Number = buffer.readUnsignedInt();
						if (playerId == 0) {
							break;
						}
						
						var nodeX:Number = buffer.readUnsignedInt();
						var nodeY:Number = buffer.readUnsignedInt();
						var radius:Number = buffer.readUnsignedShort();
						var colorR:Number = buffer.readUnsignedByte();
						var colorG:Number = buffer.readUnsignedByte();
						var colorB:Number = buffer.readUnsignedByte();
						// Sound Activators
						if (this.isSFX) {
							swooshSound = buffer.readUnsignedByte();
							ejectSound = buffer.readUnsignedByte();
						}
						///
						var isVirus:Boolean = false;
						//var isAgitated:Boolean = false;
						//var read_fa:Boolean = false;
						var flags:Number = buffer.readUnsignedByte();
						if (flags == 0) {
							isVirus = false;
						} else if (flags == 1) {
							isVirus = true;
						} else {
							trace("ERROR! flag " + flags + " recieved!");
						}
						/*switch (flags) {
							case 0:
								isVirus = true;
								trace("VIRUS");
								break;
							case 1:
								buffer.position += 4;
								trace("SKIP 4");
								break;
							case 2:
								trace("FLAG BIT 2!! NEED HELP WHAT TO DO!!!!!!!!!!!??????????");
								read_fa = true;
								// TODO idk what dis is for
								break;
							case 4:
								trace("AGITATED");
								isAgitated = true;
								break;
							default:
								trace("RECIEVED: " + flags);
								break;
						}
						var fa:String = "";
						if (read_fa) {
							for (;;) {
								charCode = buffer.readByte();
								if (charCode == 0) {
									break;
								}
								fa += String.fromCharCode(charCode);
							}
							trace("FA IS: " + fa + ". <------------------------");
						}*/
						nodeName = "";
						for (;;) {
							charCode = buffer.readUnsignedShort();
							if (charCode == 0) {
								break;
							}
							nodeName += String.fromCharCode(charCode);
						}
						var nodeSkin = "";
						for (;;) {
							charCode = buffer.readUnsignedShort();
							if (charCode == 0) {
								break;
							}
							nodeSkin += String.fromCharCode(charCode);
						}
						
						updates.push({
							"nodeId": playerId,
							"nodeName": nodeName,
							"nodeSkin": nodeSkin,
							"nodeX": nodeX,
							"nodeY": nodeY,
							"radius": radius,
							"colorR": colorR,
							"colorG": colorG,
							"colorB": colorB,
							"isVirus": isVirus,
							"swooshSound": swooshSound,
							"ejectSound": ejectSound
						});
					}
					Main.getCanvas().drawNodes(updates);
					var numRemoveNodes:Number = buffer.readUnsignedInt();
					var toRemoveNodes:Array = new Array();
					for (i = 0; i < numRemoveNodes; i++) {
						nodeId = buffer.readUnsignedInt();
						if (swallowVictims.indexOf(nodeId) < 0) {
							toRemoveNodes.push(nodeId);
						}
					}
					Main.getCanvas().removeNodes(toRemoveNodes)
					Main.getCanvas().swallowThenRemove(swallowNodes);
					break;
				case 55: // Sound Effects (SFX)
					var audio = buffer.readUnsignedByte();
					Main.getCanvas().playAudio(audio);
					break;
				case 17: // view update (spectate mode)
					var viewX:Number = buffer.readFloat();
					var viewY:Number = buffer.readFloat();
					var viewZoom:Number = buffer.readFloat();
					trace("view x: " + viewX + ", y: " + viewY + ", zoom: " + viewZoom);
					trace('1 mapholder size w:' + Main.getCanvas().mapholder.map.width + ', h: ' + Main.getCanvas().mapholder.map.height);
					Main.getCanvas().setZoomratio(viewZoom);
					Main.getCanvas().setCameraTo(viewX, viewY, true);
					trace('2 mapholder size w:' + Main.getCanvas().mapholder.map.width + ', h: ' + Main.getCanvas().mapholder.map.height);
					break;
				case 20: // reset known/controlled cells
					Main.getGame().reset();
					break;
				case 32: // owns blob
					nodeId = buffer.readUnsignedInt();
					trace('my node id is: ' + nodeId);
					Main.getGame().setMyMainNodeId(nodeId);
					Main.getGame().addMyNodeId(nodeId);
					break;
				case 34: // send score
					Main.getScoreBox().setScore(buffer.readUnsignedInt());
					break;
				case 49: // ffa leaderboard
					var nodeAmt:Number = buffer.readUnsignedInt();
					var leaderboardNodes:Array = new Array();
					for (i = nodeAmt; i > 0; i--) {
						nodeId = buffer.readUnsignedInt();
						nodeName = "";
						for (;;) {
							charCode = buffer.readShort();
							if (charCode == 0) {
								break;
							}
							nodeName += String.fromCharCode(charCode);
						}
						leaderboardNodes.push({
							"nodeId": nodeId,
							"nodeName": nodeName
						});
					}
					Main.getLeaderboard().updateLeaderboardFFA(nodeAmt, leaderboardNodes);
					break;
				case 64: // game world size
					Main.getCanvas().setWorldSize(buffer.readDouble(), buffer.readDouble(), buffer.readDouble(), buffer.readDouble());
					break;
			}
		}
		
		protected function handleWebSocketClosed(event:WebSocketEvent):void
		{
			trace("Socket closed");
			if (ExternalInterface.available) {
				ExternalInterface.call("console.log", "Socket closed: " + event.message);
				ExternalInterface.call("console.log", event.target);
			}
			
			// Reset game
			var nodes:Array = new Array();
			var canvasChild:DisplayObject;
			var cellId:Number;
			for (var i:Number = 0; i < Main.getCanvas().mapholder.map.numChildren; i++) {
				canvasChild = Main.getCanvas().mapholder.map.getChildAt(i);
				try {
					cellId = Cell(canvasChild).getCellId();
					if (cellId.toString().length > 0) {
						nodes.push(cellId);
					}
				} catch(error:Error) {
					//trace('WebSocketClosed - Not a cell error (' + canvasChild.name + '): ' + error.message);
				}
			}
			
			this.isSFX = false
			
			Main.getCanvas().removeNodes(nodes);
			Main.getCanvas().resetScale();
			Main.getGame().reset();
			
			Main.getSidebar().showAlert();
		}
		
		protected function handleConnectionFail(event:WebSocketErrorEvent):void
		{
			trace("Error connecting to socket");
			if (ExternalInterface.available) {
				ExternalInterface.call("console.log", "error: " + event.text);
			}
			
			this.isSFX = false
			
			Main.getSidebar().showAlert();
		}
		
		public function executeJavascriptFunction(func:String):Boolean
		{
			if (ExternalInterface.available) {
				ExternalInterface.call(func);
				return true;
			} else {
				return false;
			}
		}
		
	}
	
}