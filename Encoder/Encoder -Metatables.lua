--By Tipsy Hobbit
mod_name = "Encoder"
postfix = ''
version = 2
version_string = "The UI fix."

WorkshopID='https://steamcommunity.com/sharedfiles/filedetails/?id=828894732'
WebRequest.get(WorkshopID,self,'versionCheck')

-- Metatables
EncObj = {
	this = nil,
	oName = "",
	encoded = {},
	menus = {},
	editing = nil,
	flip = 1,
	disable = false
	}
function EncObj:new(o)
	o = o or {}
	setmetatable(o,self)
	self.__index = self
	return o
end
function EncObj:newEncode(obj)
	o = {}
	setmetatable(o,self)
	self.__index = self
	self.this = obj
	self.oName = obj.getName()
	return o
end
function EncObj:flip()
	if self.flip ~= 1 then
		self.flip = 1
		self.this.hide_when_face_down = true
		self.this.flip()
	else
		self.flip = -1
		self.this.hide_when_face_down = false
		self.this.flip()
	end
end
function EncObj:toggleProperty(prop)
	if not self.encoded[prop] then
		self.encoded[prop] = Propteries[prop]:newData()
	end
end
function EncObj:buildButtons()
	local o = self.this
	o.clearButtons()
	o.clearInputs()
	if o.disable ~= true then
		local flip = o.flip
		local scaler = {x=1,y=1,z=1}
		local zpos = 0.28*flip*scaler.z
		
	end
end
EncodedObjects = {} -- EncodedObjects[objID] = EncObj:newEncode(obj)
EncProp = {
	ID = "",
	name = "",
	dataStruct = {},
	funcOwner = nil,
	callOnActivate = true,
	activateFunc = 'callEditor'
	}
function EncProp:new(o)
end
function EncProp:newProperty(prop)
end
function EncProp:createButtons(obj)
end
Properties = {} -- Properties[propID] = EncProp:newProperty(prop)
EncMenu = {
	ID = "",
	name = "",
	pos = {x=0,y=1,z=0,0,1,0}
	rot = {x=0,y=0,z=0,0,0,0}
	open = false
	children = {}
	}
function EncMenu:newMenu(id,name,pos,rot)
	o = {}
	setmetatable(o,self)
	self.__index = self
	self.ID = id
	self.name = name
	self.pos = pos
	self.rot = rot
	return o
end
Menu = EncMenu:new("C","Home")


---------------------Needs Updating Below this Line!----------------------------

local players = {}
basic_buttons = {}

-- Preps the core code for module integration as well
--   as load in any save_data
-----------------------------------------------------
-- @param save_data Game data from autosaves. 
function onLoad(saved_data)
	-- Version Display
  broadcastToAll(mod_name.." "..version..postfix,{0.2,0.2,0.2})
	
	-- Make sure that the loaded object is at least newer then the previous version on the table.
  if (Global.getVar('Encoder') == nil or Global.getVar('Encoder').getVar('version') < version) and mod_name == 'Encoder' then
    Global.setVar('Encoder',self)
  end
	
	-- Make the core pretty.
  basic_buttons['Name'] = {click_function='doNothing',function_owner=self,label='Encoder',position={-0,0.12,-0.115},rotation={0,0,0},width=0,height=0,font_size=145,color={0,0,0,1},font_color={1,0,0,1}}
  -- Version Display
  barSize,fsize,offset_x,offset_y = updateSize(''..version,60,6.0,1,0)
  basic_buttons['VersionDisp'] = {click_function='doNothing',function_owner=self,label=''..version,position={0.6+offset_x*0.47,0.12,0.05+offset_y},rotation={0,0,0},width=0,height=0,font_size=fsize,color={0,0,0,1},font_color={1,0,0,1}}
	basic_buttons['toggleUI'] = {click_function='toggleUI',function_owner=self,label='Toggle UI',position={0+offset_x*0,0.12,0.4+offset_y},rotation={0,0,0},width=300,height=100,font_size=fsize,color={0,0,0,1},font_color={1,0,0,1}}
  
	--Load up the save data.
  if saved_data ~= nil and saved_data ~= "" then
    loaded_data = JSON.decode(saved_data)
    if loaded_data.cards ~= nil then
      for i,v in pairs(loaded_data.cards) do
        if i ~= nil and v ~= nil and v ~= "" then
          EncodedObjects[i] = JSON.decode(v)
          EncodedObjects[i].this = getObjectFromGUID(i)
          if EncodedObjects[i].this == nil then
            EncodedObjects[i] = nil
          end
        end
      end
    end
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
  end
  for i,v in pairs(EncodedObjects) do 
    buildButtons(v.this)
  end
  createEncoderButtons()
	buildPlayerData()
	buildUI()
