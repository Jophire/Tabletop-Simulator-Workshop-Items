--[[Loyalty Counter Module
by Tipsy Hobbit//STEAM_0:1:13465982
This module adds only Loyalty Counters.
]]
pID = "MTG_Loyalty"
UPDATE_URL='https://raw.githubusercontent.com/Jophire/Tabletop-Simulator-Workshop-Items/master/Encoder/Modules/Encoder_Loyalty_Addon.lua'
version = '1.12'
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
    name = "Loyalty",
    values = {'loyaltyCounter','moduleMod','moduleMath'},
    funcOwner = self,
    tags="basic,counter",
    activateFunc ='callEditor'
    }
    enc.call("APIregisterProperty",properties)
    
    value = {
    valueID = 'loyaltyCounter', 
    validType = 'number',
    desc = 'MTG:Loyalty Counter used by planeswalkers.',
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
      temp = ""..data.loyaltyCounter
      barSize,fsize,offset_x,offset_y = enc.call('APIformatButton',{str=temp,font_size=90,max_len=90,xJust=-1,yJust=0})
      t.obj.createButton(Style.new{
      label=temp, click_function='toggleEditor', function_owner=self,
      position={(-1.1+offset_x)*flip*scaler.x,0.28*flip*scaler.z,(1.4+offset_y)*scaler.y}, height=170, width=barSize > 150 and barSize or 150, font_size=fsize,
      rotation={0,0,90-90*flip}
      })
    elseif editing == pID then
      temp = ""..data.loyaltyCounter
      barSize,fsize,offset_x,offset_y = enc.call('APIformatButton',{str=temp,font_size=400,max_len=90,xJust=1,yJust=0})
      t.obj.createButton(Style.new{
      label=temp, click_function='cycleMain', function_owner=self,
      position={0,0.28*flip*scaler.z,-0.8}, height=400, width=barSize > 800 and barSize or 800, font_size=fsize,rotation={0,0,90-90*flip}, tooltip='Modify Loyalty'
      })
      t.obj.createButton(Style.new{
      label= data.moduleMath, click_function='cycleMath', function_owner=self,
      position={-0.4*flip,0.28*flip*scaler.z,0}, height=400, width=400, font_size=240,rotation={0,0,90-90*flip},
      tooltip = data.moduleMath == '+-' and 'Add or Subtract '..data.moduleMod or 'Multiply or Divide by '..data.moduleMod
      })
      t.obj.createButton(Style.new{
      label= data.moduleMod, click_function='cycleMod', function_owner=self,
      position={0.4*flip,0.28*flip*scaler.z,0}, height=400, width=400, font_size=240,rotation={0,0,90-90*flip},
      tooltip = data.moduleMath == '+-' and 'Add or Subtract '..data.moduleMod or 'Multiply or Divide by '..data.moduleMod
      })
      t.obj.createButton(Style.new{
      label= "Reset", click_function='resetValues', function_owner=self,
      position={0*flip,0.28*flip*scaler.z,1.0}, height=200, width=600, font_size=240,rotation={0,0,90-90*flip},
      tooltip = 'Left click to reset values, right click to reset editor.'
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

function callEditor(obj,ply,alt)
  if type(obj) == 'Table' then obj=obj[1] ply=obj[2] alt=obj[3] end
  if alt then
    enc.call("APIobjResetProp",{obj=obj,propID=pID})
  else
    enc.call("APItoggleProperty",{obj=obj,propID=pID})
    if enc.call("APIobjIsPropEnabled",{obj=obj,propID=pID}) then
      toggleEditor(obj,nil)
    else
      enc.call("APIrebuildButtons",{obj=obj})
    end
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
    data = enc.call("APIobjGetPropData",{obj=obj,propID=pID})
    temp = ""..data.loyaltyCounter
    barSize,fsize,offset_x,offset_y = enc.call('APIformatButton',{str=temp,font_size=400,max_len=90,xJust=0,yJust=0})
    obj.editButton({
    index=0,label=temp,width=barSize > 800 and barSize or 800, font_size=fsize})
    obj.editButton({
    index=1,label=data.moduleMath,
      tooltip = data.moduleMath == '+-' and 'Add or Subtract '..data.moduleMod or 'Multiply or Divide by '..data.moduleMod})
    obj.editButton({
    index=2,label=data.moduleMod,
      tooltip = data.moduleMath == '+-' and 'Add or Subtract '..data.moduleMod or 'Multiply or Divide by '..data.moduleMod})
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
        data.loyaltyCounter = data.loyaltyCounter+mMod
      else
        data.loyaltyCounter = data.loyaltyCounter-mMod
      end
    else
      if alt == false then
        data.loyaltyCounter = data.loyaltyCounter*mMod
      else
        if data.moduleMod == 0 then
          data.moduleMod = 1
        end
        data.loyaltyCounter = data.loyaltyCounter/mMod
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
      enc.call("APIobjDefaultValue",{obj=obj,valueID='loyaltyCounter'})
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