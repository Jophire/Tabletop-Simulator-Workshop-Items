--By Tipsy Hobbit
mod_name = "Encoder"
postfix = ''
version = '4.4.01'
version_string = "Player,Menu and Style update."
beta=false

URLS={
  ENCODER='https://raw.githubusercontent.com/Jophire/Tabletop-Simulator-Workshop-Items/master/Encoder/Encoder%20Core.lua',
  ENCODER_BETA='https://raw.githubusercontent.com/Jophire/Tabletop-Simulator-Workshop-Items/update_branch/Encoder/Encoder%20Core.lua',
  XML='https://raw.githubusercontent.com/Jophire/Tabletop-Simulator-Workshop-Items/update_branch/Encoder/XML.json'
  }

EncodedObjects = {}
--[[
Object Structure
EncodedObjects[objID] = {
	this = Object
	oName = Original Name
  values = {valueID = value}
	encoded = {propID = boolean}
  menus = {}
	editing = nil
  flip = 1
  disabled = false
]]
Players = {}
--[[
  For attaching values to player colors instead of objects.
  {ply=color} is how color is referenced in data for the api.
  Players[color] = {
    this = color
    values = {valueID = value}
    encoded = {propID = boolean}
    editing = nil
  }
]]
Properties = {}
--[[
  propID = internal name,
  name = external name,
  values = {},  --List of Values this property calls on. DOES NOT GET REGISTERED FROM HERE.
  funcOwner = obj,
  callOnActivate = true,
  activateFunc ='callEditor',
  visible = true, --Should this property show up in the menu.
  xml_index = tableindex
  }
]]
Values = {}
--[[
  valueID = internal name, used by Values as key,
  type = Lua type definition
  default = 'default_value'
  props = {} list of properties that use this value.
  desc = A description for other module creators to understand the values use.
]]
Tools = {}
--[[
  toolID = internal name
  name = external name
  funcOwner = function owner
  activateFunc = string
  display = bool
]]
Zones = {}
--[[
  name=Zone name
  activateFunc = function to call
]]
Styles = {}
--[[
  styleID = internal name,
  funcOwner = obj
  --Encoder calls createStyleButton(t) from this to create buttons so they follow a standard style.
]]
Styles["basic"] = {styleID = "basic",funcOwner = self} --The basic style that comes with the encoder.
Menus = {}
--[[
  menuID = internal name,
  funcOwner = obj
  --Encoder calls this to create its menus. createMenu({obj=obj})
]]

basic_buttons = {}

-- Preps the core code for module integration as well
--   as load in any save_data
-----------------------------------------------------
-- @param save_data Game data from autosaves. 
function onLoad(saved_data)
	-- Version Display
  broadcastToAll(mod_name.." "..version..postfix,{0.2,0.2,0.2})
	
	-- Set Global Encoder variable to the last spawned encoder.
  Global.setVar('Encoder',self)

	
	-- Make the core pretty.
  basic_buttons['Name'] = {click_function='doNothing',function_owner=self,label='Encoder',position={-0,0.12,-0.115},rotation={0,0,0},width=0,height=0,font_size=145,color={0,0,0,1},font_color={1,0,0,1}}
  -- Version Display
  barSize,fsize,offset_x,offset_y = updateSize(''..version,60,6.0,1,0)
  basic_buttons['VersionDisp'] = {click_function='doNothing',function_owner=self,label=''..version,position={0.6+offset_x*0.47,0.12,0.05+offset_y},rotation={0,0,0},width=0,height=0,font_size=fsize,color={0,0,0,1},font_color={1,0,0,1}}
	basic_buttons['toggleUI'] = {click_function='minimize',function_owner=self,label='Toggle UI',position={0+offset_x*0,0.12,0.4+offset_y},rotation={0,0,0},width=300,height=100,font_size=fsize,color={0,0,0,1},font_color={1,0,0,1}}
  
	--Load up the save data.
  if saved_data ~= nil and saved_data ~= "" then
    loaded_data = JSON.decode(saved_data)
    if loaded_data.properties ~= nil then 
      for i,v in pairs(loaded_data.properties) do
        if i ~= nil and v ~= nil and v ~= "" then
          Properties[i] = JSON.decode(v)
          Properties[i].funcOwner = getObjectFromGUID(Properties[i].funcOwner)
          if Properties[i].funcOwner == nil then
            Properties[i] = nil
          else
            buildPropFunction(i)
          end
        end
      end
    end
    if loaded_data.tools ~= nil then
      for i,v in pairs(loaded_data.tools) do
        if i ~= nil and v ~= nil and v ~= "" then
          Tools[i] = JSON.decode(v)
          Tools[i].funcOwner = getObjectFromGUID(Tools[i].funcOwner)
          if Tools[i].funcOwner == nil then
            Tools[i] = nil
          end
        end
      end
    end
    if loaded_data.zones ~= nil then
      Zones = JSON.decode(loaded_data.zones)
    end
    if loaded_data.values ~= nil then
      for i,v in pairs(loaded_data.values) do
        if i ~= nil and v ~= nil and v ~= "" then
          Values[i] = JSON.decode(v)
          if Values[i].validate == nil then
            buildValueValidationFunction(i)
          end
        end
      end
    end
    if loaded_data.players ~= nil then
      Players = JSON.decode(loaded_data.players)
    end
    if loaded_data.cards ~= nil then
      for i,v in pairs(loaded_data.cards) do
        if i ~= nil and v ~= nil and v ~= "" then
          EncodedObjects[i] = JSON.decode(v)
          EncodedObjects[i].this = getObjectFromGUID(i)
          if EncodedObjects[i].this == nil then
            EncodedObjects[i] = nil
          else
            buildButtons(EncodedObjects[i].this)
          end
        end
      end
    end
  end
  buildZones()
  for k,v in pairs(Player.getColors()) do
    encodePlayer({ply=v})
  end
  createEncoderButtons()
  
  self.clearContextMenu()
  self.addContextMenuItem('Main Branch', function(p) 
    if Player[p].admin then
      beta = false
      Player[p].broadcast('Switching back to the stable update branch.')
      Player[p].broadcast("Please don't forget to preform a version check to force the swith to occur.")
    else
      Player[p].broadcast('Please ask the server host or an admin to change versions.')
    end
  end
  )
  self.addContextMenuItem('Beta Branch', function(p) 
    if Player[p].admin then
      beta = true
      Player[p].broadcast('Switching to the un-stable update branch.')
      Player[p].broadcast("Please don't forget to preform a version check to force the swith to occur.")
      Player[p].broadcast("Bugs are to be expected.")
    else
      Player[p].broadcast('Please ask the server host or an admin to change versions.')
    end
  end
  )
  self.addContextMenuItem('Update', function(p) 
    if Player[p].admin then
      callVersionCheck(p)
      broadcastToAll('Preforming an update.')
    else
      Player[p].broadcast('Please ask the server host or an admin to check for updates.')
    end
  end
  )
  
  if beta then
    WebRequest.get(URLS['ENCODER_BETA'],self,"updateCheck")
  else
    WebRequest.get(URLS['ENCODER'],self,"updateCheck")
  end
  
	--WebRequest.get(URLS['XML'],self,"buildUI")
