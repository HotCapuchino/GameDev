class Vector2D {
    public var x: Float;
    public var y: Float;

    public function new(x: Float, y: Float) {
        this.x = x;
        this.y = y;
    }

    public static function zero(): Vector2D {
        return new Vector2D(0, 0);
    } 

    public static function random(xmin, xmax, ymin, ymax): Vector2D {
        return new Vector2D(Random.float(xmin, xmax), Random.float(ymin, ymax));
    }

    public function add(other: Vector2D) {
        return new Vector2D(x + other.x, y + other.y);
    }

    public function sub(other: Vector2D) {
        return new Vector2D(x - other.x, y - other.y);
    }

    public function mul(val: Float) {
        return new Vector2D(x * val, y * val);
    }

    public function div(val: Float) {
        return new Vector2D(x / val, y / val);
    }

    public function magnitude() {
        return Math.sqrt(Math.pow(x, 2) + Math.pow(y, 2));
    }

    public function norm() {
        var magnitude = this.magnitude();
        return this.div(magnitude);
    }

    public function limit(max: Float) {
        var magnitude = this.magnitude();
        if (magnitude > max) {
            return this.norm().mul(max);
        } 
        return copy(this);
    }

    public static function copy(vector: Vector2D) {
        return new Vector2D(vector.x, vector.y);
    }

    public function toString() {
        return 'Vector($x, $y)';
    }
}