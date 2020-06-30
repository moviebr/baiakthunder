vector = {}

setmetatable(vector, {
	__call = function(self, ...)
		local obj = {...}
		return setmetatable(obj, {__index = self})
	end
})

function vector:front()
	return self[1]
end

function vector:back()
	return self[#self]
end

function vector:at(index)
	return self[index]
end
vector.get = vector.at

function vector:empty()
	return #self == 0
end

function vector:size()
	return #self
end

function vector:clear()
	for i = 1, #self do
		self[i] = nil
	end
end
vector.reset = vector.clear

function vector:emplace_back(element)
	self[#self + 1] = element
end

function vector:emplace_front(element)
	table.insert(self, 1, element)
end

function vector:erase(element)
	for i = 1, #self do
		if self[i] == element then
			table.remove(self, i)
			break
		end
	end
end

function vector:pop_back()
	self[#self] = nil
end

function vector:pop_front()
	self:erase(self[1])
end

function vector:rand()
	return self[math.random(#self)]
end