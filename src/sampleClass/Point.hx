package sampleClass;

/**
 * サンプルクラスその①
 * @author 000ubird
 */
import sampleClass.Color;
class Point {
	public var x(default, null) : Int;
	public var y(default, null) : Int;
	public var e(default, null) : Color;
	
	public function new(x : Int , y : Int, e : Color) {
		this.x = x;
		this.y = y;
		this.e = e;
	}	
}
