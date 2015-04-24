package serializationReader;

import sys.io.File;

/**
 * ファイルの読み込みと書き込みを行う
 */

class FileTools {
	private static var SR_FILE_OUT_STR : String = "sr_";
	
	/**
	 * String型の文字列をテキストファイルに出力する
	 * @param	output 出力する文字列
	 * @param	fileName  出力するテキストファイル名
	 * @return  出力したファイル名
	 */
	public static function outputString(output : String, fileName : String) : String {
		//ディレクトリ名を含まないファイル名だけの文字列を抽出
		var pos = fileName.lastIndexOf('/');
		fileName = fileName.substr(pos + 1);
		//シリアライズエディタの出力ファイルであることを示す文字列を挿入
		fileName = SR_FILE_OUT_STR + fileName;
		
		var fileOut = File.write(fileName);
		fileOut.writeString(output);
		fileOut.close();
		
		return fileName;
	}
	
	/**
	 * テキストファイルから文字列を取得する
	 * 指定したファイルが無かった場合はnullを返す
	 * @param	fileName 読み込むテキストファイル名
	 * @return  読み込んだテキストファイルのデータ
	 */
	public static function readTextFile(fileName : String) : String {
		try {
			return File.getContent(fileName);
		}catch( unknown : Dynamic ){
			return null;
		}
	}
	
	/**
	 * テキストファイルから指定した1行を取得し返す
	 * @param	fileName 読み取るテキストファイル名
	 * @param	lineNumber 読み取る行
	 * @return 取得した1行の文字列
	 */
	public static function readLine(fileName, lineNumber) : String {
		var fin = sys.io.File.read(fileName, false);
		var line = "";
		try {
			for (i in 0...lineNumber) {
				fin.readLine();	
			}
			line = fin.readLine();
			fin.close();
		} catch (e:haxe.io.Eof) { return null; }
		return line;
	}
}
