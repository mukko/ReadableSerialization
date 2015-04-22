package serializationWriter;
import haxe.ds.IntMap;
import haxe.ds.ObjectMap;
import haxe.ds.StringMap;
import haxe.ds.EnumValueMap;
import serializationReader.FileTools;
import Type;

import sampleClass.Point;

/**
 * 整形シリアライズデータを元に元のデータを生成する
 * @author 000ubird
 */
class SerializationWriter {
	private var fileName : String = "";	//整形シリアライズデータの書かれたテキストファイル名
	private var line : String = "";		//整形シリアライズ文字列の1行を保持
	private var currentLine : Int = 0;		//読み取る行数
	private static var MAX_SET_CONSTRUCTORS = 8;	//クラス生成時の最大コンストラクタ数
	
	/**
	 * 整形シリアライズデータの文字列が書かれたテキストファイル名を
	 * 引数に取ってフィールドに保持する
	 * @param	filename 読み込むテキストファイル名
	 */
	public function new(fileName : String) {
		this.fileName = fileName;
	}
	
	/**
	 * 整形シリアライズデータから元のデータを生成を実行
	 * データの生成に失敗した場合は問題のある行数を出力し、nullを返す
	 * @return シリアライズ元データ
	 */
	public function run() : Dynamic { 
		//TODO エラーメッセージを詳細化
		try {
			return getOriginalValue();
		}catch (msg : String) {
			var line = StringTools.replace(this.line, '	', '');	//インデント文字の削除
			trace('\nError in line '+(currentLine+1)+' \nLine detail : $line \nError message : $msg');
			return null;
		}
	}
	
