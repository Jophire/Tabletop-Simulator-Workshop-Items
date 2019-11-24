--Vampire
--by Tipsy Hobbit//STEAM_0:1:13465982
encVersion = 1.2
pID = "mtg_vampire"

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
		name = "Vampirize",
		dataStruct = {},
		funcOwner = self,
		callOnActivate = true,
		activateFunc ='toggleVamp'
		}
		enc.call("APIregisterProperty",properties)
  end
end

function createButtons(t)
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    flip = enc.call("APIgetFlip",{obj=t.object})
    scaler = {x=1,y=1,z=1}--t.object.getScale()
    temp = " Vampire "
    barSize,fsize,offset_x,offset_y = enc.call('APIformatButton',{str=temp,font_size=90,max_len=90,xJust=0,yJust=0})
    t.object.createButton({
    label=temp, click_function='doNothing', function_owner=self,
    position={(0+offset_x)*flip*scaler.x,0.28*flip*scaler.z,(-0.1+offset_y)*scaler.y}, height=170, width=barSize, font_size=fSize,
    rotation={0,0,90-90*flip},tooltip="Is a vampire in addition to its other types"
    })
  end
end

function toggleVamp(t)
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    enc.call("APIrebuildButtons",{obj=t.object})
  end
end

function removeFrozen(object,ply)
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    data = enc.call("APIgetObjectData",{obj=object,propID=pID})
    data.enabled = false
    enc.call("APIsetObjectData",{obj=object,propID=pID,data=data})
    enc.call("APIrebuildButtons",{obj=object})
  end
end