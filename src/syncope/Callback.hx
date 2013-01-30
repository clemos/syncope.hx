package syncope;

#if ( !display && !syncope_sync )
@:autoBuild( syncope.macro.Callback.build() )
#end
interface Callback {}