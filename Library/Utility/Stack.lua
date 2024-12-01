local addonName, ENV = ...
ENV.Stack = ENV.Stack or {}
local this = ENV.Stack

function this:new()
    local stack = { items = {} }
    setmetatable(stack, self)
    self.__index = self
    return stack
end

function this:push(item)
    table.insert(self.items, item)
end

function this:pop()
    if self:isEmpty() then
        return nil
    end
    return table.remove(self.items)
end

function this:peek()
    return self.items[#self.items]
end

function this:isEmpty()
    return #self.items == 0
end