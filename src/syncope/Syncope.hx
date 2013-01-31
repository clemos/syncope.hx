package syncope;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
#end

class Syncope {

	public static inline var asyncMeta = ":async";
	
	@:macro
	public static function run( e : Expr ){
		#if ( display || syncope_sync )
			return e;
		#else
			return transform( e ).expr;
		#end
	}

	#if macro
	static function transform( e : Expr , ?block : Array<Expr> = null ) : { expr : Expr , block : Array<Expr> } {
		
		switch( e.expr ){
			case EBlock( exprs ) :
				var currentBlock = [];
				var appendBlock = ( block != null ) ? block : currentBlock;
				
				for( e1 in exprs ){
					var w = transform( e1 , block );
					var e2 = w.expr;
					var newBlock = w.block;

					appendBlock.push( e2 );

					if( newBlock != null )
						appendBlock = newBlock;
					
				}
				e.expr = EBlock( currentBlock );

			case EVars( vars ) :
				var outp = [];
				for( v in vars ){
					switch( v.expr.expr ){
						case ECall( e1 , params ) :
							if( isAsync( e1 ) ){
								block = [];
								params.push( {
									expr : EFunction( null , {
										ret : null,
										expr : {
											pos : v.expr.pos,
											expr : EBlock( block )
										},
										params : [],
										args : [
											{ 
												name : v.name,
												opt : false,
												type : null,
												value : null
											}
										]
									} ),
									pos : v.expr.pos
								} );
							}else{
								var w = transform( v.expr , block );
								v.expr = w.expr;
								block = w.block;
							}

							outp.push( v );

						default:
							var w = transform( v.expr , block );
							v.expr = w.expr;
							block = w.block;
							outp.push( v );
					}
				}
				e.expr = EVars( outp );

			case EWhile( cond , body , normalWhile ) :
				e.expr = EWhile( cond , transform( body , block ).expr , normalWhile );

			case EFor( it , body ) :
				e.expr = EFor( it , transform( body , block ).expr );

			case EIf( cond , eif , eelse ) :
				e.expr = EIf( cond , transform( eif , block ).expr , (eelse==null) ? null : transform( eelse , block ).expr );

			default :
				if( block != null )
					block.push( e );

		
		}

		var r = { expr : e , block : block };
		
		return r;
		
	}

	static function isAsync( e : Expr ){

		switch( e.expr ){
			case EField( e2 , methodName ) :
				//trace("e2 : "+Context.typeof( e2 ));
				var eType = Context.typeof( e2 );
				//trace( e2.expr );
				switch( eType ){
					case TInst( t , params ) :
						//trace(t.get());
						for( f in t.get().fields.get() ){
							if( f.name == methodName 
								&& f.meta.has( asyncMeta ) ){
								return true;
							}
						}
					default:
				}
				switch( e2.expr ){
					case EConst( c ) :
						switch( c ){
							case CIdent( cl ) :
								//trace("type of " + cl );

								switch( Context.getType( cl ) ){
									case TInst( ref , params ) :
										for( m in ref.get().statics.get() ){
											if( m.name == methodName 
												&& m.meta.has(asyncMeta) ){
												return true;
											}
										}
										//trace();
									default:
								}
							default:
						}
					default:
				}
			default:
		}
		
		return false;
	}

	#end

}