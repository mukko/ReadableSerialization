package ;
import haxe.Serializer;

class Main {
	
	public static function main() {
		//デシリアライズした結果を変数に格納
		var exampleUnserializedData1 = ExtendedUnserializer.run('cy17:flash.geom.Matrixy1:ai1y2:txi100y1:bzy2:tyi200y1:czy1:di1g');
		var exampleUnserializedData2 = ExtendedUnserializer.run('wy17:com.example.Colory3:Rgb:1i128');
		var exampleUnserializedData3 = ExtendedUnserializer.run('awy5:Colory3:Rgb:1i128wR0y3:Red:0h');
		var exampleUnserializedData4 = ExtendedUnserializer.run('oy1:bcy16:flash.geom.Pointy1:xzy1:yi100gy1:ewy5:Colory3:Rgb:1i10y1:ccy17:flash.geom.Matrixy2:txzy1:ai1y2:tyzR0zR7zy1:di1gR10ai1i2i3hR12wR5y3:Red:0g');
		
		//デシリアライズした整形前のデータを出力
		trace(exampleUnserializedData1);
		trace(exampleUnserializedData2);
		trace(exampleUnserializedData3);
		trace(exampleUnserializedData4);
		
		//デシリアライズデータの整形と表示
		var result1 = SerializationReader.getObjectJsonData(exampleUnserializedData1);
		var result2 = SerializationReader.getObjectJsonData(exampleUnserializedData2);
		var result3 = SerializationReader.getObjectJsonData(exampleUnserializedData3);
		var result4 = SerializationReader.getObjectJsonData(exampleUnserializedData4);
		trace(result1);
		trace(result2);
		trace(result3);
		trace(result4);
		
		//ファイル出力・読み込みのテスト
		SerializationReader.outputString(result1, "out.txt");
		var data = SerializationReader.readTextFile("out.txt");
		trace(data);
		/*SerializationReader.getOriginalUnserializedData(data);
		var dataS = Serializer.run(data);*/
	}
}
