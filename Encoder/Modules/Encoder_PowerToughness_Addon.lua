--[[One One Counter Module
by Tipsy Hobbit//STEAM_0:1:13465982
This module adds only 1/1 Counters
]]
pID = "MTG_Power_Toughness"
version = '1.2.4'
UPDATE_URL='https://raw.githubusercontent.com/Jophire/Tabletop-Simulator-Workshop-Items/master/Encoder/Modules/Encoder_PowerToughness_Addon.lua'
Style={}

function onload()
  self.addContextMenuItem('Register Module', function(p) 
    registerModule()
  end)
  Wait.condition(registerModule,function() return Global.getVar('Encoder') ~= nil and true or false end)
end
function registerModule()
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    properties = {
    propID = pID,
    name = "Power/Toughness",
    values = {'power_base','toughness_base','power_mod','toughness_mod','oneOneCounter','moduleMod','moduleMath'},
    funcOwner = self,
    tags="base_stat,basic",
    activateFunc ='callEditor'
    }
    enc.call("APIregisterProperty",properties)
    
    value = {
    valueID = 'power_base', 
    validType = 'number',
    desc = 'MTG:Base creature power.',
    default = 0       
    }
    enc.call("APIregisterValue",value)
    value = {
    valueID = 'toughness_base', 
    validType = 'number',
    desc = 'MTG:Base creature toughness.',
    default = 0       
    }
    enc.call("APIregisterValue",value)
    value = {
    valueID = 'power_mod', 
    validType = 'number',
    desc = 'MTG:Static modifiers to base power.',
    default = 0       
    }
    enc.call("APIregisterValue",value)
    value = {
    valueID = 'toughness_mod', 
    validType = 'number',
    desc = 'MTG:Static modifiers to base toughness.',
    default = 0       
    }
    enc.call("APIregisterValue",value)
    value = {
    valueID = 'oneOneCounter', 
    validType = 'number',
    desc = 'Amount of +1/+1 Counters.',   
    default = 0       
    }
    enc.call("APIregisterValue",value)
    value = {
    valueID = 'moduleMod', 
    validType = 'number',
    desc = 'The value used in conjunction by moduleMath to change values by.',   
    default = 1       
    }
    enc.call("APIregisterValue",value)
    value = {
    valueID = 'moduleMath', 
    validType = 'pattern(^[*+][/-]$)',
    desc = 'Used by various modules button click functions. Either Add/Subtract or Multiply/Divide.',   
    default = "+-"       
    }
    enc.call("APIregisterValue",value)

    Style.proto = enc.call("APIgetStyleTable",nil)
    Style.mt = {}
    Style.mt.__index = Style.proto
    function Style.new(o)
      for k,v in pairs(Style.proto) do
        if o[k] == nil then
          o[k] = v
        end
      end
      return o
    end
  end
end

