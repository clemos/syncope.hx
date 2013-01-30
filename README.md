Syncope.hx
==========

A minimalistic async library for Haxe

No fancy [Promises](https://github.com/jdonaldson/promhx), 
[Monads](https://code.google.com/p/hxmonads/), 
[Continuations](https://github.com/Atry/haxe-continuation) or whatever, 
Syncope.hx's primary goal is to provide a basic compatibility layer between 
asynchronous platforms (like node.js) and synchronous platforms (like php).

**It's currently very basic, largely untested, and quite experimental.**

## Usage

### Transforming synchronous signatures to asynchronous

In a class that implements `syncope.Callback`, methods marked with the `@:makeCallback` meta 
will be automatically translated to an asynchronous method. 

For instance, a class such as :
```haxe
class MyLibrary implements syncope.Callback {
  @:makeCallback
  @:async // we'll see this later
  public static function test( val : Int ) : String {
    if( val > 5 )
      return Std.string(val);
    return null;
  }  
}
```
will be translated to something like :
```haxe
class MyLibrary {
  public static function test( val : Int , onDone : String -> Void ) : Void {
    if( val > 5 )
      return onDone( Std.string(val) );
    return onDone( null );
  }  
}
```

### Transforming synchronous code to asynchronous code

Code executed through the `syncope.Syncope.run` macro translates calls of methods marked with the `@:async` meta, 
so that this code :
```
Syncope.run({
   var str1 = MyLibrary.test( 1 );
   var str2 = MyLibrary.test( 2 );
   trace( str1 );
   trace( str2 );
});
```
would become something like that :
```
var str1 = MyLibrary.test( 1 , function( str1 ){
  var str2 = MyLibrary.test( 2 , function( str2 ){
    trace( str1 );
    trace( str2 );
  } );
} );
```
For now, only simple `var` declarations get translated properly, so the following code *won't work* :
```
Syncope.run({ 
  trace( MyLibrary.test( 1 ) );
});
```
Please also note that the variable declaration (`var str1 = ...`) is kept, but could probably be removed. 
This should have no side effect, and might be actually removed in the future.

### Compiling to a "synchronous" platform

Even though the tranformed code should work correctly on "synchronous" platforms such as PHP, 
you will likely prefer to have your code compiled without the callbacks, 
since it should in theory behave petty much the same way...

The compiler flag `syncope_sync` acts as a noop, so compiling with `-D syncope_sync` will leave 
classes implementing `syncope.Callback` and code executed with `Syncope.run` as-is.
