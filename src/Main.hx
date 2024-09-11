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
        var playerAcceleration = [0.0, 0.0, 0.0];
        var gravity = -9.8;
        var jumpVelocity = 5.0;
        var isOnGround = false;
        var acceleration = 20.0;
        var deceleration = 10.0;
        var maxSpeed = 4.0;
        var lastShotTime = 0.0;
        var shotCooldown = 0.5; // 0.5 seconds between shots
        var bulletSpeed = 50.0;
        var bulletRange = 20.0;
        var bulletSpread = 0.1;
        var bulletsPerShot = 8;
        var resolutionUniformLocation = Shim.g.getUniformLocation(program, "uResolution");
        function checkCollision(x:Float, y:Float, z:Float):Bool {
            var ix = Math.floor(x);
            var iy = Math.floor(y);
            var iz = Math.floor(z);
            var playerRadius = 0.4; // Adjust this value as needed

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
                                    // Sphere-cube collision check
                                    var dx = Math.max(Math.abs(x - cubeX) - 0.5, 0);
                                    var dy = Math.max(Math.abs(y - cubeY) - 0.5, 0);
                                    var dz = Math.max(Math.abs(z - cubeZ) - 0.5, 0);
                                    var distance = Math.sqrt(dx*dx + dy*dy + dz*dz);

                                    if(distance < playerRadius) {
                                        return true;
                                    }
                                }
                            }
                        }
                    }
                }
            }

            return false;
        }
        function shootShotgun() {
            var currentTime = haxe.Timer.stamp();

            if(currentTime - lastShotTime < shotCooldown) { return; }

            lastShotTime = currentTime;

            for(i in 0...bulletsPerShot) {
                var spreadX = (Math.random() - 0.5) * bulletSpread;
                var spreadY = (Math.random() - 0.5) * bulletSpread;
                var spreadZ = (Math.random() - 0.5) * bulletSpread;
                var dirX = Math.cos(cameraPitch) * Math.sin(cameraYaw) + spreadX;
                var dirY = Math.sin(cameraPitch) + spreadY;
                var dirZ = Math.cos(cameraPitch) * Math.cos(cameraYaw) + spreadZ;
                var dir = normalizeVector([dirX, dirY, dirZ]);
                var start = [cameraPosition[0], cameraPosition[1], cameraPosition[2]];
                var end = addVectors(start, multiplyVector(dir, bulletRange));

                // Perform raycast and handle hits
                for(j in 0...Std.int(bulletRange)) {
                    var point = addVectors(start, multiplyVector(dir, j));

                    if(checkCollision(point[0], point[1], point[2])) {
                        // Hit a block, you can add destruction logic here
                        trace('Hit block at ${point[0]}, ${point[1]}, ${point[2]}');
                        break;
                    }
                }
            }

            // Add muzzle flash or sound effect here
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
            // Reset acceleration
            playerAcceleration[0] = 0;
            playerAcceleration[2] = 0;
            var previous_y = playerPosition[1];

            // Apply input-based acceleration
            if(getKey("w")) {
                playerAcceleration[0] -= dirX * acceleration;
                playerAcceleration[2] -= dirZ * acceleration;
            }

            if(getKey("s")) {
                playerAcceleration[0] += dirX * acceleration;
                playerAcceleration[2] += dirZ * acceleration;
            }

            if(getKey("a")) {
                playerAcceleration[0] -= rightX * acceleration;
                playerAcceleration[2] -= rightZ * acceleration;
            }

            if(getKey("d")) {
                playerAcceleration[0] += rightX * acceleration;
                playerAcceleration[2] += rightZ * acceleration;
            }

            // Apply acceleration to velocity
            playerVelocity[0] += playerAcceleration[0] * deltaTime;
            playerVelocity[2] += playerAcceleration[2] * deltaTime;

            // Apply deceleration when no input
            if(playerAcceleration[0] == 0) {
                playerVelocity[0] *= Math.pow(1 - deceleration * deltaTime, 2);
            }

            if(playerAcceleration[2] == 0) {
                playerVelocity[2] *= Math.pow(1 - deceleration * deltaTime, 2);
            }

            // Limit speed
            var speed = Math.sqrt(playerVelocity[0] * playerVelocity[0] + playerVelocity[2] * playerVelocity[2]);

            if(speed > maxSpeed) {
                playerVelocity[0] *= maxSpeed / speed;
                playerVelocity[2] *= maxSpeed / speed;
            }

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
                // Push the player out of the collision
                var pushDirection = newX > playerPosition[0] ? -1 : 1;
                playerPosition[0] += pushDirection * 0.01;
            }

            if(!checkCollision(playerPosition[0], newY, playerPosition[2])) {
                playerPosition[1] = newY;
                isOnGround = false;
            } else {
                if(playerVelocity[1] < 0) {
                    isOnGround = true;
                }

                playerVelocity[1] = 0;
                // Push the player out of the collision
                var pushDirection = newY > playerPosition[1] ? -1 : 1;
                // playerPosition[1] += pushDirection * 0.01;
                playerPosition[1] = previous_y;
            }

            if(!checkCollision(playerPosition[0], playerPosition[1], newZ)) {
                playerPosition[2] = newZ;
            } else {
                playerVelocity[2] = 0;
                // Push the player out of the collision
                var pushDirection = newZ > playerPosition[2] ? -1 : 1;
                playerPosition[2] += pushDirection * 0.01;
            }

            // Update camera position to match player position
            cameraPosition[0] = playerPosition[0];
            cameraPosition[1] = playerPosition[1] + 0.2; // Eye level
            cameraPosition[2] = playerPosition[2];
            // Update uniform values for camera
            Shim.g.uniform3f(cameraPositionUniformLocation, cameraPosition[0], cameraPosition[1], cameraPosition[2]);
            Shim.g.uniform1f(cameraYawUniformLocation, cameraYaw);
            Shim.g.uniform1f(cameraPitchUniformLocation, cameraPitch);
            Shim.g.uniform2f(resolutionUniformLocation, Shim.canvas.width, Shim.canvas.height);

            // Handle shotgun shooting
            if(getKey("x")) {
                shootShotgun();
            }

            draw(numCubes * 36);
            mouseMove[0] = mouseMove[1] = 0;
            js.Browser.window.requestAnimationFrame(loop);
        }
        js.Browser.window.requestAnimationFrame(loop);
    }
    // Add these static functions instead
    static function normalizeVector(v:Array<Float>):Array<Float> {
        var length = Math.sqrt(v[0]*v[0] + v[1]*v[1] + v[2]*v[2]);
        return [v[0]/length, v[1]/length, v[2]/length];
    }

    static function addVectors(v1:Array<Float>, v2:Array<Float>):Array<Float> {
        return [v1[0] + v2[0], v1[1] + v2[1], v1[2] + v2[2]];
    }

    static function multiplyVector(v:Array<Float>, scalar:Float):Array<Float> {
        return [v[0] * scalar, v[1] * scalar, v[2] * scalar];
    }

}
