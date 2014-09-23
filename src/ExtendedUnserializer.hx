package ;

import haxe.Unserializer;

class ExtendedUnserializer {
	
	public static function run(v:String):Dynamic {
		var extendedUnserializer = new ExtendedUnserializer(v);
		return extendedUnserializer.unserialize();
	}
	
	private var unserializer:Unserializer;
	
	private function new(v:String) {
		unserializer = new Unserializer(v);
		unserializer.setResolver(this);
	}
	
	private function unserialize():Dynamic {
		return unserializer.unserialize();
	}
	
	public function resolveClass(name:String):Class<Dynamic> {
		return untyped name;
	}
	
	public function resolveEnum(name:String):Enum<Dynamic> {
		return untyped name;
	}

}
