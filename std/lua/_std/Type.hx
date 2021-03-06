/*
 * Copyright (C)2005-2015 Haxe Foundation
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
enum ValueType
{
	TNull;
	TInt;
	TFloat;
	TBool;
	TObject;
	TFunction;
	TClass( c : Class<Dynamic> );
	TEnum( e : Enum<Dynamic> );
	TUnknown;
}

@: coreApi class Type
{

	public static inline function getClass<T>( o : T ) : Class<T>
	{
		return if (o == null) null else @: privateAccess lua.Boot.getClass(o);
	}

	public static function getEnum( o : EnumValue ) : Enum<Dynamic> untyped
	{
		if ( o == null )
			return null;
		return o.__enum__;
	}

	public static function getSuperClass( c : Class<Dynamic> ) : Class<Dynamic> untyped
	{
		return c.__super__;
	}


	public static function getClassName( c : Class<Dynamic> ) : String
	{
		var a : Array<String> = untyped c.__name__;
		if (a == null)
			return null;
		return a.join(".");
	}

	public static function getEnumName( e : Enum<Dynamic> ) : String
	{
		var a : Array<String> = untyped e.__ename__;
		return a.join(".");
	}

	public static function resolveClass( name : String ) : Class<Dynamic> untyped
	{
		var cl : Class<Dynamic> = hxClasses[name];
		// ensure that this is a class
		if ( cl == null || !lua.Boot.isClass(cl) )
			return null;
		return cl;
	}

	public static function resolveEnum( name : String ) : Enum<Dynamic> untyped
	{
		var e : Dynamic = hxClasses[name];
		// ensure that this is an enum
		if ( e == null || !lua.Boot.isEnum(e) )
			return null;
		return e;
	}

	public static function createInstance<T>( cl : Class<T>,
			args : Array<Dynamic> ) : T untyped
	{
		switch ( args.length )
		{
		case 0:
			return __new__(cl);
		case 1:
			return __new__(cl, args[0]);
		case 2:
			return __new__(cl, args[0], args[1]);
		case 3:
			return __new__(cl, args[0], args[1], args[2]);
		case 4:
			return __new__(cl, args[0], args[1], args[2], args[3]);
		case 5:
			return __new__(cl, args[0], args[1], args[2], args[3], args[4]);
		case 6:
			return __new__(cl, args[0], args[1], args[2], args[3], args[4], args[5]);
		case 7:
			return __new__(cl, args[0], args[1], args[2], args[3], args[4], args[5], args[6]);
		case 8:
			return __new__(cl, args[0], args[1], args[2], args[3], args[4], args[5], args[6],
			args[7]);
		default:
			throw "Too many arguments";
		}
		return null;
	}

	public static function createEmptyInstance<T>( cl : Class<T> ) : T
	{
		return untyped __lua__("(setmetatable({}, cl))");
	}

	public static function createEnum<T>( e : Enum<T>, constr : String,
										  ? params : Array<Dynamic> ) : T
	{
		var f: Dynamic = Reflect.field(e, constr);
		if ( f == null ) throw "No such constructor " + constr;
		if ( Reflect.isFunction(f) )
		{
			if ( params == null ) throw "Constructor " + constr + " need parameters";
			return Reflect.callMethod(e, f, params);
		}
		if ( params != null && params.length != 0 )
			throw "Constructor " + constr + " does not need parameters";
		return f;
	}

	public static function createEnumIndex<T>( e : Enum<T>, index : Int,
			? params : Array<Dynamic> ) : T
	{
		var c : String = (untyped e.__constructs__)[index];
		if ( c == null ) throw index + " is not a valid enum constructor index";
		return createEnum(e, c, params);
	}

	public static function getInstanceFields( c : Class<Dynamic> ) : Array<String>
	{
		var a = [];

		// TODO untyped __lua__("--for(var i in c.prototype) a.push(i)");

		untyped __lua__("for key, value in pairs (c) do a:push(key); end");

		a.remove("__class__");
		a.remove("__properties__");

		a.remove("__name__");
		a.remove("__interfaces__");
		a.remove("__properties__");
		a.remove("__super__");
		a.remove("__meta__");
		a.remove("prototype");

		return a;
	}

	public static function getClassFields( c : Class<Dynamic> ) : Array<String>
	{
		var a = Reflect.fields(c);
		a.remove("__name__");
		a.remove("__interfaces__");
		a.remove("__properties__");
		a.remove("__super__");
		a.remove("__meta__");
		a.remove("prototype");
		return a;
	}

	public static function getEnumConstructs( e : Enum<Dynamic> ) : Array<String>
	{
		var a : Array<String> = untyped e.__constructs__;
		return a.copy();
	}

	public static function typeof( v : Dynamic ) : ValueType untyped
	{
		if (v == null) return TNull;
		var t: String = untyped type(v);

		if (t == "string")
		{
			return TClass(String);
		}
		else if (t == "boolean") return TBool;
		else if (t == "number")
		{
			try
			{
				var f = untyped math.modf;
				var i = f(v);
				if (i == v) return TInt;
			}
			catch (e: Dynamic) trace(e);
			return TFloat;
		}
		else if (t == "function") return TFunction;
		else if (t == "table")
		{
			var mt = lua.Lib.getmetatable(v);
			if (mt == untyped Object) return TObject;
			else
				return TClass(cast mt);
		}

		// TODO TEnum( e : Enum<Dynamic> );

		return TUnknown;

		/*switch ( __lua__("typeof")(v) )
		{
		case "boolean": return TBool;
		case "string": return TClass(String);
		case "number":
			// this should handle all cases : NaN, +/-Inf and Floats outside range
			if ( Math.ceil(v) == v % 2147483648.0 )
				return TInt;
			return TFloat;
		case "object":
			if ( v == null )
				return TNull;
			var e = v.__enum__;
			if ( e != null )
				return TEnum(e);
			var c = lua.Boot.getClass(v);
			if ( c != null )
				return TClass(c);
			return TObject;
		case "function":
			if ( lua.Boot.isClass(v) || lua.Boot.isEnum(v) )
				return TObject;
			return TFunction;
		case "undefined":
			return TNull;
		default:
			return TUnknown;
		}*/
	}

	public static function enumEq<T>( a : T, b : T ) : Bool untyped
	{
		if ( a == b )
			return true;
		try {
			if ( a[0] != b[0] )
				return false;
			for ( i in 2...a.length )
				if ( !enumEq(a[i], b[i]) )
					return false;
			var e = a.__enum__;
			if ( e != b.__enum__ || e == null )
				return false;
			if (lua.Lib.getmetatable(a) != lua.Lib.getmetatable(b)) return false;
		}
		catch ( e : Dynamic )
		{
			return false;
		}
		return true;
	}

	public inline static function enumConstructor( e : EnumValue ) : String
	{
		return untyped e[0];
	}

	public inline static function enumParameters( e : EnumValue ) : Array<Dynamic>
	{
		return untyped e.slice(2);
	}

	public inline static function enumIndex( e : EnumValue ) : Int
	{
		return untyped e[1];
	}

	public static function allEnums<T>( e : Enum<T> ) : Array<T>
	{
		return untyped e.__empty_constructs__;
	}

}

