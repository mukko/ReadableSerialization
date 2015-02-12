package serializationWriter;
import haxe.Serializer;
import haxe.Unserializer;

class Main extends mcli.CommandLine {
	
	public function runDefault(?name:String) {
		if (name == null) {
			//var sw = new SerializationWriter("objectSample.txt");
			//var originValue = sw.run();
			//Sys.println("type => "+Type.typeof(originValue)+" , Value => "+originValue);
			Sys.println("No files selected.");
		}
		else {
			//指定したファイルからシリアライズ文字列を取得
			/*var sr = FileTools.readTextFile(name);
			if (sr == null) {
				Sys.println("No such file "+name);
			}
			else {
				var sr = new SerializationReader(sr);
				FileTools.outputString(sr.run(),"out_"+name+".txt");
				Sys.println("Save as out_"+name+".txt");
			}*/
		}
	}
	
	public static function main() {
		new mcli.Dispatch(Sys.args()).dispatch(new Main());
	}
}
