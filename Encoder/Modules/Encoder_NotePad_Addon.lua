--Notepad
--by Tipsy Hobbit//STEAM_0:1:13465982
pID = "notepad"
UPDATE_URL='https://raw.githubusercontent.com/Jophire/Tabletop-Simulator-Workshop-Items/master/Encoder/Modules/Encoder_Notepad_Addon.lua'
version = '1.1'

function onload()
  self.createButton({
  label="+", click_function='registerModule', function_owner=self,
  position={0,0.2,-0.5}, height=100, width=100, font_size=100,
  rotation={0,0,0},tooltip=""
  })
  Wait.condition(registerModule,function() return Global.getVar('Encoder') ~= nil and true or false end)
end


function registerModule()
  enc = Global.getVar('Encoder')
  if enc ~= nil then
		properties = {
		propID = pID,
		name = "Notepad",
		values = {'notes'},
		funcOwner = self,
		callOnActivate = false,
		activateFunc =''
		}
		enc.call("APIregisterProperty",properties)
    value = {
    valueID = 'notes',
    validType = nil,
    desc = "Lets you keep notes in a more organized manner then the description.",
    default = {text='',tooltip=false}
    }
    enc.call("APIregisterValue",value)
  end
end

function createButtons(t)
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    flip = enc.call("APIgetFlip",{obj=t.object})
		data = enc.call("APIobjGetPropData",{obj=t.object,propID=pID})
		scaler = {x=1,y=1,z=1}
		tooltip = ""
		if data.notes.tooltip == true then
			tooltip = data.notes.text
		end
		editing = enc.call("APIgetEditing",{obj=t.object})
    if editing == nil then
			temp = "[=]"
			barSize,fsize,offset_x,offset_y = enc.call('APIformatButton',{str=temp,font_size=60,max_len=90,xJust=0,yJust=0})
			t.object.createButton({
			label=temp, click_function='toggleEditor', function_owner=self,
			position={(0.780+offset_x)*flip*scaler.x,0.28*flip*scaler.z,(0.235+offset_y)*scaler.y}, height=110, width=barSize, font_size=fSize,
			rotation={0,0,90-90*flip},tooltip=tooltip
			})
		elseif editing == pID then
			t.object.createInput({
			label="NotePad", input_function='editText', function_owner=self,
			position={(0.0)*flip*scaler.x,0.28*flip*scaler.z,(0.0)*scaler.y}, height=1200, width=700, font_size=70,
			rotation={0,0,90-90*flip},tooltip='',alignment=2,value=data.notes,validation=1,tab=3
			})
			temp = ' V '
			barSize,fsize,offset_x,offset_y = enc.call('APIformatButton',{str=temp,font_size=60,max_len=90,xJust=0,yJust=0})
			t.object.createButton({
			label=temp, click_function='toggleToolTip', function_owner=self,
			position={(-1.1+offset_x)*flip*scaler.x,0.28*flip*scaler.z,(0+offset_y)*scaler.y}, height=110, width=barSize, font_size=fSize,
			rotation={0,0,90-90*flip},tooltip=data.notes.tooltip==true and 'Visible' or 'Hidden'
			})
		end
  end
end

function editText(obj,ply,val,sel)
	if sel == false then
		enc = Global.getVar('Encoder')
		if enc ~= nil then
			data = enc.call("APIobjGetPropData",{obj=obj,propID=pID})
			data.notes.text = val
			enc.call("APIobjSetPropData",{obj=obj,propID=pID,data=data})
		end
	else	
		log(val,"input_text", "Notepad"..obj.getGUID())
		--obj.editInput({index=0,value=val})
	end
end
function toggleToolTip(obj,ply)
	enc = Global.getVar('Encoder')
	if enc ~= nil then
		data = enc.call("APIobjGetPropData",{obj=obj,propID=pID})
		if data.notes.tooltip == true then
			data.notes.tooltip = false
		else
			data.notes.tooltip = true
		end
		enc.call("APIobjSetPropData",{obj=obj,propID=pID,data=data})
	end
end
function toggleEditor(object)
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    enc.call("APIsetEditing",{obj=object,propID=pID})
    enc.call("APIrebuildButtons",{obj=object})
  end
end
function toggleEditClose(object,ply)
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    enc.call("APIclearEditing",{obj=object})
    object.clearButtons()
    object.clearInputs()
    enc.call("APIrebuildButtons",{obj=object})
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

