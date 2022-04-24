local gears	= require("gears")

--typesafe function overloader (copied from lua-users.org) {{{
--source: http://lua-users.org/wiki/OverloadedFunctions
local function overloaded()
        local fns = {}
        local mt = {}
        local function oerror()
            return error("Invalid argument types to overloaded function")
        end
        function mt:__call(...)
            local arg = {...}
            local default = self.default
            local signature = {}
            for i,arg in ipairs {...} do
                signature[i] = type(arg)
            end
            signature = table.concat(signature, ",")
            return (fns[signature] or self.default)(...)
        end
        function mt:__index(key)
            local signature = {}
            local function __newindex(self, key, value)
                print(key, type(key), value, type(value))
                signature[#signature+1] = key
                fns[table.concat(signature, ",")] = value
                print("bind", table.concat(signature, ", "))
            end
            local function __index(self, key)
                print("I", key, type(key))
                signature[#signature+1] = key
                return setmetatable({}, { __index = __index, __newindex = __newindex })
            end
            return __index(self, key)
        end
        function mt:__newindex(key, value)
            fns[key] = value
        end
        return setmetatable({ default = oerror }, mt)
    end
--}}}

local function dec_hex(IN)
    local B,K,OUT,I,D=16,"0123456789ABCDEF","",0
    while IN>0 do
        I=I+1
        IN,D=math.floor(IN/B),(IN%B)+1
        OUT=string.sub(K,D,D)..OUT
    end
    return #OUT == 2 and OUT or "0" .. OUT
end

-- color helpers {{{
local color = {}

color.col_shift = overloaded()
color.col_shift.string.number = function(c, s)
	local r,g,b,o = gears.color.parse_color(c)
	return "#" .. dec_hex(r*255+s)
		.. dec_hex(g*255+s)
		.. dec_hex(b*255+s)
		.. dec_hex(o*255)
end
color.col_shift.string.number.number.number = function(c,sr,sg,sb)
	local r,g,b,o = gears.color.parse_color(c)
	return "#" .. dec_hex(r*255+sr)
		.. dec_hex(g*255+sg)
		.. dec_hex(b*255+sb)
		.. dec_hex(o*255)
end
color.col_shift.string.number.number.number.number = function(c,sr,sg,sb,so)
	local r,g,b,o = gears.color.parse_color(c)
	return "#" .. dec_hex(r*255+sr)
		.. dec_hex(g*255+sg)
		.. dec_hex(b*255+sb)
		.. dec_hex(o*255+so)
end

color.col_diff = function(f, s)
	local fr, fg, fb, fo = gears.color.parse_color(f)
	local sr, sg, sb, so = gears.color.parse_color(s)
	return sr-fr,sg-fg,sb-fb,so-fo
end
--}}}
return {
	color	= color
}
