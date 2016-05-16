/**
 * Created by rhett on 14/11/2.
 */
package td.core
{

	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

	public class ReusablePool
	{
		private static var pools:Dictionary = new Dictionary();

		private static function getPool( type:Class ):Array
		{
			return type in pools ? pools[type] : pools[type] = new Array();
		}

		public static function getObject( type:Class, ...parameters ):*
		{
			var pool:Array = getPool( type );
			if ( pool.length > 0 )
			{
				return pool.pop();
			}
			else
			{
				return getNewClass( type, parameters );
			}
		}

		public static function addToPool( object:*, type:Class = null ):void
		{
			if (object == null)	return;
			if ( !type )
			{
				var typeName:String = getQualifiedClassName( object );
				type = getDefinitionByName( typeName ) as Class;
			}
			var pool:Array = getPool( type );
			if(pool.indexOf(object) == -1)
			{
				pool.push( object );
			}
		}

		private static function getNewClass( classRef:Class, initParms:Array ):*
		{
			if (initParms && initParms.length)
			{
				switch(initParms.length)
				{
					case 1:
						return new classRef( initParms[0] );
					case 2:
						return new classRef( initParms[0], initParms[1] );
					case 3:
						return new classRef( initParms[0], initParms[1], initParms[2] );
					case 4:
						return new classRef( initParms[0], initParms[1], initParms[2], initParms[3] );
					case 5:
						return new classRef( initParms[0], initParms[1], initParms[2], initParms[3], initParms[4] );
				}
			}
			return new classRef();
		}
	}
}
