--Morph
--By Tipsy Hobbit
encVersion = 1.2
pID = "MTG_Morph"
version = 1.5

function onload()
  self.createButton({
  label="+", click_function='registerModule', function_owner=self,
  position={0,0.2,-0.5}, height=100, width=100, font_size=100,
  rotation={0,0,0},tooltip="Version: "..version
  })
end


--image_URL = "https://www.cardkingdom.com/images/magic-the-gathering/khans-of-tarkir/morph-token-41016-medium.jpg"
image_URL = 'https://img.scryfall.com/cards/png/front/e/9/e9375cbe-93c0-41a5-a6e3-fb4416f54a69.png?1572370830'

function registerModule()
  enc = Global.getVar('Encoder')
  if enc ~= nil then
		properties = {
		propID = pID,
		name = "Morph",
		dataStruct = {},
		funcOwner = self,
		callOnActivate = true,
		activateFunc ='toggleMorph'
		}
		enc.call("APIregisterProperty",properties)
  end
end

function createButtons(t)
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    flip = enc.call("APIgetFlip",{obj=t.object})
    scaler = {x=1,y=1,z=1}--t.object.getScale()
    temp = " Morph "
    barSize,fsize,offset_x,offset_y = enc.call('APIformatButton',{str=temp,font_size=120,max_len=90,xJust=0,yJust=0})
    t.object.createButton({
    label=temp, click_function='tMorph', function_owner=self,
    position={(0+offset_x)*flip*scaler.x,0.3*flip*scaler.z,(-1.38+offset_y)*scaler.y}, height=170, width=barSize, font_size=fSize,
    rotation={0,0,90-90*flip,font_color={1,1,1,1}}
    })
		
  end
end

function toggleMorph(t)
	enc = Global.getVar('Encoder')
  if enc ~= nil then
		tMorph(t.object,t.player)
		local selection =Player[t.player].getSelectedObjects()
		if selection ~= nil then
			for k,v in pairs(selection) do
				if v ~= t.object and enc.call("APIobjectExist",{obj=v}) == true then 
					tMorph(v,t.player)
				end
			end
		end
	end
end

function tMorph(object,ply)
	enc = Global.getVar('Encoder')
  if enc ~= nil then
    flip = enc.call("APIgetFlip",{obj=object})
    data = enc.call("APIgetObjectData",{obj=object,propID=pID})
    if data ~= nil then 
      if data.enabled ~= true then
        object.setName(" Morph ")
        if flip >= 0 then
          enc.call("APIFlip",{obj=object})
        end
        hasDecal = false
        if object.getDecals() ~= nil then
        for k,v in pairs(object.getDecals()) do
          if v.name == "Morph" then
            hasDecal = true
            break
          end
        end
        end
        if hasDecal == false then
          object.addDecal({name="Morph",url=image_URL,position={0,-0.2,0},rotation={-90,0,0},scale={2.15,3.15,1}})
        end
      else
        data.enabled = false
        enc.call("APIsetObjectData",{obj=object,propID=pID,data=data})
        object.setName(enc.call("APIgetOName",{obj=object}))
        if flip < 0 then
          enc.call("APIFlip",{obj=object})
        end
        local decals = object.getDecals()
        if decals ~= nil then
          for k,v in pairs(decals) do
            if v.name == "Morph" then
              table.remove(decals,k)
            end
          end
          object.setDecals(decals)
        end
        if type(ply) == "string" then
        local selection =Player[ply].getSelectedObjects()
        if selection ~= nil then
          for k,v in pairs(selection) do
            if v ~= tar and enc.call("APIobjectExist",{obj=v}) == true then 
              removeMorph(v,0)
            end
          end
        end
      end
    end
    enc.call("APIrebuildButtons",{obj=object})
  end
end