	/**
	 * 整形シリアライズデータから元のデータを生成
	 * @return シリアライズ元データ
	 */
	private function getOriginalValue() : Dynamic {
		var originalValue : Dynamic = null;
		while (true) {
			var type = null;
			//文字列を取得
			line = FileTools.readLine(fileName, currentLine);
			//読み取った行がnullになるのは最後の行
			if (line == null) {
				//最後の行になったらループを抜ける
				break;
			}
			//現在の行のデータがマップだった場合は型情報の部分を抽出して型情報を取得
			if (isMap()) {
				var r : EReg = ~/ : S.*Map = \(/;
				r.match(line);
				var mapType = r.matched(0);
				type = typeof(mapType);
			}
			else {
				type = typeof(line);	//型情報を習得
			}
			
			//元のデータを生成
			switch (type) {
				case TNull : originalValue = null;
				case TInt: originalValue = getInt(line);
				case TFloat: originalValue = getFloat(line);
				case TBool : originalValue = getBool(line);
				case TClass(c) : 
					switch(Type.getClassName(c)) {
						case "String" : originalValue = getString(line);
						case "haxe.ds.IntMap","haxe.ds.StringMap",
							 "haxe.ds.EnumValueMap","haxe.ds.ObjectMap" :
							//TODO マップの生成処理の実装
							originalValue = getObjectMap();
						case "Array" : 
							currentLine++;
							originalValue = getArray();
						//外部クラスの場合はインポートが必要
						default : 
							currentLine++;
							originalValue = getClass();
					}
				case TObject : 
					currentLine++;
					originalValue = getObject();
				case TEnum(c) :
					originalValue = getEnumValue();
				default : originalValue = null;
			}
			currentLine++;
		}
		return originalValue;
	}
	
	/**
	 * 整形シリアライズ文字列の1行分のデータからInt型の数値を返す
	 * @param  Int型のデータが含まれた整形シリアライズ文字列
	 * @return Int型の値
	 */
	private function getInt(str : String) : Int {
		var value = getPrimitiveValue(str);
		return Std.parseInt(value);
	}
	
	/**
	 * 整形シリアライズ文字列の1行分のデータからFloat型の数値を返す
	 * @param  Float型のデータが含まれた整形シリアライズ文字列
	 * @return Float型の値
	 */
	private function getFloat(str : String) : Float {
		var value = getPrimitiveValue(str);
		return Std.parseFloat(value);
	}
	
	/**
	 * 整形シリアライズ文字列の1行分のデータからBool型の値を返す
	 * @param  Bool型のデータが含まれた整形シリアライズ文字列
	 * @return Bool型の値
	 */
	private function getBool(str : String) : Bool {
		var value = getPrimitiveValue(str);
		if (value == "true") return true;
		else return false;
	}
	
	/**
	 * 整形シリアライズ文字列の1行分のデータからString型の値を返す
	 * @param  String型のデータが含まれた整形シリアライズ文字列
	 * @return String型の値
	 */
	private function getString(str : String) : String {
		var value = getPrimitiveValue(str);
		
		//String型の値が「""」だった場合は空列を代入
		if (value == '""') value = '';
		
		return value.toString();
	}
	
	/**
	 * 整形シリアライズデータ文字列から配列を返す
	 * @return 元データの配列
	 */
	private function getArray() : Array<Dynamic> {
		var array : Array<Dynamic> = [];
		//配列の要素を追加
		while(true){
			//文字列を取得
			line = FileTools.readLine(fileName, currentLine);
			
			//オブジェクトの終わりを示す記号が来たらループを抜ける
			if (isEndOfInstance()) break;
			
			//型情報を習得
			var type = typeof(line);
			
			//元のデータを生成
			switch (type) {
				case TNull : array.push(null);
				case TInt: array.push(getInt(line));
				case TFloat: array.push(getFloat(line));
				case TBool : array.push(getBool(line));
				case TClass(c) : 
					switch(Type.getClassName(c)) {
						case "String" : array.push(getString(line));
						case "Array" : 
							currentLine++;
							array.push(getArray());
						//外部クラスの場合はインポートが必要
						default : 
							currentLine++;
							array.push(getClass());
					}
				case TObject :
					currentLine++;
					array.push(getObject());
				default : array.push(null);
			}
			currentLine++;
		}
		return array;
	}
	
	/**
	 * 整形シリアライズデータ文字列からObject型の値を返す
	 * @return Object型の値
	 */
	private function getObject() : Dynamic {
		var obj = {};
		while(true){
			//文字列を取得
			line = FileTools.readLine(fileName, currentLine);
			
			//オブジェクトとマップの終わりを示す記号が来たらループを抜ける
			if (isEndOfInstance()) break;
			
			//型情報を習得
			var type = typeof(line);
			
			//元のデータを生成
			switch (type) {
				case TNull : Reflect.setField(obj, getValueName(), null);
				case TInt: Reflect.setField(obj,getValueName(),getInt(line));
				case TFloat: Reflect.setField(obj,getValueName(),getFloat(line));
				case TBool : Reflect.setField(obj,getValueName(),getBool(line));
				case TClass(c) : 
					switch(Type.getClassName(c)) {
						case "String" : Reflect.setField(obj, getValueName(), getString(line));
						case "Array" : 
							currentLine++;
							Reflect.setField(obj, getValueName(), getArray());
						//外部クラスの場合はインポートが必要
						default : 
							currentLine++;
							Reflect.setField(obj, getValueName(), getClass());
					}
				case TObject :
					currentLine++;
					Reflect.setField(obj, getValueName(), getObject());
				default : obj = null;
			}
			currentLine++;
		}
		return obj;
	}
	
	/**
	 * 整形シリアライズデータ文字列からクラスのインスタンスを返す
	 * @return　Classのインスタンス
	 */
	private function getClass() : Class<Dynamic> {
		var className = getClassName();
		var resolveClass = Type.resolveClass(className);
		//クラスが見つからなかった場合はエラーと読み取った行数を出力
		if (resolveClass == null) throw '$currentLine : class "$className" is not found';
		
		var originalClass = Type.createEmptyInstance(resolveClass);
		var numberOfConstructors = 0;
		
		while(true){
			//文字列を取得
			line = FileTools.readLine(fileName, currentLine);
			//インスタンスとマップの終わりを示す記号が来たらループを抜ける
			if (isEndOfInstance() ) break;
			//設定可能コンストラクタ数を超えたらエラーを出力
			if (numberOfConstructors > MAX_SET_CONSTRUCTORS) throw "Too many arguments";
			//型情報を習得
			var type = typeof(line);
			
			//元のデータを生成
			switch (type) {
				case TNull : Reflect.setField(originalClass, getValueName(), null);
				case TInt: Reflect.setField(originalClass,getValueName(),getInt(line));
				case TFloat: Reflect.setField(originalClass,getValueName(),getFloat(line));
				case TBool : Reflect.setField(originalClass,getValueName(),getBool(line));
				case TClass(c) : 
					switch(Type.getClassName(c)) {
						case "String" : Reflect.setField(originalClass, getValueName(), getString(line));
						case "Array" : 
							currentLine++;
							Reflect.setField(originalClass, getValueName(), getArray());
						//外部クラスの場合はインポートが必要
						default : currentLine++;
								  Reflect.setField(originalClass, getValueName(), getClass());
					}
				case TObject :
					currentLine++;
					Reflect.setField(originalClass, getValueName(), getObject());
				default : originalClass = null;
			}
			numberOfConstructors++;
			currentLine++;
		}
		return originalClass;
	}
	
	/**
	 * 整形シリアライズデータ文字列からObjectMap型のインスタンスを返す
	 * @return ObjectMap型のインスタンス
	 */
	private function getObjectMap() : ObjectMap <Dynamic,Dynamic> {
		var objectMap = new ObjectMap();
		var key : Dynamic = null;
		var value : Dynamic = null;
		
		if (isMapValueAndKeyNone()) return objectMap;
		
		while (true){
			//キーの型の習得
			var keyType = getMapKeyType();
			
			switch(keyType) {
				case TNull : key = null;
				case TInt :
					var keyStr = getMapPrimitiveKeyStr(line);
					key = getInt(keyStr);
				case TFloat:
					var keyStr = getMapPrimitiveKeyStr(line);
					key = getFloat(keyStr);
				case TBool :
					var keyStr = getMapPrimitiveKeyStr(line);
					key = getBool(keyStr);
				case TClass(c) : 
					switch(Type.getClassName(c)) {
						case "String" : 
							var keyStr = getMapPrimitiveKeyStr(line);
							key = getString(keyStr);
						case "haxe.ds.IntMap","haxe.ds.StringMap",
							 "haxe.ds.EnumValueMap","haxe.ds.ObjectMap" :
							//TODO マップの生成処理の実装
						case "Array" : 
							currentLine++;
							key = getArray();
						//外部クラスの場合はインポートが必要
						default : 
							currentLine++;
							key = getClass();
					}
				case TObject : 
					currentLine++;
					key = getObject();
				default : key = null;
			}
			
			//デバッグ
			trace("key => "+key);
			
			//値の型の取得
			var valueType = getMapValueType();
			
			switch(valueType) {
				case TNull : value = null;
				case TInt: 
					var valueStr = getMapPrimitiveValueStr(line);
					value = getInt(valueStr);
				case TFloat:
					var valueStr = getMapPrimitiveValueStr(line);
					value = getFloat(valueStr);
				case TBool :
					var valueStr = getMapPrimitiveValueStr(line);
					value = getBool(valueStr);
				case TClass(c) : 
					switch(Type.getClassName(c)) {
						case "String" : 
							var valueStr = getMapPrimitiveValueStr(line);
							value = getString(valueStr);
						case "haxe.ds.IntMap","haxe.ds.StringMap",
							 "haxe.ds.EnumValueMap", "haxe.ds.ObjectMap" :
							value = getObjectMap();
							//TODO マップの生成処理の実装
						case "Array" : 
							currentLine++;
							value = getArray();
						default : 
							currentLine++;
							value = getClass();
					}
				case TObject : 
					currentLine++;
					value = getObject();
				default : value = null;
			}
			
			//デバッグ
			trace("value => "+value);
			
			//取得した値とキーを登録
			objectMap.set(key, value);
			
			//文字列を取得
			currentLine++;
			line = FileTools.readLine(fileName, currentLine);
			//現在の行が空行だったらループを抜ける
			if (line == null) break;
			//マップ以外のインスタンスが宣言されていた場合はループを抜ける
			if (isNewInstance()) break;
		}
		
		return objectMap;
	}

	/**
	* 整形シリアライズデータ文字列からEnumのインスタンスを返す
	* ex)Enum名.Rgb(255,255,255)
	* @return Enumインスタンスの文字列
	**/
	private function getEnumValue () : Dynamic {
		var enumValue : Dynamic = "$getEnumName."; //Enum名.
		var r : EReg = ~/.$/;
		r.match(line);

		var value = r.matched(0); //','か'{'しかこない
		if(value == ","){
			enumValue += "$getPrimitiveValue"; //Enum名.Bar
			currentLine++;
		}
		else{
			enumValue += "$getPrimitiveValue("; //Enum名.Bar(
			while(!isEndOfInstance()){ //},がでてくるまで繰り返す
				enumValue += "$getOriginalValue()";
			}
			enumValue += ")"; //Enum名.Bar(10,20,30,)
			currentLine++;
		}
		return enumValue;
	}

	/**
	 * 現在の行がオブジェクト・クラス・配列の終わりを示す文字列であるかを取得
	 * @return　終わりを示す記号だった場合は真を返す
	 */
	private function isEndOfInstance() : Bool {
		//インデント文字列と「,」を除いた文字列が「}」なら真
		var str = StringTools.replace(line, '	', '');
		str = StringTools.replace(str, ',', '');
		if (str == '}' || str == ']') return true;
		else return false;
	}
	
	/**
	 * 現在の行が新たなインスタンスの生成部分であるかを取得
	 * @return  新たなインスタンス生成部分だったら真を返す
	 */
	private function isNewInstance() : Bool	{
		var str = StringTools.replace(line, '	', '');
		if (str.charAt(0) == '"' || str.charAt(0) == '_') return true;
		else return false;
	}
	
	/**
	 * 整形シリアライズ文字列の1行分のデータからクラス名を取得する
	 * SClassの次に記述される括弧内の文字列を抽出する
	 * @return クラス名の文字列
	 */
	private function getClassName() : String {
		var r : EReg = ~/SClass(.*) =/;	//クラス名を取り出す正規表現
		r.match(line);
		var value = r.matched(0);	//正規表現によって抽出された文字列を保持
		value = StringTools.replace(value, 'SClass','');//不要な文字の削除
		value = StringTools.replace(value, '(', '');	//「(」の削除
		value = StringTools.replace(value, ')', '');	//「)」の削除
		value = StringTools.replace(value, ' ', '');	//スペースの削除
		value = StringTools.replace(value, '=', '');	//「=」の削除
		return value.toString();
	}

	/**
	* 元のEnum名を取得
	* SEnumの次に記述される括弧内の文字列を抽出する
	* 例:(serializationReader.Color2) → serializationReader.Color2
	* (Color2) → Color2
	* @return 元のEnum名
	**/
	private function getEnumName() : String {
		var r : EReg = ~/SEnum(.*) =/;	//クラス名を取り出す正規表現
		r.match(line);
		var value = r.matched(0);	//正規表現によって抽出された文字列を保持
		value = StringTools.replace(value, 'SEnum','');//不要な文字の削除
		value = StringTools.replace(value, '(', '');	//「(」の削除
		value = StringTools.replace(value, ')', '');	//「)」の削除
		value = StringTools.replace(value, ' ', '');	//スペースの削除
		value = StringTools.replace(value, '=', '');	//「=」の削除
		return value.toString();
	}

	/**
	 * 整形シリアライズ文字列の1行分のデータから変数名を取得する
	 * ダブルクオーテーションで囲まれた部分を抽出する
	 * @return 変数名の文字列
	 */
	private function getValueName() : String {
		var r : EReg = ~/".*" : /;	//型名を取り出す正規表現
		r.match(line);
		var value = r.matched(0);	//正規表現によって抽出された文字列を保持
		value = StringTools.replace(value, ':','');		//「:」の削除
		value = StringTools.replace(value, '"', '');	//「"」の削除
		value = StringTools.replace(value, ' ', '');	//スペースの削除
		return value.toString();
	}
	
	/**
	 * 引数のシリアライズ文字列から値の部分の文字列を抽出して返す
	 * 「=」と「,」に囲まれた部分を抽出する。
	 * プリミティブ型の場合のみ正しく動作する
	 * @param str 整形シリアライズ文字列の現在処理する1行の文字列
	 * @return 値の文字列
	 */
	private function getPrimitiveValue(str : String) : String {
		var r : EReg = ~/=.*,/;	//型名を取り出す正規表現
		r.match(str);
		var value = r.matched(0);	//正規表現によって抽出された文字列を保持
		value = StringTools.replace(value, '=','');	//「=」の削除
		value = StringTools.replace(value, ',', '');//「,」の削除
		value = StringTools.replace(value, ' ', '');//スペースの削除
		return value.toString();
	}
	
	/**
	 * マップ(IntMap,StringMap,ObjectMap,SEnumValueMap)のキーの型を取得する
	 * @return マップのキーの型
	 */
	private function getMapKeyType() : ValueType {
		//マップのキーの部分の文字列を抽出し型情報を取得
		var r : EReg = ~/__mapKey.*->/;
		var keyTypeStr = "";
		
		//再帰が必要でない場合の型の抽出
		if (r.match(line)) {
			keyTypeStr = r.matched(0);	
		}
		//再帰が必要な場合の型の抽出
		else {
			r = ~/__mapKey.*=/;
			r.match(line);
			keyTypeStr = r.matched(0);
		}
		
		return typeof(keyTypeStr);
	}
	
	/**
	 * マップ(IntMap,StringMap,ObjectMap,SEnumValueMap)の値の型を取得する
	 * @return マップの値の型
	 */
	private function getMapValueType() : ValueType {
		//マップの値の部分の文字列を抽出し型情報を取得
		var r : EReg = ~/ __mapValue :.*=/;
		r.match(line);
		var valueTypeStr = r.matched(0);
		
		return typeof(valueTypeStr);
	}
	
	/**
	 * マップのプリミティブ型のキーの文字列部分を抽出する
	 * @param	str  マップ変数の整形シリアライズデータ
	 * @return  キーの文字列
	 */
	private function getMapPrimitiveKeyStr(str : String) : String {
		var r : EReg = ~/ __mapKey .* ->/;
		r.match(str);
		var mapKeyStr = r.matched(0);
		mapKeyStr = StringTools.replace(mapKeyStr, '-', '');
		mapKeyStr = StringTools.replace(mapKeyStr, '>', '');
		
		//getPrimitiveValueメソッドにて処理をするため「,」を付ける
		return mapKeyStr+",";
	}
	
	/**
	 * マップのプリミティブ型の値の文字列部分を抽出する
	 * @param	str  マップ変数の整形シリアライズデータ
	 * @return  値の文字列
	 */
	private function getMapPrimitiveValueStr(str : String) : String {
		var r : EReg = ~/ __mapValue .*\)/;
		r.match(str);
		var mapValueStr = r.matched(0);
		mapValueStr = StringTools.replace(mapValueStr, ')', '');
		
		//getPrimitiveValueメソッドにて処理をするため「,」を付ける
		return mapValueStr+",";
	}
	
	
	/**
	 * 読み込んだ行のマップ変数の値はキーと値が登録されているかを判定
	 * @return 登録されていない場合は真を返す
	 */
	private function isMapValueAndKeyNone() : Bool {
		var r : EReg = ~/__mapKey : __none = __none -> __mapValue : __none = __none/;
		return r.match(line);
	}
	
