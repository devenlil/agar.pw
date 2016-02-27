package pw.agar.pwclient
{
		
	public class Game
	{
		
		private var myMainNodeId:Number;
		private var myNodesId:Array;
		private var myNode:Cell;
		private var worldWidth:Number;
		private var worldHeight:Number;
		
		public function Game()
		{
			myMainNodeId = 0;
			myNodesId = new Array();
		}
		
		public function setMyMainNodeId(nodeId):void
		{
			myMainNodeId = nodeId;
		}
		
		public function getMyMainNodeId():Number
		{
			return myMainNodeId;
		}
		
		public function addMyNodeId(nodeId):void
		{
			if (myNodesId.indexOf(nodeId) < 0) {
				myNodesId.push(nodeId);
			}
		}
		
		public function removeMyNodeId(nodeId):void
		{
			for (var i:Number = 0; i < myNodesId.length; i++) {
				if (myNodesId[i] == nodeId) {
					myNodesId.splice(i, 1);
					break;
				}
			}
		}
		
		public function isMyNode(nodeId):Boolean
		{
			if (myNodesId.indexOf(nodeId) > -1) {
				return true;
			}
			return false;
		}
		
		public function getAllMyNodesId():Array
		{
			return myNodesId;
		}
		
		public function setMyNode(cell:Cell):void
		{
			myNode = cell;
		}
		
		public function getMyNode():Cell
		{
			return myNode;
		}
		
		public function isMyNodeIdSpecified():Boolean
		{
			if (myMainNodeId != 0) {
				return true;
			}
			return false;
		}
		
		public function setWorldSize(wWidth:Number, wHeight:Number):void
		{
			worldWidth = wWidth;
			worldHeight = wHeight;
		}
		
		public function getWorldSize():Object
		{
			var worldSizeData:Object = { width: worldWidth, height: worldHeight };
			return worldSizeData;
		}
		
		public function reset():void
		{
			myMainNodeId = 0;
			myNodesId = new Array();
			myNode = undefined;
			worldWidth = undefined;
			worldHeight = undefined;
		}
		
	}
	
}