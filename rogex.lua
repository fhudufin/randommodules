local rogex = {}

local function get(str, i)
	return str:sub(i, i)
end

local patterns = {
	["%d"] = ("1234567890"):split("");
	["%s"] = {" "};
}

local function didmatch(str, patternT):boolean
	local i = 1
	local consumed = 0
	print(patternT)
	for _, v in patternT do
		print(`got {v}`)
		if v:sub(1, 1) == "%" then
			local p = patterns[v]
			for _, v in p do
				if str:sub(1, 1) == v then
					return true
				end
			end
		elseif str:sub(1, #v) == v then
			print("matched")
			return true
		end
	end
	return false
end

function rogex.match(str, pattern):boolean
	local f = get(pattern, 1)
	if f ~= "!" and f ~= "=" then error("Invalid start") end
	local MatchWhole = f == "="
	pattern = pattern:sub(2, -1)
	local statements = pattern:split(";")
	local Satisfied = false
	for i, v in statements do
		local modifiers = {
			["!"] = false;
			["+"] = false;
			["*"] = false;
			["?"] = false
		}
		local i = 1
		local done = 0
		local char = {}
		local cidx = 1
		local isSet = false
		if get(v, i) == ">" and not Satisfied then
			print("skipping")
			continue
		end
		while i <= #v do
			local x = get(v, i)
			print(`print(x) = {x}`)
			if modifiers[x] ~= nil then
				if x ~= "!" then
					done += 1
				end
				if done > 1 then
					error("cannot have colliding modifiers")
				end
				modifiers[x] = true
			else
				if x == "%" then
					i += 1
					if not char[cidx] then
						char[cidx] = ""
					end
					if not patterns["%" .. get(v, i)] then
						char[cidx] ..= get(v, i)
					else
						char[cidx] ..= "%" ..  get(v, i)
					end
				elseif x == "[" then
					isSet = true
					while x ~= "]" do
						i += 1
						x = get(v, i)
						if x == "]" then break end
						cidx += 1
						char[cidx] = get(v, i)
						if not x then
							error("malformed set")
						end
					end
					cidx += 1
				end
			end
			if modifiers[x] == nil and x ~= "%" then
				if isSet then
					error("cannot have set and str in the same statement")
				end
				if not char[cidx] then
					char[cidx] = ""
				end
				char[cidx] ..= x
			end
			i += 1
		end
		-- all info about statment gotten
		if char == "" then
			error("cannot have empty statment")
		end
		Satisfied = false
		if modifiers["+"] then
			local done = 0
			local i = 1
			while i <= #str do
				if not didmatch(get(str, i), char) then
					if MatchWhole then
						if done == 0 then
							return false
						end
					end
					break
				else
					if modifiers["!"] then break end
				end
				done += 1
				Satisfied = true
				str = str:sub(2, -1)
			end
			if done == 0 then
				return false
			end
			
		elseif modifiers["?"] then
			if didmatch(str, char) and not modifiers["!"] then
				Satisfied = true
				str = str:sub(2, -1)
			else
				if modifiers["!"] then
					Satisfied = true
					str = str:sub(2, -1)
				end
			end
		elseif modifiers["*"] then
			local i = 1
			while i <= #str do
				if not didmatch(str, char) then
					break
				else
					if modifiers["!"] then break end
				end
				Satisfied = true
				str = str:sub(2, -1)
			end
		else
			if isSet then
				for _, c in char do
					if didmatch(str, c) then
						Satisfied = true
						str = str:sub(#c+1, -1)
					end
				end
			else
				print(char[1])
				if didmatch(str, char) then
					Satisfied = true
					str = str:sub(#char[1]+1, -1)
				end
			end
		end
	end
	if MatchWhole then
		return str == ""
	end
	return true
end

return rogex
