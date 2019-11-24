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
		dataStruct = {},
		funcOwner = self,
		callOnActivate = false,
		activateFunc =''
		}
		enc.call("APIregisterProperty",properties)
  end
end

function createButtons(t)
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    flip = enc.call("APIgetFlip",{obj=t.object})
    scaler = {x=1,y=1,z=1}--t.object.getScale()
    temp = " PHASED OUT "
    barSize,fsize,offset_x,offset_y = enc.call('APIformatButton',{str=temp,font_size=400,max_len=90,xJust=0,yJust=0})
    t.object.createButton({
    label=temp, click_function='unPhased', function_owner=self,
    position={(0+offset_x)*flip*scaler.x,0.63*flip*scaler.z,(0+offset_y)*scaler.y}, height=1000, width=1500, font_size=200,color={0,0,0,1},font_color={0.6,0.6,1,1},
    rotation={0,90,90-90*flip}
    })
  end
end

function unPhased(object,ply)
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    flip = enc.call("APIgetFlip",{obj=object})
		
		data = enc.call("APIgetObjectData",{obj=object,propID=pID})
		if data ~= nil and data.enabled == true then
			data.enabled = false
			enc.call("APIsetObjectData",{obj=object,propID=pID,data=data})
		end
		if type(ply) == "string" then
			local selection =Player[ply].getSelectedObjects()
			if selection ~= nil then
				for k,v in pairs(selection) do
					if v ~= tar and enc.call("APIobjectExist",{obj=v}) == true then 
						unPhased(v,0)
					end
				end
			end
		end
    enc.call("APIrebuildButtons",{obj=object})
  end
end