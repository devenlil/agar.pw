package pw.agar.pwclient.sidebar
{
	import flash.display.MovieClip;
	import flash.errors.IOError;
	import flash.events.IOErrorEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.Security;
	import flash.text.TextField;
	import flash.text.TextFormatAlign;
	import flash.text.TextFormat;
	import flash.utils.setInterval;
	
	import pw.agar.pwclient.Main;
	import pw.agar.pwclient.ServerHandler;
	import flash.events.SecurityErrorEvent;
	
	public class Dropdown extends MovieClip
	{
		
		private var config:XML;
		private var lobbies:Array;
		
		public function Dropdown()
		{
			Security.allowDomain("http://*.agar.pw");
			
			var myLoader:URLLoader = new URLLoader();
			myLoader.addEventListener(Event.COMPLETE, processConfig);
			myLoader.load(new URLRequest('servers.xml'));
		}
		
		protected function processConfig(event:Event):void
		{
			config = new XML(event.target.data);
			lobbies = new Array();
			
			for (var i:Number = 0; i < config.region.length(); i++) {
				for (var b:Number = 0; b < config.region[i].server.length(); b++) {
					for (var c:Number = 0; c < config.region[i].server[b].gamemode.length(); c++) {
						lobbies.push({
							"name": config.region[i].server[b].gamemode[c].@name,
							"type": config.region[i].server[b].gamemode[c].@type,
							"port": config.region[i].server[b].gamemode[c].@port,
							"statsport": config.region[i].server[b].gamemode[c].@stats_port,
							"sfx": (config.region[i].server[b].gamemode[c].@sfx == "true") ? true : false,
							"serverip": config.region[i].server[b].@ip,
							"serverid": config.region[i].server[b].@id,
							"region": config.region[i].@id,
							"stats": null
						});
						getNumPlayers(config.region[i].server[b].@ip, config.region[i].server[b].gamemode[c].@stats_port);
					}
				}
			}
			setInterval(updateStats, 60000);
		}
		
		private function updateStats():void
		{
			for (var i:Number = 0; i < lobbies.length; i++) {
				trace("Updating Server Stats...");
				getNumPlayers(lobbies[i].serverip, lobbies[i].statsport);
			}
		}
		
		public function getNumPlayers(serverIp, statsPort):void
		{
			try {
				var stats:Object;
				var statsLoader:URLLoader = new URLLoader();
				statsLoader.addEventListener(IOErrorEvent.IO_ERROR, function(error) {
					 trace("Stats Server IO Error! Is the server running? : " + error.text);
				});
				statsLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, function(error) {
					trace("Stats Server Security Error! : " + error.text);
					 if (ExternalInterface.available) {
						ExternalInterface.call("console.log", "Stats Server Security Error! : " + error.text);
					}
				});
				statsLoader.addEventListener(Event.COMPLETE, function(event:Event) {
					stats = JSON.parse(event.target.data);
					trace("Loaded Stats: " + stats.current_players + " players / " + stats.spectators + " spectators / " + stats.max_players + " maxplayers");
					for (var i = 0; i < lobbies.length; i++) {
						if (lobbies[i].serverip != serverIp || lobbies[i].statsport != statsPort) {
							continue;
						}
						lobbies[i].stats = stats;
						break;
					}
				});
				statsLoader.load(new URLRequest('http://' + serverIp + ':' + statsPort));
			} catch (error:Error) {
				trace("Error loading server stats from stats server: " + error.message);
				if (ExternalInterface.available) {
					ExternalInterface.call("console.log", "Error loading server stats from stats server: " + error.message);
				}
			}
		}
		
		public function dropMenu(event:MouseEvent):void
		{
			this.gotoAndStop(2);
			
			var fields:Array = new Array();
			for (var i:Number = 0; i < lobbies.length; i++) {
				fields.push(new DropItem());
			}
			
			var fieldLabel:TextField;
			var fieldLabels:Array = new Array();
			var myFormat:TextFormat = new TextFormat();
			
			myFormat.align = TextFormatAlign.LEFT;
			myFormat.font = "Arial";
			myFormat.size = 12;
			myFormat.color = 0x000000;
			
			var nextY = 13.6;
			for (i = 0; i < fields.length; i++) {
				//fields[i].name = "server_" + lobbies[i].region + "_" + lobbies[i].serverid + "_" + lobbies[i].type + "_" + i;
				fields[i].name = "server_" + i;
				fields[i].x = -177.85;
				fields[i].y = nextY;
				fields[i].addEventListener(MouseEvent.CLICK, onServerSelected);
				
				fieldLabel = new TextField();
				fieldLabel.text = "[" + lobbies[i].region + "-" + lobbies[i].serverid + "] " + lobbies[i].name + " (" + ((lobbies[i].stats != null) ? lobbies[i].stats.alive + ":" + lobbies[i].stats.spectators : "...") + ")";
				fieldLabel.setTextFormat(myFormat);
				fieldLabel.width = 187.75;
				fieldLabel.height = 19.6;
				fieldLabel.x = -177.85;
				fieldLabel.y = nextY + 3.85;
				fieldLabel.selectable = false;
				fieldLabel.mouseEnabled = false;
				fieldLabels.push(fieldLabel);
				
				this.addChild(fields[i]);
				nextY += 26;
			}
			
			for (i = 0; i < fieldLabels.length; i++) {
				this.addChildAt(fieldLabels[i], this.numChildren);
			}
		}
		
		public function closeMenu(event:MouseEvent):void
		{
			for (var i:Number = this.numChildren - 1; i > 0; i--) {
				if (this.getChildAt(i).name != "arrowbtn") {
					this.removeChildAt(i);
				}
			}
			this.gotoAndStop(1);
		}
		
		protected function onServerSelected(event:MouseEvent):void
		{
			Main.getSidebar().serverselectiontip.visible = false;
			var lobbiesindex:Number = event.target.name.split("_")[1];
			closeMenu(null); // close dropmenu
			MovieClip(this.parent).currentserver.text = "[" + lobbies[lobbiesindex].region + "-" + lobbies[lobbiesindex].serverid + "] " + lobbies[lobbiesindex].name; // set current server label
			Main.getServerHandler().closeConnection(function() {
				Main.getServerHandler().openConnection(lobbies[lobbiesindex].serverip, lobbies[lobbiesindex].port, lobbies[lobbiesindex].sfx); // open new connection
			}); // close old connection if open
			
		}
		
	}
	
}