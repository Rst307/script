require("queue")

local basalt = require("basalt")
local way = {{x=1,y=0},{x=1,y=-1},{x=1,y=1},{x=0,y=-1},{x=0,y=1},{x=-1,y=0},{x=-1,y=-1},{x=-1,y=1}}

local minesXY = {}
local minesB = {}
-- the number of mines
local NMines = 25
-- points in x,y
local NPX = 22
local NPY = 10
-- block size
local sizeX = 3
local sizeY = 3

local PMaxX
local PMaxY

local left = NMines
local trueLeft = NMines
-- ms=true biaoji,false click
local ms = false

local function search(button,x,y)
    if(button["mine"]==true)then
        return 1
    end 
    local que = queue:new()
    que:push(button)
    while not(que:empty()) do
        local text = 0
        local bt = que:pop()
        bt["search"]=true
        x=minesB[bt]["x"]
        y=minesB[bt]["y"]
        for i=1,8 do
            local nx,ny = x+way[i]["x"],y+way[i]["y"]
            if(nx>=1 and nx<=NPX and ny>=1 and ny<=NPY)then
                if(minesXY[nx][ny]["mine"]==true)then
                    text=text+1
                end
            end
        end
        bt:setText(tostring(text))
        if(text==0)then
            bt:setText("")
            -- search --
            for i=1,8 do
                local nx,ny = x+way[i]["x"],y+way[i]["y"]
                if(nx>=1 and nx<=NPX and ny>=1 and ny<=NPY)then
                    if(minesXY[nx][ny]["search"]==false and minesXY[nx][ny]["mine"]==false)then
                        que:push(minesXY[nx][ny])
                    end
                end
            end
        end
    end

end



local function checkWin()
    return left==0 and trueLeft==0
end

local function showInformation(text,time)
    local t = basalt.addMonitor()
    t:setMonitor(monitor)
    local label = t:addLabel()
    label:setText(text)
    label:setSize(15,15)
    label:setPosition((maxX+20)/2,(maxY+50)/2)
    basalt.setActiveFrame(t)
end

local function clickBlock(self,event,button,x,y)
    local xt,yt=minesB[self]["x"],minesB[self]["y"]
    if(ms==false)then
        if(self["mine"])then
            lo()
        else
            search(self,xt,yt)
        end
    else
        self["tagged"]=not(self["tagged"])
        if(self["tagged"])then
            if(self["mine"])then
                trueLeft=trueLeft-1
                left=left-1
            else
                left=left-1
            end
        else
            if(self["mine"])then
                trueLeft=trueLeft+1
                left=left+1
            else
                left=left+1
            end
        end
        if(self["tagged"])then
            self["yuan"]=self:getText()
            self:setText("X")
        else
            self:setText("#")
            self:setText(self["yuan"])
        end
    end
    leftText:setText(tostring(left))
    if(checkWin())then
        wi()
    end
end

local function change()
    ms=not ms
    if(ms)then
        changeButton:setText("1")
    else
        changeButton:setText("2")
    end
end


local function putMines()
    for x=1,NPX do
        for y=1,NPY do
            local button = main:addButton()
            button:setText("#")
            button:setSize(sizeX,sizeY)
            button:setPosition(x*sizeX,sizeY*y)
            button["mine"]=false
            button["search"]=false
            button["tagged"]=false
            minesXY[x][y]=button
            minesB[button]={}
            minesB[button]["x"]=x
            minesB[button]["y"]=y
            button:onClick(clickBlock)
        end
    end
    math.randomseed(os.time())
    for i=1,NMines do
        local x=math.random(1,NPX)
        local y=math.random(1,NPY)
        if(minesXY[x][y]["mine"]==true)then
            i=i-1
        end
        minesXY[x][y]["mine"]=true
        minesXY[x][y]:setText("-1")
    end
end

local function start()
    startButton:setVisible(false)
    changeButton:setVisible(true)
    leftText:setVisible(true)
    leftText:setText(tostring(left))
    for i=1,maxX do
        minesXY[i]={}
        for i2=1,maxY do
            minesXY[i][i2]=nil
        end
    end
    putMines()
end

local function reload()
    basalt.debug("reloading")

    startButton:setVisible(true)
    changeButton:setVisible(false)
    leftText:setVisible(false)
    for i,v in pairs(minesB)do
        i:remove()
        minesB[i]=nil
    end
    for i,v in pairs(minesXY) do
        for a,b in pairs(v)do
            b=nil
        end
    end
    left=NMines
    trueLeft=NMines

end

wi= function()
    --print(basalt.getActiveFrame():getName())
    --basalt.removeFrame(basalt.getActiveFrame():getName())
    local speaker = peripheral.find("speaker")
    speaker.playSound("entity.player.levelup")
    reload()
end

lo= function()
    local speaker = peripheral.find("speaker")
    speaker.playSound("entity.player.death")
    reload()
end

monitor = peripheral.find("monitor")
main = basalt.addMonitor()
main:setMonitor(monitor)

startButton = main:addButton()
changeButton = main:addButton()
leftText = main:addLabel()

maxX,maxY = monitor:getSize()
maxY=maxY-20
maxX=maxX-50
ms=false

startButton:setPosition(41,20)
startButton:setText("start")
startButton:setSize(10,5)
startButton:setVisible(true)

changeButton:setSize(6,5)
changeButton:setText("2")
changeButton:setPosition(80,20)
changeButton:setVisible(false)


left=NMines
trueLeft=NMines
leftText:setVisible(false)
leftText:setSize(7,7)
leftText:setPosition(maxX+40,1)

startButton:onClick(start)
changeButton:onClick(change)
reload()
basalt.autoUpdate()
