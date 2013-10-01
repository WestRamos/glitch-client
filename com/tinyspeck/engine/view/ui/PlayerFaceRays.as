package com.tinyspeck.engine.view.ui 
{
	import com.tinyspeck.core.beacon.StageBeacon;
	import com.tinyspeck.engine.port.AssetManager;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * This uses a small spritesheeted version of the sun rays
	 * (player_face_rays.png) as exported by Flash CS6 from
	 * level_up_rays.fla, scene smallThinFast.
	 * 
	 * Since while these rays are shown they are constantly changing, they cause
	 * a redraw and rasterization hit every single frame they were visible. The
	 * spritesheeted version is much simple.
	 * 
	 * In order to save memory, an optimized PNG sheet was pre-generated by
	 * Flash rather than creating it at runtime using e.g. AnimatedBitmap and
	 * BitmapAtlasGenerator, which have a lot of other overhead.
	 */
	public class PlayerFaceRays extends Bitmap
	{
		/** Native Framerate of the asset */
		private static const NATIVE_FRAMERATE:int = 24;
		private static const MS_PER_NATIVE_FRAME:Number = (1000 / NATIVE_FRAMERATE);
		
		/** How often we try to render it, which is <= the NATIVE_FRAMERATE */
		private static const TICK_FRAMERATE:int = 24;
		private static const MS_PER_TICK:int = (1000 / TICK_FRAMERATE);
		
		private static const FRAMES_PER_ROW:int = 9;
		private static const CELL_W:int = 109;
		private static const CELL_H:int = 109;
		private static const FRAMES:int = 89;
		
		private static const ORIGIN:Point = new Point();
		private static const RECT:Rectangle = new Rectangle(0, 0, CELL_W, CELL_H);
		
		private var spritesheet:BitmapData;
		private var frame:int;
		private var playing:Boolean;
		private var ms_since_last_tick:int = 0;
		
		public function PlayerFaceRays() {
			super(new BitmapData(CELL_W, CELL_H, true, 0));
			spritesheet = (new AssetManager.instance.assets.player_face_rays() as Bitmap).bitmapData;
		}
		
		override public function set visible(value:Boolean):void {
			super.visible = value;
			
			if (visible) {
				play();
			} else {
				stop();
			}
		}
		
		public function play():void {
			if (!playing) {
				playing = true;
				StageBeacon.enter_frame_sig.add(onEnterFrame);
			}
		}
		
		public function stop():void {
			if (playing) {
				playing = false;
				StageBeacon.enter_frame_sig.remove(onEnterFrame);
			}
		}
		
		private function onEnterFrame(ms_elapsed:int):void {
			ms_since_last_tick += ms_elapsed;
			if (ms_since_last_tick < MS_PER_TICK) {
				return;
			}
			tick(ms_since_last_tick);
			ms_since_last_tick = 0;
		}
		
		private function tick(ms_elapsed:int):void {
			frame += int((ms_elapsed / MS_PER_NATIVE_FRAME) + 0.5);
			frame %= FRAMES;

			RECT.x = CELL_W * (frame % FRAMES_PER_ROW);
			RECT.y = CELL_H * int(frame / FRAMES_PER_ROW);
			
			bitmapData.copyPixels(spritesheet, RECT, ORIGIN);
		}
	}
}