package serializationReader;
import StringBuf;

/**
 * シリアライズ文字列を整形シリアライズデータ形式に整形する
 * @author 000ubird
 */
class SerializationReader {
	public var serializedText(default, null) : String;				//シリアライズ文字列
	public var extendedUnserializedData(default, null) : Dynamic;	//拡張デシリアライザデータ
	public var readableSerializedText(default, null) : String;		//整形シリアライズ文字列
	private var recursiveDepth:Int = 0;	//再帰の深度を保持する変数
	private static var INDENT = "	";	//スペース4個分のインデント文字列
	private static var NOT_OUTPUT_VALUE_TYPE = 2;	//変数名と型を出力しない再帰深度
	private static var TYPE_HACKER_CLASS_NAME = '_readable_serialization_class_name_';	
	
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
	
	/**
	 * 拡張デシリアライズデータから整形シリアライズ文字列を取得し、
	 * インデントと改行を挿入した整形シリアライズ文字列を返す
	 */
	public function run() : String {
		readableSerializedText = getReadableSerializedText(extendedUnserializedData);
		return addIndentAndNewLine(readableSerializedText);
	}
	
	/**
	 * 整形シリアライズ文字列を読み込み、改行とインデントを付け足す
	 * @param	readableSerializedText 整形シリアライズ文字列
	 * @return  改行とインデントが含まれた整形シリアライズ文字列
	 */
	private function addIndentAndNewLine(readableSerializedData : String) : String {
		var strBuf = new StringBuf();	//文字列保持用のバッファ
		var indent = 0; 	//整形時のインデント保持用変数
		var currentChar = '';
		var nextChar = '';
		
		for (i in 0...readableSerializedData.length) {
			currentChar = readableSerializedData.charAt(i);	//現在の文字を保持
			switch(readableSerializedData.charAt(i)) {
				case '{', '[':
					nextChar = readableSerializedData.charAt(i + 1);	//現在の次の文字を保持	
					strBuf.add(currentChar + '\n');
					//「{」・「[」の次の文字が「}」・「]」だった場合は空列と判断しインデントを増加させない
					if (nextChar == '}' || nextChar == ']') {
						for (i in 0...indent) strBuf.add(INDENT);
					}
					else {
						indent++;
						for (i in 0...indent) strBuf.add(INDENT);
					}
				case '}': 
					//「}」の次の文字が「,」だったら改行を出力しない
					nextChar = readableSerializedData.charAt(i + 1);	//現在の次の文字を保持	
					var nextChar2 = readableSerializedData.charAt(i + 2);	//現在の次の次の文字を取得
					if (nextChar == ',' || nextChar == ')' || nextChar == ':' || nextChar2 == '-') {
						strBuf.add(currentChar);
					}
					else {
						strBuf.add(currentChar+'\n');
						indent--;
					}
				case ',': 
					//「,」の次の文字が「}」だったら改行を出力してインデントの数を減らす
					nextChar = readableSerializedData.charAt(i + 1);	//現在の次の文字を保持	
					if (nextChar == '}' || nextChar == ']') {
						strBuf.add(currentChar+'\n');
						indent--;
						for (i in 0...indent) strBuf.add(INDENT);
					}
					else if(nextChar == '"' || nextChar == '('){
						strBuf.add(currentChar + '\n');
						for (i in 0...indent) strBuf.add(INDENT);
					}
					else {
						strBuf.add(currentChar);
					}
				default : strBuf.add(currentChar);
			}
		}
		//最後の改行を出力
		strBuf.add('\n');
		
		return strBuf.toString();
	}
		
	/**
	 * 拡張デシリアライズデータを引数に取り、整形シリアライズ文字列を返す
	 * @return インデント・改行無しの整形シリアライズ文字列
	 */
	private function getReadableSerializedText(exUnserializedData : Dynamic) : String {
		var strbuf = new StringBuf();						//整形シリアライズ文字列バッファー
		var type = typeof(exUnserializedData);	//拡張デシリアライズデータの型取得
		
		recursiveDepth++;
		
		//デシリアライズデータの型で判定
		switch(type) {
			case SObject , SValueType.SClass : 
				strbuf.add(getSObjectReadableSerializedText(exUnserializedData, type));
			case SArray : 
				strbuf.add( getSArrayReadableSerializedText(exUnserializedData, type));
			case SIntMap, SStringMap, SEnumValueMap, SObjectMap : 
				strbuf.add(getSMapReadableSerializedText(exUnserializedData, type));
			case SString : 
				strbuf.add(getSStringReadableSerializedText(exUnserializedData, type));
			case SValueType.SEnum : 
				strbuf.add(getSEnumReadableSerializedText(exUnserializedData, type));
			default : strbuf.add('"" : $type = $exUnserializedData,');
		}
		
		recursiveDepth--;
		return strbuf.toString();
	}
	