end

-- Saves core data on save triggers.
------------------------------------
function onSave()
  local data_to_save = {}
  data_to_save["cards"] = {}
  data_to_save["properties"] = {}
  data_to_save["tools"] = {}
  data_to_save["zones"] = JSON.encode(Zones)
  data_to_save["values"] = {}
  data_to_save["players"] = JSON.encode(Players)
  
  for i,v in pairs(EncodedObjects) do
    --Removing Object reference before encoding.
    if EncodedObjects[i].this ~= nil then
      local tempThis = EncodedObjects[i].this
      EncodedObjects[i].this = ""
      data_to_save["cards"][i] = JSON.encode(EncodedObjects[i])
      EncodedObjects[i].this = tempThis
    end
  end
  for i,v in pairs(Properties) do
    --Removing Object reference before encoding.
    if Properties[i].funcOwner ~= nil then
      local tempThis = Properties[i].funcOwner
      Properties[i].funcOwner = Properties[i].funcOwner.getGUID()
      data_to_save["properties"][i] = JSON.encode(Properties[i])
      Properties[i].funcOwner = tempThis
    end
  end
  for i,v in pairs(Tools) do
    --Removing Object reference before encoding.
    if Tools[i].funcOwner ~= nil then
      local tempThis = Tools[i].funcOwner
      Tools[i].funcOwner = Tools[i].funcOwner.getGUID()
      data_to_save["tools"][i] = JSON.encode(v)
      Tools[i].funcOwner = tempThis
    end
  end
  for i,v in pairs(Values) do
    local tempThis = Values[i].validate 
    Values[i].validate = ''
    data_to_save["values"][i] = JSON.encode(Values[i])
    Values[i].validate = tempThis
  end
  saved_data = JSON.encode(data_to_save)
  return saved_data
end

function callVersionCheck(p)
  if beta then
    WebRequest.get(URLS['ENCODER_BETA'],self,"versionCheck")
  else
    WebRequest.get(URLS['ENCODER'],self,"versionCheck")
  end
  for k,v in pairs(Properties) do
    u = v.funcOwner.getVar('UPDATE_URL')
    if u ~= nil then
      WebRequest.get(u,v.funcOwner,"updateModule") 
    end
  end
end

function updateCheck(wr)
  wr = wr.text
  local ver = versionComp(string.match(wr,"version = '(.-)'"),version)
  if ''..ver ~= ''..version then
    broadcastToAll("An update has been found. Please right click the encoder and select update.")
  else
    broadcastToAll("No update found at this time. Carry on.")
  end
end
function versionCheck(wr)
  wr = wr.text
  local ver = versionComp(string.match(wr,"version = '(.-)'"),version)
  if ''..ver ~= ''..version then
    if beta == true then
      broadcastToAll("An update has been found for the beta branch. Reloading encoder.")
    else
      broadcastToAll("An update has been found for the main branch. Reloading encoder.")
    end
    self.script_code = wr
    self.reload()
  else
    broadcastToAll("No update found at this time. Carry on.")
  end
end
function versionComp(a,b)
  --First does the pattern only contain ([0-9]+)%.?
  --Pattern for versioning ##.##.##.##
  va = {}
  vb = {}
  for f in string.gmatch(a,'([0-9]+)%.?') do
    table.insert(va,tonumber(f))
  end
  for f in string.gmatch(b,'([0-9]+)%.?') do
    table.insert(vb,tonumber(f))
  end
  for k = 1, #va >= #vb and #va or #vb do
    if (va[k] ~= nil and va[k] or 0) > (vb[k] ~= nil and vb[k] or 0) then
      return a
    elseif (va[k] ~= nil and va[k] or 0) < (vb[k] ~= nil and vb[k] or 0) then
      return b
    end
  end
  return b
