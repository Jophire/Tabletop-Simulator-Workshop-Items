--Power and Toughness
--By Tipsy Hobbit
encVersion = 1
pID = "MTG_11_Counters"

function onload()
  self.createButton({
  label="+", click_function='registerModule', function_owner=self,
  position={0,0.2,-0.5}, height=100, width=100, font_size=100,
  rotation={0,0,0},tooltip="Adds the current stat"
  })
end

function registerModule()
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    properties = {
    propID = pID,
    name = "+1/+1 Counters",
    dataStruct = {power=0,toughness=0},
    funcOwner = self,
    callOnActivate = true,
    activateFunc ='callEditor'
    }
    enc.call("APIregisterProperty",properties)
  end
end

function createButtons(t)
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    data = enc.call("APIgetObjectData",{obj=t.object,propID=pID})
    flip = enc.call("APIgetFlip",{obj=t.object})
    scaler = {x=1,y=1,z=1}--t.object.getScale()
    editing = enc.call("APIgetEditing",{obj=t.object})
    if editing == nil then
      temp = ""..((data.power >= 0) and "+" or "")..data.power..'/'..((data.toughness >= 0) and "+" or "")..data.toughness..""
      barSize,fsize,offset_x,offset_y = enc.call('APIformatButton',{str=temp,font_size=90,max_len=90,xJust=1,yJust=0})
      t.object.createButton({
      label=temp, click_function='toggleEditor', function_owner=self,
      position={(1.1+offset_x)*flip*scaler.x,0.28*flip*scaler.z,(1.1+offset_y)*scaler.y}, height=170, width=barSize, font_size=fSize,
      rotation={0,0,90-90*flip}
      })
    elseif editing == pID then
      temp = ""..((data.power >= 0) and "+" or "")..data.power..'/'..((data.toughness >= 0) and "+" or "")..data.toughness..""
      t.object.createButton({
      label=temp, click_function='toggleEditClose', function_owner=self,
      position={0,0.28*flip*scaler.z,0}, height=400, width=840, font_size=400,rotation={0,0,90-90*flip}
      })
      t.object.createInput({
      label= "1", input_function='cycleSet', function_owner=self,
      position={0.0,0.28*flip*scaler.z,-1.8}, height=400, width=600, font_size=240,rotation={0,0,90-90*flip},value=1
      })
      t.object.createButton({
      label= ">", click_function='cycleup', function_owner=self,
      position={0.8*flip,0.28*flip*scaler.z,-1.8}, height=400, width=100, font_size=240,rotation={0,0,90-90*flip}
      })
      t.object.createButton({
      label= "<", click_function='cycledw', function_owner=self,
      position={-0.8*flip,0.28*flip*scaler.z,-1.8}, height=400, width=100, font_size=240,rotation={0,0,90-90*flip}
      })
      t.object.createButton({
      label= "Clear", click_function='clear', function_owner=self,
      position={0.0,0.28*flip*scaler.z,1.8}, height=400, width=800, font_size=240,rotation={0,0,90-90*flip}
      })
      t.object.createButton({
      label="+", click_function='addB', function_owner=self,
      position={0.0,0.28*flip*scaler.z,-0.9}, height=400, width=800, font_size=480,rotation={0,0,90-90*flip}
      })
      t.object.createButton({
      label="-", click_function='subB', function_owner=self,
      position={0,0.28*flip*scaler.z,0.9}, height=400, width=800, font_size=480,rotation={0,0,90-90*flip}
      })
      t.object.createButton({
      label="+", click_function='addP', function_owner=self,
      position={-1.8*flip,0.28*flip*scaler.z,-0.45}, height=300, width=300, font_size=480,rotation={0,0,90-90*flip}
      })
      t.object.createButton({
      label="-", click_function='subP', function_owner=self,
      position={-1.8*flip,0.28*flip*scaler.z,0.45}, height=300, width=300, font_size=480,rotation={0,0,90-90*flip}
      })
      t.object.createButton({
      label="+", click_function='addT', function_owner=self,
      position={1.8*flip,0.28*flip*scaler.z,-0.45}, height=300, width=300, font_size=480,rotation={0,0,90-90*flip}
      })
      t.object.createButton({
      label="-", click_function='subT', function_owner=self,
      position={1.8*flip,0.28*flip*scaler.z,0.45}, height=300, width=300, font_size=480,rotation={0,0,90-90*flip}
      })
    end
  end
end

function toggleEditor(object)
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    enc.call("APIsetEditing",{obj=object,propID=pID})
    enc.call("APIrebuildButtons",{obj=object})
  end
end

function callEditor(t)
  toggleEditor(t.object)
end

function toggleEditClose(object,ply)
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    enc.call("APIclearEditing",{obj=object})
    object.clearButtons()
    object.clearInputs()
    enc.call("APIrebuildButtons",{obj=object})
  end
end


function updateEditDisp(object)
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    flip = enc.call("APIgetFlip",{obj=object})
    scaler = object.getScale()
    data = enc.call("APIgetObjectData",{obj=object,propID=pID})
    temp = ""..((data.power >= 0) and "+" or "")..data.power..'/'..((data.toughness >= 0) and "+" or "")..data.toughness..""
    object.editButton({
    index=0,label=temp, click_function='toggleEditClose', function_owner=self,
    position={0,0.28*flip*scaler.z,0}, height=400, width=840, font_size=400,rotation={0,0,90-90*flip}
    })
  end
end
function updateCycle(object,butnum)
  object.editInput({
    index=0,label= "1", input_function='cycleSet', function_owner=self,
    position={0.0,0.28*flip*scaler.z,-1.8}, height=400, width=600, font_size=240,rotation={0,0,90-90*flip},value=butnum
    })
end

