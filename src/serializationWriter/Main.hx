package serializationWriter;

import haxe.Serializer;
import haxe.Unserializer;
import sampleClass.Point;

class Main {
	public static function main() {
		var className = 'sampleClass.Point';
		var resolveClass = Type.resolveClass(className);
		if (resolveClass == null) throw 'class not found';
		//デバッグ
		trace(resolveClass);	
		/*{ __name__ => [sampleClass,Point],
		 * __construct__ => #function:2, 
		 * prototype => { __class__ => ..., x => null, y => null,
		 * __serialize => #function:0 },
		 * new => #function:2 }
		*/
		
		//フィールド変数を代入
		var originalClassSample = Type.createEmptyInstance(resolveClass);
		Reflect.setField(originalClassSample, "x", 10);
		Reflect.setField(originalClassSample, "y", 20);
		Reflect.setField(originalClassSample, "z", 30);
		//デバッグ
		trace(originalClassSample);		//{ x => 10, y => 20, z => 30 }
	}
}
