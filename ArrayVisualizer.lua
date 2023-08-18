-- inspired by those things that show how sorts work visually
local visual = {}

function visual.new(array: {number}, frame: Frame, running: thread)
	local self = {}
	self.Blocks = {}
	local destroyed = false
	local setup = false
	local function Render(DontClear:boolean?)
		if destroyed then return end
		local max = 1
		for _, v in array do
			if v > max then
				max = v
			end
		end
		for i, v in array do
			local new = not self.Blocks[i]
			local block = self.Blocks[i] or Instance.new("Frame")
			block.Size = UDim2.fromScale(
				1/#array,
				v/max
			)
			block.Position = UDim2.fromScale(
				(1/#array) * (i-1),
				1-block.Size.Y.Scale
			)
			local k= new and table.insert(self.Blocks, block)
			block.Parent = frame
		end
		setup = true
	end
	Render()
	local ghost = setmetatable({}, {
		__index = function(tbl, index)
			local block = self.Blocks[index]
			if block then
				if block.BackgroundColor3 == Color3.new(0, 1, 0) then
					return array[index]
				end
				block.BackgroundColor3 = Color3.new(1, 0, 0)
				task.spawn(function()
					for i=1, 2 do task.wait() end
					block.BackgroundColor3 = Color3.new(1,1,1)
				end)
			else
				print("no block :(")
			end
			return array[index]
		end,
		__newindex = function(tbl, index, value)
			print(value)
			if value == nil then
				local block = self.Blocks[index]
				if block then
					block:Destroy()
					table.remove(self.Blocks, index)
				end
			end
			if index == -math.huge then
				if value == 160 then
					Render()
					return
				end
				print("clearing")
				for i, v in self.Blocks do
					v:Destroy()
				end
				setmetatable(tbl, nil)
				destroyed = true
				table.clear(self.Blocks)
				return
			elseif index == math.huge then
				local block = self.Blocks[value[1]]
				if block then
					local color = value[2]
					block.BackgroundColor3 = color
				end
				return
			end
			rawset(array, index, value)
			Render()
		end,
		__len = function(tbl)
			return rawlen(array)
		end,
		__iter = function()
			return next, array
		end,
	})
	return ghost
end

return visual
