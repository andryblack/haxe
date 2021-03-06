/*
 * Copyright (C)2005-2012 Haxe Foundation
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */
import lua.Boot;

@: keepInit
@: coreApi class Std
{

	public static function is( v : Dynamic, t : Dynamic ) : Bool
	{
		// TODO: __ename__ Enums
		// TODO basic types & funtions detection
		if (lua.Lib.getmetatable(v) == t) return true;
		return v != null && t != null && Std.instance( v, t ) != null;
	}

	public static function instance < T: {}, S: T > ( value : T, c : Class<S> ) : S
	{
		untyped __lua__("if(value == nil)then return nil end
		local mt = getmetatable(value)
		if(mt == c)then return value end
		while(mt ~= nil)do
		mt = mt.__super__
		if(mt == c and mt ~= Object)then return value end
		end
		if(type(value) == 'number' and c == Int)then return value end
		if(type(value) == 'number' and c == Float)then return value end
		if(type(value) == 'string' and c == String)then return value end
		");
		return null;
	}

	// redeclared in genlua
	public static function string( s : Dynamic ) : String return "#null";

	public static inline function int( x : Float ) : Int
	{
		return x > 0 ? lua.LuaMath.floor(x) : lua.LuaMath.ceil(x);
		//(cast x) | 0;
	}

	public static function parseInt( x : String ) : Null<Int>
	{
		return untyped __global__(tonumber, x);
		/*var v = untyped __lua__("parseInt")(x, 10);
		// parse again if hexadecimal
		if ( v == 0 && (x.charCodeAt(1) == 'x'.code || x.charCodeAt(1) == 'X'.code) )
			v = untyped __lua__("parseInt")(x);
		if ( untyped __lua__("isNaN")(v) )
			return null;
		return cast v;*/
	}

	public static inline function parseFloat( x : String ) : Float
	{
		return untyped __global__(tonumber, x);
	}

	public static function random( x : Int ) : Int
	{
		return untyped x <= 0 ? 0 : Math.floor(Math.random() * x);
		// math.random(0,x-1)
	}

	static function __init__() : Void untyped
	{
		/*__feature__("lua.Boot.getClass", String.prototype.__class__ = __feature__("Type.resolveClass", $hxClasses["String"] = String, String));
		__feature__("lua.Boot.isClass", String.__name__ = __feature__("Type.getClassName", ["String"], true));
		__feature__("Type.resolveClass", $hxClasses["Array"] = Array);
		__feature__("lua.Boot.isClass", Array.__name__ = __feature__("Type.getClassName", ["Array"], true));
		__feature__("Date.*", {
			__feature__("lua.Boot.getClass", __lua__('Date').prototype.__class__ = __feature__("Type.resolveClass", $hxClasses["Date"] = __lua__('Date'), __lua__('Date')));
			__feature__("lua.Boot.isClass", __lua__('Date').__name__ = ["Date"]);
		});
		__feature__("Int.*", {
			var Int = __feature__("Type.resolveClass", $hxClasses["Int"] = { __name__ : ["Int"] }, { __name__ : ["Int"] });
		});
		__feature__("Dynamic.*", {
			var Dynamic = __feature__("Type.resolveClass", $hxClasses["Dynamic"] = { __name__ : ["Dynamic"] }, { __name__ : ["Dynamic"] });
		});
		__feature__("Float.*", {
			var Float = __feature__("Type.resolveClass", $hxClasses["Float"] = __lua__("Number"), __lua__("Number"));
			Float.__name__ = ["Float"];
		});
		__feature__("Bool.*", {
			var Bool = __feature__("Type.resolveEnum", $hxClasses["Bool"] = __lua__("Boolean"), __lua__("Boolean"));
			Bool.__ename__ = ["Bool"];
		});
		__feature__("Class.*", {
			var Class = __feature__("Type.resolveClass", $hxClasses["Class"] = { __name__ : ["Class"] }, { __name__ : ["Class"] });
		});
		__feature__("Enum.*", {
			var Enum = {};
		});
		__feature__("Void.*", {
			var Void = __feature__("Type.resolveEnum", $hxClasses["Void"] = { __ename__ : ["Void"] }, { __ename__ : ["Void"] });
		});*/

		/*__feature__("Array.map",
		if ( Array.prototype.map == null )
		Array.prototype.map = function(f)
		{
		var a = [];
			for ( i in 0...__this__.length )
				a[i] = f(__this__[i]);
			return a;
		}
				   );
		__feature__("Array.filter",
		if ( Array.prototype.filter == null )
		Array.prototype.filter = function(f)
		{
		var a = [];
			for ( i in 0...__this__.length )
			{
				var e = __this__[i];
				if ( f(e) ) a.push(e);
			}
			return a;
		}
				   );*/
	}
}