function createButtons(t)
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    Style.proto = enc.call("APIgetStyleTable",nil)
    data = enc.call("APIobjGetPropData",{obj=t.obj,propID=pID})
    flip = enc.call("APIgetFlip",{obj=t.obj})
    scaler = {x=1,y=1,z=1}--t.obj.getScale()
    editing = enc.call("APIgetEditing",{obj=t.obj})
    if editing == nil then
      temp = ""..data.power_base+data.power_mod+data.oneOneCounter..'/'..data.toughness_base+data.toughness_mod+data.oneOneCounter..""
      barSize,fsize,offset_x,offset_y = enc.call('APIformatButton',{str=temp,font_size=90,max_len=90,xJust=1,yJust=0})
      t.obj.createButton(Style.new{
      label=temp, click_function='toggleEditor', function_owner=self,
      position={(1.1+offset_x)*flip*scaler.x,0.28*flip*scaler.z,(1.4+offset_y)*scaler.y}, height=170, width=barSize, font_size=fsize,
      rotation={0,0,90-90*flip},tooltip="Base: "..data.power_base.."/"..data.toughness_base.."\nStatic: "..data.power_mod.."/"..data.toughness_mod.."\n Counters: "..(data.oneOneCounter > 0 and "+"..data.oneOneCounter or data.oneOneCounter)
      })
    elseif editing == pID then
      t.obj.createButton(Style.new{
      label="Base\nStats", click_function='doNothing', function_owner=self,tooltip="Base Stats",
      position={-1.05,0.28*flip*scaler.z,-1}, height=150, width=300, font_size=90,rotation={0,-90,90-90*flip}
      })
      t.obj.createButton(Style.new{
      label="/", click_function='doNothing', function_owner=self,
      position={0,0.28*flip*scaler.z,-1}, height=0, width=0, font_size=400,rotation={0,0,90-90*flip}
      })
      temp = ""..data.power_base
      barSize,fsize,offset_x,offset_y = enc.call('APIformatButton',{str=temp,font_size=400,max_len=90,xJust=1,yJust=0})
      t.obj.createButton(Style.new{
      label=temp, click_function='cyclePower', function_owner=self,
      position={(-0.2+offset_x*2.6)*flip,0.28*flip*scaler.z,-1+offset_y}, height=300, width=barSize > 500 and barSize or 500, 
      font_size=fsize,rotation={0,0,90-90*flip}, tooltip='Modify Base Power'
      })  
      temp = ""..data.toughness_base
      barSize,fsize,offset_x,offset_y = enc.call('APIformatButton',{str=temp,font_size=400,max_len=90,xJust=-1,yJust=0})
      t.obj.createButton(Style.new{
      label= temp, click_function='cycleToughness', function_owner=self,
      position={(0.2+offset_x*2.6)*flip,0.28*flip*scaler.z,-1+offset_y}, height=300, width=barSize > 500 and barSize or 500, 
      font_size=fsize,rotation={0,0,90-90*flip}, tooltip='Modify Base Toughness'
      })
      
      t.obj.createButton(Style.new{
      label="Static\nMod", click_function='doNothing', function_owner=self,tooltip="Static Modifiers",
      position={-1.05,0.28*flip*scaler.z,-0.4}, height=150, width=300, font_size=90,rotation={0,-90,90-90*flip}
      })
      t.obj.createButton(Style.new{
      label="/", click_function='doNothing', function_owner=self,
      position={0,0.28*flip*scaler.z,-0.4}, height=0, width=0, font_size=400,rotation={0,0,90-90*flip}
      })
      temp = ""..data.power_mod
      barSize,fsize,offset_x,offset_y = enc.call('APIformatButton',{str=temp,font_size=400,max_len=90,xJust=1,yJust=0})
      t.obj.createButton(Style.new{
      label=temp, click_function='cyclePowerMod', function_owner=self,
      position={(-0.2+offset_x*2.6)*flip,0.28*flip*scaler.z,-0.4+offset_y}, height=300, width=barSize > 500 and barSize or 500, 
      font_size=fsize,rotation={0,0,90-90*flip}, tooltip='Modify Power'
      })  
      temp = ""..data.toughness_mod
      barSize,fsize,offset_x,offset_y = enc.call('APIformatButton',{str=temp,font_size=400,max_len=90,xJust=-1,yJust=0})
      t.obj.createButton(Style.new{
      label= temp, click_function='cycleToughnessMod', function_owner=self,
      position={(0.2+offset_x*2.6)*flip,0.28*flip*scaler.z,-0.4+offset_y}, height=300, width=barSize > 500 and barSize or 500, 
      font_size=fsize,rotation={0,0,90-90*flip}, tooltip='Modify Toughness'
      })
      
      t.obj.createButton(Style.new{
      label="+1/+1\nCounter", click_function='doNothing', function_owner=self,tooltip="+1/+1 and -1/-1 Counters",
      position={-1.05,0.28*flip*scaler.z,0.20}, height=150, width=300, font_size=90,rotation={0,-90,90-90*flip}
      })
      temp = ((data.oneOneCounter >= 0) and "+" or "")..data.oneOneCounter
      temp = ""..temp
      barSize,fsize,offset_x,offset_y = enc.call('APIformatButton',{str=temp,font_size=400,max_len=90,xJust=1,yJust=0})
      t.obj.createButton(Style.new{
      label=temp, click_function='cycleOneOneCounter', function_owner=self,
      position={0,0.28*flip*scaler.z,0.20}, height=300, width=barSize > 900 and barSize or 900, font_size=fsize,rotation={0,0,90-90*flip},
      tooltip = 'Modify 1/1 counters.'
      })
      
      t.obj.createButton(Style.new{
      label= data.moduleMath, click_function='cycleMath', function_owner=self,
      position={-0.35*flip,0.28*flip*scaler.z,0.9}, height=300, width=300, font_size=240,rotation={0,0,90-90*flip},
      tooltip = data.moduleMath == '+-' and 'Add or Subtract '..data.moduleMod or 'Multiply or Divide by '..data.moduleMod
      })
      t.obj.createButton(Style.new{
      label= data.moduleMod, click_function='cycleMod', function_owner=self,
      position={0.35*flip,0.28*flip*scaler.z,0.9}, height=300, width=300, font_size=240,rotation={0,0,90-90*flip},
      tooltip = data.moduleMath == '+-' and 'Add or Subtract '..data.moduleMod or 'Multiply or Divide by '..data.moduleMod
      })
      t.obj.createButton(Style.new{
      label= "Reset", click_function='resetValues', function_owner=self,
      position={0*flip,0.28*flip*scaler.z,1.4}, height=200, width=600, font_size=240,rotation={0,0,90-90*flip},
      tooltip = 'Left click to reset values, right click to reset editor.'
      })
    end
  end
