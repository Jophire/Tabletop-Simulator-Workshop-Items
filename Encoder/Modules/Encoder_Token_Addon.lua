--Token Desginator
--By Tipsy Hobbit
pID = "MTG_Token"
UPDATE_URL='https://raw.githubusercontent.com/Jophire/Tabletop-Simulator-Workshop-Items/master/Encoder/Modules/Encoder_Token_Addon.lua'
version = '1.3'

function onload()
  self.createButton({
  label="+", click_function='registerModule', function_owner=self,
  position={0,0.2,-0.5}, height=100, width=100, font_size=100,
  rotation={0,0,0},tooltip=""
  })
  Wait.condition(registerModule,function() return Global.getVar('Encoder') ~= nil and true or false end)
end
function registerModule()
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    properties = {
    propID = pID,
    name = "Is Token",
    values = {'mtg_token'},
    funcOwner = self,
    callOnActivate = false,
    activateFunc ='tToken'
    }
    enc.call("APIregisterProperty",properties)
    value = {
    valueID = 'mtg_token', 
    validType = 'boolean',
    desc = 'MTG:is this a token? Tokens are non-card permanents.',   
    default = false       
    }
    enc.call("APIregisterValue",value)
  end
end

function createButtons(t)
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    flip = enc.call("APIgetFlip",{obj=t.obj})
    scaler = {x=1,y=1,z=1}--t.obj.getScale()
    temp = " Token "
    barSize,fsize,offset_x,offset_y = enc.call('APIformatButton',{str=temp,font_size=90,max_len=90,xJust=0,yJust=0})
    t.obj.createButton({
    label=temp, click_function='toggleToken', function_owner=self,
    position={(0+offset_x)*flip*scaler.x,0.28*flip*scaler.z,(-1.65+offset_y)*scaler.y}, height=170, width=barSize, font_size=fSize,
    rotation={0,0,90-90*flip}
    })
  end
end

function tToken(t)
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    data = enc.call("APIobjGetPropData",{obj=t.obj,propID=pID})
    if data.mtg_token ~= true then
      data.mtg_token = true
    else
      data.mtg_token = false
    end
  end
end

function toggleToken(obj,ply)
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    data = enc.call("APIobjGetPropData",{obj=obj,propID=pID})
    data.mtg_token = false
    enc.call("APIobjDisableProp",{obj=obj,propID=pID})
    enc.call("APIobjSetPropData",{obj=obj,propID=pID,data=data})
    
    if type(ply) == "string" then
      local selection =Player[ply].getSelectedObjects()
      if selection ~= nil then
        for k,v in pairs(selection) do
          if v ~= tar and enc.call("APIobjExists",{obj=v}) == true then 
            toggleToken(v,0)
          end
        end
      end
    end
    
    enc.call("APIrebuildButtons",{obj=obj})
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
