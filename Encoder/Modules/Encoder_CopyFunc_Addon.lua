--[[
  Copy Tools:
  Detects dropped cards and if they are not yet encoded, adds them to the encoder.
]]

pID = "CopyTools"
UPDATE_URL='https://raw.githubusercontent.com/Jophire/Tabletop-Simulator-Workshop-Items/master/Encoder/Modules/Encoder_CopyFunc_Addon.lua'
version = '1.3'

function onload()
  self.createButton({
  label="+", click_function='registerModule', function_owner=self,
  position={0,0.2,-0.5}, height=100, width=100, font_size=100,
  rotation={0,0,0},tooltip="Adds the current stat"
  })
  Wait.condition(registerModule,function() return Global.getVar('Encoder') ~= nil and true or false end)
end

function registerModule()
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    properties = {
    toolID = "exactCopy",
    name = "Exact Copy",
    funcOwner = self,
    activateFunc ='exactCopy',
    display=true
    }
    enc.call("APIregisterTool",properties)   
  end
end


target = nil
function exactCopy(obj,ply)
  target = obj
  startLuaCoroutine(self,"createExactCopy")
end

function createExactCopy()
 tar = target
 cop = createCopy(tar)
 enc.call("APIencodeObject",{obj=cop})
 enc.call("APIobjSetProps",{obj=cop,data=enc.call("APIobjGetProps",{obj=tar})})
 enc.call("APIobjSetAllData",{obj=cop,data=enc.call("APIobjGetAllData",{obj=tar})})
 enc.call("APIrebuildButtons",{obj=cop})
 cop.setLock(false)
 return 1
end

function createCopy(tar)
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    local flip = enc.call("APIgetFlip",{obj=tar})
    local params = {}
    params.position = addVectors(addVectors(tar.getPosition(),multVectors(tar.getTransformRight(),-3.5*flip)),multVectors(tar.getTransformUp(),4*flip))
    v = tar.clone(params)
    v.setLock(true)
    while v.getGUID() == tar.getGUID() do
      waitFrames(5)
    end 
    return v
  end
end


function addVectors(a,b)
return {x=a['x']+b['x'],y=a['y']+b['y'],z=a['z']+b['z']}
end
function multVectors(a,b)
  if type(b) ~= "table" then
    b={x=b,y=b,z=b}
  end
  return {x=a['x']*b['x'],y=a['y']*b['y'],z=a['z']*b['z']}
end
function waitFrames(num_frames)
    for i=0, num_frames, 1 do
        coroutine.yield(0)
    end
    num_frames = 1
    return 1
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