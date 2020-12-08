--[[Color Module
by Tipsy Hobbit//STEAM_0:1:13465982
This module adds color Designators.
]]
pID = "MTG_Colors"
UPDATE_URL='https://raw.githubusercontent.com/Jophire/Tabletop-Simulator-Workshop-Items/master/Encoder/Modules/Encoder_Color_Addon.lua'
version = '1.3'

colors={
w={r=1,g=1,b=1},
u={r=0,g=0,b=1},
b={r=0,g=0,b=0},
r={r=1,g=0,b=0},
g={r=0,g=1,b=0}
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

    properties = {
    propID = pID,
    name = "MTG Colors",
    values = {'mtg_colors'},
    funcOwner = self,
    callOnActivate = true,
    activateFunc ='callEditor'
    }
    enc.call("APIregisterProperty",properties)

    value = {
    valueID = 'mtg_colors',
    validType = 'pattern(^[wubrg]*$)',
    desc = "MTG:Color Identity of the card.",
    default = ''
    }
    enc.call("APIregisterValue",value)
    
    for c,t in pairs(colors) do 
      _G['toggle'..c]=function(obj,ply,alt) toggleStatus(obj,ply,alt,c) end
    end
  end
end

function toggleStatus(obj,ply,alt,val)
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    data = enc.call("APIobjGetPropData",{obj=obj,propID=pID})
    if string.find(data['mtg_colors'],val) then
      data['mtg_colors']=string.gsub(data['mtg_colors'],val,'')
    else
      data['mtg_colors']=data['mtg_colors']..val
    end
    
    enc.call("APIobjSetPropData",{obj=obj,propID=pID,data=data})
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
    
    i = 0
    for c,a in pairs(colors) do
      if editing == nil then
        if string.find(data['mtg_colors'],c) then
          t.obj.createButton({
          label=temp, click_function='toggleEditor', function_owner=self,
          position={1.0*flip*scaler.x,0.28*flip*scaler.z,(-1.4+i*0.1)*scaler.y}, height=50, width=75, font_size=0,
          rotation={0,0,90-90*flip}, color=a
          })
          i = i+1
        end
      elseif editing == pID then
        t.obj.createButton({
        label='', click_function='toggle'..c, function_owner=self,
        position={-0*flip,0.28*flip*scaler.z,(-1.2+i*0.4)*scaler.y}, height=100, width=300, font_size=0,
        rotation={0,0,90-90*flip}, color=a
        })
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