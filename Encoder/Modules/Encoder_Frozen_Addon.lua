--Frozen
--by Tipsy Hobbit//STEAM_0:1:13465982
encVersion = 1.2
pID = "mtg_frozen"

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
		propID = pID,
		name = "Frozen",
		values = {'mtg_frozen'},
		funcOwner = self,
		callOnActivate = true,
		activateFunc ='toggleFrozen'
		}
		enc.call("APIregisterProperty",properties)
    value = {
    valueID = 'mtg_frozen',
    validType = 'boolean',
    desc = 'MTG: This creature is currently frozen, not untapping during the owners untap step.',
    default = false
    }
    enc.call("APIregisterValue",value)
  end
end

function createButtons(t)
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    flip = enc.call("APIgetFlip",{obj=t.obj})
    scaler = {x=1,y=1,z=1}--t.object.getScale()
    temp = " Frozen "
    barSize,fsize,offset_x,offset_y = enc.call('APIformatButton',{str=temp,font_size=90,max_len=90,xJust=0,yJust=0})
    t.obj.createButton({
    label=temp, click_function='removeFrozen', function_owner=self,
    position={(0+offset_x)*flip*scaler.x,0.28*flip*scaler.z,(-1.0+offset_y)*scaler.y}, height=170, width=barSize, font_size=fSize,
    rotation={0,0,90-90*flip},tooltip="Does Not Untap"
    })
  end
end

function toggleFrozen(t)
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    data = enc.call("APIobjGetPropData",{obj=t.obj,propID=pID})
    if data.mtg_frozen ~= true then
      data.mtg_frozen = true
    else
      data.mtg_frozen = false
    end
    enc.call("APIobjSetPropData",{obj=t.obj,propID=pID,data=data})
    enc.call("APIrebuildButtons",{obj=t.obj})
  end
end

function removeFrozen(obj,ply)
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    data = enc.call("APIobjGetPropData",{obj=obj,propID=pID})
    data.mtg_frozen = false
    enc.call("APIobjSetPropData",{obj=obj,propID=pID,data=data})
    enc.call("APIobjDisableProp",{obj=obj,propID=pID})
    enc.call("APIrebuildButtons",{obj=obj})
  end
end