end
--[[
function buildUI(wr)
  wr = wr.text
  wr = string.gsub(wr,"VERSION_NUMBER",version)
  wr = string.gsub(wr,"GUID_HERE",self.getGUID())
	local xml = UI.getXmlTable()
  local found = 0
  for k,v in pairs(xml) do
    if v.attributes.id ~= nil and v.attributes.id == "Encoder" then
      found = k
      break
    end
  end
  if found == 0 then
    table.insert(xml,JSON.decode(wr)[1])
  else
    xml[found] = JSON.decode(wr)[1]
  end
end

-- Update the XML UI to show new modules as they are registered.
function updateUI()
	local g = self.getGUID()
	local tab = UI.getXmlTable()
	local ps = {}
	for m,n in pairsByKeys(Properties) do
		if n.funcOwner ~= nil then
			table.insert(ps,{tag="Row",attributes={preferredHeight=30},children={tag="Cell",children={tag="Button",attributes={id=n.propID,onClick=g.."/"..n.propID.."UIToggle",fontStyle="Bold",fontSize=10,text=n.name},value=n.name}}})
		end
	end 
	local ts = {}
	for m,n in pairsByKeys(Tools) do
		if n.funcOwner ~= nil then
			table.insert(ts,{tag="Row",attributes={preferredHeight=30},children={tag="Cell",children={tag="Button",attributes={id=n.toolID,onClick=g.."/"..n.toolID.."UIToggle",fontStyle="Bold",fontSize=10,text=n.name},value=n.name}}})
		end
	end 
  local index = 0
  for k,v in pairs(tab) do
    if v.attributes ~= nil and v.attributes.id == "Encoder" then
      index = k
      break
    end
  end
	for k,v in pairs(Player.getColors()) do
		if k ~= "Grey" then
			--tab[index]["children"][k]["children"][4]["children"][1]["children"][2]["children"][1]["children"][1]["children"] = ps
			--tab[index]["children"][k]["children"][4]["children"][1]["children"][4]["children"][1]["children"][1]["children"] = ts
		end
	end
	UI.setXmlTable(tab)	
end

-- Hide the XML UI.
function minimize(plr,n,id)
	id = string.sub(id,0,-4)
	log(id)
	local temp = UI.getAttribute(id,"active")
	if temp == "True" or temp == nil then
		UI.setAttribute(id,"active",false)
	else
		UI.setAttribute(id,"active",true)
	end
end]]

-- NEW- Creates scripting zones around each players hands.
-- This is used to more reliably hide/reveal card buttons as it transitions zones.
function buildZones()
  ZtoG = {}
  for k,v in pairs(Zones) do
    ZtoG[v.name]=k
  end
  for k,v in pairs(Player.getColors()) do
    if v ~= "Grey" then
    for i=1,Player[v].getHandCount() do
      z = getObjectFromGUID(ZtoG[v..''..i])
      if z == nil then
        h = Player[v].getHandTransform(i)
        local j = v
        local ind = i
        params = {}
        params.type = "scriptingTrigger"
        params.position = h.position
        params.rotation = h.rotation
        hs = Vector(h.scale.x,h.scale.y,h.scale.z)
        params.scale = hs*(4/3)
        params.sound = false
        params.callback_function = function(obj) Zones[obj.guid] = {
          name = j..''..ind,
          func_enter = 'hideCardDetails',
          func_leave = 'showCardDetails',
          color = j
          }
          end
        spawnObject(params)
      end
    end
    end
  end
end

-- Functions to hide or show card details as it transitions from hand to table and back.
function hideCardDetails(tar)
  tar= tar[1]
  if EncodedObjects[tar.getGUID()] ~= nil then 
    tar.clearButtons()
    tar.clearInputs()  
  end
end
function showCardDetails(tar)
  tar = tar[1]
  if EncodedObjects[tar.getGUID()] ~= nil and tar.getButtons() == nil then
    buildButtons(tar)
  end
end

-- Event Triggers
function onObjectEnterScriptingZone(zone, obj)
  if Zones[zone.getGUID()] ~= nil then
    self.call(Zones[zone.getGUID()].func_enter,{obj})
  end
end
function onObjectLeaveScriptingZone(zone, obj)
  if Zones[zone.getGUID()] ~= nil then
    self.call(Zones[zone.getGUID()].func_leave,{obj})
  end
end
function onObjectLeaveContainer(__,obj)
  if obj.use_hands == true and EncodedObjects[obj.getGUID()] ~= nil then
    Wait.condition( function() 
    Wait.condition(
      function() handCheck(obj) end,
      function() return obj == nil or obj.resting end
    ) end,
    function() return not obj.resting end)
  end
end
function onObjectDestroyed(obj)
  if obj == self then
    for i,v in pairs(EncodedObjects) do 
      v.this.clearButtons()
      v.this.setName(v.name)
      v.this.clearContextMenu()
    end
		for k,v in pairs(Player.getColors()) do
			if v ~= "Grey" then
				--UI.setAttribute(k.."MainMenu","active",false)
			end
		end
  end
end
function onObjectDropped(c,obj)
  local ver = versionComp(Global.getVar('Encoder').getVar('version'),version)
  if ver == version and mod_name == 'Encoder' or Global.getVar('Encoder') == nil then
    Global.setVar('Encoder',self)
  end
  
  if EncodedObjects[obj.getGUID()] ~= nil and obj.use_hands == true then
    Wait.condition(
      function() handCheck(obj) end,
      function() return obj == nil or obj.resting end
    )
  end
end
--Use a raycast to check if an object is resting in a hand or not.
function handCheck(obj)
  if obj ~= nil and obj.getLock() == false and obj.held_by_color == nil then
    params = {
      origin = obj.getPosition(),
      direction = Vector(0,-1,0),
      type=1,
      debug=false
    }
    c = Physics.cast(params)
    dist = 10000
    for k,v in pairs(c) do
      if v.hit_object.tag == 'Surface' or v.hit_object.interactable == false  then
        dist = v.distance < dist and v.distance or dist
      end
    end
    --If the card is above 2 and resting, its in a hand. 
    --Or if its resting, but there is nothing below it, its in a hand.
    if dist > 2.0 or c[1] == nil then 
      hideCardDetails({obj})
    else
      showCardDetails({obj})
    end
  else
  end
end

function doNothing()
end

function createEncoderButtons()
  for i,v in pairs(basic_buttons) do
    self.createButton(v)
  end
end

-- If the encoder is deleted, make sure to cleanup. 
function encodeObject(o)
  if o.getVar('noencode') == true then
    return false
  end
  if EncodedObjects[o.getGUID()] == nil and o ~= self then
    EncodedObjects[o.getGUID()] = {
    this = o,
    oName = o.getName(),
    values = {},
    encoded = {},
    menus = {props={open=false,pos=0},copy={open=false,pos=0}},
    editing = nil,
    flip = 1,
    disable = false
    }
    buildButtons(o)
    buildContextMenu(o)
    return true
  end
  return false
