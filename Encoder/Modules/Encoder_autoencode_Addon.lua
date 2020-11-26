--[[
  Auto Encoder:
  Detects dropped cards and if they are not yet encoded, adds them to the encoder.
]]

pID = "AutoEncoder"
version = 1.0

function onload()
  self.createButton({
  label="+", click_function='registerModule', function_owner=self,
  position={0,0.2,-0.5}, height=100, width=100, font_size=100,
  rotation={0,0,0},tooltip=""
  })
  
  
end

function registerModule()
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    properties = {
    toolID = pID,
    name = "Auto Encoder",
    funcOwner = self,
    activateFunc ='',
    display=false
    }
    enc.call("APIregisterTool",properties)
  end
end

function onObjectDropped(c,obj)
  local enc = Global.getVar('Encoder')
  if enc ~= nil then  
    if obj.tag == "Card" and enc.call("APIobjectExists",{obj=obj}) == false and obj.getVar("noencode") == nil then
      enc.call("APIencodeObject",{obj=obj})
    end
  end
end