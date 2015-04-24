package sampleClass;

class Primitive {
	public var numInt(default, null) : Int;
	public var numFloat(default, null) : Float;
	public var text(default, null) : String;
	public var bool(default, null) : Bool;

	public function new(i : Int, f : Float, s : String, b : Bool) {
		this.numInt = i;
		this.numFloat = f;
		this.text = s;
		this.bool = b;
	}
}
