package pw.agar.pwclient.sidebar
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import pw.agar.pwclient.Main;
	
	public class Sidebar extends MovieClip
	{
		
		private var name_placeholder:String = "Type name here ";
		private var skin_placeholder:String = "Type skin-id here ";
		
		public function Sidebar()
		{
			Main.setSidebar(this);
			
			// Defaults
			Main.setOverlaysVisible(true);
			Main.setHideCellsNames(false);
			Main.setHideLeaderboard(false);
			Main.setDarkMode(true);
			Main.setShowYourMass(false);
			Main.setShowOthersMass(false);
			Main.setShowVirusMass(false);
			Main.setSeeThruCells(false);
			Main.setIsVisibleChat(true);
			Main.setSound(false);
			Main.setGifsState(true);
		}
		
		public function showSide():void
		{
			if (MovieClip(this.parent).currentFrame != 1) {
				MovieClip(this.parent).play();
			}
			Main.setOverlaysVisible(true);
			
			// Show ads
			if (ExternalInterface.available) {
				ExternalInterface.call("showRevad", "");
			}
		}
		
		public function hideSide():void
		{
			if (MovieClip(this.parent).currentFrame != 6) {
				MovieClip(this.parent).play();
			}
			Main.setOverlaysVisible(false);
			
			// Hide ads
			if (ExternalInterface.available) {
				ExternalInterface.call("hideRevad", "");
			}
		}
		
		/*
		 * Event Listeners were registered directly on the timeline
		 */
		
		protected function onNickBoxFocused(event:FocusEvent):void
		{
			if (nick.text == name_placeholder) {
				nick.text = "";
			}
		}
		
		protected function onNickBoxUnfocused(event:FocusEvent):void
		{
			if (nick.text == "") {
				nick.text = name_placeholder;
			}
		}
		
		protected function onSkinBoxFocused(event:FocusEvent):void
		{
			if (skinid.text == skin_placeholder) {
				skinid.text = "";
			}
		}
		
		protected function onSkinBoxUnfocused(event:FocusEvent):void
		{
			if (skinid.text == "") {
				skinid.text = skin_placeholder;
			}
		}
		
		protected function onPlayButtonPressed(event:MouseEvent):void
		{
			trace('Play');
			
			// initialize
			var buffer:ByteArray = new ByteArray();
			buffer.endian = Endian.LITTLE_ENDIAN;
			var pname:String = "";
			var skin:String = "";
			
			if (nick.text != name_placeholder) {
				pname = nick.text;
			}
			if (skinid.text != skin_placeholder) {
				skin = skinid.text;
			}
			if (nick.text == name_placeholder && skinid.text != skin_placeholder) {
				pname = skinid.text;
			}
			
			buffer.writeByte(0); // packet id
			// Name
			for (var i:Number = 0; i < pname.length; i++) {
				buffer.writeShort(pname.charCodeAt(i));
			}
			buffer.writeShort(0); // null-terminator
			// Skin Id
			for (i = 0; i < skin.length; i++) {
				buffer.writeShort(skin.charCodeAt(i));
			}
			buffer.writeShort(0); // null-terminator
			
			
			if (Main.getServerHandler().sendBytes(buffer)) { // send bytes
				hideSide();
			}
		}
		
		protected function onSpectateButtonPressed(event:MouseEvent):void
		{
			trace('Spectate');
			
			// initialize
			var buffer:ByteArray = new ByteArray();
			buffer.endian = Endian.LITTLE_ENDIAN;
			
			buffer.writeByte(1); // packet id
			
			if (Main.getServerHandler().sendBytes(buffer)) { // send bytes
				hideSide();
			}
		}
		
		/* Options/Mods */
		
		protected function onHideOthersNameToggled(event:MouseEvent):void
		{
			Main.setHideCellsNames(hideothersname_chk.checkbox.toggle());
		}
		
		protected function onHideLeaderboardToggled(event:MouseEvent):void
		{
			Main.setHideLeaderboard(hideleaderboard_chk.checkbox.toggle());
		}
		
		protected function onDarkModeToggled(event:MouseEvent):void
		{
			var mapborders_mc:MovieClip = Main.getCanvas().mapholder.map.getChildByName("mapborders_mc");
			if (darkmode_chk.checkbox.toggle()) {
				// dark theme
				Main.setDarkMode(true);
				Main.getCanvas().gameback.gotoAndStop("dark");
				Main.getCanvas().grid.gotoAndStop("dark");
				
				// update map borders				
				if (mapborders_mc != null) {
					Main.getCanvas().mapholder.map.removeChild(mapborders_mc);
					Main.getCanvas().drawMapBorder(0xffffff);
				}
				
				// update chatbox
				if (Main.getIsVisibleChat()) {
					Main.getChatbox().setLightMode(true);
				}
			} else {
				// light theme
				Main.setDarkMode(false);
				Main.getCanvas().gameback.gotoAndStop("light");
				Main.getCanvas().grid.gotoAndStop("light");
				
				// update map borders
				if (mapborders_mc != null) {
					Main.getCanvas().mapholder.map.removeChild(mapborders_mc);
					Main.getCanvas().drawMapBorder(0x000000);
				}
				
				// update chatbox
				if (Main.getIsVisibleChat()) {
					Main.getChatbox().setLightMode(false);
				}
			}
		}
		
		protected function onShowYourMassToggled(event:MouseEvent):void
		{
			Main.setShowYourMass(showyourmass_chk.checkbox.toggle());
		}
		
		protected function onShowOthersMassToggled(event:MouseEvent):void
		{
			Main.setShowOthersMass(showothersmass_chk.checkbox.toggle());
		}
		
		protected function onShowVirusMassToggled(event:MouseEvent):void
		{
			Main.setShowVirusMass(showvirusmass_chk.checkbox.toggle());
		}
		
		protected function onSeeThruCellsToggled(event:MouseEvent):void
		{
			Main.setSeeThruCells(seethrucells_chk.checkbox.toggle());
		}
		
		protected function onShowMapBordersToggled(event:MouseEvent):void
		{
			var canvas:MovieClip = Main.getCanvas();
			if (mapborders_chk.checkbox.toggle()) {
				if (Main.getDarkMode()) {
					Main.getCanvas().drawMapBorder(0xffffff);
				} else {
					Main.getCanvas().drawMapBorder(0x000000);
				}
			} else {
				var mapborders_mc:DisplayObject = canvas.mapholder.map.getChildByName("mapborders_mc");
				if (mapborders_mc != null) {
					canvas.mapholder.map.removeChild(mapborders_mc);
				}
			}
		}
		
		protected function onShowChatToggled(event:MouseEvent):void
		{
			/*Main.setIsVisibleChat(true);
			if (chatbox_chk.checkbox.toggle()) {
				if (Main.getDarkMode()) {
					Main.getChatbox().setLightMode(true);
				} else {
					Main.getChatbox().setLightMode(false);
				}
			} else {
				Main.getChatbox().hide();
			}*/
			// Pass to js
			if (chatbox_chk.checkbox.toggle()) {
				Main.getServerHandler().executeJavascriptFunction("showChat()");
			} else {
				Main.getServerHandler().executeJavascriptFunction("hideChat()");
			}
		}
		
		protected function onSoundEffectsToggled(event:MouseEvent):void
		{
			if (soundeffects_chk.checkbox.toggle()) {
				Main.setSound(true);
			} else {
				Main.setSound(false);
			}
		}
		
		protected function onDisableGifsToggled(event:MouseEvent):void
		{
			if (disablegifs_chk.checkbox.toggle()) {
				Main.setGifsState(false);
			} else {
				Main.setGifsState(true);
			}
		}
		
		public function hideAlert():void
		{
			serveralert_mc.visible = false;
		}
		
		public function showAlert():void
		{
			serveralert_mc.visible = true;
		}
		
	}
	
}