end
function encodePlayer(c)
  if Players[c] == nil then
    Players[c] = {
      this = c,
      values = {},
      encoded = {},
      editing = nil,
      style = "basic",
      menus = {},
      token = nil
    }
    buildButtons(c)
    buildContextMenu(c)
    return true
  end
  return false
end

function updateSize(text,font_size,max_len,x_just,y_just)
  local temp = ''..text
  local size = 0
  local depth = 0
  local old_i = 0
  local i = 0
  local fsize = font_size
  while old_i < #temp do
    i = string.find(temp,"\n",old_i)
    if i == nil then 
      i = #temp
    end
    if i - old_i > size then
      size = i-old_i
    end
    old_i = i+1
    depth = depth+1
  end
  if size <= max_len then
    fsize = font_size 
  else
    fsize = font_size*(max_len/size)
  end
  
  offset_x = x_just*(size/19+0.05)*-1--*(fsize/(150/86)))
  offset_y = 0--y_just*((depth/2*fsize)+8)
  barSize = size*((fsize/(150/83)))+20
  return barSize,fsize,offset_x,offset_y
end

function buildContextMenu(o)
  o.addContextMenuItem('Flip Menu',function(ply) flipMenu(o,0) end)
end

function buildButtons(o)
  for k,v in pairs(Menus)
    v.funcOwner.call("createMenu",{obj=o,ply=p})
  end
end

--[[
function buildButtons(o)
  if type(o) == 'String' and Players[o] ~= nil then
    for k,v in pairs(Players[o].encoded) do
      if v == true and Properties[k]~=nil and Properties[k].funcOwner~= nil then
        Properties[k].funcOwner.call("createButtons",{ply=o,obj=Players[o].token})
      end
    end
  else
    o.clearButtons()
    o.clearInputs()
    if EncodedObjects[o.getGUID()].disable ~= true then
      local flip = EncodedObjects[o.getGUID()].flip
      local scaler = {x=1,y=1,z=1}--o.getScale()
      zpos = 0.28*flip*scaler.z
      if EncodedObjects[o.getGUID()].editing == nil then
        if EncodedObjects[o.getGUID()].menus.copy.open == false then
          o.createButton({
          label=">\n>\n>", click_function='toggleCopyMenu', function_owner=self,
          position={1*flip*scaler.x,zpos,-0.7*scaler.y}, height=250, width=10, font_size=60,
          rotation={0,0,90-90*flip},color={0,0,0,1},font_color={1,1,1,1},tooltip="Tool Menu"
          })
        else
          o.createButton({
          label="<\n<\n<", click_function='toggleCopyMenu', function_owner=self,
          position={1*flip*scaler.x,zpos,-0.7*scaler.y}, height=250, width=10, font_size=60,
          rotation={0,0,90-90*flip},color={0,0,0,1},font_color={1,1,1,1},tooltip="Tool Menu"
          })
          temp = "Disable Encoding"
          barSize,fsize,offset_x,offset_y = updateSize(temp,90,90,-1,0)
          o.createButton({
          label=temp, click_function='disableEncoding', function_owner=self,
          position={(1.05+offset_x)*flip*scaler.x,zpos,(1.5+offset_y)*scaler.y}, height=100, width=barSize, font_size=fsize,
          rotation={0,0,90-90*flip},color={0,0,0,1},font_color={1,0,0,1}
          })
          temp = "↿     ↾"
          barSize,fsize,offset_x,offset_y = updateSize(temp,90,90,-1,0)
          o.createButton({
          label=temp, click_function='CMscrollUp', function_owner=self,
          position={(1.05+offset_x)*flip*scaler.x,zpos,(-1+offset_y)*scaler.y}, height=100, width=barSize, font_size=fsize,
          rotation={0,0,90-90*flip},color={0,0,0,1},font_color={1,1,1,1}
          })
          temp = "⇃     ⇂"
          barSize,fsize,offset_x,offset_y = updateSize(temp,90,90,-1,0)
          o.createButton({
          label=temp, click_function='CMscrollDown', function_owner=self,
          position={(1.05+offset_x)*flip*scaler.x,zpos,1*scaler.y}, height=100, width=barSize, font_size=fsize,
          rotation={0,0,90-90*flip},color={0,0,0,1},font_color={1,1,1,1}
          })
          local count = 0
          local pos = EncodedObjects[o.getGUID()].menus.copy.pos
          for k,v in pairsByKeys(Tools) do
            if v.display==true and v.funcOwner ~= nil then
              if pos <= count and count < pos+7 then
                temp = v.name
                barSize,fsize,offset_x,offset_y = updateSize(temp,90,90,-1,0)
                o.createButton({
                label=temp, click_function=v.activateFunc, function_owner=v.funcOwner,
                position={(1.05+offset_x)*flip*scaler.x,zpos,(-0.75+((count-pos)/3)+offset_y)*scaler.y}, height=100, width=barSize, font_size=fsize,
                rotation={0,0,90-90*flip},color={0,0,0,1},font_color={1,1,1,1}
                })
              end
              count = count+1
            end
          end
        end
        if EncodedObjects[o.getGUID()].menus.props.open == false then
          o.createButton({
          label="<\n<\n<", click_function='togglePropMenu', function_owner=self,
          position={-1.0*flip*scaler.x,zpos,-0.7*scaler.y}, height=250, width=10, font_size=60,
          rotation={0,0,90-90*flip},color={0,0,0,1},font_color={1,1,1,1},tooltip="Module Menu"
          })
        else
          o.createButton({
          label=">\n>\n>", click_function='togglePropMenu', function_owner=self,
          position={-1.0*flip*scaler.x,zpos,-0.7*scaler.y}, height=250, width=10, font_size=60,
          rotation={0,0,90-90*flip},color={0,0,0,1},font_color={1,1,1,1},tooltip="Module Menu"
          })
          temp = " Flip "
          barSize,fsize,offset_x,offset_y = updateSize(temp,90,90,1,0)
          o.createButton({
          label=temp, click_function='flipMenu', function_owner=self,
          position={(-1.05+offset_x)*flip*scaler.x,zpos,(1.25+offset_y)*scaler.y}, height=100, width=barSize, font_size=fsize,
          rotation={0,0,90-90*flip},color={0,0,0,1},font_color={1,1,1,1}
          })
          temp = "↿     ↾"
          barSize,fsize,offset_x,offset_y = updateSize(temp,90,90,1,0)
          o.createButton({
          label=temp, click_function='PMscrollUp', function_owner=self,
          position={(-1.05+offset_x)*flip*scaler.x,zpos,(-1+offset_y)*scaler.y}, height=100, width=barSize, font_size=fsize,
          rotation={0,0,90-90*flip},color={0,0,0,1},font_color={1,1,1,1}
          })
          temp = "⇃     ⇂"
          barSize,fsize,offset_x,offset_y = updateSize(temp,90,90,1,0)
          o.createButton({
          label=temp, click_function='PMscrollDown', function_owner=self,
          position={(-1.05+offset_x)*flip*scaler.x,zpos,(1+offset_y)*scaler.y}, height=100, width=barSize, font_size=fsize,
          rotation={0,0,90-90*flip},color={0,0,0,1},font_color={1,1,1,1}
          })
          
          local count = 0
          local pos = EncodedObjects[o.getGUID()].menus.props.pos
          for k,v in pairsByKeys(Properties) do
            if v.funcOwner ~= nil and v.visible ~= false then
              if pos <= count and count < pos+7 then
                temp = v.name
                barSize,fsize,offset_x,offset_y = updateSize(temp,90,90,1,0)
                o.createButton({
                label=temp, click_function=v.propID..'Toggle', function_owner=self,
                position={(-1.05+offset_x)*flip*scaler.x,zpos,(-0.75+((count-pos)/3.9)+offset_y)*scaler.y}, height=100, width=barSize, font_size=fsize,
                rotation={0,0,90-90*flip},color={0,0,0,1},font_color={1,1,1,1}
                })
              end
              count = count+1
            end
          end
        end
        
        for k,v in pairs(EncodedObjects[o.getGUID()].encoded) do
          if v == true and Properties[k]~=nil and Properties[k].funcOwner~= nil then
            --print(k)
            Properties[k].funcOwner.call("createButtons",{obj=o})
          end
        end
      else
        k = EncodedObjects[o.getGUID()].editing
        if Properties[k]~=nil and Properties[k].funcOwner~= nil then
          Properties[k].funcOwner.call("createButtons",{obj=o})
        end
        temp = " X "
        barSize,fsize,offset_x,offset_y = updateSize(temp,90,90,0,0)
        o.createButton({
        label=temp, click_function='closeEditor', function_owner=self,
        position={(-1.1+offset_x)*flip,zpos,(1.4+offset_y)}, height=100, width=barSize, font_size=fsize,
        rotation={0,0,90-90*flip}
        })
      end
    end
  end
end
]]
function CMscrollDown(o,p)
  if EncodedObjects[o.getGUID()].menus.copy.pos < length(Properties) then
    EncodedObjects[o.getGUID()].menus.copy.pos = EncodedObjects[o.getGUID()].menus.copy.pos+1
  end
  buildButtons(o)
