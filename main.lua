term.setCursorBlink(false)

---- some variables

-- table indices for X and Y components
local x = 1 
local y = 2

local score = 0

-- width and height of the screen
local width, height = term.getSize()
height = height -1

-- some snake-realted variables
local head = { [x] = math.floor(width/2), [y] = math.floor(height/2)}
local tail = {}
local objects = {}
local atail = 0
local dir = 3 -- 1: up ; 2: right ; 3: down ; 4: left
local inc = math.ceil(math.min(width,height)/30)

---- utility functions

function mergeTables(...)
    local t = {}
    for _,tt in pairs({...}) do
        for _,v in pairs(tt) do
            t[#t+1] = v
        end
    end
    return t
end

function addFood()
    local xx,yy
    while true do
        xx = math.random(2,width-2)
        yy = math.random(2,height-2)
        local collide = false
        for _,p in pairs(mergeTables({head},tail,objects)) do
            if (xx == p[x]) or (yy == p[y]) then collide = true break end
        end
        if not collide then break end
    end
    objects[#objects+1] = {
        pos = {xx,yy},
        type = "food"
    }
end

function addGoldenFood()
    local xx,yy
    while true do
        xx = math.random(2,height-2)
        yy = math.random(2,height-2)
        local collide = false
        for _,p in pairs(mergeTables({head},tail,objects)) do
            if (xx == p[x]) or (yy == p[y]) then collide = true break end
        end
        if not collide then break end
    end
    objects[#objects+1] = {
        pos = {xx,yy},
        type = "golden_food"
    }
end

---- graphical functions

function displayBack()
    paintutils.drawFilledBox(2,2,width-1,height-1,colors.black)
end

function displayFrame()
    paintutils.drawBox(1,1,width,height,colors.gray)
    term.setCursorPos(1,1)
    term.write("               Score: "..tostring(score))
    term.setCursorPos(1,height)
    --term.write("Golden food chance: "..tostring(math.log((score+1)^4)/(inc)).."%")
end

function displaySnake()
    for _,p in pairs(tail) do
        paintutils.drawPixel(p[x],p[y],colors.lime)
    end
    paintutils.drawPixel(head[x],head[y],colors.green)
end

function displayObjects()
    for _,obj in pairs(objects) do
        local color = colors.magenta
        if obj.type == "food" then
            color = colors.red
        elseif obj.type == "golden_food" then
            color = colors.yellow
        end
        paintutils.drawPixel(obj.pos[x],obj.pos[y],color)
    end
end

addFood()

displayBack()
displaySnake()
displayObjects()
displayFrame()

term.setCursorPos(1,height)
term.write("press any key to start")

term.setCursorPos(1,2)
print("Collect the food (red dots) but avoid your tail which grows everytime you eat food, there is special golden food which remove a bit of your tail")
print("Controls: wasd / arrow keys")

os.pullEventRaw()
os.pullEventRaw()

---- mainloop

while true do
    term.setTextColor(colors.lightBlue)
    term.setCursorPos(1,1)

    displayBack()
    displaySnake()
    displayObjects()
    displayFrame()

    local id = os.startTimer(1/(score/2+1))
    local evt = {os.pullEventRaw()}
    os.cancelTimer(id)
    local evtName = evt[1]

    if evtName == "key" then
        local key = evt[2]
        if (key == keys.z or key == keys.up) and (dir ~= 3) then
            dir = 1
        elseif (key == keys.q or key == keys.left) and (dir ~= 2) then
            dir = 4 
        elseif (key == keys.s or key == keys.down) and (dir ~= 1) then
            dir = 3
        elseif (key == keys.d or key == keys.right) and (dir ~= 4) then
            dir = 2
        end

        if key == keys.g then
            addGoldenFood()
        end
        if key == keys.f then
            addFood()
        end
    end

    if evtName == "terminate" then
        term.setCursorPos(1,1)
        term.write("Terminated     Score: "..tostring(score).."      Press any key to exit")
        sleep(1)
        os.pullEventRaw("key")
        term.setCursorPos(1,1)
        term.setBackgroundColor(colors.black)
        term.setTextColor(colors.white)
        term.clear()
        return
    end
    
    if atail ~= 0 then
        if atail > 0 then -- add tail (regular food effect)
            table.insert(tail,{0,0})
            atail = atail -1
        else -- remove tail (goldn food effect)
            table.remove(tail,#tail)
            atail = atail +1
        end
        if atail < 0 and #tail==0 then atail = 0 end -- make sure to not remove any more of the tail if thare is none
    end

    -- move each part of the tail
    for i,p in pairs(tail) do
        tail[i] = textutils.unserialiseJSON(textutils.serialiseJSON(mergeTables(tail,{head})[i+1]))
    end

    -- move the head
    if dir == 1 then
        head[y] = head[y] -1
    elseif dir == 2 then
        head[x] = head[x] +1
    elseif dir == 3 then
        head[y] = head[y] +1
    elseif dir == 4 then
        head[x] = head[x] -1
    end

    -- check for object collision
    for i,obj in pairs(objects) do
        if head[x] == obj.pos[x] and head[y] == obj.pos[y] then
            if obj.type == "food"  then
                addFood() -- add a new food source
                table.remove(objects,i) -- remove the current object
                atail = atail +inc
                score = score +1
                -- add a new food source every 10 points
                if score%10 == 0 then
                    addFood()
                end
                if math.random(0,100) < math.log((score^4)+1)/(inc) then
                    addGoldenFood()
                end
            elseif obj.type == "golden_food" then
                table.remove(objects,i) -- remove the current object
                atail = -math.ceil(#tail/3)
                score = score +10
            end
        end
    end

    -- check for tail collision
    for i,p in pairs(tail) do
        if p[x] == head[x] and p[y] == head[y] then
            term.setCursorPos(1,1)
            term.write("Game Over      Score: "..tostring(score).."      Press any key to exit")
            sleep(1)
            os.pullEventRaw("key")
            term.setCursorPos(1,1)
            term.setBackgroundColor(colors.black)
            term.setTextColor(colors.white)
            term.clear()
            return
        end
    end

    -- check for border collision

    if head[x] == 1 then
        head[x] = width-1
    end
    if head[y] == 1 then
        head[y] = height-1
    end
    if head[x] == width then
        head[x] = 2
    end
    if head[y] == height then
        head[y] = 2
    end

end