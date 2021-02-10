--[[Status Effects Module
by Tipsy Hobbit//STEAM_0:1:13465982
This module adds only Status Effects.
]]
pID = "MTG_Status_Effects"
UPDATE_URL='https://raw.githubusercontent.com/Jophire/Tabletop-Simulator-Workshop-Items/master/Encoder/Modules/Encoder_Status_Effects_Addon.lua'
version = '1.12'

StatusList={
  mtg_exert={name="Exerted", des=":Card does not untap the next Controller's untap step.",val='boolean',def=false},
  mtg_frozen={name="Frozen", des=":Card does not untap during the untap step as long as this effect is in effect.",val='boolean',def=false},
  mtg_detain={name="Detained", des=":Creature can't block, attack, or activate abilities till %Color%'s next turn.",val='color',def=''},
  mtg_monstrous={name="Monstrous", des=":This creature has been made monstrous.",val='boolean',def=false},
  mtg_goad={name="Goaded", des=":This creature must attack a player other then %Color% if able.",val='color',def='',func=function() return Turns.turn_color end}
}


function onload()
  self.createButton({
  label="+", click_function='registerModule', function_owner=self,
  position={0,0.2,-0.5}, height=100, width=100, font_size=100,
  rotation={0,0,0},tooltip="Version: "..version
  })
  Wait.condition(registerModule,function() return Global.getVar('Encoder') ~= nil and true or false end)
end

function registerModule(obj,ply)
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    values={}
    for k,v in pairs(StatusList) do
      table.insert(values,k)
    end
    properties = {
    propID = pID,
    name = "Status Effects",
    values = values,
    funcOwner = self,
    tags="basic,face_prop",
    activateFunc ='callEditor'
    }
    enc.call("APIregisterProperty",properties)
    for k,v in pairs(StatusList) do
      value = {
      valueID = k,
      validType = v.val,
      desc = v.des,
      default = v.def
      }
      enc.call("APIregisterValue",value)
      local g = k
      _G['toggleStatus'..g] = function(o,p,a) toggleStatus(o,p,a,g) end
    end
  end
end

function toggleStatus(obj,ply,alt,val)
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    data = enc.call("APIobjGetValueData",{obj=obj,valueID=val})
    if StatusList[val].val == 'boolean' then
      if data[val] ~= true then
      data[val] = true
      else
        data[val] = false
      end
    elseif StatusList[val].val == 'color' then
      if data[val] ~= '' then
      data[val] = ''
      else
        data[val] = StatusList[val].func ~= nil and StatusList[val].func() or ply
      end
    end
    enc.call("APIobjSetValueData",{obj=obj,valueID=val,data=data})
    enc.call("APIrebuildButtons",{obj=obj})
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

function createButtons(t)
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    data = enc.call("APIobjGetPropData",{obj=t.obj,propID=pID})
    flip = enc.call("APIgetFlip",{obj=t.obj})
    scaler = {x=1,y=1,z=1}--t.obj.getScale()
    editing = enc.call("APIgetEditing",{obj=t.obj})
    
    tooltip = "Status Effects:\n"
    for k,v in pairs(data) do
      if StatusList[k].val == 'boolean' and v == true then
        tooltip = tooltip..StatusList[k].name..StatusList[k].des..'\n'
      elseif StatusList[k].val == 'color' and v ~= '' then
        tooltip = tooltip..StatusList[k].name..string.gsub(StatusList[k].des,'%%Color%%',v)..'\n'
      end
    end
      
    if editing == nil then     
      temp = "Status"
      barSize,fsize,offset_x,offset_y = enc.call('APIformatButton',{str=temp,font_size=90,max_len=90,xJust=0,yJust=0})
      t.obj.createButton({
      label=temp, click_function='toggleEditor', function_owner=self,
      position={(-0+offset_x)*flip*scaler.x,0.28*flip*scaler.z,(-1.2+offset_y)*scaler.y}, height=170, width=barSize, font_size=fSize,
      rotation={0,0,90-90*flip}, tooltip=tooltip,color={r=1,g=1,b=1,a=0.4}
      })
    elseif editing == pID then
      temp = "Status"
      barSize,fsize,offset_x,offset_y = enc.call('APIformatButton',{str=temp,font_size=90,max_len=90,xJust=0,yJust=0})
      t.obj.createButton({
      label=temp, click_function='toggleEditClose', function_owner=self,
      position={(-0+offset_x)*flip*scaler.x,0.28*flip*scaler.z,(-1.2+offset_y)*scaler.y}, height=160, width=barSize, font_size=fsize,
      rotation={0,0,90-90*flip}, tooltip=tooltip
      })
      i = 1
      for k,v in pairs(data) do
        if (StatusList[k].val == 'boolean' and v == true) or StatusList[k].val == 'color' and v ~= '' then
          temp =StatusList[k].name
          barSize,fsize,offset_x,offset_y = enc.call('APIformatButton',{str=temp,font_size=90,max_len=90,xJust=0,yJust=0})
          t.obj.createButton({
          label= temp, click_function='toggleStatus'..k, function_owner=self,
          position={-0*flip,0.28*flip*scaler.z,(-1.2+offset_y+i*0.25)*scaler.y}, height=160, width=barSize, font_size=fsize,
          rotation={0,0,90-90*flip}, color={r=0,g=0,b=0}, font_color={r=1,g=0,b=0},tooltip=StatusList[k].des
          })
        else
          temp =StatusList[k].name
          barSize,fsize,offset_x,offset_y = enc.call('APIformatButton',{str=temp,font_size=90,max_len=90,xJust=0,yJust=0})
          t.obj.createButton({
          label= temp, click_function='toggleStatus'..k, function_owner=self,
          position={-0*flip,0.28*flip*scaler.z,(-1.2+offset_y+i*0.25)*scaler.y}, height=160, width=barSize, font_size=fsize,
          rotation={0,0,90-90*flip}, color={r=0,g=0,b=0}, font_color={r=1,g=1,b=1},tooltip=StatusList[k].des
          })
        end
        i = i+1
      end
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