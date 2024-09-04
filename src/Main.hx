@:native("")
extern class Shim {
    @:native("c") static var canvas:js.html.CanvasElement;
    @:native("g") static var g:Dynamic;
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
        {
            js.Syntax.code(" for(i in g=c.getContext(`webgl`)) { g[i[0]+i[6]]=g[i]; } "); // From Xem
        }
        inline function createProgram(...args) {
            return Shim.g.cP(args);
        }
        inline function createShader(...args) {
            return Shim.g.cS(args);
        }
        inline function shaderSource(...args) {
            Shim.g.sS(args);
        }
        inline function compileShader(...args) {
            Shim.g.compilerShader(args);
        }
        inline function attachShader(...args) {
            Shim.g.aS(args);
        }
        inline function linkProgram(...args) {
            Shim.g.lo(args);
        }
        inline function useProgram(...args) {
            Shim.g.ug(args);
        }
        inline function fragmentShader() {
            return Shim.g.FN;
        }
        inline function vertexShader() {
            return Shim.g.V_;
        }
        {
            var src = "attribute vec3 aVertexPosition;
            void main(void) {
                gl_Position = vec4(aVertexPosition, 1.0);
            }";
            var vs = createShader(vertexShader());
            shaderSource(vs, src);
            compileShader(vs);
            var src="void main(void){gl_FragColor=vec4(1.0,1.0,1.0,1.0);}";
            var fs = createShader(fragmentShader());
            shaderSource(vs, src);
            compileShader(vs);

            var program = createProgram();
            attachShader(program, vs);
            attachShader(program, fs);
            linkProgram(program);
            useProgram(program);
        }
        function loop(t:Float) {
            trace("yep");
            untyped setTimeout(loop, 1000);
        }
        loop(0);
    }
}
