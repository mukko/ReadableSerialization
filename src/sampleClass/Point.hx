package sampleClass;

/**
 * サンプルクラスその①
 * @author 000ubird
 */
class Point {
	public var x(default, null) : Int;
	public var y(default, null) : Int;
	public var e(default, null) : Enum;
	
	public function new(x : Int , y : Int, e : Enum) {
		this.x = x;
		this.y = y;
		this.e = e;
	}	
}
