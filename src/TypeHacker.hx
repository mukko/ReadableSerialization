package ;
import haxe.macro.Context;
import haxe.macro.Expr.ExprDef;

#if macro
import haxe.macro.Compiler;
import haxe.macro.Expr;
#end

class TypeHacker {
	
	#if macro
	public static function run():Void {
		Compiler.addMetadata('@:build(TypeHacker.hack())', 'Type');
	}
	
	private static function hack():Array<Field> {
		var fields = Context.getBuildFields();
		for (field in fields) {
			switch (field) {
				case { name: 'createEmptyInstance', kind: FFun(f) } :
					f.expr = macro untyped {
						var o = __dollar__new(null);
						__dollar__objsetproto(o, cl.prototype);
						Reflect.setField(o, '_readable_serialization_class_name_', cl);
						return o;
					};
				case { name: 'createEnum', kind: FFun(f) } :
					f.expr = macro untyped { return DummyEnum.Dummy_Enum(e, constr, params); };
				case _ :
					
			}
		}
		
		return fields;
	}
	#end
}
