--Exerted
--by Tipsy Hobbit//STEAM_0:1:13465982
encVersion = 1.2
pID = "mtg_exert"

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
		name = "Exert",
		values = {'mtg_exert'},
		funcOwner = self,
		callOnActivate = true,
		activateFunc ='toggleExerted'
		}
		enc.call("APIregisterProperty",properties)
    value = {
    valueID = 'mtg_exert',
    validType = 'boolean',
    desc = "MTG: This creature is currently exerted and won't untap during the players next untap step.",
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
    temp = " Exerted "
    barSize,fsize,offset_x,offset_y = enc.call('APIformatButton',{str=temp,font_size=90,max_len=90,xJust=0,yJust=0})
    t.obj.createButton({
    label=temp, click_function='removeExerted', function_owner=self,
    position={(0+offset_x)*flip*scaler.x,0.28*flip*scaler.z,(-1.2+offset_y)*scaler.y}, height=170, width=barSize, font_size=fSize,
    rotation={0,0,90-90*flip},tooltip="Currently Exerted"
    })
  end
end

function toggleExerted(t)
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    data = enc.call("APIobjGetPropData",{obj=t.obj,propID=pID})
    if data.mtg_exert ~= true then
      data.mtg_exert = true
    else
      data.mtg_exert = false
    end
    enc.call("APIobjSetPropData",{obj=t.obj,propID=pID,data=data})
    enc.call("APIrebuildButtons",{obj=t.obj})
  end
end

function removeExerted(obj,ply)
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    data = enc.call("APIobjGetPropData",{obj=obj,propID=pID})
    data.mtg_exert = false
    enc.call("APIobjSetPropData",{obj=obj,propID=pID,data=data})
    enc.call("APIobjDisableProp",{obj=obj,propID=pID})
    enc.call("APIrebuildButtons",{obj=obj})
  end
end