	/**
	 * SObject型の拡張デシリアライズデータを整形シリアライズ文字列にして返す
	 * @param	exUnserializedData 拡張デシリアライズデータ
	 * @param	type 拡張デシリアライズデータの型
	 * @return  改行・インデント無しの整形シリアライズ文字列
	 */
	private function getSObjectReadableSerializedText(exUnserializedData : Dynamic, type : SValueType) : String{
		var strbuf = new StringBuf();		//整形シリアライズデータ保持用バッファ
		var fields = Reflect.fields(exUnserializedData);
		//2回目移行の再帰の場合は変数名と型名を出力しない
		if (recursiveDepth >= NOT_OUTPUT_VALUE_TYPE) {
			strbuf.add('{');
		}
		else {
			strbuf.add('"" : $type = {');
		}
		//フィールド走査を行いそれぞれのフィールドを整形シリアライズデータ形式にする
		for (field in fields) {
			var reflectField = Reflect.field(exUnserializedData, field);
			var fieldType = typeof(reflectField);
			
			if (isRecursive(fieldType)) {
				//フィールド名がマクロによって返されたクラス名以外だったら出力
				if (field != TYPE_HACKER_CLASS_NAME) {
					strbuf.add('"$field" : $fieldType = ' + getReadableSerializedText(reflectField) + ',');
				}
			}
			else {
				strbuf.add('"$field" : $fieldType = $reflectField,');
			}
		}
		strbuf.add('}');
		return strbuf.toString();
	}
	
	/**
	 * SArray型の拡張デシリアライズデータを整形シリアライズ文字列にして返す
	 * @param	exUnserializedData 拡張デシリアライズデータ
	 * @param	type 拡張デシリアライズデータの型
	 * @return  改行・インデント無しの整形シリアライズ文字列
	 */
	private function getSArrayReadableSerializedText(exUnserializedData : Dynamic, type : SValueType) : String {
		var strbuf = new StringBuf();		//整形シリアライズデータ保持用バッファ
		var array : Array<Dynamic> = exUnserializedData;	//デシリアライズデータを明示的に配列に代入
		var fields = Reflect.fields(exUnserializedData);	//フィールド取得
		var name = fields[0];	//フィールドのインデックスの0番目に配列のインスタンス名が保持されている
		
		//インスタンス名が「__a」だった場合はトップレベルの配列であることを名前部分に出力する
		if (name == "__a") {
			if (recursiveDepth >= NOT_OUTPUT_VALUE_TYPE) strbuf.add('[');
			else strbuf.add('__topLevelValue : $type = [');
		}
		
		for (i in 0...array.length) {
			var fieldType = typeof(array[i]);	//配列の要素の型を取得
			if (isRecursive(fieldType)) {
				strbuf.add('"" : $fieldType = '+getReadableSerializedText(array[i])+',');
			}
			else {
				strbuf.add('"" : $fieldType = '+array[i]+',');
			}
		}
		
		if (recursiveDepth >= NOT_OUTPUT_VALUE_TYPE) {
			strbuf.add(']');
		}
		else {
			strbuf.add('],');
		}
		
		return strbuf.toString();
	}
	
	/**
	 * マップ型の拡張デシリアライズデータを整形シリアライズ文字列にして返す
	 * @param	exUnserializedData 拡張デシリアライズデータ
	 * @param	type 拡張デシリアライズデータの型
	 * @return  改行・インデント無しの整形シリアライズ文字列
	 */
	private function getSMapReadableSerializedText(exUnserializedData : Dynamic, type : SValueType) : String {
		var map : Map<Dynamic,Dynamic> = exUnserializedData;
		var strBuf = new StringBuf();	//マップ用文字列バッファ
		
		//変数名と型名を出力
		if (recursiveDepth < NOT_OUTPUT_VALUE_TYPE) {
			strBuf.add('"" : $type = ');
		}
		
		//キーの設定が何も無かった場合は型名と値に「__none」という文字列を出力する
		if (!map.keys().hasNext()) {
			strBuf.add('( __mapKey : __none = __none -> __mapValue : __none = __none ),');
		}
		
		for (key in map.keys()) {
			var keyType = typeof(key);				//キーの型情報を取得
			var valueType = typeof(map.get(key));	//値の情報を取得
			
			//キーの型が再帰が必要な場合、キーを引数に入れて再帰的に呼び出す.
			if (isRecursive(keyType)) {
				//値の型が再帰が必要な場合、値を引数に入れて再帰的に呼び出す.
				if (isRecursive(valueType)) {
					strBuf.add('( __mapKey : $keyType = '+getReadableSerializedText(key)+' -> __mapValue : $valueType = ' +getReadableSerializedText(map.get(key))+'),');
				}
				else {
					strBuf.add('( __mapKey : $keyType = '+getReadableSerializedText(key)+' -> __mapValue : $valueType = '+map.get(key)+'),');
				}
			}
			else {
				if (isRecursive(valueType)) {
					strBuf.add('( __mapKey : $keyType = $key -> __mapValue : $valueType = ' +getReadableSerializedText(map.get(key))+'),');
				}
				else {
					strBuf.add('( __mapKey : $keyType = $key -> __mapValue : $valueType = '+map.get(key)+'),');
				}
			}
		}
		return strBuf.toString();
	}
	
