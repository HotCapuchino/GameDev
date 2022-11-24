import Fly.RandomFly;
import Fly.PurposefulFly;
import hxd.res.DefaultFont;
import Fly.HerdFlies;
import h2d.Text;
import h2d.Bitmap;
import hxd.Window;
import h2d.Console;

class Main extends hxd.App {
    var fpsLabel: Text;
    var herd: HerdFlies;
    var fly: Fly;
    var console: Console;
    var noise: Noise;

    override function init() {
        hxd.Res.initEmbed();
        engine.backgroundColor = 0x7ca4cc;

        var image = hxd.Res.background.toTile();

        var width = Std.int(image.width);
        var height = Std.int(image.height);

        var bg: Bitmap = new Bitmap(image, s2d);
        Window.getInstance().resize(width, height);

        var image = hxd.Res.mosquito_small.toTile();
        herd = new HerdFlies(image, 10, s2d, width / 2, height / 2, 25, Fly);
        // fly = new Fly(image, 2, s2d, width / 2, height / 2);
        
        console = new Console(DefaultFont.get(), s2d);
        console.autoComplete = true;

        fpsLabel = new Text(DefaultFont.get(), s2d);
        fpsLabel.textColor = 0xff0000;
        fpsLabel.setScale(2);  

        noise = new Noise();
        console.log("" + noise.perlin(0.6, 0.0, 0.0));
    }

    override function update(dt: Float) {
        fpsLabel.text = 'fps: ${Math.round(1 / dt)}';
        herd.update(dt);
        // fly.update(dt);
    }
    
    static function main() {
        new Main();
    }
}