--Morph
--By Tipsy Hobbit
pID = "MTG_Morph"
UPDATE_URL='https://raw.githubusercontent.com/Jophire/Tabletop-Simulator-Workshop-Items/master/Encoder/Modules/Encoder_Moprh_Addon.lua'
version = '1.8'

function onload()
  self.createButton({
  label="+", click_function='registerModule', function_owner=self,
  position={0,0.2,-0.5}, height=100, width=100, font_size=100,
  rotation={0,0,0},tooltip="Version: "..version
  })
  Wait.condition(registerModule,function() return Global.getVar('Encoder') ~= nil and true or false end)
end


--image_URL = "https://www.cardkingdom.com/images/magic-the-gathering/khans-of-tarkir/morph-token-41016-medium.jpg"
image_URL = 'https://img.scryfall.com/cards/png/front/e/9/e9375cbe-93c0-41a5-a6e3-fb4416f54a69.png?1572370830'

function registerModule()
  enc = Global.getVar('Encoder')
  if enc ~= nil then
		properties = {
		propID = pID,
		name = "Morph",
		values = {'mtg_morphed'},
		funcOwner = self,
		tags="basic,face_prop",
		activateFunc ='toggleMorph'
		}
		enc.call("APIregisterProperty",properties)
    value = {
    valueID = 'mtg_morphed',
    validType = 'boolean',
    desc = 'MTG: Morphed permanents are 3/3 creature morphs with Morph:flip this card face up.',
    default = false
    }
    enc.call("APIregisterValue",value)
  end
end

function createButtons(t)
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    editing = enc.call("APIgetEditing",{obj=t.obj})
    if editing == nil then
      flip = enc.call("APIgetFlip",{obj=t.obj})
      scaler = {x=1,y=1,z=1}--t.obj.getScale()
      temp = " Morph "
      barSize,fsize,offset_x,offset_y = enc.call('APIformatButton',{str=temp,font_size=120,max_len=90,xJust=0,yJust=0})
      
      t.obj.createButton({
      label=temp, click_function='tMorph', function_owner=self,
      position={(0+offset_x)*flip*scaler.x,0.3*flip*scaler.z,(-1.38+offset_y)*scaler.y}, height=170, width=barSize, font_size=fSize,
      rotation={0,0,90-90*flip,font_color={1,1,1,1}}
      })
    end
  end
end

function toggleMorph(t)
  enc.call("APItoggleProperty",{obj=t.obj,propID=pID})
  tMorph(t.obj,t.ply)
end

function tMorph(obj,ply)
	enc = Global.getVar('Encoder')
  if enc ~= nil then
    flip = enc.call("APIgetFlip",{obj=obj})
    data = enc.call("APIobjGetPropData",{obj=obj,propID=pID})
    if data.mtg_morphed ~= true then
      obj.setName(" Morph ")
      data.mtg_morphed = true
      if flip > 0 then
        enc.call("APIFlip",{obj=obj})
      end
      hasDecal = false
      if obj.getDecals() ~= nil then
      for k,v in pairs(obj.getDecals()) do
        if v.name == "Morph" then
          hasDecal = true
          break
        end
      end
      end
      if hasDecal == false then
        obj.addDecal({name="Morph",url=image_URL,position={0,-0.28,0},rotation={-90,0,0},scale={2.15,3.15,1}})
      end
    else
      data.mtg_morphed = false
      obj.setName(enc.call("APIgetOName",{obj=obj}))
      enc.call("APIobjDisableProp",{obj=obj,propID=pID})
      if flip < 0 then
        enc.call("APIFlip",{obj=obj})
        obj.flip()
      end
      local decals = obj.getDecals()
      obj.setDecals({})
      if decals ~= nil then
        for k,v in pairs(decals) do
          if v.name ~= "Morph" then
            obj.addDecal(v)
          end
        end
      end
    end
    if type(ply) == "string" then
      local selection =Player[ply].getSelectedObjects()
      if selection ~= nil then
        for k,v in pairs(selection) do
          if v ~= tar and enc.call("APIobjExists",{obj=v}) == true then 
            tMorph(v,0)
          end
        end
      end
    end
    enc.call("APIobjSetPropData",{obj=obj,propID=pID,data=data})
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