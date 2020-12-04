--[[Status Effects Module
by Tipsy Hobbit//STEAM_0:1:13465982
This module adds only Loyalty Counters.
]]
encVersion = 4.2.10
pID = "MTG_Status_Affects"
version = 1.0

StatusList={
  mtg_Exert={name="Exerted", des=":Card does not untap the next Controller's untap step.",val='boolean',def=false},
  mtg_Frozen={name="Frozen", des="Frozen:Card does not untap during the untap step as long as this effect is in effect.",val='boolean',def=false},
  mtg_Detain={name="Detained", des="Detained:Creature can't block, attack, or activate abilities till %Color%'s next turn.",val='color',def=''},
  mtg_Monstrous={name="Monstrous", des="Monstrous:This creature has been made monstrous.",val='boolean',def=false},
  mtg_Goad={name="Goaded", des="Goaded:This creature must attack a player other then 'Color' if able.",val='color',def='',func=function() return Turns.turn_color end}
}


function onload()
  self.createButton({
  label="+", click_function='registerModule', function_owner=self,
  position={0,0.2,-0.5}, height=100, width=100, font_size=100,
  rotation={0,0,0},tooltip="Version: "..version
  })
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
    name = "Keyword Affects",
    values = values,
    funcOwner = self,
    callOnActivate = true,
    activateFunc ='callEditor'
    }
    enc.call("APIregisterProperty",properties)
    for k,v in pairs(StatusList) do
      value = {
      valueID = k
      validType = v.val,
      desc = v.desc
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
    if StatusList[val].val == 'boolean' and data[val] ~= true then
      data[val] = true
    else
      data[val] = false
    end
    
    if StatusList[val].val == 'color' and data[val] ~= '' then
      data[val] = ''
    else
      data[val] = if StatusList[val].func ~= nil and StatusList[val].func() or ply
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

function createButtons(t)
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    data = enc.call("APIobjGetPropData",{obj=t.obj,propID=pID})
    flip = enc.call("APIgetFlip",{obj=t.obj})
    scaler = {x=1,y=1,z=1}--t.obj.getScale()
    editing = enc.call("APIgetEditing",{obj=t.obj})
    
    tooltip = ""
    for k,v in pairs(data) do
      if StatusList[k].val == 'boolean' and v == true then
        tooltip = tooltip..StatusList[k].name..StatusList[k].des..'\n'
      elseif StatusList[k] == 'color' and v ~= '' then
        tooltip = tooltip..StatusList[k].name..string.gsub(StatusList[k].des,'%%Color%%',v)..'\n'
      end
    end
      
    if editing == nil then
      for k,v in pairs(data)
      
      temp = "Status"
      barSize,fsize,offset_x,offset_y = enc.call('APIformatButton',{str=temp,font_size=90,max_len=90,xJust=0,yJust=0})
      t.obj.createButton({
      label=temp, click_function='toggleEditor', function_owner=self,
      position={(-0+offset_x)*flip*scaler.x,0.28*flip*scaler.z,(-1.2+offset_y)*scaler.y}, height=170, width=barSize, font_size=fSize,
      rotation={0,0,90-90*flip}, tooltip=tooltip
      })
    elseif editing == pID then
      temp = "Status"
      barSize,fsize,offset_x,offset_y = enc.call('APIformatButton',{str=temp,font_size=90,max_len=90,xJust=0,yJust=0})
      t.obj.createButton({
      label=temp, click_function='toggleEditClose', function_owner=self,
      position={(-0+offset_x)*flip*scaler.x,0.28*flip*scaler.z,(-1.2+offset_y)*scaler.y}, height=170, width=barSize, font_size=fsize,
      rotation={0,0,90-90*flip}, tooltip=tooltip
      })
      i = 1
      for k,v in pairs(data) do
        if (StatusList[k].val == 'boolean' and v == true) or StatusList[k] == 'color' and v ~= '' then
          temp =StatusList[k].name
          barSize,fsize,offset_x,offset_y = enc.call('APIformatButton',{str=temp,font_size=90,max_len=90,xJust=0,yJust=0})
          t.obj.createButton({
          label= temp, click_function='toggleStatus'..k, function_owner=self,
          position={-0*flip,0.28*flip*scaler.z,(-1.2+offset_y+i*0.2)*scaler.y}, height=170, width=barSize, font_size=fsize,
          rotation={0,0,90-90*flip}, color={r=0,g=0,b=0}, font_color={r=1,g=0,b=0}
          })
        else
          temp =StatusList[k].name
          barSize,fsize,offset_x,offset_y = enc.call('APIformatButton',{str=temp,font_size=90,max_len=90,xJust=0,yJust=0})
          t.obj.createButton({
          label= temp, click_function='toggleStatus'..k, function_owner=self,
          position={-0*flip,0.28*flip*scaler.z,(-1.2+offset_y+i*0.2)*scaler.y}, height=170, width=barSize, font_size=fsize,
          rotation={0,0,90-90*flip}, color={r=0,g=0,b=0}, font_color={r=0,g=0,b=0}
          })
        end
        i = i+1
      end
    end
  end
end




