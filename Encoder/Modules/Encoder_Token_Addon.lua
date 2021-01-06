--Token Desginator
--By Tipsy Hobbit
pID = "MTG_Token"
UPDATE_URL='https://raw.githubusercontent.com/Jophire/Tabletop-Simulator-Workshop-Items/master/Encoder/Modules/Encoder_Token_Addon.lua'
version = '1.7.1'
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
    name = "Is Token",
    values = {'mtg_token'},
    funcOwner = self,
    tags='tool',
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
    flip = enc.call("APIgetFlip",{obj=t.obj})
    scaler = {x=1,y=1,z=1}--t.obj.getScale()
    temp = " Token "
    barSize,fsize,offset_x,offset_y = enc.call('APIformatButton',{str=temp,font_size=90,max_len=90,xJust=0,yJust=0})
    t.obj.createButton(Style.new{
    label=temp, click_function='toggleToken', function_owner=self,
    position={(0+offset_x)*flip*scaler.x,0.28*flip*scaler.z,(-1.65+offset_y)*scaler.y}, height=170, width=barSize, font_size=fsize,
    rotation={0,0,90-90*flip}
    })
  end
end

function tToken(obj,ply)
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    enc.call("APItoggleProperty",{obj=obj,propID=pID})
    data = enc.call("APIobjGetPropData",{obj=obj,propID=pID})
    if data.mtg_token ~= true then
      data.mtg_token = true
    else
      data.mtg_token = false
    end
    enc.call("APIrebuildButtons",{obj=obj})
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
