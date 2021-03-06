/*
 * ND2D - A Flash Molehill GPU accelerated 2D engine
 *
 * Author: Lars Gerckens
 * Copyright (c) nulldesign 2011
 * Repository URL: http://github.com/nulldesign/nd2d
 * Getting started: https://github.com/nulldesign/nd2d/wiki
 *
 *
 * Licence Agreement
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

package de.nulldesign.nd2d.materials {

    import de.nulldesign.nd2d.utils.TextureHelper;

    import flash.display.BitmapData;
    import flash.geom.Point;
    import flash.geom.Rectangle;

    public class SpriteSheet extends ASpriteSheetBase {

        protected var numSheetsPerRow:uint;
        protected var numRows:uint;
        protected var numSheets:uint;
        protected var uvRects:Vector.<Rectangle>;

        public var pixelOffset:Point = new Point(0.0, 0.0);
        public var uvOffset:Point = new Point(0.0, 0.0);
        public var uvSize:Point = new Point(0.0, 0.0);
        private var spritesPackedWithoutSpace:Boolean;

        public function get totalFrames():uint {
            return numSheets;
        }

        /**
         *
         * @param bitmapData
         * @param spriteWidth
         * @param spriteHeight
         * @param fps
         * @param spritesPackedWithoutSpace set to true to get rid of pixel bleeding for packed sprites without spaces: http://www.nulldesign.de/2011/08/30/nd2d-pixel-bleeding/
         */
        public function SpriteSheet(bitmapData:BitmapData, spriteWidth:Number, spriteHeight:Number, fps:uint,
                                    spritesPackedWithoutSpace:Boolean = false) {
            this.bitmapData = bitmapData;
            this._spriteWidth = spriteWidth;
            this._spriteHeight = spriteHeight;
            this.spritesPackedWithoutSpace = spritesPackedWithoutSpace;
            this.fps = fps;

            init();
        }

        private function init():void {

            var textureDimensions:Point = TextureHelper.getTextureDimensionsFromBitmap(bitmapData);

            _textureWidth = textureDimensions.x;
            _textureHeight = textureDimensions.y;

            pixelOffset = new Point((_textureWidth - bitmapData.width) / 2.0, (_textureHeight - bitmapData.height) / 2.0);

            uvOffset.x = pixelOffset.x / _textureWidth;
            uvOffset.y = pixelOffset.y / _textureHeight;

            if(spritesPackedWithoutSpace) {
                uvSize = new Point((spriteWidth - 1.0) / _textureWidth, (spriteHeight - 1.0) / _textureHeight);
            } else {
                uvSize = new Point(spriteWidth / _textureWidth, spriteHeight / _textureHeight);
            }

            numSheetsPerRow = Math.round(bitmapData.width / spriteWidth);
            numRows = Math.round(bitmapData.height / spriteHeight);
            numSheets = numSheetsPerRow * numRows;

            uvRects = new Vector.<Rectangle>(numSheets, true)
        }

        override public function getUVRectForFrame():Rectangle {

            if(uvRects[frame]) {
                return uvRects[frame];
            }

            var rowIdx:uint = frame % numSheetsPerRow;
            var colIdx:uint = Math.floor(frame / numSheetsPerRow);
            var rect:Rectangle;

            if(spritesPackedWithoutSpace) {
                rect = new Rectangle((0.5 + pixelOffset.x + spriteWidth * rowIdx) / textureWidth,
                                     (0.5 + pixelOffset.y + spriteHeight * colIdx) / textureHeight, 1.0, 1.0);
            } else {
                rect = new Rectangle((pixelOffset.x + spriteWidth * rowIdx) / textureWidth,
                                     (pixelOffset.y + spriteHeight * colIdx) / textureHeight, 1.0, 1.0);
            }

            uvRects[frame] = rect;

            return rect;
        }

        override public function clone():ASpriteSheetBase {
            var s:SpriteSheet = new SpriteSheet(bitmapData, _spriteWidth, _spriteHeight, fps, spritesPackedWithoutSpace);
            s.frame = frame;

            for(var name:String in animationMap) {
                var anim:SpriteSheetAnimation = animationMap[name];
                s.addAnimation(name, anim.frames.concat(), anim.loop);
            }

            return s;
        }
    }
}