end
function CMscrollUp(o,p)
  if EncodedObjects[o.getGUID()].menus.copy.pos > 0 then
    EncodedObjects[o.getGUID()].menus.copy.pos = EncodedObjects[o.getGUID()].menus.copy.pos-1
  end
  buildButtons(o)
end
function PMscrollDown(o,p)
  if EncodedObjects[o.getGUID()].menus.props.pos < length(Properties) then
    EncodedObjects[o.getGUID()].menus.props.pos = EncodedObjects[o.getGUID()].menus.props.pos+1
  end
  buildButtons(o)
end
function PMscrollUp(o,p)
  if EncodedObjects[o.getGUID()].menus.props.pos > 0 then
    EncodedObjects[o.getGUID()].menus.props.pos = EncodedObjects[o.getGUID()].menus.props.pos-1
  end
  buildButtons(o)
end
function disableEncoding(o,p)
  EncodedObjects[o.getGUID()].disable = true
  o.setName(EncodedObjects[o.getGUID()].oName)
  local selection =Player[p].getSelectedObjects()
  if selection ~= nil then
    for k,v in pairs(selection) do
      if EncodedObjects[v.getGUID()] ~= nil and v ~= o then
        EncodedObjects[v.getGUID()].disable = true
        v.setName(EncodedObjects[v.getGUID()].oName)
        buildButtons(v)
      end
    end
  end
  buildButtons(o)
end


function flipMenu(o,p)
  local flip = EncodedObjects[o.getGUID()].flip
  if flip ~= 1 then
    EncodedObjects[o.getGUID()].flip = 1
		o.hide_when_face_down = true
  else
    EncodedObjects[o.getGUID()].flip = -1
		o.hide_when_face_down = false
  end
  if type(p) == "string" then
    local selection =Player[p].getSelectedObjects()
    if selection ~= nil then
      for k,v in pairs(selection) do
        if EncodedObjects[v.getGUID()] ~= nil and v ~= o then
          flipMenu(v,0)
        end
      end
    end
  end
  buildButtons(o)
end
function toggleCopyMenu(o)
  if EncodedObjects[o.getGUID()].menus.copy.open ~= true then
    EncodedObjects[o.getGUID()].menus.copy.open = true
  else
    EncodedObjects[o.getGUID()].menus.copy.open = false
  end
  buildButtons(o)
