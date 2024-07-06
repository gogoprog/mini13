@:native("")
extern class Shim {
    @:native("a") static var canvas:js.html.CanvasElement;
    @:native("c") static var context:js.html.CanvasRenderingContext2D;
}

abstract Point(Array<Float>) from Array<Float> to Array<Float> {
    public var x(get, set):Float;
    inline function get_x() return this[0];
    inline function set_x(value) return this[0] = value;
    public var y(get, set):Float;
    inline function get_y() return this[1];
    inline function set_y(value) return this[1] = value;
}

class Main {
    static function main() {
        var screenSize = 512;
        var halfSize:Int = cast screenSize/ 2;
        Shim.canvas.width = Shim.canvas.height = screenSize;
        var randomSeed = 0;
        var time:Int = 0;
        var walls:Array<Dynamic> = [];
        var camPos:Point = [screenSize, screenSize];
        var camAngle:Float = 0;
        /* var keys:Dynamic = {}; */
        var mx:Int = 0;
        var mmove:Int = 0;
        var textureCanvas:js.html.CanvasElement;
        function loop(t:Float) {
            untyped setTimeout(loop, 10);
        }
        loop(0);
    }
}
