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

package lua;

class Lib
{
	inline static public function eval(code: String): Dynamic
	return (untyped __global__(dostring, code));

	inline static public function setmetatable<T>(obj: T, mt: Class<Dynamic>): T
	return (untyped __call__("setmetatable", obj, mt));

	inline static public function setmetatabledef<T>(obj: T, mt: Metatable): T
	return (untyped __call__("setmetatable", obj, mt));

	inline static public function getmetatable<T>(obj: T): Metatable
	return (untyped __call__("getmetatable", obj));

	/** Pack multiple returns of function into LuaArray **/
	@: extern inline static public function _pack(arg: Dynamic): LuaArray<Dynamic>
	return cast untyped pack(arg);

	/**
		Inserts '#' char before expression
	**/
	inline static public function hash(obj: Dynamic): Int
	return cast untyped __hash__(obj);

	/**
		Display an alert message box containing the given message
	**/
	public static function alert( v : Dynamic )
	{
		untyped __lua__("alert")(lua.Boot.__string_rec(v, ""));
	}

	/**
		Inserts a `require` expression that loads JavaScript object from
		a module or file specified in the `module` argument.

		This is only supported in environments where `require` function
		is available, such as Node.js or RequireJS.
	**/
	public static inline function require( module: String ) : Dynamic
	{
		return untyped __lua__("require")(module);
	}

	/**
		Returns JavaScript `undefined` value.

		Note that this is only needed in very rare cases when working with external JavaScript code.

		In Haxe, `null` is used to represent the absence of a value.
	**/
	public static var undefined(get, never) : Dynamic;
	static inline function get_undefined() : Dynamic
	{
		return untyped __lua__("undefined");
	}
}
