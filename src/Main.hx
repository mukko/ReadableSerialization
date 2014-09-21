package ;

import haxe.Serializer;
import haxe.Unserializer;
import haxe.ds.HashMap;
import flash.geom.Point;

//enumの例を定義
enum Color{
    Red;
    Green;
    Blue;
}

class Main {
    static function main() {
		//シリアライズ検証用変数の定義
		var array = new Array<Int>();
		array[0] = 50;
		array[5] = 100;
		var enum_color = Color.Green;
		var point = new Point(10, 20);
		var float = 10.55;
		var hash = new Map();
		hash.set("abc", 1);
		
        var object = {
			color : enum_color,
			p : point,
            x: 120,
            y: 230,
            z: 990,
			array: array,
        }
		
        var str = haxe.Serializer.run(object);
		trace(str);
    }
}
