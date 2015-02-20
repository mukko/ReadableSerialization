package serializationWriter;

import haxe.Serializer;
import haxe.Unserializer;

class Main {
	public static function main() {
		//試験的な元データ生成
		var sw = new SerializationWriter("arraySample.txt");
		var originValue = sw.run();
		//デバッグ
		trace(originValue);
		trace(Type.typeof(originValue));
	}
}
