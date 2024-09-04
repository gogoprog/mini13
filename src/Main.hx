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
        js.Syntax.code(" for(i in g=c.getContext(`webgl2`)) { g[i[0]+i[6]]=g[i]; } "); // From Xem
        inline function createProgram() {
            return Shim.g.cP();
        }
        inline function createShader(a) {
            return Shim.g.cS(a);
        }
        inline function shaderSource(a, b) {
            Shim.g.sS(a, b);
        }
        inline function compileShader(a) {
            Shim.g.compileShader(a);
#if dev

            if(!Shim.g.getShaderParameter(a, Shim.g.COMPILE_STATUS)) {
                // trace("An error occurred compiling the shaders: " + Shim.g.getShaderInfoLog(a));
                trace("An error occurred compiling the shaders: ");
                trace(Shim.g.getShaderInfoLog(a));
            }

#end
        }
        inline function attachShader(a, b) {
            Shim.g.aS(a, b);
        }
        inline function linkProgram(a) {
            Shim.g.lo(a);
#if dev

            if(!Shim.g.getProgramParameter(a, Shim.g.LINK_STATUS)) {
                // trace("An error occurred compiling the shaders: " + Shim.g.getShaderInfoLog(a));
                trace("An error occurred linking the program: ");
                trace(Shim.g.getProgramInfoLog(a));
            }

#end
        }
        inline function useProgram(a) {
            Shim.g.ug(a);
        }
        inline function fragmentShader() {
            return Shim.g.FRAGMENT_SHADER;
        }
        inline function vertexShader() {
            return Shim.g.VERTEX_SHADER;
        }
        inline function draw(count) {
            Shim.g.dr(Shim.g.TRIANGLES, 0, count);
        }
        var program;
        {
            var src = Macros.getFileContent("src/fs.glsl");
            var vs = createShader(vertexShader());
            shaderSource(vs, src);
            compileShader(vs);
            var src = Macros.getFileContent("src/vs.glsl");
            var fs = createShader(fragmentShader());
            shaderSource(fs, src);
            compileShader(fs);
            program = createProgram();
            attachShader(program, vs);
            attachShader(program, fs);
            linkProgram(program);
            useProgram(program);
        }
        function loop(t:Float) {
            trace("yep");
            draw(60);
            untyped setTimeout(loop, 1000);
        }
        loop(0);
    }
}
