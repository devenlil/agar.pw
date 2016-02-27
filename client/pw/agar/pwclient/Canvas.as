package pw.agar.pwclient
{
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.media.Sound;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.*;
	import fl.transitions.easing.Regular;
	
	import com.greensock.TimelineLite;
	import com.greensock.TweenLite;
	
	import pw.agar.pwclient.Main;
	
	public class Canvas extends MovieClip
	{
		
		private var worldDim:Object = {minX: 0, minY: 0, maxX: 1000, maxY: 1000};
		
		private var zoomratio:Number = 1;
		private var scale:Number = 1;
		
		public function Canvas()
		{
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPressed);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyReleased);
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			stage.addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, onMouseWheelDown);
			//stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			Main.setCanvas(this);
			setInterval(function() { updateMousePosition(NaN, NaN); }, 25);
		}
		
		public function resetScale():void
		{
			zoomratio = 1;
			scale = 1;
		}
		
		protected function onKeyPressed(event:KeyboardEvent):void
		{
			var sendBuffer:Boolean = false;
			var buffer:ByteArray = new ByteArray;
			buffer.endian = Endian.LITTLE_ENDIAN;
			trace('key pressed: ' + event.keyCode);
			switch (event.keyCode) {
				case 32: // space key
					buffer.writeByte(17);
					sendBuffer = true;
					break;
				case 81: // q key
					buffer.writeByte(18);
					sendBuffer = true;
					break;
				case 192: // ~ key
					buffer.writeByte(20);
					sendBuffer = true;
					break;
				case 87: // w key
					buffer.writeByte(21);
					sendBuffer = true;
					break;
				case 27: // escape key
					Main.getSidebar().showSide();
					break;
			}
			
			if (sendBuffer) {
				Main.getServerHandler().sendBytes(buffer);
			}
		}
		
		protected function onKeyReleased(event:KeyboardEvent):void
		{
			var sendBuffer:Boolean = false;
			var buffer:ByteArray = new ByteArray;
			buffer.endian = Endian.LITTLE_ENDIAN;
			
			switch (event.keyCode) {
				case 19: // q key
					buffer.writeByte(19);
					sendBuffer = true;
					break;
			}
			
			if (sendBuffer) {
				Main.getServerHandler().sendBytes(buffer);
			}
		}
		
		protected function onMouseMove(event:MouseEvent):void
		{
			updateMousePosition(event.localX, event.localY);
		}
		
		protected function onMouseWheel(event:MouseEvent):void
		{
			var diff:Number = event.delta / Math.abs(event.delta);
			diff *= 0.05;
			if (scale + diff >= 0.05 && scale + diff <= 4) {
				scale += diff;
				updateZoom();
				var myPlayer:Cell = Main.getGame().getMyNode();
				setCameraTo(myPlayer.x, myPlayer.y, false);
			}
		}
		
		protected function onMouseWheelDown(event:MouseEvent):void
		{
			scale = 1;
		}
		
		private function updateMousePosition(mousex:Number, mousey:Number):void
		{
			if (Main.getOverlaysVisible()) {
				return;
			}
			
			var myNode:Cell = Main.getGame().getMyNode();
			if (myNode != null) {
				if (Math.abs(myNode.x - (isNaN(mousex) ? mapholder.map.mouseX : mousex)) < myNode.getMass(-1) * 0.5) {
					if (Math.abs(myNode.y - (isNaN(mousey) ? mapholder.map.mouseY : mousey)) < myNode.getMass(-1) * 0.5) {
						return;
					}
				}
			}
			
			var buffer:ByteArray = new ByteArray;
			buffer.endian = Endian.LITTLE_ENDIAN;
			
			buffer.writeByte(16);
			buffer.writeInt((isNaN(mousex)) ? mapholder.map.mouseX : mousex);
			buffer.writeInt(isNaN(mousey) ?mapholder. map.mouseY : mousey);
			buffer.writeUnsignedInt(0); // which blob to move (0 = all)
			
			Main.getServerHandler().sendBytes(buffer);
		}
		
		public function setWorldSize(minX, minY, maxX, maxY):void
		{
			trace("minX: " + minX + ", minY: " + minY + ", maxX: " + maxX + ", maxY: " + maxY);
			mapholder.map.filler.x = minX;
			mapholder.map.filler.y = minY;
			var diffX:Number = maxX - minX;
			var diffY:Number = maxY - minY;
			mapholder.map.filler.width = diffX;
			mapholder.map.filler.height = diffY;
			
			// save world dimensions
			worldDim = {
				minX: minX,
				minY: minY,
				maxX: maxX,
				maxY: maxY
			};
			
			// reset map borders if exist
			var mapborders_mc:DisplayObject = mapholder.map.getChildByName("mapborders_mc");
			if (mapborders_mc != null) {
				mapholder.map.removeChild(mapborders_mc);
				if (Main.getDarkMode()) {
					drawMapBorder(0xffffff);
				} else {
					drawMapBorder(0x000000);
				}
			}
		}
		
		public function setCameraTo(posX, posY, animate:Boolean):void
		{	
			// Flip Glitch Prevention [helps but still glitchy]
			if (posX < 0) posX = 0;
			if (posY < 0) posY = 0;
			
			updateZoom();
			
			var newX:Number = -1 * ((posX * zoomratio) * scale) + (stage.stageWidth / 2);
			var newY:Number = -1 * ((posY * zoomratio) * scale) + (stage.stageHeight / 2);
			/* Original -- testing new code below
			var diffX:Number = newX - mapholder.map.x;
			var diffY:Number = newY - mapholder.map.y;*/
			var diffX:Number = newX - mapholder.x;
			var diffY:Number = newY - mapholder.y;
			
			var gridX:Number;
			var gridY:Number;
			gridX = grid.x + diffX;
			gridY = grid.y + diffY;
			if (gridX > 50 || gridX < -50) {
				gridX = gridX / 50;
				if (gridX < 0) {
					gridX = (gridX + Math.abs(Math.floor(gridX))) * 50;
				} else if (gridX > 0) {
					gridX = (gridX - Math.floor(gridX)) * 50;
				} else {
					gridX = 0;
				}
			}
			if (gridY > 50 || gridY < -50) {
				gridY = gridY / 50;
				if (gridY < 0) {
					gridY = (gridY + Math.abs(Math.floor(gridY))) * 50;
				} else if (gridY > 0) {
					gridY = (gridY - Math.floor(gridY)) * 50;
				} else {
					gridY = 0;
				}
			}
			//trace('new x: ' + newX + ", y: " + newY);
			if (animate) {
				//TweenLite.to(mapholder.map, 2, {x: newX, y: newY});
				mapholder.x = newX;
				mapholder.y = newY;
				//TweenLite.to(grid, 1, {x: gridX, y: gridY});
				grid.x = gridX;
				grid.y = gridY;
			} else {
				mapholder.x = newX;
				mapholder.y = newY;
				grid.x = gridX;
				grid.y = gridY;
			}
			//updateMousePosition(null, null);
		}
		
		public function updateZoom():void
		{
			var mapWidth:Number = mapholder.map.width;
			var mapHeight:Number = mapholder.map.height;
			mapholder.width = (mapWidth * zoomratio) * scale;
			mapholder.height = (mapHeight * zoomratio) * scale;
			/*grid.width = (3000 * zoomratio) * scale;
			grid.height = (2900 * zoomratio) * scale;*/
			/* Not needed
			mapholder.map.width = mapWidth;
			mapholder.map.height = mapHeight;*/
		}
		
		public function setZoomratio(ratio:Number):void
		{
			zoomratio = ratio;
		}
		
		public function playAudio(audioId:int):void
		{
			/*
			 * 1: Swoosh
			 * 2: Eject
			 * 3: BlobEat
			 * 4: Eat
			*/
			if (Main.getSound()) {
				trace("playing sound");
				var sfx:Sound;
				switch(audioId) {
					case 1:
						sfx = new Swoosh();
						break;
					case 2:
						sfx = new Eject();
						break;
					case 3:
						sfx = new BlobEat();
						break;
					case 4:
						sfx = new Eat();
						break;
				}
				sfx.play();
			}
		}
		
		public function drawNodes(nodesUnsorted:Array):void
		{
			var i:Number;
			var offset:Object;
			var isCreated:Boolean;
			var cell:Cell;
			var nodeX:Number;
			var nodeY:Number;
			
			var nodes:Array;
			for (i = 0; i < nodesUnsorted.length; i++) {
				//trace("U_NODE: " + nodesUnsorted[i]["radius"]);
			}
			nodes = nodesUnsorted.sortOn("radius", Array.NUMERIC);
			/*if (Main.getGame().isMyNodeSpecified()) {
				for (i = 0; i < nodes.length; i++) {
					if (nodes[i]["nodeId"] != Main.getGame().getMyNodeId()) {
						continue;
					}
					break;
				}
			}*/
			for (i = 0; i < nodes.length; i++) {
				isCreated = true;
				cell = Cell(mapholder.map.getChildByName("node_" + nodes[i]["nodeId"]));
				if (cell == null) {
					cell = new Cell(nodes[i]["nodeId"], nodes[i]["nodeName"], nodes[i]["nodeSkin"], nodes[i]["isVirus"]);
					isCreated = false;
				}
				if (Main.getGame().isMyNode(nodes[i]["nodeId"])) {
					cell.setShowMass(Main.getShowYourMass());
					if (Main.getGame().getMyMainNodeId() == nodes[i]["nodeId"]) {
						setZoomratio(1); // TODO
					}
				} else {
					cell.setHideName(Main.getHideCellsNames());
					if (cell.isVirusCell()) {
						cell.setShowMass(Main.getShowVirusMass());
					} else {
						cell.setShowMass(Main.getShowOthersMass());
					}
				}
				cell.setSeeThru(Main.getSeeThruCells());
				cell.setRadius(nodes[i]["radius"], isCreated);
				cell.setColor(nodes[i]["colorR"], nodes[i]["colorG"], nodes[i]["colorB"], (nodes[i]["radius"] < 9) ? false : true);
				if (nodes[i]["nodeName"] != null && nodes[i]["nodeName"] != "" && cell.getName() != nodes[i]["nodeName"]) {
					cell.setName(nodes[i]["nodeName"]);
				}
				
				nodeX = nodes[i]["nodeX"];
				nodeY = nodes[i]["nodeY"];
				
				if (isCreated) {
					//TweenLite.to(cell, 1, {x: nodeX, y: nodeY}); // causes jumping
					cell.x = nodeX;
					cell.y = nodeY;
				} else {
					cell.x = nodeX;
					cell.y = nodeY;
				}
				cell.name = "node_" + nodes[i]["nodeId"];
				
				if (!isCreated) {
					mapholder.map.addChild(cell);
				}
				
				// Sound Effects Public
				if (Main.getSound()) {
					var sfx:Sound;
					if (nodes[i]["swooshSound"]) {
						trace('Playing swoosh');
						sfx = new Swoosh(); 
						sfx.play();
					}
					if (nodes[i]["ejectSound"]) {
						trace('Playing eject');
						sfx = new Eject(); 
						sfx.play();
					}
				}
				
				if (Main.getGame().isMyNodeIdSpecified()) {
					if (Main.getGame().getMyMainNodeId() == nodes[i]["nodeId"]) {
						setCameraTo(cell.x, cell.y, false);
						Main.getGame().setMyNode(cell);
						if (!isCreated) {
							Main.getServerHandler().executeJavascriptFunction("updateProfile('" + cell.getName() + "', '" + cell.getColor() + "')");
						}
					}
				}
			}
			reorderNodes();
			//updateScore();
		}
		
		public function reorderNodes():void
		{
			var i:Number;
			var cell:Cell;
			var nodes:Array = new Array();
			for (i = 0; i < mapholder.map.numChildren; i++) {
				try {
					cell = Cell(mapholder.map.getChildAt(i));
					nodes.push({
						'cell': cell,
						'mass': cell.getMass(-1)
					});
				} catch(error:Error) {}
			}
			nodes.sortOn('mass', Array.NUMERIC);
			for (i = 0; i < nodes.length; i++) {
				mapholder.map.setChildIndex(nodes[i]['cell'], i+1);
			}
		}
		
		/*public function updateScore():void {
			var cell:Cell
			var myScore:Number = 0;
			for (var i:Number = 0; i < mapholder.map.numChildren; i++) {
				try {
					cell = Cell(mapholder.map.getChildAt(i));
					if (Main.getGame().isMyNode(cell.getCellId())) {
						myScore += cell.getMass(-1);
					}
				} catch(error:Error) {}
			}
			if (Main.getScoreBox().getScore() < myScore) {
				trace("prev setting score");
				Main.getScoreBox().setScore(myScore);
			}
		}*/
		
		/*public function removeNodes(nodes:Array, filters:Array):void
		{
			var cell:DisplayObject;
			for (var i:Number = 0; i < nodes.length; i++) {
				if (filters == null || filters.indexOf(nodes[i]) == -1) {
					cell = mapholder.map.getChildByName("node_" + nodes[i]);
					trace('2 remove cell ' + "node_" + nodes[i]);
					if (cell != null) {
						trace("3 remove cell " + Cell(cell).getCellId());
						mapholder.map.removeChild(cell);
						if (Main.getGame().isMyNode(nodes[i])) {
							Main.getGame().removeMyNodeId(nodes[i]);
							try {
								var anyMoreParts:Boolean = false;
								for (var b:Number = 0; b < mapholder.map.numChildren; b++) {
									if (Main.getGame().isMyNode(Cell(mapholder.map.getChildAt(b)).getCellId())) {
										anyMoreParts = true;
										break;
									}
								}
								if (!anyMoreParts) {
									Main.getSidebar().showSide();
								}
							} catch (error:Error) {
								trace('err: ' + error.message);
							}
						}
					}
				}
			}
		}*/
		
		public function removeNodes(nodes:Array):void
		{
			var cell:Cell;
			for (var i:Number = 0; i < nodes.length; i++) {
				try {
					cell = Cell(mapholder.map.getChildByName("node_" + nodes[i]));
					mapholder.map.removeChild(cell);
					if (Main.getGame().isMyNode(nodes[i])) {
						Main.getGame().removeMyNodeId(nodes[i]);
						if (Main.getGame().getMyMainNodeId() == nodes[i]) {
							var myNodes:Array = Main.getGame().getAllMyNodesId();
							if (myNodes.length > 0) {
								try {
									var newCell:Cell = Cell(mapholder.map.getChildByName("node_" + myNodes[0]));
									Main.getGame().setMyMainNodeId(newCell.getCellId());
									Main.getGame().setMyNode(newCell);
									setCameraTo(newCell.x, newCell.y, true);
								} catch(error:Error) {
									trace("ASSIGNING NEW MAIN NODE ERROR: " + error.message);
								}
							}
						}
						var isDead:Boolean = true;
						for (var b:Number = 0; b < mapholder.map.numChildren; b++) {
							try {
								if (Main.getGame().isMyNode(Cell(mapholder.map.getChildAt(b)).getCellId())) {
									isDead = false;
									break;
								}
							} catch(error:Error) { }
						}
						if (isDead) {
							Main.getSidebar().showSide();
							Main.getScoreBox().hide();
						}
					}
				} catch (error:Error) {
					trace("REMOVE NODES ERROR: " + error.message);
				}
			}
		}
		
		public function swallowThenRemove(swallowNodes:Array):void
		{
			var killer:Cell;
			var victim:Cell;
			var tl:TimelineLite;
			var destroyQueue:Array;
			for (var i:Number = 0; i < swallowNodes.length; i++) {
				try {
					killer = Cell(mapholder.map.getChildByName("node_" + swallowNodes[i]["killerId"]));
					victim = Cell(mapholder.map.getChildByName("node_" + swallowNodes[i]["victimId"]));
				} catch(error:Error) {
					trace("SWALLOW THEN REMOVE ERROR: " + error.message);
					continue;
				}
				destroyQueue = new Array();
				destroyQueue.push(victim.getCellId());
				if (killer != null && victim != null) {
					tl = new TimelineLite();
					tl.add(TweenLite.to(victim, 1, {x: killer.x, y: killer.y, ease: Regular.easeOut, onComplete: removeNodes, onCompleteParams: [destroyQueue]}));
					tl.add(function() { victim.alpha = 0; }, tl.duration() * 0.1);
				} else if (victim != null) {
					// bug-prevention
					removeNodes(destroyQueue);
				}
			}
		}
		
		/*public function swallow(swallowNodes:Array, victims:Array, deleteAfter:Boolean):void
		{
			var killer:MovieClip;
			var victim:MovieClip;
			var temp:Array;
			for (var i:Number = 0; i < swallowNodes.length; i++) {
				killer = MovieClip(mapholder.map.getChildByName("node_" + swallowNodes[i]["killerId"]));
				victim = MovieClip(mapholder.map.getChildByName("node_" + swallowNodes[i]["victimId"]));
				if (killer == null || victim == null) {
					continue;
				}
				//trace('delete after: ' + deleteAfter);
				if (deleteAfter) {
					temp = new Array();
					temp.push(swallowNodes[i]["victimId"]);
					//TweenLite.to(victim, 1, {x: killer.x, y: killer.y, ease: Regular.easeOut, onComplete: removeNodes, onCompleteParams: [temp, null]});
					var tl = new TimelineLite();
					tl.add(TweenLite.to(victim, 1, {x: killer.x, y: killer.y, ease: Regular.easeOut}));
					tl.add(function() { removeNodes(temp); }, tl.duration() * .1)
				} else {
					TweenLite.to(victim, 1, {x: killer.x, y: killer.y, ease: Regular.easeOut});
				}
			}
		}*/
		
		public function drawMapBorder(color):void
		{
			var stroke_mc:MovieClip = new MovieClip();
			stroke_mc.name = "mapborders_mc";
			stroke_mc.graphics.lineStyle(3, color);
			trace('worlddim ' + "minX: " + worldDim['minX'] + ", minY: " + worldDim['minY'] + ", maxX: " + worldDim['maxX'] + ", maxY: " + worldDim['maxY']);
			stroke_mc.graphics.lineTo(worldDim["maxX"], worldDim["minY"]);
			stroke_mc.graphics.lineTo(worldDim["maxX"], worldDim["maxY"]);
			stroke_mc.graphics.lineTo(worldDim["minX"], worldDim["maxY"]);
			stroke_mc.graphics.lineTo(worldDim["minX"], worldDim["minY"]);
			mapholder.map.addChild(stroke_mc);
			mapholder.map.setChildIndex(stroke_mc, 0);
		}
		
	}
	
}