end

function doNothing()
end
function toggleEditor(obj,ply)
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    enc.call("APIsetEditing",{obj=obj,propID=pID})
    enc.call("APIrebuildButtons",{obj=obj})
  end
end
function callEditor(obj,ply)
  enc.call("APItoggleProperty",{obj=obj,propID=pID})
  if enc.call("APIobjIsPropEnabled",{obj=obj,propID=pID}) then
    toggleEditor(obj,nil)
  else
    enc.call("APIrebuildButtons",{obj=obj})
  end
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
    flip = enc.call("APIgetFlip",{obj=obj})
    scaler = {x=1,y=1,z=1}--t.obj.getScale()
    data = enc.call("APIobjGetPropData",{obj=obj,propID=pID})
    
    temp = ""..data.power_base
    barSize,fsize,offset_x,offset_y = enc.call('APIformatButton',{str=temp,font_size=400,max_len=90,xJust=1,yJust=0})
    obj.editButton({
    position={(-0.2+offset_x*2.6)*flip,0.28*flip*scaler.z,-1+offset_y},
    index=2,label=temp,width=barSize > 500 and barSize or 500, font_size=fsize})
    
    temp = ""..data.toughness_base
    barSize,fsize,offset_x,offset_y = enc.call('APIformatButton',{str=temp,font_size=400,max_len=90,xJust=-1,yJust=0})
    obj.editButton({
    position={(0.2+offset_x*2.6)*flip,0.28*flip*scaler.z,-1+offset_y},
    index=3,label=temp,width=barSize > 500 and barSize or 500, font_size=fsize})
    
    temp = ""..data.power_mod
    barSize,fsize,offset_x,offset_y = enc.call('APIformatButton',{str=temp,font_size=400,max_len=90,xJust=1,yJust=0})
    obj.editButton({
    position={(-0.2+offset_x*2.6)*flip,0.28*flip*scaler.z,-0.4+offset_y},
    index=6,label=temp,width=barSize > 500 and barSize or 500, font_size=fsize})
    temp = ""..data.toughness_mod
    barSize,fsize,offset_x,offset_y = enc.call('APIformatButton',{str=temp,font_size=400,max_len=90,xJust=-1,yJust=0})
    obj.editButton({
    position={(0.2+offset_x*2.6)*flip,0.28*flip*scaler.z,-0.4+offset_y},
    index=7,label=temp,width=barSize > 500 and barSize or 500, font_size=fsize})
    
    temp = ((data.oneOneCounter >= 0) and "+" or "")..data.oneOneCounter
    temp = ""..temp
    barSize,fsize,offset_x,offset_y = enc.call('APIformatButton',{str=temp,font_size=400,max_len=90,xJust=0,yJust=0})
    obj.editButton({
    index=9,label=temp,width=barSize > 900 and barSize or 900, font_size=fsize})
    
    obj.editButton({
    index=10,label=data.moduleMath,tooltip = data.moduleMath == '+-' and 'Add or Subtract '..data.moduleMod or 'Multiply or Divide by '..data.moduleMod})
    
    obj.editButton({
    index=11,label=data.moduleMod,tooltip = data.moduleMath == '+-' and 'Add or Subtract '..data.moduleMod or 'Multiply or Divide by '..data.moduleMod})
  end
