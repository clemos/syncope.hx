package syncope;

class Test {
	
	public static function main(){
		Syncope.run( {
			for( i in 0...10 ){
				if( i > 5 ){
					var toto = SomeLib.test( i );
					var toto2 = SomeLib.test( i+1 );
					SomeLib.notAsync(toto2);
				}
			}
		} );

	}
}

class SomeLib implements syncope.Callback {

	@:makeCallback
	@:async
	public static function test( val : Int ) : String {
		if( val > 5 )
			return Std.string(val);

		return null;
	}

	public static function notAsync( test : String ) {
		trace("TESSSST" + test);
		return;
	}

}
