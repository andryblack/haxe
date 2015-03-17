all:
#	../../haxe compile-js.hxml
	../../haxe compile-lua.hxml
# -D dump=pretty
	/usr/local/bin/luajit -joff bin/unit.lua
	/usr/local/bin/luajit -joff bin/unit.lua > lua.yml
#	/usr/local/bin/lua ./bin/unit.lua