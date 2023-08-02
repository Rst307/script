queue = {index=1,last=1,arr={}}

function queue:new()
    local q = {}
    q.index=1
    q.last=1
    q["arr"]={}
    setmetatable(q,{__index = self})
    return q
end

function queue:push(value)
    self["arr"][self.last] = value
    self.last=self.last+1
end

function queue:first()
    return self["arr"][self.index]
end

function queue:last()
    return self["arr"][self.last]
end

function queue:pop()
    if(self:empty()==true)then
        return nil
    end
    local r = self["arr"][self.index]
    self["arr"][self.index]=nil
    self.index=self.index+1
    return r
end

function queue:empty()
    return self.index==self.last
end