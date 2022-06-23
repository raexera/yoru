local utils = require(COLOR_DIR.."utils")

--constants for clarity
local ANY = {"r", "g", "b", "h", "s", "l", "hex", "a"}
local ANYSUBHEX = {"r", "g", "b", "h", "s", "l", "a"}
local RGB = {"r", "g", "b"}
local HSL = {"h", "s", "l"}
local HEX = {"hex"}

--create a color object
local function color(args)
	-- The object that will be returned
	local obj = {_props = {}}

	-- Default properties here
	obj._props.r = args.r or 0
	obj._props.g = args.g or 0
	obj._props.b = args.b or 0
	obj._props.h = args.h or 0
	obj._props.s = args.s or 0
	obj._props.l = args.l or 0
	obj._props.a = args.a or 1
	obj._props.hex = args.hex and args.hex:gsub("#", "") or "000000"

	obj._props.small_rgb = args.small_rgb or false

	-- Default actual normal properties
	obj.hashtag = args.hashtag or true
	obj.disable_hsl = args.disable_hsl or false

	-- Set access to any
	obj._access = ANY

	--temporary values
	--alpha since it can be nil and don't wanna overwrite,
	--hex_no_alpha just as a placeholder in _alphaize_hex
	local alpha, hex_no_alpha

	-- Methods and stuff
	function obj:_hex_to_rgba()
		obj._props.r, obj._props.g, obj._props.b, alpha = utils.hex_to_rgba(obj._props.hex)
		if alpha then self._props.a = alpha end
		if obj._props.small_rgb then
			obj._props.r = math.floor(obj._props.r / 255)
			obj._props.g = math.floor(obj._props.g / 255)
			obj._props.b = math.floor(obj._props.b / 255)
		end
	end
	function obj:_rgba_to_hex()
		obj._props.hex = utils.rgba_to_hex(obj._props)
	end
	function obj:_rgb_to_hsl()
		obj._props.h, obj._props.s, obj._props.l = utils.rgb_to_hsl(obj._props)
	end
	function obj:_hsl_to_rgb()
		obj._props.r, obj._props.g, obj._props.b = utils.hsl_to_rgb(obj._props)
	end
	function obj:_alphaize_hex()
		hex_no_alpha = #obj._props.hex == 6 and obj._props.hex or obj._props.hex:sub(1, 6)
		obj._props.hex = hex_no_alpha..(obj._props.a ~= 1
			and string.format("%02x", math.floor(obj._props.a*255)) or "")
	end
	function obj:set_no_update(key, value)
		obj._props[key] = value
	end

	-- Initially set other values
	if obj._props.r ~= 0 or obj._props.g ~= 0 or obj._props.b ~= 0 then
		obj:_rgba_to_hex()
		if not obj.disable_hsl then obj:_rgb_to_hsl() end

	elseif obj._props.hex ~= "000000" then
		obj:_hex_to_rgba()
		if not obj.disable_hsl then obj:_rgb_to_hsl() end

	elseif obj._props.h ~= 0 or obj._props.s ~= 0 or obj._props.l ~= 0 then
		obj:_hsl_to_rgb()
		obj:_rgba_to_hex()

	end --otherwise it's just black and everything is correct already


	-- Set up the metatable
	local mt = getmetatable(obj) or {}

	-- Check if it's already in _props to return it
	-- TODO: Only remake values if necessary
	mt.__index = function(self, key)
		if self._props[key] then
			-- Check if to just return nil for hsl
			if obj.disable_hsl and utils.contains(HSL, key) then return self._props[key] end

			-- Check if something in ANY isn't currently accessible
			if not utils.contains(obj._access, key) and utils.contains(ANY, key) then

				if obj._access == RGB then
					self:_rgba_to_hex()
					if not obj.disable_hsl then obj:_rgb_to_hsl() end

				elseif obj._access == HEX then
					self:_rgba_to_hex()
					if not obj.disable_hsl then obj:_rgb_to_hsl() end

				elseif obj._access == HSL then
					self:_hsl_to_rgb()
					self:_rgba_to_hex()

				elseif obj._access == ANYSUBHEX then
					self:_alphaize_hex()
				end

				-- Reset accessibleness
				obj._access = ANY
			end

			-- Check for hashtaginess
			if obj.hashtag and key == "hex" then return "#"..self._props.hex end

			return self._props[key]

		else return rawget(self, key) end
	end

	mt.__newindex = function(self, key, value)
		if self._props[key] ~= nil then


			-- Set what values are currently accessible
			if utils.contains(RGB, key) then obj._access = RGB
			elseif utils.contains(HSL, key) and not obj.disable_hsl then obj._access = HSL
			elseif key == "hex" then obj._access = HEX
			elseif key == "a" then obj._access = ANYSUBHEX

			-- If it's not any of those and is small_rgb then update the rgb values
			elseif key == "small_rgb" and value ~= obj._props.small_rgb then
				if obj._props.small_rgb then
					obj._props.r = obj._props.r / 255
					obj._props.g = obj._props.g / 255
					obj._props.b = obj._props.b / 255
				else
					obj._props.r = math.floor(obj._props.r * 255)
					obj._props.g = math.floor(obj._props.g * 255)
					obj._props.b = math.floor(obj._props.b * 255)
				end
			end

			-- Set the new value
			self._props[key] = value

		-- If it's not part of _props just normally set it
		else rawset(self, key, value) end
	end

	-- performs an operation on the color and returns the new color
	local function operate(new, operator)
		local newcolor = color {r=obj.r, g=obj.g, b=obj.b}
		local key = new:match("%a+")
		if operator == "+" then newcolor[key] = newcolor[key] + new:match("[%d\\.]+")
		elseif operator == "-" then newcolor[key] = newcolor[key] - new:match("[%d\\.]+") end
		return newcolor
	end

	mt.__add = function(_, new) return operate(new, "+") end
	mt.__sub = function(_, new) return operate(new, "-") end

	setmetatable(obj, mt)
	return obj
end

return color
