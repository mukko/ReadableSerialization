package sampleClass;

import haxe.ds.ObjectMap;
enum Color {
	Red;
	Green;
	Blue;
	Grey( v : Int );
	testRgb( r : Int, g : Int, b : Color); //Enum内にEnum
	testClass( c : Primitive); //Enum内にクラス
	testArray( a : Array<Dynamic>); //Enum内に配列
	testMap( m : ObjectMap<Dynamic, Dynamic>); //Enum内にマップ
	testObject( o : Dynamic); //Enum内にオブジェクト 
}