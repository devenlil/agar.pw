package pw.agar.pwclient
{
	import flash.display.MovieClip;
	
	public class ScoreBox extends MovieClip
	{
		
		public function ScoreBox() {
			this.visible = false;
			Main.setScoreBox(this);
		}
		
		public function hide():void {
			this.visible = false;
		}
		
		public function show():void {
			this.visible = true;
		}
		
		public function setScore(score:Number) {
			if (this.visible == false) {
				this.visible = true;
			}
			this.score_txt.text = "" + score;
		}
		
		public function getScore():Number {
			return parseInt(this.score_txt.text);
		}
		
	}
	
}