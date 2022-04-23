--[[Example Module
by Tipsy Hobbit//STEAM_0:1:13465982

This Example Module uses all the api features for modules.
]]

--pID or property ID: This is the unique interior name that the encoder uses
--for identifying your module. Without it, it will not be detected by the
--AutoRegister for modules.
pID="example_module"
--URL used for updating the module should you want to include one.
UPDATE_URL='https://raw.githubusercontent.com/Jophire/Tabletop-Simulator-Workshop-Items/master/Encoder/Modules/Encoder_Example_Addon.lua'
--Module Version Number
version = '1.4'


--Recommended
function onload()
	--It is recommended that you create a button on load that will register the module
	--manually in the event that the table does not want to use the auto-register.
  self.createButton({
  label="+", click_function='registerModule', function_owner=self,
  position={0,0.2,-0.5}, height=100, width=100, font_size=100,
  rotation={0,0,0},tooltip="Adds the current stat"
  })
  Wait.condition(registerModule,function() return Global.getVar('Encoder') ~= nil and true or false end)
end

--REQUIRED: Your module must have a function called registerModule.
--This is the function which is called by the autoregister when a pID is detected.
function registerModule()
	--Make sure the encoder exists. I do this check before everything api related.
  enc = Global.getVar('Encoder')
  if enc ~= nil then
		--Building the modules property table.
    properties = {
    propID = pID,	--The modules unique internal name.
    name = "Example Module", --The visible name located in the api menu.
    values = {'example1','example2'}, --The values you will be sending and requesting with APIobjGetValues APIobjSetValues
    funcOwner = self, --Who owns the triggering function. Generally will be self,
											--but you could make it target other objects.
    tags="list,of,tags", --Used by menus to decide if this belongs in it.
    activateFunc ='callEditor' --The function that should be called in the funcOwner.
    }
		--Time to register the property. You can register multiple properties from one module.
		--How you keep up with which one is which later is up to you.
    enc.call("APIregisterProperty",properties)
    
    --Building the value tables.
    value = {
    valueID = 'example1', --The value id, what it is called.
    validType = 'number',   --The value's type, if left blank it will accept any type.
    desc = 'Hello this is an example', --Description of what this value is.
    default = 0       --The default value when encoding it for the first time.
    }
    enc.call("APIregisterValue",value) --Registering the value. If the value already exists nothing happens.
    
    value = {
    valueID = 'example2',
    validType = 'string',
    desc = 'Hello this is an example',
    default = 'hello world'
    }
    enc.call("APIregisterValue",value)
  end
end

--REQUIRED: Your module must have a function called createButtons(var)
--This function is called by the encoder to make sure all objects update at the same time.
--In this function t = {obj=objectBeingUpdated}
function createButtons(t)
	--Encoder Check.
  enc = Global.getVar('Encoder')
  if enc ~= nil then
		--Get the data structure for our encoded object. This willreturn a 
    --table[valueID] = value 
    --based on what we listed in properties.values
    data = enc.call("APIobjGetPropData",{obj=t.obj,propID=pID})
		--Get the flip value of the object. Determines which side the buttons appear on.
    flip = enc.call("APIgetFlip",{obj=t.obj})
		--Get the currently edited property ID. This is so that we don't try to create buttons
    --while another module might be trying to edit a value.
    editing = enc.call("APIgetEditing",{obj=t.obj})
    if editing == nil then
			--Useful format for buttons that can be variable in length.
			temp = ""..data.length..""
			--This function helps keep buttons all formated the same.
			--It takes a string, the font size, max_len the string can be, and justifications:
			--xJust= -1 left, 0 center, 1 right.
			--yJust= -1 top, 0, center, 1 bottom.
			--It returns the width, adjusted font size, and offset values.
      barSize,fsize,offset_x,offset_y = enc.call('APIformatButton',{str=temp,font_size=90,max_len=90,xJust=1,yJust=0})
      t.obj.createButton({
      label=temp, click_function='toggleEditor', function_owner=self,
      position={(data.location.x+offset_x)*flip,data.location.y*flip,data.location.z+offset_y}, height=170, width=barSize, font_size=fSize,
      rotation={0,0,90-90*flip}
      })
		elseif editing == 'example_module' then
			--Try to make sure there is always a button that will toggle the editor to close.
			--The encoder will add one anyways, but its still good to have one if you want to customize it.
			temp = ""..data.length..""
			barSize,fsize,offset_x,offset_y = enc.call('APIformatButton',{str=temp,font_size=90,max_len=90,xJust=1,yJust=0})
      t.obj.createButton({
      label=temp, click_function='toggleEditClose', function_owner=self,
      position={(data.location.x+offset_x)*flip,data.location.y*flip,data.location.z+offset_y}, height=170, width=barSize, font_size=fSize,
      rotation={0,0,90-90*flip}
      })
		end
	end
end

--Button function
function toggleEditor(object)
	--We have api calls, so make sure to check the encoder still exists.
  enc = Global.getVar('Encoder')
  if enc ~= nil then
		--We set the editing value of the object to our pID
		--an object can only have one editing value, NIL or a pID.
    enc.call("APIsetEditing",{obj=object,propID=pID})
		--We want to rebuild the buttons on this object to display the change.
    enc.call("APIrebuildButtons",{obj=object})
  end
end

--Button Function
function toggleEditClose(object,ply)
	--More api calls, check encoder exists.
  enc = Global.getVar('Encoder')
  if enc ~= nil then
		data = enc.call("APIobjGetPropData",{obj=object,propID=pID})
		x = math.random(-1,1)
		y = 0.28 --Standard Button float height.
		z = math.random(-1,1)
		data.location={x=x,y=y,z=z}
		data.length=math.random(-20012,58601)
		
		--Sets the objects data to the new values.
		enc.call("APIobjSetPropData",{obj=object,propID=pID,data=data})
		
		--Clear the editing value. aka: set it to nil
    enc.call("APIclearEditing",{obj=object})
		--Rebuild Buttons.
    enc.call("APIrebuildButtons",{obj=object})
  end
end


--REQUIRED: This is the function specified up in properties.
--If you specify a function, you must make sure it has the function.
function callEditor(obj,ply)
  enc.call("APItoggleProperty",{obj=obj,propID=pID}) --Toggle prop if this is not a one time use thing.
  if enc.call("APIobjIsPropEnabled",{obj=obj,propID=pID}) then --So it does not call the editor on disabling the prop.
    toggleEditor(obj)
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