end

-- Saves core data on save triggers.
------------------------------------
function onSave()
  local data_to_save = {}
  data_to_save["cards"] = {}
  data_to_save["properties"] = {}
  data_to_save["tools"] = {}
  
  for i,v in pairs(EncodedObjects) do
    --Removing Object reference before encoding.
    if EncodedObjects[i].this ~= nil then
      local tempThis = EncodedObjects[i].this
      EncodedObjects[i].this = ""
      data_to_save["cards"][i] = JSON.encode(v)
      EncodedObjects[i].this = tempThis
    end
  end
  for i,v in pairs(Properties) do
    --Removing Object reference before encoding.
    if Properties[i].funcOwner ~= nil then
      local tempThis = Properties[i].funcOwner
      Properties[i].funcOwner = Properties[i].funcOwner.getGUID()
      data_to_save["properties"][i] = JSON.encode(v)
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
  saved_data = JSON.encode(data_to_save)
  return saved_data
end

-- Version check code given to me by Amuzet.
function versionCheck(wr)
  local _,b=wr.text:find(mod_name..' Version ')
  local v=wr.text:sub(b,b+10):match('%d+%p%d+')
  --This matches the first instance of Number Punctuation Number (1.1)
  local txt='How to Use this Item'
  --Version Checking
  if version<tonumber(v)then
    txt=txt..'\n[fff600]There is an Update for '..mod_name
  end
  self.setDescription(txt)
  print(txt)
end

-- Gather the available colors for the player table.
--   Used for the XML UI.
function buildPlayerData()
	for k, v in pairs(Player.getColors()) do
		players[v] = {visibleMain=false}
	end
end

-- Configure the XML UI, building the various menus and buttons.
function buildUI()
	-- Lets not write over existing XML UI elements.
	local txt = UI.getXml().."\n"
	local g = self.getGUID()
	for k,v in pairs(players) do
		if v ~= "Grey" then
			if UI.getAttribute(k.."EncMainMenu","active") == nil then
				txt = txt..[[
				<Panel id="]]..k..[[EncMainMenu" active="True" visibility="]]..k..[[" width="198" height="30" position="-700 400" color="white" allowDragging="true" returnToOriginalPositionWhenReleased="False">
					<Button id="]]..k..[[DroplistBut" onClick="]]..g..[[/minimize" width="30" height="30" color="white" position="-60 0" fontStyle="bold" fontSize="15">_</Button>
					<Button id="]]..k..[[EncMainMenuBut" onClick="]]..g..[[/minimize" width="30" height="30" color="white" position="-85 0" fontStyle="bold" fontSize="15">X</Button>
					<Text position="20 0" fontStyle="bold" fontSize="15">Encoder Menu</Text>
					<Panel id="]]..k..[[Droplist" active="False" height="30" position="0 -30" color="white">
						<TableLayout autoCalculateHeight="True">
							<Row preferredHeight="30"><Cell><Button id="]]..k..[[PropListBut" onClick="]]..g..[[/minimize" fontStyle="normal" fontSize="15" >Properties</Button></Cell></Row>
							<Row preferredHeight="206" id="]]..k..[[PropList" active="False">
								<VerticalScrollView width="200" height="205" color="white" verticalScrollbarVisibility="AutoHideAndExpandViewport">
									<TableLayout autoCalculateHeight="True">
									</TableLayout>
								</VerticalScrollView>
							</Row>
							<Row preferredHeight="30"><Cell><Button id="]]..k..[[ToolListBut" onClick="]]..g..[[/minimize" fontStyle="normal" fontSize="15">Tools</Button></Cell></Row>
							<Row preferredHeight="206" id="]]..k..[[ToolList" active="False">
								<VerticalScrollView width="200" height="205" color="white" verticalScrollbarVisibility="AutoHideAndExpandViewport">
									<TableLayout autoCalculateHeight="True">
									</TableLayout>
								</VerticalScrollView>
							</Row>
						</TableLayout>
					</Panel>
				</Panel>	
				]]
			end
		end
	end
	UI.setXml(txt)
end

