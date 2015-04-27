package serializationReader;
import haxe.ds.EnumValueMap;
import haxe.ds.IntMap;
import haxe.ds.ObjectMap;
import haxe.ds.StringMap;
import haxe.Serializer;
import haxe.Unserializer;
import sampleClass.Color;
import sampleClass.Point;
import sampleClass.Primitive;
import serializationWriter.SerializationWriter;
class Main extends mcli.CommandLine {
	
	public function runDefault(?name:String) {
		if (name == null) {
			Sys.println("No files selected.");
		}
		else if (name == "sample") {
			//プリミティブ型のサンプル
			var int = 10;
			var float = 3.14;
			var bool = true;
			var str = "abcde";
			//プリミティブ型以外のサンプル
			var enm : Color = Color.Green;
			var enm2 : Color = Color.Grey(100);
			var array : Array<Dynamic> = [int, float, bool];
			
			var intMap = new IntMap();
			var strMap = new StringMap();
			var objMap = new ObjectMap();
			var enmMap = new EnumValueMap();
			intMap.set(int, str);
			
			var obj = { i : int, b: float , m : strMap };
			array.push(obj);
			var cls = new Point(10, 20, new Primitive(10, 3.14, "abc", true), array, strMap, obj,enm2);
			var cls2 = new Point(100, 200, new Primitive(100, 3.104, "abcf", false), array, intMap, obj,enm2);
			
			strMap.set(str, int);
			objMap.set(cls, strMap);
			enmMap.set(enm, cls);
			enmMap.set(enm, cls2);
			
			var obj2 = { i : int, b: float , m : strMap };
			
			//テスト処理
			var sr_origin = Serializer.run(cls2);
			
			var sr = new SerializationReader(sr_origin);
			Sys.println(sr.run());
			FileTools.outputString(sr.run(), "out.txt");
			
			Sys.println(sr_origin+"\n");
		}
		else {
			//指定したファイルからシリアライズ文字列を取得
			var sr = FileTools.readTextFile(name);
			if (sr == null) {
				Sys.println("No such file "+name);
			}
			else {
				var sr = new SerializationReader(sr);
				name += ".txt";
				//整形シリアライズ形式の文字列を出力し、出力ファイル名を取得
				var outFileName = FileTools.outputString(sr.run(), name);
				
				Sys.println("Save as "+outFileName);
			}
		}
	}
	
	public static function main() {
		new mcli.Dispatch(Sys.args()).dispatch(new Main());
	}
}
