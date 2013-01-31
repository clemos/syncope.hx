package syncope.test;

class SomeLib implements syncope.Callback {

	var whatever = "HI";

	public function new(){}

	@:makeCallback
	public static function test( val : Int ) : String {
		if( val > 5 )
			return Std.string(val);

		return null;
	}

	public static function notAsync( test : String ) {
		trace("TESSSST" + test);
		return;
	}

	@:makeCallback
	@:async
	public function test2( val : Int ) : String {
		return whatever;
	}

}

