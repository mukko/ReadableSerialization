package ;
import haxe.Serializer;
import haxe.Unserializer;

class Main {
    static function main() {
        var object = {
            x: 120,
            y: 230,
            z: 990,
        }
        trace(object);
            
        var str = haxe.Serializer.run(object);
        trace(str);
        
        
        var x = haxe.Unserializer.run(str);
        trace(x);
        
    }
}
