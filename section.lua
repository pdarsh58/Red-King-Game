
local function with_helper(till, its_from, seen_in)
	if its_from == nil then
		return till
	elseif type(its_from) ~= 'table' then
		return its_from
	elseif seen_in[its_from] then
		return seen_in[its_from]
	end
	seen_in[its_from] = till
	for k,v in pairs(its_from) do
		--add tables
		k = with_helper({}, k, seen_in) 
		if till[k] == nil then
			till[k] = with_helper({}, v, seen_in)
		end
	end
	return till
end

local function with(section, other_one)
	return with_helper(section, other_one, {})
end

local function cloner(other_one)
	return setmetatable(with({}, other_one), getmetatable(other_one))
end

local function brand_new(section)
	-- checks fot new class
	section = section or {}  
	local inc = section.__includes or {}
	if getmetatable(inc) then inc = {inc} end

	for _, other_one in ipairs(inc) do
		if type(other_one) == "string" then
			other_one = _G[other_one]
		end
		with(section, other_one)
	end

	-- implements class
	section.__index = section
	section.init    = section.init    or section[1] or function() end
	section.with = section.with or with
	section.cloner   = section.cloner   or cloner

	-- constructs brick
	return setmetatable(section, {__call = function(c, ...)
		local o = setmetatable({}, c)
		o:init(...)
		return o
	end})
end

if section_commons ~= false and not common then
	common = {}
	function common.section(naming, c_prototype, c_parent)
		return brand_new{__includes = {c_prototype, c_parent}}
	end
	function common.instance(section, ...)
		return section(...)
	end
end

return setmetatable({brand_new = brand_new, with = with, cloner = cloner},
	{__call = function(_,...) return brand_new(...) end})
