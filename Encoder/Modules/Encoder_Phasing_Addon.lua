--Phasing
--By Tipsy Hobbit
encVersion = 1.2
pID = "MTG_Phase"
version = 1.0

function onload()
  self.createButton({
  label="+", click_function='registerModule', function_owner=self,
  position={0,0.2,-0.5}, height=100, width=100, font_size=100,
  rotation={0,0,0},tooltip="Version: "..version
  })
end


function registerModule()
  enc = Global.getVar('Encoder')
  if enc ~= nil then
		properties = {
		propID = pID,
		name = "Phase Out",
		values = {'mtg_phased'},
		funcOwner = self,
		callOnActivate = true,
		activateFunc ='phaseOut'
		}
		enc.call("APIregisterProperty",properties)
    value = {
    valueID = 'mtg_phased',
    validType = 'boolean',
    desc = 'MTG: Is the card phased out?.',
    default = false
    }
    enc.call("APIregisterValue",value)
  end
end

function createButtons(t)
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    flip = enc.call("APIgetFlip",{obj=t.obj})
    scaler = {x=1,y=1,z=1}--t.obj.getScale()
    temp = " PHASED OUT "
    barSize,fsize,offset_x,offset_y = enc.call('APIformatButton',{str=temp,font_size=400,max_len=90,xJust=0,yJust=0})
    t.obj.createButton({
    label=temp, click_function='unPhased', function_owner=self,
    position={(0+offset_x)*flip*scaler.x,0.63*flip*scaler.z,(0+offset_y)*scaler.y}, height=1000, width=1500, font_size=200,color={0,0,0,1},font_color={0.6,0.6,1,1},
    rotation={0,90,90-90*flip,tooltip="This is Phased Out."}
    })
  end
end

function phaseOut(t)
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    data = enc.call("APIobjGetPropData",{obj=t.obj,propID=pID})
		if data.mtg_phased ~= true then
			data.mtg_phased = true
    else
      data.mtg_phased = false
    end
    enc.call("APIobjSetPropData",{obj=t.obj,propID=pID,data=data})
  end
end

function unPhased(obj,ply)
  enc = Global.getVar('Encoder')
  if enc ~= nil and enc.call("APIobjectExists",{obj=obj}) then
    flip = enc.call("APIgetFlip",{obj=obj})
		
		data = enc.call("APIobjGetPropData",{obj=obj,propID=pID})
		if data.mtg_phased == true then
			data.mtg_phased = false
			enc.call("APIobjSetPropData",{obj=obj,propID=pID,data=data})
      enc.call("APIobjDisableProp",{obj=obj,propID=pID})
		end
		if type(ply) == "string" then
			local selection =Player[ply].getSelectedObjects()
			if selection ~= nil then
				for k,v in pairs(selection) do
					if v ~= tar and enc.call("APIobjectExists",{obj=v}) == true then 
						unPhased(v,0)
					end
				end
			end
		end
    enc.call("APIrebuildButtons",{obj=obj})
  end
end