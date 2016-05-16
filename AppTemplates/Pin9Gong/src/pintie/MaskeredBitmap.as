/**
 * Created by rhett on 15/4/4.
 */
package pintie
{

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.display.Sprite;

public class MaskeredBitmap extends Sprite
{
    private var bmp:Bitmap;

    public function MaskeredBitmap( maskerW:int, maskerH:int )
    {
        var thumbMask:Shape = new Shape();
        thumbMask.graphics.beginFill( 0 );
        thumbMask.graphics.drawRect( 0, 0, maskerW, maskerH );
        thumbMask.graphics.endFill();
        bmp = new Bitmap();
        bmp.mask = thumbMask;
        addChild( bmp );
        addChild( thumbMask );
    }

    public function set bitmapData( bitmapData:BitmapData ):void {bmp.bitmapData = bitmapData;}

    public function set bScaleX( bScaleX:Number ):void {bmp.scaleX = bScaleX;}

    public function get bScaleX():Number { return bmp.scaleX;		}
    public function get bScaleY():Number { return bmp.scaleY;		}

    public function set bScaleY( bScaleY:Number ):void {bmp.scaleY = bScaleY;}
}
}
