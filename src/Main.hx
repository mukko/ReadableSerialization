package ;
import haxe.Serializer;
import haxe.Unserializer;

class Main {
	private static var FILENAME = "sample.txt";
	
	public static function main() {
		//デシリアライズした結果を変数に格納
		var exampleSerializedData1 = 'cy17:flash.geom.Matrixy1:ai1y2:txi100y1:bzy2:tyi200y1:czy1:di1g';
		var exampleSerializedData2 = 'wy17:com.example.Colory3:Rgb:1i128';
		var exampleSerializedData3 = 'awy5:Colory3:Rgb:1i128wR0y3:Red:0h';
		var exampleSerializedData4 = 'oy1:bcy16:flash.geom.Pointy1:xzy1:yi100gy1:ewy5:Colory3:Rgb:1i10y1:ccy17:flash.geom.Matrixy2:txzy1:ai1y2:tyzR0zR7zy1:di1gR10ai1i2i3hR12wR5y3:Red:0g';
		var exampleSerializedData5 = 'by3:YESi123h';
		//var exampleSerializedData6 = SerializationReader.readTextFile(FILENAME);
		
		//マップ変数のテスト
		var m:Map<Int, String> = [
            1 => "One",
            2 => "Two",
            3 => "Three",
        ];
		var map1 = new Map();
		var map2 = new Map();
		var map3 = new Map();
		
		var obj1 = {
			a : 10,
			b : 20,
		}
		var obj2 = {
            x: 120,
            y: 230,
            z: obj1,
            array: [10, 20],
			bool : true,
			hash : m,
        }
		map1.set("foo", obj2);
		map2.set("bar", map1);
		map3.set("hoge", map2);
		var exampleSerializedData7 = Serializer.run(map3);
		
		//ファイル出力・読み込みのテスト
		var unserialData = ExtendedUnserializer.run(exampleSerializedData7);
		var out = SerializationReader.getShapedSerializeData(unserialData,0);
		SerializationReader.outputString(out, "out.txt");
		trace(out);
		/*
		var read = SerializationReader.readTextFile("out.txt");
		trace(SerializationReader.getOriginalUnserializedData(read));
		*/
	}
}