function updateUI()
	local g = self.getGUID()
	local tab = UI.getXmlTable()
	local ps = {}
	local count = 1
	for m,n in pairsByKeys(Properties) do
		if n.funcOwner ~= nil then
			ps[count] = {tag="Row",attributes={preferredHeight=30},children={tag="Cell",children={tag="Button",attributes={id=n.propID,onClick=g.."/"..n.propID.."UIToggle",fontStyle="Bold",fontSize=10,text=n.name},value=n.name}}}
			count = count+1
		end
	end 
	local ts = {}
	local count = 1
	for m,n in pairsByKeys(Tools) do
		if n.funcOwner ~= nil then
			ts[count] = {tag="Row",attributes={preferredHeight=30},children={tag="Cell",children={tag="Button",attributes={id=n.toolID,onClick=g.."/"..n.toolID.."UIToggle",fontStyle="Bold",fontSize=10,text=n.name},value=n.name}}}
			count = count+1
		end
	end 
	
	
	for k,v in pairs(players) do
		if k ~= "Grey" then
			for m,n in pairs(tab) do
				log(n)
				if n.attributes ~= nil and n.attributes.id == k.."EncMainMenu" then
					tab[m]["children"][4]["children"][1]["children"][2]["children"][1]["children"][1]["children"] = ps
					tab[m]["children"][4]["children"][1]["children"][4]["children"][1]["children"][1]["children"] = ts
					break
				end
			end
		end
	end
	UI.setXmlTable(tab)	
end

function minimize(plr,n,id)
	id = string.sub(id,0,-4)
	log(id)
	local temp = UI.getAttribute(id,"active")
	if temp == "True" or temp == nil then
		UI.setAttribute(id,"active",false)
	else
		UI.setAttribute(id,"active",true)
	end
end


function onObjectDestroyed(obj)
  if obj == self then
    for i,v in pairs(EncodedObjects) do 
      v.this.clearButtons()
      v.this.setName(v.name)
    end
		for k,v in pairs(players) do
			if v ~= "Grey" then
				UI.setAttribute(k.."MainMenu","active",false)
			end
		end
  end
end


function onObjectDropped(c,obj)
	--print(obj)
  if (Global.getVar('Encoder') == nil or Global.getVar('Encoder').getVar('version') < version) and mod_name == 'Encoder' then
    Global.setVar('Encoder',self)
  end
  if EncodedObjects[obj.getGUID()] ~= nil and c ~= "Black" then
    local inHand = false
    for k=1,Player[c].getHandCount() do
      for i,v in pairs (Player[c].getHandObjects(k)) do
        if v == obj then
          inHand = true
        end
      end
    end
    if inHand == false and obj.getButtons() == nil then
			--print(obj)
      buildButtons(obj)
    elseif inHand == true then
      obj.clearButtons()
      obj.clearInputs()
    end
  end
end

function doNothing()
end

function createEncoderButtons()
  for i,v in pairs(basic_buttons) do
    self.createButton(v)
  end
end

function encodeObject(o)
  if EncodedObjects[o.getGUID()] == nil and o ~= self then
    EncodedObjects[o.getGUID()] = buildBaseForm(o)
    buildButtons(o)
  end
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

function buildButtons(o)
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
							position={(1.05+offset_x)*flip*scaler.x,zpos,(-0.75+((count-pos)/4)+offset_y)*scaler.y}, height=100, width=barSize, font_size=fsize,
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
					if v.funcOwner ~= nil then
						if pos <= count and count < pos+7 then
							temp = v.name
							barSize,fsize,offset_x,offset_y = updateSize(temp,90,90,1,0)
							o.createButton({
							label=temp, click_function=v.propID..'Toggle', function_owner=self,
							position={(-1.05+offset_x)*flip*scaler.x,zpos,(-0.75+((count-pos)/4)+offset_y)*scaler.y}, height=100, width=barSize, font_size=fsize,
							rotation={0,0,90-90*flip},color={0,0,0,1},font_color={1,1,1,1}
							})
						end
						count = count+1
					end
        end
      end
      
      for k,v in pairs(EncodedObjects[o.getGUID()].encoded) do
        if v.enabled == true and Properties[k]~=nil and Properties[k].funcOwner~= nil then
					--print(k)
          Properties[k].funcOwner.call("createButtons",{object=o})
        end
      end
    else
			--print(EncodedObjects[o.getGUID()].editing)
      Properties[EncodedObjects[o.getGUID()].editing].funcOwner.call("createButtons",{object=o})
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
		o.flip()
  else
    EncodedObjects[o.getGUID()].flip = -1
		o.hide_when_face_down = false
		o.flip()
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
  if EncodedObjects[o.getGUID()] == nil then
    --How the fuck did you get here?!
  else
    propTable = EncodedObjects[o.getGUID()].encoded[p]
    if propTable == nil then
      propTable = buildPropData(p)
      propTable['enabled'] = true
    else
      if propTable.enabled ~= true then
        propTable.enabled = true
      else
        propTable.enabled = false
      end
    end
    EncodedObjects[o.getGUID()].encoded[p] = propTable
    return propTable.enabled
  end
end
function closeEditor(o)
  EncodedObjects[o.getGUID()].editing = nil
  buildButtons(o)
end

