--[[
  Auto Property Register
  Place on table anywhere.
  Make sure you are using at least version 1 of my new encoder.
  Will automatically register any properties as they are dropped on the table.
  By: Tipsy Hobbit
]]--
pID = "ENC_AUTOREGISTER"
UPDATE_URL='https://raw.githubusercontent.com/Jophire/Tabletop-Simulator-Workshop-Items/master/Encoder/Extras/Encoder%20AutoRegister.lua'
version = '1.2.6'

function onLoad()
  Wait.condition(registerModule,function() if Global.getVar("Encoder") ~= nil then return true else return false end end)
end

function registerModule()
  enc = Global.getVar("Encoder")
  if enc ~= nil then
    properties = {
    propID = pID,
    name = "Encoder Module Autoregister",
    values = {},
    funcOwner = self,
    tags="hidden",
    activateFunc ='doNothing',
    visible = false
    }
    enc.call("APIregisterProperty",properties)
  end
end

function onObjectDropped(c,object)
  local enc = Global.getVar('Encoder')
  if enc ~= nil then
    if object.getVar("pID") ~= nil and object ~= self then
      object.setLock(true)
      
      start = 0
      modules = {}
      for k,v in pairs(enc.call("APIgetPropsList",nil)) do
        table.insert(modules,enc.call("APIgetProp",{propID=k}))
      end
      for k,v in pairs(enc.call("APIlistMenus",nil)) do
        table.insert(modules,enc.call("APIgetMenu",{menuID=k}))
      end
      count = 0
      
      startPos = self.getPosition()+self.getTransformUp()*1
      start = start;
      rev = 1
      radius = 1.5
      ao = 2*math.pi/(((2*math.pi*radius)/1.05)-1)
  
      enc.setRotation(self.getRotation()+Vector(0,start*20))
      enc.setPositionSmooth(startPos,false,false)
      enc.setLock(true)
      enc.setScale(self.getScale()*0.675)
      
      for k,v in pairs(modules) do
        if v.funcOwner ~= nil and v.funcOwner ~= self then
          v.funcOwner.setRotation(self.getRotation())
          offset = Vector(math.cos(start*rev+ao*count*rev)*(radius),0,math.sin(start*rev+ao*count*rev)*(radius))
          v.funcOwner.setPositionSmooth(startPos+offset, false, false)
          v.funcOwner.setScale(self.getScale()*0.315)
          count = count+1
          if count >= (2*math.pi*radius)/1.05-1 then
            radius = radius + 1.1
            ao = 2*math.pi/(((2*math.pi*radius)/1.05-1))
            rev=-rev
          end
        end
      end
    end
  end
end

function tableMerge(t1, t2)
    local t3 = t1
    for k,v in pairs(t2) do
        if type(v) == "table" then
            if type(t3[k] or false) == "table" then
                tableMerge(t1[k] or {}, t2[k] or {})
            else
                t3[k] = v
            end
        else
            t3[k] = v
        end
    end
    return t3
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