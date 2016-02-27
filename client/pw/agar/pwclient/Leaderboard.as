package pw.agar.pwclient
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	
	import pw.agar.pwclient.Main;
	
	public class Leaderboard extends MovieClip
	{
		
		public function Leaderboard()
		{
			Main.setLeaderboard(this);
		}
		
		public function updateLeaderboardFFA(numNodes, topNodes):void
		{
			var i:Number;
			if (Main.getHideLeaderboard()) {
				this.gotoAndStop("0_lb");
				return;
			}
			if (numNodes < 0) { // invalid top player amount
				return;
			} else if (numNodes != topNodes.length) { // invalid request
				return;
			}
			
			var myPlayerLB:Object = null;
			
			if (numNodes > 10) {
				this.gotoAndStop("10_lb");
				for (i = 0; i < topNodes.length; i++) {
					if (Main.getGame().isMyNode(topNodes[i]["nodeId"])) {
						if (i + 1 > 10) {
							this.gotoAndStop("11_lb");
							myPlayerLB = {"nodeId": topNodes[i]["nodeId"], "nodeName": topNodes[i]["nodeName"]};
						}
						break;
					}
				}
			} else {
				this.gotoAndStop(numNodes + "_lb"); // set leaderboard size
			}
			
			for (i = 0; i < ((topNodes.length > 10) ? 10 : topNodes.length); i++) {
				// TODO sort by score size
				var nodename:String = topNodes[i]["nodeName"];
				if (nodename == "") {
					nodename = "Unnamed Cell";
				} else if (Main.getHideCellsNames() && Main.getGame().getMyMainNodeId() != topNodes[i]["nodeId"]) {
					nodename = "P" + topNodes[i]["nodeId"];
				}

				TextField(this.getChildByName("lbplayer_" + (i + 1))).text = (i + 1) + ". " + nodename;
				if (Main.getGame().isMyNode(topNodes[i]["nodeId"])) {
					TextField(this.getChildByName("lbplayer_" + (i + 1))).textColor = 0xFFBB55;
				} else {
					TextField(this.getChildByName("lbplayer_" + (i + 1))).textColor = 0xFFFFFF;
				}
			}
			
			if (myPlayerLB != null)
				TextField(this.getChildByName("lbplayer_me")).text = (i + 1) + ". " + ((myPlayerLB["nodeName"] == "") ? "Unnamed Cell" : myPlayerLB["nodeName"]);
		}
		
	}
	
}