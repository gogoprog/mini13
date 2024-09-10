@:native("")
extern class Shim {
    @:native("c") static var canvas:js.html.CanvasElement;
    @:native("g") static var g:Dynamic;
}

class Main {
    static function main() {
        Shim.canvas.width = js.Browser.window.innerWidth;
        Shim.canvas.height = js.Browser.window.innerHeight;
        var randomSeed = 0;
        var time:Int = 0;
        var keys:Dynamic = {};
        var mouseMove = [0, 0];
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
        Shim.canvas.onclick = e -> Shim.canvas.requestPointerLock();
        Shim.canvas.onmousemove = function(e) {
            mouseMove[0] += e.movementX;
            mouseMove[1] += e.movementY;
        }
        untyped onkeydown = onkeyup = function(e) {
            keys[e.key] = e.type[3] == 'd';
        }
        // Shim.canvas.oncontextmenu = e->false;
        inline function getKey(str:String) {
            return untyped keys[str];
        }
        var program;
        var src = Macros.getFileContent("src/vs.glsl");
        var vs = createShader(vertexShader());
        shaderSource(vs, src);
        compileShader(vs);
        var src = Macros.getFileContent("src/fs.glsl");
        var fs = createShader(fragmentShader());
        shaderSource(fs, src);
        compileShader(fs);
        program = createProgram();
        attachShader(program, vs);
        attachShader(program, fs);
        linkProgram(program);
        useProgram(program);
        Shim.g.enable(Shim.g.DEPTH_TEST);
        Shim.g.disable(Shim.g.CULL_FACE);
        var timeUniformLocation = Shim.g.getUniformLocation(program, "uTime");
        var dataLoc = Shim.g.getUniformLocation(program, "uData");
        var data = new js.lib.Float32Array(16 * 3);

        for(i in 0...16) {
            data[i * 3 + 0] = Std.int(Math.random() * 20) - 10;
            data[i * 3 + 1] = Std.int(Math.random() * 2);
            data[i * 3 + 2] = Std.int(Math.random() * 2);
        }

        Shim.g.uniform3fv(dataLoc, data);
        var cameraPosition = [0.0, 1, 5];
        var cameraYaw = 0.0;
        var cameraPitch = 0.0;
        var cameraPositionUniformLocation = Shim.g.getUniformLocation(program, "uCameraPosition");
        var cameraYawUniformLocation = Shim.g.getUniformLocation(program, "uCameraYaw");
        var cameraPitchUniformLocation = Shim.g.getUniformLocation(program, "uCameraPitch");
        function loop(t:Float) {
            Shim.g.clear(Shim.g.COLOR_BUFFER_BIT | Shim.g.DEPTH_BUFFER_BIT);
            Shim.g.uniform1f(timeUniformLocation, t);
            var moveSpeed = 0.4;
            var rotateSpeed = 0.05;

            // Handle movement
            if(getKey("w")) {
                cameraPosition[0] += Math.sin(cameraYaw) * moveSpeed;
                cameraPosition[2] -= Math.cos(cameraYaw) * moveSpeed;
            }

            if(getKey("s")) {
                cameraPosition[0] -= Math.sin(cameraYaw) * moveSpeed;
                cameraPosition[2] += Math.cos(cameraYaw) * moveSpeed;
            }

            if(getKey("a")) {
                cameraPosition[0] -= Math.cos(cameraYaw) * moveSpeed;
                cameraPosition[2] -= Math.sin(cameraYaw) * moveSpeed;
            }

            if(getKey("d")) {
                cameraPosition[0] += Math.cos(cameraYaw) * moveSpeed;
                cameraPosition[2] += Math.sin(cameraYaw) * moveSpeed;
            }

            // Handle rotation
            if(getKey("ArrowLeft")) { cameraYaw -= rotateSpeed; }

            if(getKey("ArrowRight")) { cameraYaw += rotateSpeed; }

            if(getKey("ArrowUp")) { cameraPitch = Math.max(cameraPitch - rotateSpeed, -Math.PI / 2); }

            if(getKey("ArrowDown")) { cameraPitch = Math.min(cameraPitch + rotateSpeed, Math.PI / 2); }

            Shim.g.uniform3f(cameraPositionUniformLocation, cameraPosition[0], cameraPosition[1], cameraPosition[2]);
            Shim.g.uniform1f(cameraYawUniformLocation, cameraYaw);
            Shim.g.uniform1f(cameraPitchUniformLocation, cameraPitch);
            draw(16 * 36);

            mouseMove[0] = mouseMove[1] = 0;
            js.Browser.window.requestAnimationFrame(loop);
        }
        js.Browser.window.requestAnimationFrame(loop);
    }
}
