LUA_LIB = -L/usr/local/bin -llua53
LUA_INC = -I/usr/local/include

sha1.dll : lsha1.c
	gcc -Wall -O2 --shared -o $@ $^ $(LUA_LIB) $(LUA_INC)

clean :
	rm -rf sha1.dll

install : Chinese.xml
	lua import.lua && cp $^ "/c/Users/cloudwu/Documents/Rogue's Tale/2.0/mods/locales"