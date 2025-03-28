----#include TTS_Armada/src/Magic Ruler
ASSETS_ROOT = 'https://raw.githubusercontent.com/valadian/TabletopSimulatorIncludeDir/master/TTS_armada/assets/'
rulers = {}
cmds = {}
last_rot = 0
target_rot = 0
cmd_dir = 0
stable_count = 0
-- local ASTEROIDS = {
--     "http://pastebin.com/raw/SWhJfkwB",
--     "http://pastebin.com/raw/dJTxnY50",
--     "http://pastebin.com/raw/zSSXLYZ5",
--     "http://pastebin.com/raw/z4DDMq9f",
--     "http://pastebin.com/raw/j0Xr1xsQ",
--     "http://pastebin.com/raw/ZUZuC55E"
-- }
-- local ASTEROID_TOKENS = {
--     "http://i.imgur.com/KWkWB6p.png",
--     "http://i.imgur.com/Zdz7dZF.png"
-- }
--real_rot = 0
function onload()
    self.interactable = false
    drawButtons()
    last_rot = self.getRotation()[2]
    target_rot = self.getRotation()[2]
    --real_rot = self.getRotation()[2]
end
function update ()
    local cmd_string = self.getDescription()
--    if cmd == " " then
--        destroyRulers()
--    end
    self.setDescription("");
    if string.len(cmd_string)>0 then
        printToAll('Processing Cmd "'..cmd_string..'"',{1,0,0})
        local new_cmds = cmd_string:split(",",5,false)
        if #new_cmds>0 then
            if isCmd(new_cmds[1]) then
                buildRuler(new_cmds)
            end
        end
    end
    --restrictRotation(22.5)
    --moveRuler()
    moveChildren()
end
function buildRuler(new_cmds)
    destroyRulers()
    cmds = table.copy(new_cmds)
--    for _,c in ipairs(new_cmds) do
--        printToAll('"'..tonumber(c)..'"',{1,0,0})
--    end
    if #new_cmds>0 then
        extendSelf(self, 1, new_cmds)
    end
    drawButtons()
    --startLuaCoroutine(self, 'lockRuler')
end
--colliding = false
--function onCollisionExit( collision_info )
--    colliding = false
--end
--function onCollisionStay( collision_info )
--    self.setRotation({0,target_rot,0})
--end
--pickedUp = false
--override = 0
--dropProtect = 0
--function onPickedUp( player_color )
--    pickedUp = true
--    override = self.getRotation()[2]
--    stable_count = 10
--    cmd_dir = 0
--end
--function onDropped( player_color )
--    pickedUp = false
--    printToAll("Dropped "..cmd_dir.." "..stable_count,{1,0,0})
--    target_rot = override
--    dropProtect = 20
--end
function restrictRotation(increment)
    if pickedUp then
        self.setRotation({0,override,0})
    elseif not colliding then
        local curr_rot = self.getRotation()[2]
        --printToAll(curr_rot,{1,0,0})
        local diff = angleDiff(curr_rot,last_rot)
        --printToAll(diff,{1,0,0})
        last_rot = curr_rot
        if math.abs(diff)<0.01 then
            stable_count = stable_count + 1
            if stable_count>2 then
                cmd_dir = 0
                if target_rot~=nil then
                    --printToAll("Adjust",{0,1,0})
                    --NOT COMMANDED
                    -- target_rot = math.round(curr_rot/increment)*increment
                    local new_rot = math.clamp(target_rot,curr_rot-3,curr_rot+3)
                    last_rot = math.mod(new_rot,360)
                    self.setRotation({0,new_rot,0})
                end
            end
        else
            stable_count = 0
            dropProtect = dropProtect -1
            if dropProtect<0 then
                cmd_dir = cmd_dir + math.sign(diff)
            end
            --external commanding
            --local direction = math.sign(diff)

            if cmd_dir > 5 and math.abs(curr_rot-target_rot)>7 then
                target_rot = math.mod(math.ceil(curr_rot/increment)*increment,360)
                printToAll("New Target CW - "..target_rot,{0,1,0})
            elseif cmd_dir < -5 then
                target_rot = math.floor(curr_rot/increment)*increment
                printToAll("New Target CCW- "..target_rot,{0,1,0})
            end
        end
    end
end
function math.sign(x)
    if x<0 then return -1
    elseif x>0 then return 1
    else return 0 end
end
function angleDiff(a,b)
    angle = a - b
    return math.mod(angle + 180, 360) - 180
