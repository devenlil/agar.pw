package pw.agar.pwclient
{
	
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.external.ExternalInterface;
		
	import pw.agar.pwclient.Canvas;
	import pw.agar.pwclient.Game;
	import pw.agar.pwclient.Leaderboard;
	import pw.agar.pwclient.sidebar.Sidebar;
	import pw.agar.pwclient.Chat;
	
	public final class Main extends MovieClip
	{
		
		private static var serverHandler:ServerHandler;
		private static var game:Game;
		private static var _canvas:Canvas;
		private static var _leaderboard:Leaderboard;
		private static var _sidebar:Sidebar;
		private static var _chatbox:Chat;
		private static var _scorebox:ScoreBox;
		
		private static var overlaysVisible:Boolean;
		
		private static var hideCellsNames:Boolean;
		private static var hideLeaderboard:Boolean;
		private static var isDarkMode:Boolean;
		private static var showYourMass:Boolean;
		private static var showOthersMass:Boolean;
		private static var showVirusMass:Boolean;
		private static var seeThruCells:Boolean;
		private static var isVisibleChat:Boolean;
		private static var isSound:Boolean;
		private static var isGifs:Boolean;
		
		public function Main()
		{			
			serverHandler = new ServerHandler();
			game = new Game();
			if (ExternalInterface.available) {
				ExternalInterface.call("console.log", "test");
			}
		}
		
		public static function getServerHandler():ServerHandler
		{
			return serverHandler;
		}
		
		public static function getGame():Game
		{
			return game;
		}
		
		public static function getCanvas():Canvas
		{
			return _canvas;
		}
		
		public static function getLeaderboard():Leaderboard
		{
			return _leaderboard;
		}
		
		public static function getSidebar():Sidebar
		{
			return _sidebar;
		}
		
		public static function setCanvas(canvas):void
		{
			_canvas = canvas;
		}
		
		public static function setLeaderboard(leaderboard):void
		{
			_leaderboard = leaderboard;
		}
		
		public static function setSidebar(sidebar):void
		{
			_sidebar = sidebar;
		}
		
		public static function setChatbox(chatbox):void
		{
			_chatbox = chatbox;
		}
		
		public static function getChatbox():Chat
		{
			return _chatbox;
		}
		
		public static function setScoreBox(scorebox):void {
			_scorebox = scorebox;
		}
		
		public static function getScoreBox():ScoreBox {
			return _scorebox;
		}
		
		public static function setOverlaysVisible(overlays):void
		{
			overlaysVisible = overlays;
		}
		
		public static function getOverlaysVisible():Boolean
		{
			return overlaysVisible;
		}
		
		/* Options/Mods */
		
		public static function setHideCellsNames(hideNames):void
		{
			hideCellsNames = hideNames;
		}
		
		public static function getHideCellsNames():Boolean
		{
			return hideCellsNames;
		}
		
		public static function setHideLeaderboard(hideLB):void
		{
			hideLeaderboard = hideLB;
		}
		
		public static function getHideLeaderboard():Boolean
		{
			return hideLeaderboard;
		}
		
		public static function setDarkMode(darkMode):void
		{
			isDarkMode = darkMode;
		}
		
		public static function getDarkMode():Boolean
		{
			return isDarkMode;
		}
		
		public static function setShowYourMass(showMass):void
		{
			showYourMass = showMass;
		}
		
		public static function getShowYourMass():Boolean
		{
			return showYourMass;
		}
		
		public static function setShowOthersMass(showMass):void
		{
			showOthersMass = showMass;
		}
		
		public static function getShowOthersMass():Boolean
		{
			return showOthersMass;
		}
		
		public static function setShowVirusMass(showMass):void
		{
			showVirusMass = showMass;
		}
		
		public static function getShowVirusMass():Boolean
		{
			return showVirusMass;
		}
		
		public static function setSeeThruCells(seeThru):void
		{
			seeThruCells = seeThru;
		}
		
		public static function getSeeThruCells():Boolean
		{
			return seeThruCells;
		}
		
		public static function setIsVisibleChat(isChat):void
		{
			isVisibleChat = isChat;
		}
		
		public static function getIsVisibleChat():Boolean
		{
			return isVisibleChat;
		}
		
		public static function setSound(isSoundEnabled):void
		{
			isSound = isSoundEnabled;
		}
		
		public static function getSound():Boolean
		{
			return isSound;
		}
		
		public static function setGifsState(gifs):void
		{
			isGifs = gifs;
		}
		
		public static function getGifsState():Boolean
		{
			return isGifs;
		}
		
	}
	
}