	/**
	 * SEnum型の拡張デシリアライズデータを整形シリアライズ文字列にして返す
	 * @param	exUnserializedData 拡張デシリアライズデータ
	 * @param	type 拡張デシリアライズデータの型
	 * @return  改行・インデント無しの整形シリアライズ文字列
	 */
	private function getSEnumReadableSerializedText(exUnserializedData : Dynamic, type : SValueType) : String {
		var dummyEnum : DummyEnum = exUnserializedData;
		var enumParam = dummyEnum.getParameters();
		var params : Array<Dynamic> = enumParam[2];	//Enumのパラメータを取得
		var constructorName = enumParam[1];			//コンストラクタ名を取得
		var paramType;	//Enumのパラメータの型を保持
		var strBuf = new StringBuf();	//文字列バッファ
		
		//コンストラクタが引数ありの場合
		if (params != null) {
			//再帰で呼び出された場合はコンストラクタ名と括弧を出力
			if (recursiveDepth >= NOT_OUTPUT_VALUE_TYPE) {
				strBuf.add('$constructorName{');
			}
			else {
				strBuf.add('"" : $type = $constructorName{');
			}
			//Enumのパラメータを再帰的に整形シリアライズテキスト化
			for (param in params) {
				paramType = typeof(param);
				if (isRecursive(paramType)) {
					strBuf.add('"" : $paramType = '+getReadableSerializedText(param)+',');
				}
				//プリミティブ型の場合はここでシリアライズテキストを出力
				else {
					strBuf.add('"" : $paramType = $param,');
				}
			}
			if (recursiveDepth >= NOT_OUTPUT_VALUE_TYPE) {
				strBuf.add('}');
			}
			else {
				strBuf.add('},');
			}
		}
		//コンストラクタが引数無しの場合
		else {
			if (recursiveDepth >= NOT_OUTPUT_VALUE_TYPE) {
				strBuf.add(constructorName);
			}
			else {
				strBuf.add('"" : $type = $constructorName,');
			}
		}
		return strBuf.toString();
	}
	
	/**
	 * SString型の拡張デシリアライズデータを整形シリアライズ文字列にして返す
	 * URLデコードを使用して拡張デシリアライズデータから文字列を取得する
	 * @param	exUnserializedData 拡張デシリアライズデータ
	 * @param	type 拡張デシリアライズデータの型
	 * @return  改行・インデント無しの整形シリアライズ文字列
	 */
	private function getSStringReadableSerializedText(exUnserializedData : Dynamic, type : SValueType) : String {
		var strBuf = new StringBuf();
		//改行文字を変換
		var str = StringTools.replace(exUnserializedData, '\n', '\\n');
		//文字列が空列だった場合には「""」を代入
		if (str == '') str = '""';
		if (recursiveDepth >= NOT_OUTPUT_VALUE_TYPE) {
			strBuf.add(str);
		}
		else {
			strBuf.add('"" : $type = $str,');
		}
		return strBuf.toString();
	}
	
	/**
	 * 引数の型が再帰が必要な型かを返す
	 * @param	t SValueTypeのコンストラクタ
	 * @return  再帰が必要な場合はtrue、必要無い場合はfalse
	 */
	private static function isRecursive(t : SValueType) : Bool{
		switch(t) {
			//オブジェクト・クラス・Enum・配列は再帰が必要
			case SObject, SValueType.SClass, SValueType.SEnum, SArray,SString : return true;
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
		if (Reflect.hasField(v, TYPE_HACKER_CLASS_NAME)) {
			return SClass(Reflect.field(v, TYPE_HACKER_CLASS_NAME));
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
						SEnum(e);
					case _ :
						throw 'Internal Error';
				}
			case TUnknown  : SUnknown;
		}
	}
}
