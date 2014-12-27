package ;

/**
 * シリアライズ文字列を整形シリアライズデータ形式に整形する
 * @author 000ubird
 */
class NewSerializationReader {
	public var serializedText(default, null) : String;				//シリアライズ文字列
	public var extendedUnserializedData(default, null) : Dynamic;	//拡張デシリアライザデータ
	public var readableSerializedText(default, null) : String;		//整形シリアライズ文字列
	private var indent : Int = 0;		//整形時のインデント保持用変数
	private var recursiveDepth:Int = 0;	//再帰の深度を保持する変数
	private static var INDENT = "	";	//スペース4個分のインデント文字列
	private static var NOT_OUTPUT_VALUE_TYPE = 2;	//変数名と型を出力しない再帰深度
	
	/**
	 * シリアライズ文字列を引数に取る
	 * 引数のシリアライズ文字列を拡張デシリアライザデータにしてフィールド変数に保持
	 * @param	serializedText シリアライズ文字列
	 */
	public function new(serializedText : String) {
		this.serializedText = serializedText;
		extendedUnserializedData = ExtendedUnserializer.run(serializedText);
		readableSerializedText = "";
	}
	
	public function getSeikeiSerializedData() : String {
		trace(indent);
		indent++;
		trace(indent);
		return this.extendedUnserializedData;
	/**
	 * 引数の型が再帰が必要な型かを返す
	 * @param	t SValueTypeのコンストラクタ
	 * @return  再帰が必要な場合はtrue、必要無い場合はfalse
	 */
	private static function isRecursive(t : SValueType) : Bool{
		switch(t) {
			//オブジェクト・クラス・Enum・配列は再帰が必要
			case SObject, SValueType.SClass, SValueType.SEnum, SArray : return true;
			//マップ型も再帰が必要
			case SIntMap, SStringMap, SEnumValueMap, SObjectMap : return true;
			//それ以外はプリミティブ型と判断し、再帰が必要でないとする
			default : return false;
		}
	}
	
	/**
	 * デシリアライズしたデータから得られたオブジェクトの型名を取得するメソッド
	 * @param	v デシリアライズしたデータ
	 * @return	要素の型名
	 */ 
	private static function typeof(v:Dynamic):SValueType {
		if (Reflect.hasField(v, '_readable_serialization_class_name_')) {
			return SClass(Reflect.field(v, '_readable_serialization_class_name_'));
		}
		return switch (Type.typeof(v)) {
			case TNull     : SNull;
			case TInt      : SInt;
			case TFloat    : SFloat;
			case TBool     : SBool;
			case TObject   : SObject;
			case TFunction : SFunction;
			case TClass(c) : //trace(Type.getClassName(c));	//デバッグ用
				switch (Type.getClassName(c)) {
					case "Array"				: SArray;
					case "String"				: SString;
					case "haxe.ds.IntMap"		: SIntMap;
					case "haxe.ds.StringMap"	: SStringMap;
					case "haxe.ds.EnumValueMap"	: SEnumValueMap;
					case "haxe.ds.ObjectMap"	: SObjectMap;
					default						: SClass(Type.getClassName(c)); 
				};
			case TEnum(e)  : 
				switch (v) {
					case DummyEnum.Dummy_Enum(e, c, p) :
						SEnum(e, c, p);
					case _ :
						throw 'Internal Error';
				}
			case TUnknown  : SUnknown;
		}
	}
}