end

function cycleValue(obj,ply,alt,val)
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    data = enc.call("APIobjGetPropData",{obj=obj,propID=pID})
    local mMod = type(ply)=="string" and data.moduleMod or ply['mod']
    local mMat = type(ply)=="string" and data.moduleMath or ply['mat']
    if mMat == '+-' then
      if alt == false then
        data[val] = data[val]+mMod
      else
        data[val] = data[val]-mMod
      end
    else
      if alt == false then
        data[val] = data[val]*mMod
      else
        if data.moduleMod == 0 then
          data.moduleMod = 1
        end
        data[val] = data[val]/mMod
      end
    end
    enc.call("APIobjSetPropData",{obj=obj,propID=pID,data=data})
    if type(ply) == "string" then
      updateEditDisp(obj)
      local selection =Player[ply].getSelectedObjects()
      if selection ~= nil then
        for k,v in pairs(selection) do
          if v ~= obj and enc.call("APIobjectExists",{obj=v}) == true then 
            cycleValue(v,{mod=mMod,mat=mMat},alt,val)
          end
        end
      end
    else
      enc.call("APIrebuildButtons",{obj=obj})
    end
  end
end
function cyclePower(obj,ply,alt)
  cycleValue(obj,ply,alt,'power_base')
end
function cycleToughness(obj,ply,alt)
  cycleValue(obj,ply,alt,'toughness_base')
end
function cyclePowerMod(obj,ply,alt)
  cycleValue(obj,ply,alt,'power_mod')
end
function cycleToughnessMod(obj,ply,alt)
  cycleValue(obj,ply,alt,'toughness_mod')
end
function cycleOneOneCounter(obj,ply,alt)
  cycleValue(obj,ply,alt,'oneOneCounter')
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
      enc.call("APIobjDefaultValue",{obj=obj,valueID='toughness_base'})
      enc.call("APIobjDefaultValue",{obj=obj,valueID='power_base'})
      enc.call("APIobjDefaultValue",{obj=obj,valueID='toughness_mod'})
      enc.call("APIobjDefaultValue",{obj=obj,valueID='power_mod'})
      enc.call("APIobjDefaultValue",{obj=obj,valueID='oneOneCounter'})
    else
      enc.call("APIobjDefaultValue",{obj=obj,valueID='moduleMath'})
      enc.call("APIobjDefaultValue",{obj=obj,valueID='moduleMod'})
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
function updateModule(wr)
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    wr = wr.text
    wrv = string.match(wr,"version = '(.-)'")
    if wrv == 'DEPRECIATED' then
      enc.call("APIremoveProperty",{propID=pID})
      self.destruct()
    end
    local ver = enc.call("APIversionComp",{wv=wrv,cv=version})
    if ''..ver ~= ''..version then
      broadcastToAll("An update has been found for "..pID..". Reloading Module.")
      self.script_code = wr
      self.reload()
    else
      broadcastToAll("No update found for "..pID..". Carry on.")
    end
  end
end