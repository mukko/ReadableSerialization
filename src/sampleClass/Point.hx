package sampleClass;

/**
 * サンプルクラスその①
 * @author 000ubird
 */
import haxe.ds.ObjectMap;
import sampleClass.Color;
//クラスのテストに利用するクラス
class Point {
	public var x(default, null) : Int;
	public var y(default, null) : Int;
	public var primitive(default, null) : Primitive; //クラス
	public var array(default, null) : Array<Dynamic>; //配列
	public var map(default, null) : Map<Dynamic, Dynamic>; //マップ
	public var object(default, null) : Dynamic; //オブジェクト
	public var e(default, null) : Color; //Enum
	
	public function new(x : Int , y : Int, primitive : Primitive, array : Array<Dynamic>, map : Map<Dynamic,Dynamic>, object : Dynamic ,e : Color) {
		this.x = x;
		this.y = y;
		this.primitive = primitive;
		this.array = array;
		this.map = map;
		this.object = object;
		this.e = e;
	}	
}