--Editor Functions
function clear(tar,ply)
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    data = enc.call("APIgetObjectData",{obj=tar,propID=pID})
    data.power = 0
    data.toughness = 0
    enc.call("APIsetObjectData",{obj=tar,propID=pID,data=data})
    if type(ply) == "string" then
      updateEditDisp(tar)
      local selection =Player[ply].getSelectedObjects()
      if selection ~= nil then
        for k,v in pairs(selection) do
          
          if v ~= tar and enc.call("APIobjectExist",{obj=v}) == true then 
            clear(v,0)
          end
        end
      end
    else
      enc.call("APIrebuildButtons",{obj=tar})
    end
  end
end
function addB(tar,ply)
  local ma = (type(ply)=="string") and tonumber(tar.getInputs()[1].value) or ply
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    data = enc.call("APIgetObjectData",{obj=tar,propID=pID})
    data.power = data.power+ma
    data.toughness = data.toughness+ma
    
    enc.call("APIsetObjectData",{obj=tar,propID=pID,data=data})
    if type(ply) == "string" then
      updateEditDisp(tar)
      local selection =Player[ply].getSelectedObjects()
      if selection ~= nil then
        for k,v in pairs(selection) do
          
          if v ~= tar and enc.call("APIobjectExist",{obj=v}) == true then 
            addB(v,ma)
          end
        end
      end
    else
      enc.call("APIrebuildButtons",{obj=tar})
    end
  end
end
function subB(tar,ply)
  local ma = (type(ply)=="string") and tonumber(tar.getInputs()[1].value) or ply
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    data = enc.call("APIgetObjectData",{obj=tar,propID=pID})
    data.power = data.power-ma
    data.toughness = data.toughness-ma
    
    enc.call("APIsetObjectData",{obj=tar,propID=pID,data=data})
    if type(ply) == "string" then
      updateEditDisp(tar)
      local selection =Player[ply].getSelectedObjects()
      if selection ~= nil then
        for k,v in pairs(selection) do
          
          if v ~= tar and enc.call("APIobjectExist",{obj=v}) == true then 
            subB(v,ma)
          end
        end
      end
    else
      enc.call("APIrebuildButtons",{obj=tar})
    end
  end
end
function addP(tar,ply)
  local ma = (type(ply)=="string") and tonumber(tar.getInputs()[1].value) or ply
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    data = enc.call("APIgetObjectData",{obj=tar,propID=pID})
    data.power = data.power+ma
    
    enc.call("APIsetObjectData",{obj=tar,propID=pID,data=data})
    if type(ply) == "string" then
      updateEditDisp(tar)
      local selection =Player[ply].getSelectedObjects()
      if selection ~= nil then
        for k,v in pairs(selection) do
          
          if v ~= tar and enc.call("APIobjectExist",{obj=v}) == true then 
            addP(v,ma)
          end
        end
      end
    else
      enc.call("APIrebuildButtons",{obj=tar})
    end
  end
end
function subP(tar,ply)
  local ma = (type(ply)=="string") and tonumber(tar.getInputs()[1].value) or ply
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    data = enc.call("APIgetObjectData",{obj=tar,propID=pID})
    data.power = data.power-ma
    
    enc.call("APIsetObjectData",{obj=tar,propID=pID,data=data})
    if type(ply) == "string" then
      updateEditDisp(tar)
      local selection =Player[ply].getSelectedObjects()
      if selection ~= nil then
        for k,v in pairs(selection) do
          
          if v ~= tar and enc.call("APIobjectExist",{obj=v}) == true then 
            subP(v,ma)
          end
        end
      end
    else
      enc.call("APIrebuildButtons",{obj=tar})
    end
  end
end
function addT(tar,ply)
  local ma = (type(ply)=="string") and tonumber(tar.getInputs()[1].value) or ply
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    data = enc.call("APIgetObjectData",{obj=tar,propID=pID})
    data.toughness = data.toughness+ma
    
    enc.call("APIsetObjectData",{obj=tar,propID=pID,data=data})
    if type(ply) == "string" then
      updateEditDisp(tar)
      local selection =Player[ply].getSelectedObjects()
      if selection ~= nil then
        for k,v in pairs(selection) do
          
          if v ~= tar and enc.call("APIobjectExist",{obj=v}) == true then 
            addT(v,ma)
          end
        end
      end
    else
      enc.call("APIrebuildButtons",{obj=tar})
    end
  end
end
function subT(tar,ply)
  local ma = (type(ply)=="string") and tonumber(tar.getInputs()[1].value) or ply
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    data = enc.call("APIgetObjectData",{obj=tar,propID=pID})
    data.toughness = data.toughness-ma
    
    enc.call("APIsetObjectData",{obj=tar,propID=pID,data=data})
    if type(ply) == "string" then
      updateEditDisp(tar)
      local selection =Player[ply].getSelectedObjects()
      if selection ~= nil then
        for k,v in pairs(selection) do
          
          if v ~= tar and enc.call("APIobjectExist",{obj=v}) == true then 
            subT(v,ma)
          end
        end
      end
    else
      enc.call("APIrebuildButtons",{obj=tar})
    end
  end
end

--Cycle Functions
function cycleSet(tar,ply)
  local butnum = tonumber(tar.getInputs()[1].value)
  updateCycle(tar,butnum)
end
function cycleup(tar,ply)
  local butnum = tonumber(tar.getInputs()[1].value) 
  if #(""..butnum) < 10 then
    butnum = butnum*10
  end
  updateCycle(tar,butnum)
end
function cycledw(tar,ply)
  local butnum = tonumber(tar.getInputs()[1].value) 
  if #(""..butnum) > 1 then
    butnum = butnum/10
  end
  butnum = math.floor(butnum)
  updateCycle(tar,butnum)
end
