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
        js.Syntax.code(" for(i in g=c.getContext(`webgl2`)) { g[i[0]+i[6]]=g[i]; } ");
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
        var numCubes = 4096 * 4;
        var data = new js.lib.Uint32Array(numCubes);
        var dataLen = 0;
        inline function addCube(x:Int, y:Int, z:Int) {
            trace('adding cube for $x, $z');
            data[dataLen] = x | (y << 8) | (z << 16);
            ++dataLen;
        }
        var size = 100;

        for(x in 0...size) {
            for(z in 0...size) {
                addCube(x, 0, z);
                var h = Std.int(Math.random() * 3);

                for(y in 1...h) {
                    addCube(x, y, z);
                }
            }
        }

        var ubo = Shim.g.createBuffer();
        Shim.g.bindBuffer(Shim.g.UNIFORM_BUFFER, ubo);
        Shim.g.bufferData(Shim.g.UNIFORM_BUFFER, data, Shim.g.STATIC_DRAW);
        Shim.g.bindBuffer(Shim.g.UNIFORM_BUFFER, null);
        var uboIndex = Shim.g.getUniformBlockIndex(program, "CubeData");
        Shim.g.uniformBlockBinding(program, uboIndex, 0);
        Shim.g.bindBufferBase(Shim.g.UNIFORM_BUFFER, 0, ubo);
        var cameraPosition = [0.0, 1, 5];
        var cameraYaw = 0.0;
        var cameraPitch = 0.0;
        var cameraPositionUniformLocation = Shim.g.getUniformLocation(program, "uCameraPosition");
        var cameraYawUniformLocation = Shim.g.getUniformLocation(program, "uCameraYaw");
        var cameraPitchUniformLocation = Shim.g.getUniformLocation(program, "uCameraPitch");
        var playerPosition = [size/2, 10.0, size/2];
        var playerVelocity = [0.0, 0.0, 0.0];
        var gravity = -9.8;
        var jumpVelocity = 5.0;
        var isOnGround = false;
        function checkCollision(x:Float, y:Float, z:Float):Bool {
            var ix = Math.floor(x);
            var iy = Math.floor(y);
            var iz = Math.floor(z);

            for(dx in -1...2) {
                for(dy in -1...2) {
                    for(dz in -1...2) {
                        var cx = ix + dx;
                        var cy = iy + dy;
                        var cz = iz + dz;

                        if(cy >= 0 && cy < size * 2) {
                            for(i in 0...dataLen) {
                                var cubeData = data[i];
                                var cubeX = cubeData & 0xFF;
                                var cubeY = (cubeData >> 8) & 0xFF;
                                var cubeZ = (cubeData >> 16) & 0xFF;

                                if(cubeX == cx && cubeY == cy && cubeZ == cz) {
                                    return true;
                                }
                            }
                        }
                    }
                }
            }

            return false;
        }
        function loop(t:Float) {
            Shim.g.clear(Shim.g.COLOR_BUFFER_BIT | Shim.g.DEPTH_BUFFER_BIT);
            Shim.g.uniform1f(timeUniformLocation, t);
            var moveSpeed = 0.4;
            var mouseSensitivity = 0.002;
            // Update camera yaw and pitch based on mouse movement
            cameraYaw -= mouseMove[0] * mouseSensitivity;
            cameraPitch += mouseMove[1] * mouseSensitivity;
            cameraPitch = Math.max(Math.min(cameraPitch, Math.PI / 2), -Math.PI / 2);
            var dirX = Math.cos(cameraPitch) * Math.sin(cameraYaw);
            var dirY = Math.sin(cameraPitch);
            var dirZ = Math.cos(cameraPitch) * Math.cos(cameraYaw);
            var rightX = Math.cos(cameraYaw);
            var rightZ = -Math.sin(cameraYaw);
            var deltaTime = 1 / 60; // Assuming 60 FPS
            // Apply gravity
            playerVelocity[1] += gravity * deltaTime;

            // Handle jump
            if(isOnGround && getKey(" ")) {
                playerVelocity[1] = jumpVelocity;
                isOnGround = false;
            }

            // Update player position
            var newX = playerPosition[0] + playerVelocity[0] * deltaTime;
            var newY = playerPosition[1] + playerVelocity[1] * deltaTime;
            var newZ = playerPosition[2] + playerVelocity[2] * deltaTime;

            // Check for collisions and update position
            if(!checkCollision(newX, playerPosition[1], playerPosition[2])) {
                playerPosition[0] = newX;
            } else {
                playerVelocity[0] = 0;
            }

            if(!checkCollision(playerPosition[0], newY, playerPosition[2])) {
                playerPosition[1] = newY;
                isOnGround = false;
            } else {
                if(playerVelocity[1] < 0) {
                    isOnGround = true;
                }

                playerVelocity[1] = 0;
            }

            if(!checkCollision(playerPosition[0], playerPosition[1], newZ)) {
                playerPosition[2] = newZ;
            } else {
                playerVelocity[2] = 0;
            }

            // Update camera position to match player position
            cameraPosition[0] = playerPosition[0];
            cameraPosition[1] = playerPosition[1] - 0.8; // Eye level
            cameraPosition[2] = playerPosition[2];
            // Update player velocity based on input
            var moveSpeed = 4.0;
            playerVelocity[0] = 0;
            playerVelocity[2] = 0;

            if(getKey("w")) {
                playerVelocity[0] -= dirX * moveSpeed;
                playerVelocity[2] -= dirZ * moveSpeed;
            }

            if(getKey("s")) {
                playerVelocity[0] += dirX * moveSpeed;
                playerVelocity[2] += dirZ * moveSpeed;
            }

            if(getKey("a")) {
                playerVelocity[0] -= rightX * moveSpeed;
                playerVelocity[2] -= rightZ * moveSpeed;
            }

            if(getKey("d")) {
                playerVelocity[0] += rightX * moveSpeed;
                playerVelocity[2] += rightZ * moveSpeed;
            }

            // Update uniform values for camera
            Shim.g.uniform3f(cameraPositionUniformLocation, cameraPosition[0], cameraPosition[1], cameraPosition[2]);
            Shim.g.uniform1f(cameraYawUniformLocation, cameraYaw);
            Shim.g.uniform1f(cameraPitchUniformLocation, cameraPitch);
            draw(numCubes * 36);
            mouseMove[0] = mouseMove[1] = 0;
            js.Browser.window.requestAnimationFrame(loop);
        }
        js.Browser.window.requestAnimationFrame(loop);
    }
}
