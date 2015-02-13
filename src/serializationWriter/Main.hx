package serializationWriter;
import haxe.Serializer;
import haxe.Unserializer;

class Main {
	
	public static function main() {
		var className = "";
		var resolveClass = Type.resolveClass(className);
		if (resolveClass == null) throw 'class not found';
		trace(resolveClass);	//デバッグ
		
		//フィールド変数を代入
		var originalClassSample = Type.createEmptyInstance(resolveClass);
		Reflect.setField(originalClassSample, "x", 10);
		Reflect.setField(originalClassSample, "y", 20);
		Reflect.setField(originalClassSample, "x", 30);
		
		trace(originalClassSample);	//デバッグ
	}
}
