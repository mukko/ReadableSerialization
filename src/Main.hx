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
		
		var m:Map<Int, String> = [
            1 => "One",
            2 => "Two",
            3 => "Three",
        ];
		var hash = Unserializer.run(exampleSerializedData5);
		var map1 = new Map();
		var map2 = new Map();
		var map3 = new Map();
		map1.set("foo", 51);
		map2.set("bar", map1);
		map3.set("hoge", map2);
		trace(SerializationReader.getStringMapContents(map3));
		
		/*
		var exampleSerializedData6 = Serializer.run(map3);
		trace(ExtendedUnserializer.run(exampleSerializedData5));
		//デシリアライズした整形前のデータを出力
		trace(exampleSerializedData1);
		trace(exampleSerializedData2);
		trace(exampleSerializedData3);
		trace(exampleSerializedData4);
		trace(exampleSerializedData5);
		trace(exampleSerializedData6);
		
		//ファイル出力・読み込みのテスト
		var unserialData = ExtendedUnserializer.run(exampleSerializedData4);
		var out = SerializationReader.getShapedSerializeData(unserialData,0);
		trace(out);
		SerializationReader.outputString(out, "out.txt");
		var read = SerializationReader.readTextFile("out.txt");
		trace(SerializationReader.getOriginalUnserializedData(read));
		*/
	}
}