end
function togglePropMenu(o)
  if EncodedObjects[o.getGUID()].menus.props.open ~= true then
    EncodedObjects[o.getGUID()].menus.props.open = true
  else
    EncodedObjects[o.getGUID()].menus.props.open = false
  end
  buildButtons(o)
end
function toggleProperty(o,p)
  if EncodedObjects[o.getGUID()] ~= nil then
    local prop = EncodedObjects[o.getGUID()].encoded[p]
    if prop == nil then
      EncodedObjects[o.getGUID()].encoded[p] = true
    else
      if prop ~= true then
        EncodedObjects[o.getGUID()].encoded[p] = true
      else
        EncodedObjects[o.getGUID()].encoded[p] = false
      end
    end
    for k,v in pairs(Properties[p].values) do
      if Values[v] ~= nil and EncodedObjects[o.getGUID()].values[v] == nil then
        EncodedObjects[o.getGUID()].values[v] = Values[v].default
      end
    end
    return EncodedObjects[o.getGUID()].encoded[p]
  elseif type(o) == 'String' and Players[o] ~= nil then
    local prop = Players[o].encoded[p]
    if prop == nil then
      Players[o].encoded[p] = true
    else
      if prop ~= true then
        Players[o].encoded[p] = true
      else
        Players[o].encoded[p] = false
      end
    end
    for k,v in pairs(Properties[p].values) do
      if Values[v] ~= nil and Players[o].values[v] == nil then
        Players[o].values[v] = Values[v].default
      end
    end
    return Players[o].encoded[p]
  end
end
function closeEditor(o)
  if type(o) == 'String' then
    Players[o].editing = nil
  else
    EncodedObjects[o.getGUID()].editing = nil
  end
  buildButtons(o)
end

-- Factories
function buildPropFunction(p)
  local pdat = Properties[p]
  _G[p.."Toggle"] = function(obj,ply) 
    enabled = toggleProperty(obj,p)
    if pdat.callOnActivate == true and enabled == true then
      pdat.funcOwner.call(pdat.activateFunc,{obj=obj,ply=ply})
    end
    local selection =Player[ply].getSelectedObjects()
    if selection ~= nil then
      for k,v in pairs(selection) do
        if EncodedObjects[v.getGUID()] ~= nil and v ~= obj then
          enabled = toggleProperty(v,p)
          buildButtons(v)
        end
      end
    end
    buildButtons(obj)
  end
	
	 _G[p.."UIToggle"] = function(ply,n,id) 
    local selection =ply.getSelectedObjects()
    if selection ~= nil then
      for k,v in pairs(selection) do
        if EncodedObjects[v.getGUID()] ~= nil then
          enabled = toggleProperty(v,p)
          if pdat.callOnActivate == true and enabled == true and k == 1 then
            pdat.funcOwner.call(pdat.activateFunc,{object=v,player=ply})
          end
          buildButtons(v)
        end
      end
    end
  end
end
function buildValueValidationFunction(p)
  v=Values[p]
  if v.validType ~= nil and v.validType ~= 'nil' then
    if string.find('stringnumberboolean',v.validType) then
      local vt = v.validType
      Values[p]['validate']= function(val,cur) 
        if type(val) == vt then return val else return cur end end
    elseif string.find(v.validType, 'pattern%b()') then
      local _,_,pat = string.find(v.validType,'pattern(%b())')
      if #pat > 2 then
        pat = string.sub(pat,2,-2)
        Values[p]['validate']= function(val,cur) 
        if string.find(val,pat) then return val else return cur end end
      end
    elseif string.find(v.validType, 'color') then  
      Values[p]['validate']= function(val,cur)
      if val == '' or val == nil or Player[val] ~= nil then return val else return cur end end
    end
  else
    Values[p]['validate']= function(val,cur) return val end
  end
  _G[p..'validate']= Values[p]['validate']
end
-- API Functions
--[[Almost all function within the api require a table to be passed to them.
Table keys that are used are as follows.
obj = the object that is the target of the api call. RW
ply = the player color that is the target of the api call. RW
propID = the property that is the target of the api call. RW
valueID = the value that is the target of the api call. RW
data = a table of key value pairs related to the cards encoded data RW
{obj=__,ply='',propID='',valueID='',data={valueID=value}}
not all of the values are required for every API function.
]]

--REGISTRATION
--[[register a new property.
  Takes a table
  {propID='internalname',name='Button name',values={list of values},funcOwner=obj,callOnActivate=boolean,activateFunc='function name'}
]]
function APIregisterProperty(p)
  Properties[p.propID] = deepcopy(p)
  print(Properties[p.propID].propID.." Registered")
  buildPropFunction(p.propID)
	--updateUI()
end
--Lists currently registered properties.
function APIlistProps()
  data = {}
  for k,v in pairs(Properties) do
    if v.funcOwner == nil then
      data[k]='[Red]MISSING![White]'
    else
      data[k]=''
    end
    data[k]=data[k]..v.propID.." : "..v.name.." {"
    for m,n in pairs(v.values) do
      data[k]=data[k]..n..","
    end
    data[k]=data[k].."}"
  end
  return data
end
--register a new tool
function APIregisterTool(p)
  Tools[p.toolID] = deepcopy(p)
  print(Tools[p.toolID].toolID.." Registered")
