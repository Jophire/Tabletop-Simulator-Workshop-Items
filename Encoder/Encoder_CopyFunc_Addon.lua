--[[
  Copy Tools:
  Detects dropped cards and if they are not yet encoded, adds them to the encoder.
]]

pID = "CopyTools"

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
    toolID = pID,
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
  startLuaCoroutine(self,"createCopy")
end


function createCopy()
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    local tar = target
    local data = enc.call("APIgetOAData",{obj=tar})
    local flip = enc.call("APIgetFlip",{obj=tar})
    local params = {}
    params.position = addVectors(addVectors(tar.getPosition(),multVectors(tar.getTransformRight(),-3.5*flip)),multVectors(tar.getTransformUp(),4*flip))
    v = tar.clone(params)
    v.setLock(true)
    while v.getGUID() == tar.getGUID() do
      waitFrames(5)
    end 
    
    enc.call("APIaddObject",{obj=v})
    enc.call("APIsetOAData",{obj=v,data=data})

    while v.getLock() do
      v.setLock(false)
      waitFrames(5)
    end
    enc.call("APIrebuildButtons",{obj=v})
  end
  return 1
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