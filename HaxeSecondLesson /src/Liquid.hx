class Liquid {
    public var c = 0.25;
    var xmin: Float;
    var xmax: Float;
    var ymin: Float;
    var ymax: Float;

    public function new(xmin, xmax, ymin, ymax, c) {
        this.xmin = xmin;
        this.xmax = xmax;
        this.ymin = ymin;
        this.ymax = ymax;
        this.c = c;
    }

    public function isInside(entity: Entity): Bool {
        var bb: Array<Float> = entity.getBoundingBox();
        return ((xmin - bb[0]) < 0 && (xmax - bb[1]) > 0) && ((ymin - bb[2]) < 0 && (ymax - bb[3]) > 0);
    }
}