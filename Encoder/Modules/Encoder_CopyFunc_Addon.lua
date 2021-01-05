--[[
  Copy Tools:
  Detects dropped cards and if they are not yet encoded, adds them to the encoder.
]]
pID = "CopyTools"
UPDATE_URL='https://raw.githubusercontent.com/Jophire/Tabletop-Simulator-Workshop-Items/master/Encoder/Modules/Encoder_CopyFunc_Addon.lua'
version = '1.4'
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
    name = "Exact Copy",
    values={},
    funcOwner = self,
    activateFunc ='exactCopy',
    tags="tool",
    visible=true
    }
    enc.call("APIregisterProperty",properties)   
  end
end

function exactCopy(obj,ply)
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    params={}
    params.position = obj.getPosition()+obj.getTransformRight()*-3.5*flip+obj.getTransformUp()*4*flip
    local tar = obj.clone(params)
    local o = obj
    tar.setLock(true)
    Wait.condition(function() 
      enc.call("APIencodeObject",{obj=tar})
      enc.call("APIobjSetProps",{obj=tar,data=enc.call("APIobjGetProps",{obj=o})})
      enc.call("APIobjSetAllData",{obj=tar,data=enc.call("APIobjGetAllData",{obj=o})})
      enc.call("APIrebuildButtons",{obj=tar})
      tar.setLock(false)
    end,
    function() return tar.spawning end)
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