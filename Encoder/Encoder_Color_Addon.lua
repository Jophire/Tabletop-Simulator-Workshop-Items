--Color Module
--by Tipsy Hobbit//STEAM_0:1:13465982
encVersion = 1.2
pID = "MTG_Colors"

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
		name = "Color Identity",
		dataStruct = {red=0,white=0,green=0,black=0,blue=0},
		funcOwner = self,
		callOnActivate = true,
		activateFunc ='callColors'
		}
		enc.call("APIregisterProperty",properties)
  end
end

function createButtons(t)
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    data = enc.call("APIgetObjectData",{obj=t.object,propID=pID})
    flip = enc.call("APIgetFlip",{obj=t.object})
    editing = enc.call("APIgetEditing",{obj=t.object})
		if data.red ~= 0 then
			t.object.createButton({
			label=temp, click_function='toggleColor', function_owner=self,
			position={(0.85)*flip,0.28*flip,(-1.25)}, height=100, width=100, font_size=0,
			rotation={0,0,90-90*flip},color={1,0,0,1},tooltip="Color Identity"
			})
		end
		if data.green ~= 0 then
			t.object.createButton({
			label=temp, click_function='toggleColor', function_owner=self,
			position={(1.0)*flip,0.28*flip,(-1.25)}, height=100, width=100, font_size=0,
			rotation={0,0,90-90*flip},color={0,1,0,1},tooltip="Color Identity"
			})
		end
		if data.white ~= 0 then
			t.object.createButton({
			label=temp, click_function='toggleColor', function_owner=self,
			position={(0.7)*flip,0.28*flip,(-1.4)}, height=100, width=100, font_size=0,
			rotation={0,0,90-90*flip},color={1,1,0.8,1},tooltip="Color Identity"
			})
		end
		if data.black ~= 0 then
			t.object.createButton({
			label=temp, click_function='toggleColor', function_owner=self,
			position={(0.85)*flip,0.28*flip,(-1.4)}, height=100, width=100, font_size=0,
			rotation={0,0,90-90*flip},color={0,0,0,1},tooltip="Color Identity"
			})
		end
		if data.blue ~= 0 then
			t.object.createButton({
			label=temp, click_function='toggleColor', function_owner=self,
			position={(1.0)*flip,0.28*flip,(-1.4)}, height=100, width=100, font_size=0,
			rotation={0,0,90-90*flip},color={0,0,1,1},tooltip="Color Identity"
			})
		end
		if editing == pID then
      t.object.createButton({
      label="Red", click_function='toggler', function_owner=self,
      position={0*flip,0.28*flip,-0.9}, height=240, width=800, font_size=220,rotation={0,0,90-90*flip},color={1,0,0,1}
      })
      t.object.createButton({
      label="Green", click_function='toggleg', function_owner=self,
      position={0*flip,0.28*flip,-0.5}, height=240, width=800, font_size=220,rotation={0,0,90-90*flip},color={0,1,0,1}
      })
      t.object.createButton({
      label="White", click_function='togglew', function_owner=self,
      position={0*flip,0.28*flip,-0.1}, height=240, width=800, font_size=220,rotation={0,0,90-90*flip},color={1,1,0.8,1}
      })
      t.object.createButton({
      label="Black", click_function='toggleb', function_owner=self,
      position={0*flip,0.28*flip,0.3}, height=240, width=800, font_size=220,rotation={0,0,90-90*flip},color={0.6,0.6,0.6,1}
      })
      t.object.createButton({
      label="Blue", click_function='toggleu', function_owner=self,
      position={0*flip,0.28*flip,0.7}, height=240, width=800, font_size=220,rotation={0,0,90-90*flip},color={0,0,1,1}
      })
      t.object.createButton({
      label="Clear", click_function='clear', function_owner=self,
      position={0*flip,0.28*flip,1.1}, height=240, width=800, font_size=220,rotation={0,0,90-90*flip},color={1,1,1,1}
      })
    end
  end
end

function callColors(t)
	toggleColor(t.object)
end
function toggleColor(object)
  enc = Global.getVar('Encoder')
  if enc ~= nil then
		if enc.call("APIgetEditing",{obj=object}) == nil then
			enc.call("APIsetEditing",{obj=object,propID=pID})
		else
			enc.call("APIclearEditing",{obj=object})
		end
    enc.call("APIrebuildButtons",{obj=object})
  end
end

function toggler(object,ply)
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    data = enc.call("APIgetObjectData",{obj=object,propID=pID})
    data.red = math.abs(data.red-1)
    enc.call("APIsetObjectData",{obj=object,propID=pID,data=data})
    enc.call("APIrebuildButtons",{obj=object})
  end
end
function toggleg(object,ply)
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    data = enc.call("APIgetObjectData",{obj=object,propID=pID})
    data.green = math.abs(data.green-1)
    enc.call("APIsetObjectData",{obj=object,propID=pID,data=data})
    enc.call("APIrebuildButtons",{obj=object})
  end
end
function togglew(object,ply)
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    data = enc.call("APIgetObjectData",{obj=object,propID=pID})
    data.white = math.abs(data.white-1)
    enc.call("APIsetObjectData",{obj=object,propID=pID,data=data})
    enc.call("APIrebuildButtons",{obj=object})
  end
end
function toggleb(object,ply)
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    data = enc.call("APIgetObjectData",{obj=object,propID=pID})
    data.black = math.abs(data.black-1)
    enc.call("APIsetObjectData",{obj=object,propID=pID,data=data})
    enc.call("APIrebuildButtons",{obj=object})
  end
end
function toggleu(object,ply)
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    data = enc.call("APIgetObjectData",{obj=object,propID=pID})
    data.blue = math.abs(data.blue-1)
    enc.call("APIsetObjectData",{obj=object,propID=pID,data=data})
    enc.call("APIrebuildButtons",{obj=object})
  end
end
function clear(object,ply)
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    data = enc.call("APIgetObjectData",{obj=object,propID=pID})
    data.red = 0
		data.green = 0
		data.white = 0
		data.black = 0
		data.blue = 0
    enc.call("APIsetObjectData",{obj=object,propID=pID,data=data})
    enc.call("APIrebuildButtons",{obj=object})
  end
end