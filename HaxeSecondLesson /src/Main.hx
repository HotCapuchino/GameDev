import hxd.res.DefaultFont;
import h2d.Text;
import h2d.Bitmap;
import hxd.Window;
import hxd.Event;
import h2d.Console;
import Vector2D;
import Liquid;

class Main extends hxd.App {
    var clouds: Bitmap;
    var center: Vector2D;
    var text: Text;
    var entity: Entity;
    var entityList: List<Entity> = new List<Entity>();
    // var cannonBall: Bitmap;

    var gravityOn: Bool = false;
    var windOn: Bool = false;
    var floatingOn: Bool = false;
    var frictionOn: Bool = true;
    var gravity = new Vector2D(0, 1);
    var wind = new Vector2D(1, 0);
    var floating = new Vector2D(0, -1.2);
    var friction: Vector2D;

    var width: Int;
    var height: Int; 
    var liquid: Liquid;

    function initScene() {
        var bg: Bitmap = new Bitmap(hxd.Res.skybox.toTile(), s2d);
        var ground: Bitmap = new Bitmap(hxd.Res.ground.toTile(), s2d);
        clouds = new Bitmap(hxd.Res.sky_clouds.toTile(), s2d);
        // cannonBall = new Bitmap(hxd.Res.ball.toTile(), s2d);

        bg.setPosition(-30, -30);
        clouds.setPosition(-30, -30);
        ground.setPosition(-30, -30);

        width = Std.int(bg.getBounds().width) - 60;
        height = Std.int(bg.getBounds().height) - 60;

        text = new Text(DefaultFont.get(), s2d);
        text.textColor = 0xff0000;
        text.setScale(2); 

        center = new Vector2D(width / 2, height / 2);
        s2d.scaleMode = ScaleMode.Stretch(width, height);

        Window.getInstance().addEventTarget(onEvent);
    }

    override function init() {
        hxd.Res.initEmbed();
        initScene();
        
        entityList.add(new Entity(hxd.Res.baloon, center, s2d, 0.2));
        var newCenter = new Vector2D(width / 3, height / 2);
        entityList.add(new Entity(hxd.Res.baloon, newCenter, s2d, 0.5));
        
        liquid = new Liquid(0, width, 2 * height / 3, height, 7);
    }

    public function remap(val: Float, start1: Float, end1: Float, start2: Float, end2: Float) {
        var percent = val / (end1 - start1);
        return start2 + (end2 - start2) * percent;
    }

    override function update(dt: Float) {
        var mouse = new Vector2D(s2d.mouseX, s2d.mouseY);
        var diff: Vector2D = center.sub(mouse);

        var newX = remap(diff.x, -center.x, center.x, -15, 15);
        var newY = remap(diff.y, -center.y, center.y, -10, 10);
        clouds.setPosition(-30 + newX, -30 + newY);

        text.text = 'Gravity = $gravityOn, Wind = $windOn, Floating = $floatingOn, Friction = $frictionOn';

        for (entity in entityList) {
            var acceleration = mouse.sub(entity.location).norm().mul(5);
    
            if (gravityOn) {
                entity.applyForce(gravity);
            }
    
            if (windOn) {
                entity.applyForce(wind);
            }
    
            if (floatingOn) {
                entity.applyForce(floating);
            }

            if (frictionOn) {
                if (entity.velocity.magnitude() != 0) {
                    friction = entity.velocity.mul(-1).norm();
                    entity.applyForce(friction.mul(0.1));
                }
            }

            if (liquid.isInside(entity)) {
                var magnitude = entity.velocity.magnitude();
                var drag = liquid.c * magnitude * magnitude;
                var dragForce = entity.velocity.mul(-1).norm().mul(drag);
                entity.applyForce(dragForce);
            }
    
            entity.update(dt);
            entity.checkBoundaries(-30, width + 30, -30, height + 30);
        }

    }

    function onEvent(event: Event) {
        switch(event.kind) {
            case EKeyDown: {
                switch(event.keyCode) {
                    case hxd.Key.F: floatingOn = !floatingOn;
                    case hxd.Key.G: gravityOn = !gravityOn;
                    case hxd.Key.R: frictionOn = !frictionOn;
                    case hxd.Key.W: {
                        windOn = !windOn;
                        if (windOn) {
                            wind.x = wind.x * -1;
                        } 
                    };
                }
            }   
            case _: 
        }
    }
    
    static function main() {
        new Main();
    }
}