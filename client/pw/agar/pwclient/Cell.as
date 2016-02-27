package pw.agar.pwclient
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.filters.GlowFilter;
	import flash.filters.BitmapFilterQuality;
	import flash.geom.ColorTransform;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.system.Security;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import fl.transitions.easing.Strong;
	
	import com.greensock.TweenLite;
	
	import com.worlize.gif.events.GIFPlayerEvent;
	import com.worlize.gif.GIFPlayer;
	
	public class Cell extends MovieClip
	{
		
		private var cellId:Number;
		private var cellName:String;
		private var cellColor:String;
		private var isVirus:Boolean;
		
		private var showMass:Boolean = false;
		private var seeThru:Boolean = false;
		private var hideName:Boolean = false;
		
		public function Cell(cellId:Number, cellName:String, cellSkin:String, isVirus:Boolean)
		{
			this.cellId = cellId;
			this.cellColor = '#fff';
			pname.autoSize = TextFieldAutoSize.CENTER;
			setName(cellName);
			if (cellSkin.length > 0) {
				setSkin(cellSkin);
			}
			this.isVirus = isVirus;
			if (isVirus) {
				cellborder.gotoAndStop("virus");
			}
		}
		
		public function isVirusCell():Boolean
		{
			return isVirus;
		}
		
		public function setName(cellName:String):void
		{
			this.cellName = cellName;
			if (!hideName) {
				showName(cellName);
			}
		}
		
		public function showName(displayName:String):void
		{
			pname.text = displayName;
			AutoSize(pname);
		}
		
		public function getName():String
		{
			return cellName;
		}
		
		public function getCellId():Number
		{
			return cellId;
		}
		
		public function setSkin(skinURL:String):void
		{
			Security.allowDomain("*");
			var urlVariables:URLVariables = new URLVariables(skinURL.split('?')[1]);
			var urlRequest:URLRequest = new URLRequest(skinURL);
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
			urlLoader.addEventListener(Event.COMPLETE, onSkinLoaded);
			urlLoader.load(urlRequest);
			
			function onSkinLoaded(event:Event):void {
				if (Main.getGifsState() && urlVariables.gifPlayer == "1") {
					var gifPlayer:GIFPlayer = new GIFPlayer();
					gifPlayer.addEventListener(GIFPlayerEvent.COMPLETE, onPlayerReady);
					gifPlayer.loadBytes(event.target.data);
					
					function onPlayerReady() {
						skin.addChild(gifPlayer);
						skin.width = cellborder.width;
						skin.height = cellborder.height;
						gifPlayer.scaleX = 500 / gifPlayer.width;
						gifPlayer.scaleY = 500 / gifPlayer.height;
					}
				} else {
					var loader:Loader = new Loader();
					loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderComplete);
					loader.loadBytes(event.target.data);
					
					function onLoaderComplete(event:Event) {
						var image:Bitmap = new Bitmap(event.target.content.bitmapData);
						skin.addChild(image);
						skin.width = cellborder.width;
						skin.height = cellborder.height;
					}
				}
			}
		}
		
		public function setColor(red:Number, green:Number, blue:Number, stroke:Boolean):void
		{
			var colorTransform:ColorTransform = new ColorTransform();
			
			this.cellColor = getColorSixHexx(red, green, blue);
			colorTransform.color = getColorHex(red, green, blue);
			cellbody.transform.colorTransform = colorTransform;
			
			if (stroke) {
				colorTransform.color = getColorHex((red - 20), (green - 20), (blue - 20));
			}
			cellborder.transform.colorTransform = colorTransform;
		}
		
		public function getColor():String
		{
			return this.cellColor;
		}
		
		private function getColorSixHexx(red:Number, green:Number, blue:Number):String
		{
			var intVal:int = red << 16 | green << 8 | blue;
			var hexVal:String = intVal.toString(16);
			hexVal = "#" + (hexVal.length < 6 ? "0" + hexVal : hexVal);
			return hexVal;
		}
		
		private function getColorHex(red:Number, green:Number, blue:Number):Number
		{
			var RGB:Number;
			if(red>255){red=255;}
			if(green>255){green=255;}
			if(blue>255){blue=255;}
 			
			if(red<0){red=0;}
			if(green<0){green=0;}
			if(blue<0){blue=0;}
 			
			RGB=(red<<16) | (green<<8) | blue;
 
			return RGB;
		}
		
		public function setRadius(radius:Number, animate:Boolean)
		{
			var mass = getMass(radius);
			var newWidth:Number = radius * 2.2;
			var newHeight:Number = radius * 2.2;
			
			if (animate) {
				TweenLite.to(this, 1, {width: newWidth, height: newHeight});
			} else {
				this.width = newWidth;
				this.height = newHeight;
			}
			
			if (showMass && mass >= 9) {
				mass_label.text = "" + mass;
			} else if (mass_label.text != "") {
				mass_label.text = "";
			}
			
			if (mass < 9) {
				if (cellborder.currentFrameLabel != "food") {
					cellborder.gotoAndStop("food");
					//cellborder.pentagon.rotation = Math.floor(Math.random() * (90 - 0 + 1)) + 0;
				}
			}
		}
		
		public function getRadius():Number
		{
			return this.height / 2.2;
		}
		
		public function getMass(radius:Number):Number
		{
			if (radius < 0) {
				radius = getRadius();
			}
			return Math.floor((radius * radius) / 100);
		}
		
		public function setShowMass(showMass:Boolean):void
		{
			this.showMass = showMass;
		}
		
		public function setSeeThru(seeThru:Boolean):void
		{
			this.seeThru = seeThru;
			if (seeThru && getMass(-1) >= 9) {
				this.alpha = 0.9;
			} else {
				this.alpha = 1;
			}
		}
		
		public function setHideName(hideName:Boolean):void
		{
			this.hideName = hideName;
			if (hideName && getMass(-1) >= 9 && !Main.getHideLeaderboard()) {
				showName("P" + cellId);
			} else if (!hideName) {
				showName(cellName);
			} else {
				showName("");
			}
		}
		
		function AutoSize(txt:TextField):void 
		{
			//You set this according to your TextField's dimensions
			var maxTextWidth:int = 100; 
			var maxTextHeight:int = 30; 
			
			var f:TextFormat = txt.getTextFormat();
			
			//decrease font size until the text fits  
			while (txt.textWidth > maxTextWidth || txt.textHeight > maxTextHeight) {
				f.size = int(f.size) - 1;
				txt.setTextFormat(f);
			}
 
		}
		
	}
	
}