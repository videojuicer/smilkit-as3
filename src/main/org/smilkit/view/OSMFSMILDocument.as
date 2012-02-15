package org.smilkit.view
{
	import org.osmf.media.MediaPlayer;
	import org.smilkit.dom.smil.SMILDocument;
	import org.smilkit.dom.smil.Time;
	import org.smilkit.w3c.dom.IDocumentType;
	
	public class OSMFSMILDocument extends SMILDocument
	{
		private var _mediaPlayer:MediaPlayer = null;
		
		public function OSMFSMILDocument(mediaPlayer:MediaPlayer)
		{
			super(null);
			
			this._mediaPlayer = mediaPlayer;
		}
		
		public override function get offset():Number
		{
			return this._mediaPlayer.currentTime;
		}
		
		public override function get duration():Number
		{
			var dur:Number = this._mediaPlayer.duration;
			
			if (dur == 0)
			{
				if (this._mediaPlayer.canSeek)
				{
					return Time.UNRESOLVED;
				}
				else
				{
					return Time.INDEFINITE;
				}
			}
			
			return (dur * 1000);
		}
	}
}