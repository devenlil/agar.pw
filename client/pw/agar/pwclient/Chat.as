package pw.agar.pwclient
{
	import flash.display.MovieClip;
	import flash.events.FocusEvent;
	
	public class Chat extends MovieClip /* Flash Chat - Never used */
	{
		
		private var chat_placeholder:String = "Type your message here ";
		
		public function Chat()
		{
			Main.setChatbox(this);
		}
		
		public function hide():void
		{
			this.gotoAndStop('hidden');
		}
		
		public function setLightMode(lightMode:Boolean):void
		{
			if (lightMode) {
				this.gotoAndStop('white');
			} else {
				this.gotoAndStop('black');
			}
		}
		
		/* Event Handlers */
		
		protected function onChatInputFocused(event:FocusEvent):void
		{
			if (chatinput.text == chat_placeholder) {
				chatinput.text = "";
			}
		}
		
		protected function onChatInputUnfocused(event:FocusEvent):void
		{
			if (chatinput.text == "") {
				chatinput.text = chat_placeholder;
			}
		}
		
	}
	
}