--    local diff = a - b
--    if diff > 180 then diff=diff-360
--    elseif diff < 180 then diff=diff+360
--    end
--    if diff == 360 then diff = 0 end
--    return diff
end
function moveRuler()
    local pos = self.getPosition()
    if pos[2]>2 then
        pos = {pos[1],2,pos[3]}
    end
    self.setPositionSmooth(pos,false,true)
end
function moveChildren()
    if rulers[1]~=nil then
        moveChild(self, 1)
    end
end
function drawButtons()
    self.clearButtons()
    local z = 0.3
    if #cmds<4 then
        self.createButton(buildButton('+',{click_function='Action_AddRuler',position={-0.2,z,1.05},width=200,height=200}))
    end
    self.createButton(buildButton('Done',{click_function='Action_ClearRuler',position={0,z,0.7},width=300}))

    local ship = self.getVar('ship')
    if ship~=nil and self.getVar('moved')~=true and (#cmds>0 or self.getRotation()[2]~=ship.getRotation()[2]) then
        self.createButton(buildButton('Move',{position={0,z,0.4},width=300}))
    end
    if #cmds>0 then
        self.createButton(buildButton('-',{click_function='Action_RemoveRuler',position={0.2,z,1.05},width=200,height=200}))
    end
    if ship~=nil then
        local prev_transforms = ship.getTable('prev_transforms')
        if prev_transforms~=nil and #prev_transforms>0 then--last_pos~=nil and last_rot~=nil and last_moved~=nil then
            if self.getVar('moved') then
                self.createButton(buildButton('Undo',{position={0,z,0.1},width=300}))
            elseif self.getVar('confirm') then
                self.createButton(buildButton('Oops!',{click_function='Toggle_Undo',position={0,z,0.1},width=300,color={0.8,0,0},font_color={1,1,1}}))
                self.createButton(buildButton('Confirm!',{click_function='Action_Undo',position={0,z,-0.1},width=300,color={0,0.8,0},font_color={1,1,1}}))
            else
                self.createButton(buildButton('Undo',{click_function='Toggle_Undo',position={0,z,0.1},width=300,color={0.8,0,0},font_color={1,1,1}}))
            end
        end
    end
    local y = 1.1
    if #cmds==0 then
        self.createButton(buildButton('<',{click_function='Action_RulerLeft0',position={0.2,z,y+0.4}}))
        self.createButton(buildButton('0',{click_function='DoNothing',position={0,z,y+0.4},color={0.8,0,0},font_color={1,1,1}}))
        self.createButton(buildButton('>',{click_function='Action_RulerRight0',position={-0.2,z,y+0.4}}))

    end
    y = y + 0.25
    local maneuver = self.getTable("maneuver")
    for i,cmd in ipairs(cmds) do
        if tonumber(cmd)>-2 then
            self.createButton(buildButton('<',{click_function='Action_RulerLeft'..i,position={0.2,z,y}}))
        end
        local clicks = "-"
        if math.abs(tonumber(cmd))==1 then clicks = "|" end
        if math.abs(tonumber(cmd))==2 then clicks = "||" end
        self.createButton(buildButton(clicks,{click_function='DoNothing',position={0,z,y},color={0,0,0},font_color={1,1,1}}))
        rulers[i].clearButtons()
        font_color = {0,0,0,10}
        color = {0,0,0,0.1}
        if maneuver~=nil then
            -- print("Found Manuever")
            if #cmds>#maneuver then
                -- rulers[i].setColorTint({1,0,0})
                -- font_color = {1,0,0}
                rulers[i].createButton(buildButton("?",{click_function='DoNothing',position={0,z,0.8},width=200,height=300,font_size=200,color=color,font_color=font_color}))
            else
                -- rulers[i].setColorTint({1,1,1})
                segment = maneuver[#cmds][i]
                value = 0
                if segment=="I" then value = 1 end
                if segment=="II" then value = 2 end
                -- print(i,segment,value,cmd)
                if math.abs(tonumber(cmd))>value then
                    font_color = {1,1,1,1}
                    color = {1,0,0,1}
                else
                    font_color = {0,0.5,0,10}
                end
                rulers[i].createButton(buildButton(segment,{click_function='DoNothing',position={0,z,0.8},width=200,height=300,font_size=200,color=color,font_color=font_color}))
            end
        else
        end
        if tonumber(cmd)<2 then
            self.createButton(buildButton('>',{click_function='Action_RulerRight'..i,position={-0.2,z,y}}))
        end
        y = y + 0.25
    end
    if maneuver~=nil then

        --for i,speed in ipairs(maneuver) do
        if (#maneuver >= #cmds) and (#cmds > 0) then
            for j,segment in ipairs(maneuver[#cmds]) do
                value = 0
                if segment=="I" then value = 1 end
                if segment=="II" then value = 2 end
                color = {0,0.4,0}
                font_color = {1,1,1}
                if math.abs(tonumber(cmds[j]))>value then
                    color = {1,0,0}
                    font_color = {0,0,0}
                end
                self.createButton(buildButton(segment,{click_function='DoNothing',position={0.5,z,1.1+0.25*j},color=color,font_color=font_color})) --1-i*0.2
            end
        end
        --end
    end
end
function Toggle_Undo()
    self.setVar('confirm',not self.getVar('confirm'))
    drawButtons()
end
function DoNothing() end
function Action_RulerLeft1() RotateRuler(1,-1) end
function Action_RulerLeft2() RotateRuler(2,-1) end
function Action_RulerLeft3() RotateRuler(3,-1) end
function Action_RulerLeft4() RotateRuler(4,-1) end
function Action_RulerLeft5() RotateRuler(5,-1) end
function Action_RulerRight1() RotateRuler(1,1) end
function Action_RulerRight2() RotateRuler(2,1) end
function Action_RulerRight3() RotateRuler(3,1) end
function Action_RulerRight4() RotateRuler(4,1) end
function Action_RulerRight5() RotateRuler(5,1) end

function Action_RulerLeft0()
    self.setRotation({self.getRotation()[1],self.getRotation()[2]-22.5,self.getRotation()[3]})
    drawButtons()
end
function Action_RulerRight0()
    self.setRotation({self.getRotation()[1],self.getRotation()[2]+22.5,self.getRotation()[3]})
    drawButtons()
end
-- last_pos = nil
-- last_rot = nil
-- last_moved = nil
function Action_Move()
    self.setVar('moved',true)
    self.setVar('confirm',false)
    local ship = self.getVar('ship')
    if ship == nil then
        ship = findNearestShip(self.getPosition(),self.getRotation()[2])
    end
    local offset = vector.sub(ship.getPosition(),self.getPosition())
    -- Handle Summa Reverse Move
    local lastRuler = self
    if #rulers>0 then
        lastRuler = rulers[#rulers]
    end
    local yRot = lastRuler.getRotation()[2] - ship.getRotation()[2]
    local yRotForOffset = yRot
    local delta = math.abs(ship.getRotation()[2]-self.getRotation()[2])
    local reversed = delta>160 and delta<200
    if reversed then
        offset = vector.add(offset, vector.rotate({0,0,2.10},ship.getRotation()[2]))
        yRotForOffset = yRotForOffset - 180
    end
    local rotatedOffset = vector.rotate(offset,yRotForOffset)
    last_pos = ship.getPosition()
    last_rot = ship.getRotation()
    local new_pos = vector.add(lastRuler.getPosition(),rotatedOffset)
    local new_rot = vector.add(last_rot,{0,yRot,0})
    if vector.eq(ship.getPosition(),new_pos) and vector.eq(ship.getRotation(),new_rot) then
        printToAll("Cancelling Move: "..ship.getName(),{1,0,0})
        drawButtons()
        return
    else
        printToAll("Moving: "..ship.getName(),{1,0,0})
    end
    ship.setPositionSmooth(new_pos,false,true)
    ship.setRotationSmooth(new_rot,false,true)
    moved_tokens = moveTokens(ship,last_pos,last_rot,new_pos,new_rot)
    storeUndo(ship,moved_tokens)
    drawButtons()
end
function API_GET_NUM_CMDS()
    return #cmds
end
function API_GET_CMD_AT(idx)
    return cmds[idx]
end
function API_MOVE_SHIP(params)
    --params = { ship, pos, rot }
    old_pos = params.ship.getPosition()
    old_rot = params.ship.getRotation()
    params.ship.setPositionSmooth(params.pos,false,true)
    params.ship.setRotationSmooth(params.rot,false,true)
    moved_tokens = moveTokens(params.ship,old_pos,old_rot,params.pos,params.rot)
    storeUndo(params.ship,moved_tokens)
end
ship_size = {
    {0.807,0,1.398,1.398}, --small
    {1.201,0,2.008,2.008}, --med
    {1.496,0,2.539,2.539}, --large
    {1.496,0,2.539,2.539*3+3.68}, --huge (=11.135)
    {1.496,0,2.539,9.10}, --custom shorthuge
    {3.65,0,2.55,2.55}, --custom wideHuge
    {8.3,0,2.55,2.55} --custom megaWideHuge
    --{1.201,0,2.008,9.10} --custom doublemed
}
-- moved_objects = {}
function moveTokens(ship, old_pos, old_rot, new_pos, new_rot)
    local moved_objects = {}
    for _,obj in ipairs(getAllObjects()) do
        local isShipIdentifier = obj.tag=="Figurine" and obj.getCustomObject()~=nil and obj.getCustomObject().thickness~=nil
        if (obj.tag~="Figurine" or isShipIdentifier) and obj~=self then -- and not table.contains(ASTEROIDS,obj.getCustomObject().mesh) and not table.contains(ASTEROID_TOKENS,obj.getCustomObject().image)
            local offset = vector.rotate(vector.sub(obj.getPosition(),old_pos),-old_rot[2])
            local size = ship_size[ship.getVar('size')]
            local ontopofshipbase = obj.getPosition()[2]>1.25
            if math.abs(offset[1])<math.abs(size[1]) and offset[3]>-size[3] and offset[3]<size[4] and ontopofshipbase then
                -- WAS ON BASE
                -- printToAll(obj.getName(), {1,1,1})
                table.insert(moved_objects,obj)
                local new_pos = vector.add(new_pos,vector.rotate(offset, new_rot[2]))
                local new_rot = vector.add(vector.sub(new_rot,old_rot),obj.getRotation())
                obj.setPositionSmooth(new_pos,false,true)
                obj.setRotationSmooth(new_rot,false,true)
                --obj.lock()
            end
        end
    end
    return moved_objects
end
function undoMoveTokens(moved_objects, old_pos, old_rot, undo_pos, undo_rot)
    for _,obj in ipairs(moved_objects) do
        local offset = vector.rotate(vector.sub(obj.getPosition(),old_pos),-old_rot[2])
        --local size = ship_size[ship.getVar('size')]
        local new_pos = vector.add(undo_pos,vector.rotate(offset, undo_rot[2]))
        local new_rot = vector.add(vector.sub(undo_rot,old_rot),obj.getRotation())
        obj.setPositionSmooth(new_pos,false,true)
        obj.setRotationSmooth(new_rot,false,true)
    end
    -- moved_objects = {}
end
function storeUndo(ship,moved_objects)
    local prev_transforms = ship.getTable('prev_transforms')
    if prev_transforms == nil then
        prev_transforms = {}
    end
    table.insert(prev_transforms,{ship.getPosition(),ship.getRotation(),moved_objects})
    ship.setTable('prev_transforms',prev_transforms)
    -- ship.setTable('moved_objects',T(moved_objects):Select(|o|o.guid))
    -- last_pos = ship.getPosition()
    -- last_rot = ship.getRotation()
    -- last_moved = ship
end
function popUndo(ship)
    local prev_transforms = ship.getTable('prev_transforms')
    if prev_transforms == nil or #prev_transforms==0 then
        printToAll("Trying to undo with no history")
    end
    last_transform = table.remove(prev_transforms)
    ship.setTable('prev_transforms',prev_transforms)
    return last_transform
end
function Action_Undo()
    self.setVar('moved',false)
    self.setVar('confirm',false)
    local ship = self.getVar('ship')
    prev_transform = popUndo(ship)
    local prev_pos = ship.getPosition()
    local prev_rot = ship.getRotation()
    -- last_moved.setPositionSmooth(last_pos,false,true)
    -- last_moved.setRotationSmooth(last_rot,false,true)
    ship.setPositionSmooth(prev_transform[1],false,true)
    ship.setRotationSmooth(prev_transform[2],false,true)
    -- undoMoveTokens(last_moved,prev_pos,prev_rot,last_pos,last_rot)
    undoMoveTokens(prev_transform[3],prev_pos,prev_rot,prev_transform[1],prev_transform[2])
    -- last_moved = nil
    -- last_pos = nil
    -- last_rot = nil
    drawButtons()
end
function findNearestShip(pos,rot_filter)
    local nearest
    local minDist = 999999
    for i,ship in ipairs(getAllObjects()) do
        if isShip(ship) then
            local distance = distance(pos[1],pos[3],ship.getPosition()[1],ship.getPosition()[3])
            -- TODO: implement rotation filter (0 or 180)
            --angleDiff(ship.getRotation()[1],rot_filter)
            if distance<minDist and ship.getRotation() then
                minDist = distance
                nearest = ship
            end
        end
    end
    return nearest
end
function distance(x,y,a,b)
    x = (x-a)*(x-a)
    y = (y-b)*(y-b)
    return math.sqrt(math.abs((x+y)))
end
function isShip(ship)
    local name = ship.getName()
    return ship.tag == "Figurine" and (name:match " S$" or name:match " M$" or name:match " L$"
            or name:match " SR$" or name:match " MR$" or name:match " LR$")
end
function RotateRuler(i, direction)
    cmds[i] = math.clamp(cmds[i]+direction,-2,2)
    buildRuler(cmds)
end
function API_SetSpeed(params)
    cmdLen = #cmds
    if params.speed>cmdLen then
        for i=cmdLen+1,params.speed do
            table.insert(cmds,"0")
        end
    end
    if params.speed<cmdLen then
        for i=params.speed,cmdLen-1 do
            table.remove(cmds)
        end
    end
    buildRuler(cmds)
end
function API_SetYaw(params)
    cmdLen = #cmds
    if params.idx>cmdLen then
        for i=cmdLen+1,params.idx do
            table.insert(cmds,"0")
        end
    end
    cmds[params.idx] = params.value
    buildRuler(cmds)
end
function Action_AddRuler()
    if #cmds<4 then
        if highlighted_index==#cmds then
            highlighted_index = highlighted_index + 1
        end
        table.insert(cmds,"0")
        buildRuler(cmds)
    end
end
function Action_RemoveRuler()
    if #cmds>0 then
        if highlighted_index==#cmds then
            highlighted_index = highlighted_index - 1
        end
        table.remove(cmds)
        buildRuler(cmds)
    end
end
function Action_ClearRuler()
    self.setVar('moved',false)
    self.setVar('confirm',false)
    destroyRulers()
    drawButtons()
    -- last_moved = nil
    -- last_pos = nil
    -- last_rot = nil
    self.destruct()
    -- self.setPositionSmooth({49,1,0},false,true)
    -- self.setRotationSmooth({0,0,0},false,true)
end
function buildButton(label, def)
    local DEFAULT_POSITION = {0,0.17,0}
    local DEFAULT_ROTATION = {0,180,0}
    --local DEFAULT_WIDTH_PER_CHAR = 125
    local DEFAULT_HEIGHT = 100
    local DEFAULT_WIDTH = 100
    local DEFAULT_FONT_SIZE = 75
    if def.position==nil then def.position = DEFAULT_POSITION end
    if def.rotation==nil then def.rotation = DEFAULT_ROTATION end
    --if def.width==nil then def.width = 100 + string.len(label)*DEFAULT_WIDTH_PER_CHAR end
    if def.width==nil then def.width = DEFAULT_WIDTH end
    if def.height==nil then def.height = DEFAULT_HEIGHT end
    if def.font_size==nil then def.font_size = DEFAULT_FONT_SIZE end
    if def.click_function==nil then def.click_function = 'Action_'..label end
    if def.function_owner==nil then def.function_owner = self end
    if def.color==nil then def.color={1,1,1} end
    if def.font_color==nil then def.font_color={0,0,0} end
    return {['click_function'] = def.click_function, ['function_owner'] = def.function_owner, ['label'] = label, ['position'] = def.position, ['rotation'] =  def.rotation, ['width'] = def.width, ['height'] = def.height, ['font_size'] = def.font_size, ['color'] = def.color, ['font_color']=def.font_color}
end
function destroyRulers()
    for _,ruler in ipairs(rulers) do
        if ruler~=nil then
            ruler.destruct()
        end
    end
    rulers = {}
    cmds = {}
end
function isCmd(cmd)
    local dir = tonumber(cmd)
    return table.contains({-2,-1,0,1,2},dir)
end
diffuse = "http://i.imgur.com/YNFhQi0.png"
start_model = ASSETS_ROOT.."misc/navruler/start.obj"
mid_model = ASSETS_ROOT.."misc/navruler/mid.obj"
end_model = ASSETS_ROOT.."misc/navruler/end.obj"
ruler_diffuse = {
    'http://i.imgur.com/Y8LTHC2.png',
    'http://i.imgur.com/PbrGnQm.png',
    'http://i.imgur.com/rZPSomm.png',
    'http://i.imgur.com/WiZESBp.png'
}
end_diffuse = {
    'http://i.imgur.com/WH1KHQf.png',
    'http://i.imgur.com/ihm03Vm.png',
    'http://i.imgur.com/1q9uCVs.png',
    'http://i.imgur.com/eMbDz3j.png'
}
function extendSelf(this, index, new_cmds)
    --printToAll("--EXTEND--",{0,0,1})
    local dir =  tonumber(new_cmds[1])
    table.remove(new_cmds, 1)
    local pos = this.getPosition()
    local rot = this.getRotation()[2]
    --printToAll("rot"..rot,{0,1,1})
    local offset = vector.scale({0,0,2.6265 },this.getScale())
    --printToAll("offset"..vector.tostring(offset),{0,1,1})
    local rotated_offset = vector.rotate(offset,rot)
    --printToAll("rotatedoffset"..vector.tostring(rotated_offset),{0,1,1})
    local obj_parameters = {}
    --obj_parameters.type = 'Custom_Token'
    obj_parameters.type = 'Custom_Model'
    obj_parameters.position = vector.add(pos, rotated_offset)
    --printToAll("newpos"..vector.tostring(obj_parameters.position),{0,1,1})
    local new_rot = dir * 22.5
    obj_parameters.rotation = {0,rot+new_rot,0 }
    --printToAll("newrot"..vector.tostring(obj_parameters.rotation),{0,1,1})
    local newruler = spawnObject(obj_parameters)
    local custom = {}
    --if index==1 then
    --    custom.mesh = start_model
    --else
    if index==#cmds then
        custom.mesh = end_model
    else
        custom.mesh = mid_model
    end
    custom.diffuse = diffuse
    --custom.collider = custom.mesh
    --custom.type = 1
    custom.material = 3
    --custom.specular_intensity = 0
    --custom.specular_color = {223/255, 207/255, 190/255}

--    if index==#cmds then
--        custom.image = end_diffuse[index]
--    else
--        custom.image = ruler_diffuse[index]
--    end
--    custom.thickness = 0.3
--    custom.merge_distance = 5
    newruler.setCustomObject(custom)
    newruler.lock()
    newruler.scale(this.getScale())
    rulers[index] = newruler
    if #new_cmds>0 then
        extendSelf(newruler, index+1, new_cmds)
    end
    --newruler.setPositionSmooth(obj_parameters.position,false,true)
    --newruler.setRotationSmooth(obj_parameters.rotation,false,true)
    --newruler.lock()
end
highlighted_index = 0
owner_color = "black"
function API_highlightIndex(params) --index, color
    if params~=nil then
        owner_color = params.color
    end
    if highlighted_index==0 then
        self.highlightOn(owner_color, 2000)
    else
        self.highlightOff()
    end
    for i,ruler in ipairs(rulers) do
        if i==highlighted_index then
            rulers[i].highlightOn(owner_color, 2000)
        else
            rulers[i].highlightOff()
        end
    end
end
function API_incrementIndex()
    if highlighted_index==#cmds then
        Action_AddRuler()
    else
        highlighted_index = highlighted_index + 1
    end
end
function API_decrementIndex()
    if highlighted_index>0 then
        highlighted_index = highlighted_index - 1
    end
end
function API_rulerLeft()
    if highlighted_index==0 then
        Action_RulerLeft0()
    else
        RotateRuler(highlighted_index,-1)
    end
end
function API_rulerRight()
    if highlighted_index==0 then
        Action_RulerRight0()
    else
        RotateRuler(highlighted_index,1)
    end
end
function API_move()
    if self.getVar('moved') then
        Action_ClearRuler()
    else
        Action_Move()
    end

end
function API_done()
    Action_ClearRuler()
end
function API_undo()
    Action_Undo()
end

-- function lockRuler()
--     for i=1, 50, 1 do
--         coroutine.yield(0)
--     end
--     for _,ruler in ipairs(rulers) do
--         if ruler~=nil then
--             ruler.lock()
--         end
--     end
--     return true
-- end
function moveChild(this, index)
    local dir =  tonumber(cmds[index])
    local pos = this.getPosition()
    if pos[2]>2 then
        pos = {pos[1],2,pos[3]}
    end
    local rot = this.getRotation()[2]
    local offset = vector.scale({0,0,2.6265 },this.getScale())
    local rotated_offset = vector.rotate(offset,rot)
    local child = rulers[index]
    child.setPositionSmooth(vector.add(pos, rotated_offset),false,true)
    local new_rot = dir * 22.5
    child.setRotationSmooth({0,rot+new_rot,0 },false,true)
    if cmds[index+1]~=nil then
        moveChild(child, index+1)
    end
end
-- function clearButtons(object)
--     --this is a workaround for obj.clearButtons() being broken as of v7.10
--     if object.getButtons() ~= nil then
--         for i=#object.getButtons()-1,0,-1 do
--             object.removeButton(i)
--         end
--     end
-- end
----#include ../../util/string
function string.starts(String,Start)
    if String==nil then
        return false
    end
    return string.sub(String,1,string.len(Start))==Start
end
function string:split(this,sSeparator, nMax, bRegexp)
    return string.split(this,sSeparator, nMax, bRegexp)
end
function string.split(str, sSeparator, nMax, bRegexp)
   assert(sSeparator ~= '')
   if type(nMax)=="string" then
       print("string.split('"..tostring(str).."','"..tostring(sSeparator).."',"..tostring(nMax)..","..tostring(bRegexp))
   end
   assert(nMax == nil or nMax >= 1)

   local aRecord = {}

   if str:len() > 0 then
      local bPlain = not bRegexp
      nMax = nMax or -1

      local nField, nStart = 1, 1
      local nFirst,nLast = str:find(sSeparator, nStart, bPlain)
      while nFirst and nMax ~= 0 do
         aRecord[nField] = str:sub(nStart, nFirst-1)
         nField = nField+1
         nStart = nLast+1
         nFirst,nLast = str:find(sSeparator, nStart, bPlain)
         nMax = nMax-1
      end
      aRecord[nField] = str:sub(nStart)
   end

   return aRecord
end
function string:strip(self)
    return string.strip(self)
end
function string.strip(str)
    str = string.gsub(str, '^%s*', '')
    str = string.gsub(str, '%s*$', '')
    return str
end

function string.hexToColor(stringColor)
    color_table = {tonumber("0x"..stringColor:sub(1,2),16)/255, tonumber("0x"..stringColor:sub(3,4),16)/255, tonumber("0x"..stringColor:sub(5,6),16)/255}
    return color_table
end

----#include ../../util/string
----#include ../../util/vector
----#include math
function math.round(x)
    return x>=0 and math.floor(x+0.5) or math.ceil(x-0.5)
end
function math.round(num, idp)
    if num == nil then return nil end
    local mult = 10^(idp or 0)
    if num >= 0 then return math.floor(num * mult + 0.5) / mult
    else return math.ceil(num * mult - 0.5) / mult end
end
function math.imod(i,mod)
    return i - math.floor((i-1)/mod)*mod --math.fmod(a,b)+1
end
function math.mod(a,b)
    return a - math.floor(a/b)*b
end
function math.approxeq(a, b)
    return math.abs(a-b)<0.01
end
function math.sign(x)
    if x<0 then return -1
    elseif x>0 then return 1
    else return 0 end
end
function math.clamp(val, lower, upper)
    assert(val and lower and upper, "sent nil value to clamp")
    if lower > upper then lower, upper = upper, lower end -- swap if boundaries supplied the wrong way
    return math.max(lower, math.min(upper, val))
end

----#include math

vector = {}
function vector.length(v)
    return math.sqrt(v[1]*v[1]+v[2]*v[2]+v[3]*v[3])
end
function vector.add(pos, offset)
    return {pos[1] + offset[1],pos[2] + offset[2],pos[3] + offset[3]}
end
function vector.sub(pos, offset)
    return {pos[1] - offset[1],pos[2] - offset[2],pos[3] - offset[3]}
end
function vector.scale(v,s)
    if type(s)=="table" then
        return {v[1] * s[1],v[2] * s[2],v[3] * s[3]}
    elseif type(s)=="number" then
        return {v[1] * s,v[2] * s,v[3] * s}
    else
        printToAll("Error: Cannot scale vector by type: "..type(s))
        return nil
    end
end
function vector.prod(v,s)
    return {v[1] * s,v[2] * s,v[3] * s}
end
function vector.onedividedby(v)
    return {1/v[1],1/v[2] ,1/v[3]}
end
function vector.rotate(direction, yRotation)

    local rotval = math.round(yRotation)
    local radrotval = math.rad(rotval)
    local xDistance = math.cos(radrotval) * direction[1] + math.sin(radrotval) * direction[3]
    local zDistance = math.sin(radrotval) * direction[1] * -1 + math.cos(radrotval) * direction[3]
    return Vector(xDistance, direction[2], zDistance)
end
function vector.toangle(v)
    return math.atan2(-v[3],v[1])*180/math.pi - 90
end
function vector.angle2D(vec1, vec2)
    if vec2 == nil then
        vec2 = {1}
        for k = 2, #vec1, 1 do
            table.insert(vec2, 0)
        end
    end
    local angle = ( math.atan2(vec2[3], vec2[1]) - math.atan2(vec1[3], vec1[1]) )
    if angle>math.pi then
        angle = angle - math.pi*2
    end
    if angle<-math.pi then
        angle = angle + math.pi*2
    end
    return angle
end
function vector.eq(a,b)
    return math.approxeq(a[1],b[1]) and math.approxeq(a[2],b[2]) and math.approxeq(a[3],b[3])
end
function vector.tostring(v)
    return "{"..math.round(v[1],3)..","..math.round(v[2],3)..","..math.round(v[3],3).."}"
end
function vector.distance(v1,v2)
    x = (v1[1]-v2[1])*(v1[1]-v2[1])
    y = (v1[3]-v2[3])*(v1[3]-v2[3])
    return math.sqrt(math.abs((x+y)))
end
function vector.cross2D(u,v)
    return u[3]*v[1]-u[1]*v[3]
end
function vector.dot(a,b)
    return a[3]*b[3] + a[1]*b[1]
end
function vector.forward(obj)
    local direction = obj.getRotation()
    local rotval = math.round(direction[2])
    local radrotval = math.rad(rotval)
    local xForward = math.sin(radrotval) * -1
    local zForward = math.cos(radrotval) * -1
    -- log(guid .. " for x: "..round(xForward,2).." y: "..round(zForward,2))
    return {xForward, 0, zForward}
end
function vector.between(v,ll,ur)
    return ((v[1]>ll[1] and v[1]<ur[1]) or (v[1]<ll[1] and v[1]>ur[1])) and
           ((v[3]>ll[3] and v[3]<ur[3]) or (v[3]<ll[3] and v[3]>ur[3]))
end

----#include ../../util/vector
----#include ../../util/table
table.Distinct = function(t)
    local distinct = T{}
    for k,v in pairs(t) do
        if not distinct:Contains(v) then
            table.insert(distinct,v)
        end
    end

    return distinct
end
table.Sum = function(t)
    local sum = 0
    for k,v in pairs(t) do
        sum = sum + v
    end

    return sum
end
table.FirstOrNil = function(t)
    if #t>0 then
        return t[1]
    else
        return nil
    end
end
table.removeByValue = function(table1, value)
    for k,v in pairs(table1) do
      if v == value then
          table.remove(table1, k)
          break
      end
    end
end
function table_to_csv(t)
    local csv = ""
    for i,val in ipairs(t) do
        csv = csv..tostring(val)
        if i!=#t then
            csv = csv..","
        end
    end
    return csv
end
-- table.OrderBy = function(t, selector)
--
-- end
table.OrderBy = function(t, selector)
    function compare(a,b)
        return selector(a)<selector(b)
    end
    table.sort(t, compare)
    return t
end
table.OrderByDesc = function(t, selector)
    function compare(a,b)
        return selector(a)>selector(b)
    end
    table.sort(t, compare)
    return t
end
table.Select = function(t, selector)
    local result = T{}
    for _,value in ipairs(t) do
        table.insert(result, selector(value))
    end
    return result
end

table.Where = function(t, predicate)
    local result = T{}
    for _,value in ipairs(t) do
        if predicate(value) then
            table.insert(result, value)
        end
    end
    return result
end

table.CountIf =function(t, predicate)
    local result = 0
    for _,value in ipairs(t) do
        if predicate(value) then
            result=result+1
        end
    end
    return result
end
function table.contains(self,val)
    for index, value in ipairs (self) do
        if value == val then
            return true
        end
    end

    return false
end
table.Contains = function(tab, el)
    for k,v in pairs(tab) do
        if v == el then
            return true
        end
    end
    return false
end
-- Shallow table copy
-- Does not include metatables
table.ShallowCopy = function(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else
        copy = orig
    end
    return copy
end
table.IndexOf = function(t,item)
    for i,v in ipairs(t) do
        if v==item then
            return i
        end
    end
    return -1
end
table.Any = function(t)
    return #t>0
end
table.Keys = function(tbl)
    local keyset={}
    local n=0

    for k,v in pairs(tbl) do
      n=n+1
      keyset[n]=k
    end
    return keyset
end
function T(t)
    local tmp = {}
    if t~=nil then
        local i = 1
        for _,val in pairs(t) do
            tmp[i]=val
            i=i+1
        end
    end
    return setmetatable(tmp, {__index = table})
end
function table.removeKey(t, k)
	local i = 0
	local keys, values = {},{}
	for k,v in pairs(t) do
		i = i + 1
		keys[i] = k
		values[i] = v
	end

	while i>0 do
		if keys[i] == k then
			table.remove(keys, i)
			table.remove(values, i)
			break
		end
		i = i - 1
	end

	local a = {}
	for i = 1,#keys do
		a[keys[i]] = values[i]
	end

	return a
end
function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

function table.merge(self, ...)
    if self == nil then
        copy = {}
    else
        copy = table.copy(self)
    end
    if ... ~= nil then
        for i,tab in ipairs({...}) do
            for k, v in pairs(tab) do
                copy[k] = v
            end
        end
    end
    return copy
end

function table.copy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
    copy = orig
    end
    return copy
end

function table.contains(self, val)
    for index, value in ipairs (self) do
        if value == val then
            return true
        end
    end

    return false
end

----#include ../../util/table

----#include TTS_Armada/src/Magic Ruler