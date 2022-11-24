import h2d.Bitmap;
import h2d.Scene;

class Entity {
    public var location(default, null): Vector2D;
    public var velocity(default, null): Vector2D = Vector2D.zero();
    public var acceleration(default, default): Vector2D = Vector2D.zero();
    var bm: Bitmap;

    public function new(image: hxd.res.Image, location: Vector2D, scene: Scene, scale=1.0) {
        var tile = image.toTile();
        bm = new Bitmap(tile, scene);
        bm.setScale(scale);
        
        bm.tile.dx = -bm.tile.width * 0.5;
        bm.tile.dy = -bm.tile.height * 0.5;
        this.location = location;
    }

    public function update(dt: Float) {
        velocity = velocity.add(acceleration.mul(dt));
        location = location.add(velocity);
        acceleration = Vector2D.zero();
        bm.setPosition(location.x, location.y);
    }

    public function applyForce(force: Vector2D) {
        acceleration = acceleration.add(force.div(bm.scaleX));
    }

    public function checkBoundaries(xmin, xmax, ymin, ymax) {
        var bmHalfWidth = bm.tile.width / 2 * bm.scaleX;
        var bmHalfHeight = bm.tile.height / 2 * bm.scaleY; 

        if ((location.x - bmHalfWidth) < xmin) {
            velocity.x = -velocity.x;
        }
        if ((location.x + bmHalfWidth) > xmax) {
            velocity.x = -velocity.x;
        }

        if ((location.y - bmHalfHeight) < ymin) {
            velocity.y = -velocity.y;
        }
        if ((location.y + bmHalfHeight) > ymax) {
            velocity.y = -velocity.y;
        }
    }

    public function getBoundingBox(): Array<Float> {
        var xmin = location.x - bm.tile.width / 2 * bm.scaleX;
        var xmax = location.x + bm.tile.width / 2 * bm.scaleX;
        var ymin = location.y - bm.tile.height / 2 * bm.scaleY;
        var ymax = location.y + bm.tile.height / 2 * bm.scaleY;
        return [xmin, xmax, ymin, ymax];
    }
}