-- Factories
function buildBaseForm(o)
    tempTable = {}
    tempTable['this'] = o
    tempTable['oName'] = o.getName()
    tempTable['encoded'] = {}
    tempTable['menus'] = {props={open=false,pos=0},copy={open=false,pos=0}}
    tempTable['editing'] = nil
    tempTable['flip'] = 1
    tempTable['disable'] = false
		tempTable['folder_path'] = "Home"
    return tempTable
end
function buildPropData(p)
  return deepcopy(Properties[p].dataStruct)
end
function buildPropFunction(p)
  local pdat = Properties[p]
  _G[p.."Toggle"] = function(obj,ply) 
    enabled = toggleProperty(obj,p)
    if pdat.callOnActivate == true and enabled == true then
      pdat.funcOwner.call(pdat.activateFunc,{object=obj,player=ply})
    end
    local selection =Player[ply].getSelectedObjects()
    if selection ~= nil then
      for k,v in pairs(selection) do
        if EncodedObjects[v.getGUID()] ~= nil and v ~= obj then
          enabled = toggleProperty(v,p)
          if pdat.callOnActivate == true and enabled == true then
            --pdat.funcOwner.call(pdat.activateFunc,{object=v,player=ply})
          end
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
        if EncodedObjects[v.getGUID()] ~= nil and v ~= obj then
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

-- API Functions
function APIregisterProperty(p)
  Properties[p.propID] = deepcopy(p)
  print(Properties[p.propID].propID.." Registered")
  buildPropFunction(p.propID)
	updateUI()
end
function APIremoveProperty(p)
  Properties[p.propID] = nil
	updateUI()
end
function APIpropertyExists(p)
  return Properties[p.propID] ~= nil
end
function APItoggleProperty(p)
  if toggleProperty(p.obj,p.propID) ~= p.enabled then
    toggleProperty(p.obj,p.propID)
  end
end
function APIobjectExist(p)
  return EncodedObjects[p.obj.getGUID()] ~= nil
end
function APIaddObject(p)
  encodeObject(p.obj)
end
function APIgetObjectData(p)
  if EncodedObjects[p.obj.getGUID()] ~= nil then
    data = EncodedObjects[p.obj.getGUID()].encoded
    if data[p.propID] ~= nil then
      return data[p.propID]
    end
  end
end
function APIsetObjectData(p)
  if EncodedObjects[p.obj.getGUID()] ~= nil then
    EncodedObjects[p.obj.getGUID()].encoded[p.propID] = p.data
  end
end
function APIgetOAData(p)
  if EncodedObjects[p.obj.getGUID()] ~= nil then
    data = EncodedObjects[p.obj.getGUID()].encoded
    return data
  end
end
function APIsetOAData(p)
  if EncodedObjects[p.obj.getGUID()] ~= nil then
    EncodedObjects[p.obj.getGUID()].encoded = p.data
  end
end
function APIdisableEncoding(p)
  if EncodedObjects[p.obj.getGUID()] ~= nil then
    EncodedObjects[p.obj.getGUID()].disable = true
		buildButtons(p.obj)
  end
end
function APIsetEditing(p)
  EncodedObjects[p.obj.getGUID()].editing = p.propID
end
function APIgetEditing(p)
  return EncodedObjects[p.obj.getGUID()].editing
end
function APIclearEditing(p)
  EncodedObjects[p.obj.getGUID()].editing = nil
end
function APIrebuildButtons(p)
  buildButtons(p.obj)
end
function APIFlip(p)
  flipMenu(p.obj)
end
function APIgetFlip(p)
  return EncodedObjects[p.obj.getGUID()].flip
end
function APIgetOName(p)
	return EncodedObjects[p.obj.getGUID()].oName
end
function APIsetOName(p)
	EncodedObjects[p.obj.getGUID()].oName = p.name
end
function APIformatButton(p)
  return updateSize(p.str,p.font_size,p.max_len,p.xJust,p.yJust)
end
function APIregisterTool(p)
  Tools[p.toolID] = deepcopy(p)
  print(Tools[p.toolID].toolID.." Registered")
end
function printPropertyGuide()
    guide = {}
    guide.title = 'Property Variables and Creation'
    guide.body = 'propID = internal name\n'..
	'name = external name\n'..
	'dataStruct = {}\n'..
	'clickFunction = function name\n'..
	'funcOwner = function owner\n'..
	'callOnActivate = bool\n'..
    '\n\n---Definitions---\n'
    addNotebookTab(guide)
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
function addVectors(a,b)
return {x=a['x']+b['x'],y=a['y']+b['y'],z=a['z']+b['z']}
end
function multVectors(a,b)
  if type(b) ~= "table" then
    b={x=b,y=b,z=b}
  end
  return {x=a['x']*b['x'],y=a['y']*b['y'],z=a['z']*b['z']}
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