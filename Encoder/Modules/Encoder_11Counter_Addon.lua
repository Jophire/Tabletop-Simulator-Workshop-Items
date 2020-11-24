--[[One One Counter Module
by Tipsy Hobbit//STEAM_0:1:13465982
This module adds only 1/1 Counters
]]
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
    values = {'oneOneCounter','moduleMod','moduleMath'},
    funcOwner = self,
    callOnActivate = true,
    activateFunc ='callEditor'
    }
    enc.call("APIregisterProperty",properties)
    
    value = {
    valueID = 'oneOneCounter', 
    validType = 'number',   
    default = 0       
    }
    enc.call("APIregisterValue",value)
    value = {
    valueID = 'moduleMod', 
    validType = 'number',   
    default = 1       
    }
    enc.call("APIregisterValue",value)
    value = {
    valueID = 'moduleMath', 
    validType = 'pattern(^[*+][/-]$)',   
    default = "+-"       
    }
    enc.call("APIregisterValue",value)
  end
end

function createButtons(t)
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    data = enc.call("APIobjGetPropData",{obj=t.obj,propID=pID})
    flip = enc.call("APIgetFlip",{obj=t.obj})
    scaler = {x=1,y=1,z=1}--t.obj.getScale()
    editing = enc.call("APIgetEditing",{obj=t.obj})
    if editing == nil then
      temp = ((data.oneOneCounter >= 0) and "+" or "")..data.oneOneCounter
      temp = ""..temp..'/'..temp..""
      barSize,fsize,offset_x,offset_y = enc.call('APIformatButton',{str=temp,font_size=90,max_len=90,xJust=1,yJust=0})
      t.obj.createButton({
      label=temp, click_function='toggleEditor', function_owner=self,
      position={(1.1+offset_x)*flip*scaler.x,0.28*flip*scaler.z,(1.1+offset_y)*scaler.y}, height=170, width=barSize, font_size=fSize,
      rotation={0,0,90-90*flip}
      })
    elseif editing == pID then
      temp = ((data.oneOneCounter >= 0) and "+" or "")..data.oneOneCounter
      temp = ""..temp..'/'..temp..""
      barSize,fsize,offset_x,offset_y = enc.call('APIformatButton',{str=temp,font_size=400,max_len=90,xJust=1,yJust=0})
      t.obj.createButton({
      label=temp, click_function='cycleMain', function_owner=self,
      position={0,0.28*flip*scaler.z,0}, height=400, width=barSize, font_size=fsize,rotation={0,0,90-90*flip}
      })
      t.obj.createButton({
      label= data.moduleMath, click_function='cycleMath', function_owner=self,
      position={-0.4*flip,0.28*flip*scaler.z,-0.8}, height=400, width=400, font_size=240,rotation={0,0,90-90*flip}
      })
      t.obj.createButton({
      label= data.moduleMod, click_function='cycleMod', function_owner=self,
      position={0.4*flip,0.28*flip*scaler.z,-0.8}, height=400, width=400, font_size=240,rotation={0,0,90-90*flip}
      })
      t.obj.createButton({
      label= "Reset", click_function='resetValues', function_owner=self,
      position={0*flip,0.28*flip*scaler.z,1.0}, height=200, width=600, font_size=240,rotation={0,0,90-90*flip}
      })
    end
  end
end

function toggleEditor(obj,ply)
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    enc.call("APIsetEditing",{obj=obj,propID=pID})
    enc.call("APIrebuildButtons",{obj=obj})
  end
end

function callEditor(t)
  toggleEditor(t.obj,nil)
end

function toggleEditClose(obj,ply)
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    enc.call("APIclearEditing",{obj=obj})
    enc.call("APIrebuildButtons",{obj=obj})
  end
end

function updateEditDisp(obj)
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    data = enc.call("APIobjGetPropData",{obj=obj,propID=pID})
    temp = ((data.oneOneCounter >= 0) and "+" or "")..data.oneOneCounter
    temp = ""..temp..'/'..temp..""
    barSize,fsize,offset_x,offset_y = enc.call('APIformatButton',{str=temp,font_size=400,max_len=90,xJust=1,yJust=0})
    obj.editButton({
    index=0,label=temp,width=barSize, font_size=fSize})
    obj.editButton({
    index=1,label=data.moduleMath})
    obj.editButton({
    index=2,label=data.moduleMod})
  end
end
function cycleMain(obj,ply,alt)
  enc = Global.getVar('Encoder')

  if enc ~= nil then
    data = enc.call("APIobjGetPropData",{obj=obj,propID=pID})
    local mMod = type(ply)=="string" and data.moduleMod or ply['mod']
    local mMat = type(ply)=="string" and data.moduleMath or ply['mat']
    if mMat == '+-' then
      if alt == false then
        data.oneOneCounter = data.oneOneCounter+mMod
      else
        data.oneOneCounter = data.oneOneCounter-mMod
      end
    else
      if alt == false then
        data.oneOneCounter = data.oneOneCounter*mMod
      else
        if data.moduleMod == 0 then
          data.moduleMod = 1
        end
        data.oneOneCounter = data.oneOneCounter/mMod
      end
    end
    enc.call("APIobjSetPropData",{obj=obj,propID=pID,data=data})
    if type(ply) == "string" then
      updateEditDisp(obj)
      local selection =Player[ply].getSelectedObjects()
      if selection ~= nil then
        for k,v in pairs(selection) do
          if v ~= obj and enc.call("APIobjectExists",{obj=v}) == true then 
            cycleMain(v,{mod=mMod,mat=mMat},alt)
          end
        end
      end
    else
      enc.call("APIrebuildButtons",{obj=obj})
    end
  end
end
function cycleMath(obj,ply,alt)
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    data = enc.call("APIobjGetPropData",{obj=obj,propID=pID})
    if data.moduleMath ~= '+-' then
      data.moduleMath = '+-'
    else
      data.moduleMath = '*/'
    end
    enc.call("APIobjSetPropData",{obj=obj,propID=pID,data=data})
    updateEditDisp(obj)
  end
end
function cycleMod(obj,ply,alt)
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    data = enc.call("APIobjGetPropData",{obj=obj,propID=pID})
    if data.moduleMod > 1 and alt == true then
      data.moduleMod = data.moduleMod-1
    elseif data.moduleMod < 10 and alt == false then
      data.moduleMod = data.moduleMod+1
    end
    enc.call("APIobjSetPropData",{obj=obj,propID=pID,data=data})
    updateEditDisp(obj)
  end
end
function resetValues(obj,ply,alt)
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    data = enc.call("APIobjGetPropData",{obj=obj,propID=pID})
    if alt == false then
      enc.call("APIobjDefaultValue",{obj=obj,valueID='oneOneCounter'})
    else
      for k,v in pairs(data) do
        enc.call("APIobjDefaultValue",{obj=obj,valueID=k})
      end
    end
    if type(ply) == "string" then
      updateEditDisp(obj)
      local selection =Player[ply].getSelectedObjects()
      if selection ~= nil then
        for k,v in pairs(selection) do
          if v ~= obj and enc.call("APIobjectExists",{obj=v}) == true then 
            resetValues(v,nil,alt)
          end
        end
      end
    else
      enc.call("APIrebuildButtons",{obj=obj})
    end
  end 
end