	/**
	 * 読み込んだ行がマップ変数のキーの終わりであるかを判定
	 * @return キーの終わりを示す文字列であれば真を返す
	 */
	private function isMapKeyEnd() : Bool {
		var r : EReg = ~/[\]\}] -> __mapValue/;
		return r.match(line);
	}
	
	/**
	 * 読み込んだ行がマップ変数の値の終わりであるかを判定
	 * @return 値の終わりを示す文字列であれば真を返す
	 */
	private function isMapValueEnd() : Bool {
		var r : EReg = ~/\)/;
		return r.match(line);
	}
	
	/**
	 * 整形シリアライズ文字列1行がクラス型のデータであるかを判定
	 * @return クラス型であった場合には真を返す
	 */
	private function isClass() : Bool {
		var r : EReg = ~/ SClass\(.*\) /;
		return r.match(line);
	}
	
	/**
	 * 整形シリアライズ文字列1行がMap型のデータであるかを判定
	 * @return SIntMap・SStringMap・SEnumValueMap・SObjectMapの場合は真を返す
	 */
	private function isMap() : Bool {
		var r : EReg = ~/: S.*Map = \(/;
		return r.match(line);
	}
	
	/**
	* 整形シリアライズ文字列1行がEnum型のデータであるかを判定
	* @return Enum型であった場合には真を返す
	**/
	private function isEnum() : Bool {
		var r : EReg = ~/ SEnum\(.*\) /;
		return r.match(line);
	}
	
	/**
	 * 整形シリアライズ文字列の1行分のデータから型情報を取り出す
	 * @param str 型を取得したい文字列
	 * @return データの型
	 */
	private function typeof(str :String) : ValueType {
		var type = "";	//型情報を保持する文字列
		
		//型が外部クラスだった場合はリゾルバクラスを取得する
		if (isClass()) {
			var className = getClassName();
			var resolveClass = Type.resolveClass(className);
			return TClass(resolveClass);
		}else if(isEnum()) {
			var enumName = getEnumName();
			var resolveClass = Type.resolveEnum(enumName);
			return TEnum(resolveClass);
		}
		//型が外部クラスでない場合は型名を取得
		else {
			var r : EReg = ~/:.*=/;	//型名を取り出す正規表現
			r.match(str);
			type = r.matched(0);	//正規表現によって抽出された文字列を保持
			type = StringTools.replace(type, ':','');	//「:」の削除
			type = StringTools.replace(type, '=', '');	//「=」の削除
			type = StringTools.replace(type, ' ', '');	//スペースの削除
		}
		
		//型情報を元にTypeのEnumコンストラクタを返す
		switch (type) {
			case "SNull"	: return TNull;
			case "SInt"		: return TInt;
			case "SFloat"	: return TFloat;
			case "SBool"	: return TBool;
			case "SObject"	: return TObject;
			case "SFunction": return TFunction;
			case "SArray"	: return TClass(Array);
			case "SString"	: return TClass(String);
			case "SIntMap"		: return TClass(haxe.ds.IntMap);
			case "SStringMap"	: return TClass(haxe.ds.StringMap);
			case "SEnumValueMap": return TClass(haxe.ds.EnumValueMap);
			case "SObjectMap"	: return TClass(haxe.ds.ObjectMap);
			case "SUnknown" : return TUnknown;
			default			: return TUnknown;
		}
	}
}
