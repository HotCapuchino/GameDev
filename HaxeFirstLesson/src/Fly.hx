import h2d.Bitmap;
import Random;
import hxd.Window;

class Fly {
    var bm: Bitmap;
    var speed: Float;
    var noiseX: Noise = new Noise();
    var noiseY: Noise = new Noise();
    var tx: Float = 0.0;
    var ty: Float = 0.0;

    public function new(image, speed, s2d, initialX: Float, initialY: Float) {
        bm = new Bitmap(image, s2d);
        bm.tile.dx = -bm.tile.width * 0.5;
        bm.tile.dy = -bm.tile.height * 0.5;
        bm.x = initialX;
        bm.y = initialY;
        this.speed = speed;
    }

    private function getPerlinCoords() {
        tx += Random.float(0.0, 0.05);
        ty += Random.float(0.0, 0.05);

        var width = Window.getInstance().width;
        var height = Window.getInstance().height;
        return [noiseX.remap(noiseX.perlin(tx, 0.0, 0.0), -1, 1, 0, width), noiseY.remap(noiseY.perlin(ty, 0.0, 0.0), -1, 1, 0, height)];
    }

    public function update(dt: Float) {
        var coords = getPerlinCoords();
        bm.x = coords[0];
        bm.y = coords[1];

        // bm.x += speed;
        // bm.y += speed;
    }

    public function toString() {
        return 'fly(x: ${bm.x}, y: ${bm.y})';
    }
}

class RandomFly extends Fly {
    public override function update(dt: Float) {
        var step = Random.int(0, 3);

        switch(step) {
            case 0: bm.y -= speed;
            case 1: bm.y += speed;
            case 2: bm.x -= speed;
            case 3: bm.x += speed;
        }
    }
}

class PurposefulFly extends Fly {
    public override function update(dt: Float) {
        var step = Random.int(0, 4);

        switch(step) {
            case 0: bm.y -= speed;
            case 1: bm.y += speed;
            case 2: bm.x -= speed;
            case _: bm.x += speed;
        }
    }
}

class HerdFlies {
    var flies: List<Fly> = new List<Fly>();

    public function new(image, speed, s2d, initialX: Float, initialY: Float, n: Int, cls: Class<Dynamic>) {
        for (i in 0...n) {
            flies.add(Type.createInstance(cls, [image, speed, s2d, initialX, initialY]));
        }
    }

    public function update(dt: Float) {
        for(fly in flies) {
            fly.update(dt);
        }
    }
}
