package pw.agar.pwclient.sidebar
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	import pw.agar.pwclient.sidebar.CheckType;
	
	public class CheckBox extends MovieClip
	{
		
		private var checked_state:String;
		
		public function CheckBox()
		{
			setCheckType(CheckType.CHECKMARK);
			this.buttonMode = true;
			//this.addEventListener(MouseEvent.CLICK, onMouseMove); event handler added in sidebar
		}
		
		public function check():void
		{
			if (this.currentFrameLabel == "unchecked") {
				this.gotoAndStop(checked_state);
			}
		}
		
		public function uncheck():void
		{
			if (this.currentFrameLabel != "unchecked") {
				this.gotoAndStop("unchecked");
			}
		}
		
		public function toggle():Boolean
		{
			var res:Boolean;
			switch (this.currentFrameLabel) {
				case "unchecked":
					check();
					res = true;
					break;
				case checked_state:
					uncheck();
					res = false;
					break;
			}
			return res;
		}
		
		public function setCheckType(checkType:int):void
		{
			switch (checkType) {
				case 1:
					checked_state = "checked";
					break;
				case 2:
					checked_state = "checked_x";
					break;
			}
		}
		
		public function isChecked():Boolean
		{
			switch (this.currentFrameLabel) {
				case "unchecked":
					return false;
					break;
				default:
					return true;
					break;
			}
		}
		
	}
	
}