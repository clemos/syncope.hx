package syncope.macro;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
#end

class Callback {

	public static inline var callbackMeta = ":makeCallback";
	public static inline var callbackName = "onDone";

	@:macro
	public static function build() : Array<Field> {

		var pos = Context.currentPos();
        var fields = Context.getBuildFields();

        for( f in fields ){
        	var isMarked = false;

        	for( m in f.meta ){
        		if( m.name == callbackMeta ){
        			isMarked = true;
        			break;
        		}
        	}

        	if( isMarked ){
        		
        		f.meta.push( {
        			pos : f.pos,
        			name : Syncope.asyncMeta,
        			params : []
        		} );
        		
        		var void = TPath( { sub : null , name : "Void" , pack : [] , params : [] } );

	        	switch( f.kind ){
	        		case FFun( fun ) : 
	        			
	        			var returnType = fun.ret;
	        			var params = if( returnType == null ) [] else [returnType];

	        			var callbackType = TFunction(
	        				params, 
	        				void
	        			);

	        			fun.args.push( {
	        				name : callbackName,
	        				type : callbackType,
	        				opt : false,
	        				value : null
	        			} );

	        			/*var body = [transform( fun.expr )];
	        			body.push( macro { return; } );
	        			fun.expr = { pos : pos , expr : EBlock( body ) };*/
	        			fun.expr = transform( fun.expr );


	        			fun.ret = void;

	        		default : 
	        			throw "not a function";
	        	}
	        }
        }
        
		return fields;
	}

	#if macro
	static function transform( e : Expr ) : Expr {
		
		switch( e.expr ){
			case EBlock( exprs ) :
				var out = [];
				for( e1 in exprs ){
					out.push( transform( e1 ) );
				}
				e.expr = EBlock( out );

			case EWhile( cond , body , normalWhile ) :
				e.expr = EWhile( cond , transform( body ) , normalWhile );

			case EFor( it , body ) :
				e.expr = EFor( it , transform( body ) );

			case EIf( cond , eif , eelse ) :
				e.expr = EIf( cond , transform( eif ) , (eelse==null) ? null : transform( eelse ) );

			case EReturn( e1 ) :
				e = macro return onDone( $e1 );

			default : 
				// leave as is
		}
		
		return e;

	}
	#end
}