end
--[[register a new value.
  Takes a table
  {valueID='internalname',validType=#CHECK_VALID_TYPES,desc='What is it used for',default=value}
  #CHECK_VALID_TYPES:
    'string'
    'boolean'
    'number'
    'pattern(here)'--example pattern(%%Color%%) the only acceptable value would be a string %Color%
    'color' --Player colors
]]
function APIregisterValue(p)
  --if Values[p.valueID] == nil then
    Values[p.valueID] = {}
    Values[p.valueID]['default']= p.default
    Values[p.valueID]['validType']= p.validType
    Values[p.valueID]['props']={}
    Values[p.valueID]['desc']= p.desc ~= nil and p.desc or 'No Description Given'
    buildValueValidationFunction(p.valueID)
  --end
  --table.insert(Values[p.valueID]['props'],p.propID)
end
--Lists currently registered values.
function APIlistValues()
  data = {}
  for k,v in pairs(Values) do
    data[k]=v.validType.." --"..v.desc
  end
  return data
end
--registers a new object to be encoded.
function APIencodeObject(p)
  encodeObject(p.obj)
end
--registers a new Player color to be encoded.
function APIencodePlayer(p)
  encodePlayer(p.ply)
end

--GETTERS/SETTERS
--checks if a given property is registered, returns BOOL
function APIpropertyExists(p)
  return Properties[p.propID] ~= nil
end
--checks if a given object is encoded, returns BOOL
function APIobjectExists(p)
  return EncodedObjects[p.obj.getGUID()] ~= nil
end
--checks if a given value is registered, returns BOOL
function APIvalueExists(p)
  return Values[p.valueID] ~= nil
end
--checks if a given player color is registered, returns BOOL
function APIplayerExists(p)
  return Players[p.ply] ~= nil
end

function APIgetPropValues(p)
  if Properties[p.propID] ~= nil then
    return Properties[p.propID].values
  end
  return {}
end

--Get or Set a single value based on valueID. Returns the value.
--{obj=obj,valueID=valueID,data={valueID=value}}
function APIobjGetValueData(p)
  local target = p.obj.getGUID()
  if EncodedObjects[target] ~= nil and Values[p.valueID] ~= nil then
    if EncodedObjects[target].values[p.valueID] == nil then
      EncodedObjects[target].values[p.valueID] = Values[p.valueID].default
    end
    val = EncodedObjects[target].values[p.valueID]
    data = {}
    data[p.valueID]=val
    return data
  end
end
function APIobjSetValueData(p)
  local target = p.obj.getGUID()
  if EncodedObjects[target] ~= nil and Values[p.valueID] ~= nil then
    EncodedObjects[target].values[p.valueID] = _G[p.valueID.."Validate"](p.data[p.valueID],EncodedObjects[target].values[p.valueID])
  end
end
function APIobjDefaultValue(p)
  local target = p.obj.getGUID()    
  if EncodedObjects[target] ~= nil and  Values[p.valueID] ~= nil then
    EncodedObjects[target].values[p.valueID] = Values[p.valueID].default
  end
end
--{ply=color,valueID=valueID,data={valueID=value}}
function APIplyGetValueData(p)
  local target = p.ply
  if Players[target] ~= nil and Values[p.valueID] ~= nil then
    if Players[target].values[p.valueID] == nil then
      Players[target].values[p.valueID] = Values[p.valueID].default
    end
    val = Players[target].values[p.valueID]
    data = {}
    data[p.valueID]=val
    return data
  end
end
function APIplySetValueData(p)
  local target = p.ply
  if Players[target] ~= nil and Values[p.valueID] ~= nil then
    Players[target].values[p.valueID] = _G[p.valueID.."Validate"](p.data[p.valueID],Players[target].values[p.valueID])
  end
end
function APIplyDefaultValue(p)
  local target = p.ply    
  if Players[target] ~= nil and  Values[p.valueID] ~= nil then
    Players[target].values[p.valueID] = Values[p.valueID].default
  end
end

--Get or Set value data based on propID. Returns and accepts an array of Key-Values. Key is a valid valueID.
--{obj=obj,propID=propID,data={valueID=value}}
function APIobjGetPropData(p)
  local target = p.obj.getGUID()
  if EncodedObjects[target] ~= nil then
    data = {}
    for k,v in pairs(Properties[p.propID].values) do
      if EncodedObjects[target].values[v] == nil and  Values[v] ~= nil then
        EncodedObjects[target].values[v] = Values[v].default
      end
      data[v]=EncodedObjects[target].values[v]
    end
    return data
  end
end
function APIobjSetPropData(p)
  local target = p.obj.getGUID()
  if EncodedObjects[target] ~= nil then
    for k,v in pairs(Properties[p.propID].values) do
      if Values[v] ~= nil and p.data[v] ~= nil then
        EncodedObjects[target].values[v] = Values[v]["validate"](p.data[v],EncodedObjects[target].values[v])
      end
    end
  end
end
--Is a given Property enabled: {obj=obj,propID=propID}
function APIobjIsPropEnabled(p)
  local target = p.obj.getGUID()
  if EncodedObjects[target] ~= nil then
    if EncodedObjects[target].encoded[p.propID] ~= nil then
      return EncodedObjects[target].encoded[p.propID]
    else
      return false
    end
  end
  return false
end
--Returns a list of props and if they are active or not: {obj=obj}
function APIobjGetProps(p)
  local target = p.obj.getGUID()
  if EncodedObjects[target] ~= nil then
    return EncodedObjects[target].encoded
  end
end
--Set a prop to active or not: {obj=obj,data={propID=bool}}
function APIobjSetProps(p)
  local target = p.obj.getGUID()
  if EncodedObjects[target] ~= nil then
    EncodedObjects[target].encoded = p.data
  end
end
--Enable target prop: {obj=obj,propID=propID}
function APIobjEnableProp(p)
  local target = p.obj.getGUID()
  if EncodedObjects[target] ~= nil then
    local prop = EncodedObjects[p.obj.getGUID()].encoded[p.propID]
    if prop ~= true then
      toggleProperty(p.obj,p.propID)
    end
  end
end
--Disable target prop: {obj=obj,propID=propID}
function APIobjDisableProp(p)
  local target = p.obj.getGUID()
  if EncodedObjects[target] ~= nil then
    local prop = EncodedObjects[p.obj.getGUID()].encoded[p.propID]
    if prop ~= false then
      toggleProperty(p.obj,p.propID)
    end
  end
end
--Toggles target prop on or off: {obj=obj,propID=propID}
function APItoggleProperty(p)
  if p.obj ~= nil then
    toggleProperty(p.obj,p.propID)
  else
    toggleProperty(p.ply,p.propID)
  end
end

function APIplyGetPropData(p)
  local target = p.ply
  if Players[target] ~= nil then
    data = {}
    for k,v in pairs(Properties[p.propID].values) do
      if Players[target].values[v] == nil and  Values[v] ~= nil then
        Players[target].values[v] = Values[v].default
      end
      data[v]=Players[target].values[v]
    end
    return data
  end
end
function APIplySetPropData(p)
  local target = p.ply
  if Players[target] ~= nil then
    for k,v in pairs(Properties[p.propID].values) do
      if Values[v] ~= nil and p.data[v] ~= nil then
        Players[target].values[v] = Values[v]["validate"](p.data[v],Players[target].values[v])
      end
    end
  end
end
--Is a given Property enabled: {ply=color,propID=propID}
function APIplyIsPropEnabled(p)
  local target = p.ply
  if EncodedObjects[target] ~= nil then
    if Players[target].encoded[p.propID] ~= nil then
      return Players[target].encoded[p.propID]
    else
      return false
    end
  end
  return false
end
--Returns a list of props and if they are active or not: {ply=color}
function APIplyGetProps(p)
  local target = p.ply
  if Players[target] ~= nil then
    return Players[target].encoded
  end
end
--Set a prop to active or not: {ply=color,data={propID=bool}}
function APIplySetProps(p)
  local target = p.ply
  if Players[target] ~= nil then
    Players[target].encoded = p.data
  end
end
--Enable target prop: {ply=color,propID=propID}
function APIplyEnableProp(p)
  local target = p.ply
  if Players[target] ~= nil then
    local prop = Players[p.obj.getGUID()].encoded[p.propID]
    if prop ~= true then
      Players(p.obj,p.propID)
    end
  end
end
--Disable target prop: {ply=color,propID=propID}
function APIplyDisableProp(p)
  local target = p.ply
  if Players[target] ~= nil then
    local prop = Players[p.obj.getGUID()].encoded[p.propID]
    if prop ~= false then
      Players(p.obj,p.propID)
    end
  end
end

--Get or Set all value data of a given object.
--{obj=obj}
function APIobjGetAllData(p)
  local target = p.obj.getGUID()
  if EncodedObjects[target] ~= nil then
   return EncodedObjects[target].values
  end
end
--{obj=obj,data={valueID=value}}
function APIobjSetAllData(p)
  local target = p.obj.getGUID()
  if EncodedObjects[target] ~= nil then
    for k,v in pairs(p.data) do
      if Values[k] ~= nil then
        EncodedObjects[target].values[k] = _G[k.."Validate"](v,EncodedObjects[target].values[k])
      else
        error('Unknown value '..k..'.')
      end
    end
  end
end
--{ply=color}
function APIplyGetAllData(p)
  local target = p.ply
  if Players[target] ~= nil then
   return Players[target].values
  end
end
--{ply=color,data={valueID=value}}
function APIplySetAllData(p)
  local target = p.ply
  if Players[target] ~= nil then
    for k,v in pairs(p.data) do
      if Values[k] ~= nil then
        Players[target].values[k] = _G[k.."Validate"](v,Players[target].values[k])
      else
        error('Unknown value '..k..'.')
      end
    end
  end
end

 
 
--BUTTON UI FUNCTIONS
--sets current editing state, so that buttons don't overlap. 
--the p.propID that is called must have a function createButtons({obj=object being edited})
function APIsetEditing(p)
  if p.obj ~= nil then
    EncodedObjects[p.obj.getGUID()].editing = p.propID
  else
    Players[p.ply].editing = p.propID
  end
end
--gets current editing state, so that buttons don't overlap.
--returns the propID currently be edited.
function APIgetEditing(p)
  if p.obj ~= nil then
    return EncodedObjects[p.obj.getGUID()].editing
  else
    return Players[p.ply].editing
  end
end
--Clears the editing value to allow other objects to gain control of editing.
function APIclearEditing(p)
  if p.obj ~= nil then
    EncodedObjects[p.obj.getGUID()].editing = nil
  else
    Players[p.ply].editing = nil
  end
end
--Builds the card buttons for all enabled properties.
function APIrebuildButtons(p)
  if p.obj ~= nil then
    buildButtons(p.obj)
  else
    buildButtons(p.ply)
  end
end
--Flips which side of the card the buttons show up on.
function APIFlip(p)
  flipMenu(p.obj,p.flip)
end
--Returns which side the menu is currently on.
function APIgetFlip(p)
  return EncodedObjects[p.obj.getGUID()].flip
end


--MISC FUNCTIONS
function APIdisableEncoding(p)
  if EncodedObjects[p.obj.getGUID()] ~= nil then
    EncodedObjects[p.obj.getGUID()].disable = true
		buildButtons(p.obj)
  end
end
function APIgetOName(p)
	return EncodedObjects[p.obj.getGUID()].oName
end
function APIformatButton(p)
  return updateSize(p.str,p.font_size,p.max_len,p.xJust,p.yJust)
end
--Compares two version strings '###.##.###.##' which is made up of any number of digits and periods.
function APIversionComp(p)
  return versionComp(p.wv,p.cv)
end

--CLEANUP
function APIremoveProperty(p)
  Properties[p.propID] = nil
	--updateUI()
end


-- Tool Functions
function length(t)
  local count = 0
  for k,v in pairs(t) do
    count = count+1
  end
  return count
end
function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end
function waitFrames(num_frames)
    for i=0, num_frames, 1 do
        coroutine.yield(0)
    end
    num_frames = 1
    return 1
end
function pairsByKeys (t, f)
	local a = {}
	for n in pairs(t) do table.insert(a, n) end
	table.sort(a, f)
	local i = 0      -- iterator variable
	local iter = function ()   -- iterator function
		i = i + 1
		if a[i] == nil then return nil
		else return a[i], t[a[i]]
		end
	end
	return iter
end
