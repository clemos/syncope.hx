package syncope.test;

import syncope.test.SomeLib;

class Main {

	static var lib : SomeLib;
	
	public static function main(){
		var lib = new SomeLib();

		Syncope.run( {
			//var lib = ;
			var b = SomeLib.test( 1 );
			//

			var test = Main.lib.test2( 1 );
			trace(b);

			
			/*for( i in 0...10 ){
				if( i > 5 ){
					var toto = SomeLib.test( i );
					var toto2 = SomeLib.test( i+1 );
					SomeLib.notAsync(toto2);
				}
			}*/
		} );

	}
}
