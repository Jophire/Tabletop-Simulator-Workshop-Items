--Notepad
--by Tipsy Hobbit//STEAM_0:1:13465982
encVersion = 1.2
pID = "mtg_notepad"

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
		name = "NotePad",
		dataStruct = {notes="",line=0,tooltip=true},
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
		data = enc.call("APIgetObjectData",{obj=t.object,propID=pID})
		scaler = {x=1,y=1,z=1}
		tooltip = ""
		if data.tooltip == true then
			tooltip = data.notes
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
			temp = ' - '
			barSize,fsize,offset_x,offset_y = enc.call('APIformatButton',{str=temp,font_size=60,max_len=90,xJust=0,yJust=0})
			t.object.createButton({
			label=temp, click_function='scrollUP', function_owner=self,
			position={(-1.1+offset_x)*flip*scaler.x,0.28*flip*scaler.z,(-1+offset_y)*scaler.y}, height=110, width=barSize, font_size=fSize,
			rotation={0,0,90-90*flip},tooltip=''
			})
			temp = ' + '
			barSize,fsize,offset_x,offset_y = enc.call('APIformatButton',{str=temp,font_size=60,max_len=90,xJust=0,yJust=0})
			t.object.createButton({
			label=temp, click_function='scrollDown', function_owner=self,
			position={(-1.1+offset_x)*flip*scaler.x,0.28*flip*scaler.z,(1+offset_y)*scaler.y}, height=110, width=barSize, font_size=fSize,
			rotation={0,0,90-90*flip},tooltip=''
			})
			temp = ' V '
			barSize,fsize,offset_x,offset_y = enc.call('APIformatButton',{str=temp,font_size=60,max_len=90,xJust=0,yJust=0})
			t.object.createButton({
			label=temp, click_function='toggleToolTip', function_owner=self,
			position={(-1.1+offset_x)*flip*scaler.x,0.28*flip*scaler.z,(0+offset_y)*scaler.y}, height=110, width=barSize, font_size=fSize,
			rotation={0,0,90-90*flip},tooltip=data.tooltip==true and 'Visible' or 'Hidden'
			})
			temp = ' X '
			barSize,fsize,offset_x,offset_y = enc.call('APIformatButton',{str=temp,font_size=60,max_len=90,xJust=0,yJust=0})
			t.object.createButton({
			label=temp, click_function='toggleEditClose', function_owner=self,
			position={(-1.1+offset_x)*flip*scaler.x,0.28*flip*scaler.z,(0.235+offset_y)*scaler.y}, height=110, width=barSize, font_size=fSize,
			rotation={0,0,90-90*flip},tooltip='Close'
			})
		end
  end
end

function editText(obj,ply,val,sel)
	if sel == false then
		enc = Global.getVar('Encoder')
		if enc ~= nil then
			data = enc.call("APIgetObjectData",{obj=obj,propID=pID})
			data.notes = val
			enc.call("APIsetObjectData",{obj=obj,propID=pID,data=data})
		end
	else	
		log(val,"input_text", "Notepad"..obj.getGUID())
		--obj.editInput({index=0,value=val})
	end
end
function scrollUP(obj,ply)
	enc = Global.getVar('Encoder')
	if enc ~= nil then
		data = enc.call("APIgetObjectData",{obj=obj,propID=pID})
		data.line = data.line-1
		enc.call("APIsetObjectData",{obj=obj,propID=pID,data=data})
	end
end
function scrollUP(obj,ply)
	enc = Global.getVar('Encoder')
	if enc ~= nil then
		data = enc.call("APIgetObjectData",{obj=obj,propID=pID})
		data.line = data.line+1
		enc.call("APIsetObjectData",{obj=obj,propID=pID,data=data})
	end
end
function toggleToolTip(obj,ply)
	enc = Global.getVar('Encoder')
	if enc ~= nil then
		data = enc.call("APIgetObjectData",{obj=obj,propID=pID})
		if data.tooltip == true then
			data.tooltip = false
		else
			data.tooltip = true
		end
		enc.call("APIsetObjectData",{obj=obj,propID=pID,data=data})
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


