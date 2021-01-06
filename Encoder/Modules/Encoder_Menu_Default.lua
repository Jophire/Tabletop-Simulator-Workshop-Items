--[[Basic Menu
by Tipsy Hobbit//STEAM_0:1:13465982
The basic menu style, default for the encoder.
If no menu has been registered, then the encoder will spawn this from the github.
]]
pID="Default_Menu"
UPDATE_URL='https://raw.githubusercontent.com/Jophire/Tabletop-Simulator-Workshop-Items/master/Encoder/Modules/Encoder_Menu_Default.lua'
version = '1.4.1'
Style = {}
function onload()
  Wait.condition(registerModule,function() return Global.getVar('Encoder') ~= nil and true or false end)
end
function registerModule()
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    menu={
      menuID='Prop_Menu',
      funcOwner=self,
      activateFunc='createPropMenu'
    }
    enc.call("APIregisterMenu",menu)
    menu={
      menuID='Tool_Menu',
      funcOwner=self,
      activateFunc='createToolMenu'
    }
    enc.call("APIregisterMenu",menu)
    
    Style.proto = enc.call("APIgetStyleTable",nil)
    Style.mt = {}
    Style.mt.__index = Style.proto
    function Style.new(o)
      for k,v in pairs(Style.proto) do
        if o[k] == nil then
          o[k] = v
        end
      end
      return o
    end
  end
end

function createToolMenu(t)
  local o = t.obj
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    Style.proto = enc.call("APIgetStyleTable",nil)
    local flip = enc.call("APIgetFlip",{obj=o})
    local scaler = {x=1,y=1,z=1}--o.getScale()
    local zpos = 0.28*flip*scaler.z
    local props = enc.call("APIgetPropsList",{tags={"tool"}})
    md = enc.call("APIobjGetMenuData",{obj=o,menuID='Tool_Menu'})
    if md.open == false then
      alpha = Style.proto.color
      alpha.a = 0.3
      o.createButton(Style.new{
      label=">\n>\n>", click_function='toggleToolMenu', function_owner=self,
      position={1*flip*scaler.x,zpos,-0.7*scaler.y}, height=250, width=10, font_size=60,
      rotation={0,0,90-90*flip},tooltip="Tool Menu",color=alpha})
    else
      o.createButton(Style.new{
      label="<\n<\n<", click_function='toggleToolMenu', function_owner=self,
      position={1*flip*scaler.x,zpos,-0.7*scaler.y}, height=250, width=10, font_size=60,
      rotation={0,0,90-90*flip},tooltip="Tool Menu"
      })
      temp = "Disable Encoding"
      barSize,fsize,offset_x,offset_y = enc.call('APIformatButton',{str=temp,font_size=90,max_len=90,xJust=-1,yJust=0})
      o.createButton(Style.new{
      label=temp, click_function='disableEncoding', function_owner=enc,
      position={(1.05+offset_x)*flip*scaler.x,zpos,(1.5+offset_y)*scaler.y}, height=100, width=barSize, font_size=fsize,
      rotation={0,0,90-90*flip},font_color={1,0,0,1}
      })
      temp = "↿     ↾"
      barSize,fsize,offset_x,offset_y = enc.call('APIformatButton',{str=temp,font_size=90,max_len=90,xJust=-1,yJust=0})
      o.createButton(Style.new{
      label=temp, click_function='CMscrollUp', function_owner=self,
      position={(1.05+offset_x)*flip*scaler.x,zpos,(-1+offset_y)*scaler.y}, height=100, width=barSize, font_size=fsize,
      rotation={0,0,90-90*flip}
      })
      temp = "⇃     ⇂"
      barSize,fsize,offset_x,offset_y = enc.call('APIformatButton',{str=temp,font_size=90,max_len=90,xJust=-1,yJust=0})
      o.createButton(Style.new{
      label=temp, click_function='CMscrollDown', function_owner=self,
      position={(1.05+offset_x)*flip*scaler.x,zpos,1*scaler.y}, height=100, width=barSize, font_size=fsize,
      rotation={0,0,90-90*flip}
      })
      local count = 0
      for h,j in pairs(props) do
        v = enc.call("APIgetProp",{propID=h})
        if v.visible~=false and v.funcOwner ~= nil then
          if md.pos <= count and count < md.pos+7 then
            temp = v.name
            barSize,fsize,offset_x,offset_y = enc.call('APIformatButton',{str=temp,font_size=90,max_len=90,xJust=-1,yJust=0})
            o.createButton(Style.new{
            label=temp, click_function=v.activateFunc, function_owner=v.funcOwner,
            position={(1.05+offset_x)*flip*scaler.x,zpos,(-0.75+((count-md.pos)/3)+offset_y)*scaler.y}, height=100, width=barSize, font_size=fsize,
            rotation={0,0,90-90*flip}
            })
          end
          count = count+1
        end
      end
    end
  end
end

function createPropMenu(t)
  local o = t.obj
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    Style.proto = enc.call("APIgetStyleTable",nil)
    local flip = enc.call("APIgetFlip",{obj=o})
    local scaler = {x=1,y=1,z=1}--o.getScale()
    local zpos = 0.28*flip*scaler.z
    local props = enc.call("APIgetPropsList",{tags={"untagged","basic"}})
    md = enc.call("APIobjGetMenuData",{obj=o,menuID='Prop_Menu'})      
    if md.open == false then
      alpha = Style.proto.color
      alpha.a = 0.3
      o.createButton(Style.new{
      label="<\n<\n<", click_function='togglePropMenu', function_owner=self,
      position={-1.0*flip*scaler.x,zpos,-0.7*scaler.y}, height=250, width=10, font_size=60,
      rotation={0,0,90-90*flip},tooltip="Property Menu",color=alpha})
    else
      o.createButton(Style.new{
      label=">\n>\n>", click_function='togglePropMenu', function_owner=self,
      position={-1.0*flip*scaler.x,zpos,-0.7*scaler.y}, height=250, width=10, font_size=60,
      rotation={0,0,90-90*flip},tooltip="Property Menu"
      })
      temp = " Flip "
      barSize,fsize,offset_x,offset_y = enc.call('APIformatButton',{str=temp,font_size=90,max_len=90,xJust=1,yJust=0})
      o.createButton(Style.new{
      label=temp, click_function='flipMenu', function_owner=enc,
      position={(-1.05+offset_x)*flip*scaler.x,zpos,(1.25+offset_y)*scaler.y}, height=100, width=barSize, font_size=fsize,
      rotation={0,0,90-90*flip}
      })
      temp = "↿     ↾"
      barSize,fsize,offset_x,offset_y = enc.call('APIformatButton',{str=temp,font_size=90,max_len=90,xJust=1,yJust=0})
      o.createButton(Style.new{
      label=temp, click_function='PMscrollUp', function_owner=self,
      position={(-1.05+offset_x)*flip*scaler.x,zpos,(-1+offset_y)*scaler.y}, height=100, width=barSize, font_size=fsize,
      rotation={0,0,90-90*flip}
      })
      temp = "⇃     ⇂"
      barSize,fsize,offset_x,offset_y = enc.call('APIformatButton',{str=temp,font_size=90,max_len=90,xJust=1,yJust=0})
      o.createButton(Style.new{
      label=temp, click_function='PMscrollDown', function_owner=self,
      position={(-1.05+offset_x)*flip*scaler.x,zpos,(1+offset_y)*scaler.y}, height=100, width=barSize, font_size=fsize,
      rotation={0,0,90-90*flip}
      })
      
      local count = 0
      for h,j in pairs(props) do
        v = enc.call("APIgetProp",{propID=h})
        if v.funcOwner ~= nil and v.visible ~= false then
          if md.pos <= count and count < md.pos+7 then
            temp = v.name
            barSize,fsize,offset_x,offset_y = enc.call('APIformatButton',{str=temp,font_size=90,max_len=90,xJust=1,yJust=0})
            o.createButton(Style.new{
            label=temp, click_function=v.activateFunc, function_owner=v.funcOwner,
            position={(-1.05+offset_x)*flip*scaler.x,zpos,(-0.75+((count-md.pos)/3.9)+offset_y)*scaler.y}, height=100, width=barSize, font_size=fsize,
            rotation={0,0,90-90*flip}
            })
          end
          count = count+1
        end
      end
    end
  end
end

function toggleToolMenu(o)
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    enc.call("APIobjToggleMenu",{obj=o,menuID="Tool_Menu"})
    enc.call("APIrebuildButtons",{obj=o})
  end
end
function togglePropMenu(o)
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    enc.call("APIobjToggleMenu",{obj=o,menuID="Prop_Menu"})
    enc.call("APIrebuildButtons",{obj=o})
  end
end

function CMscrollDown(o,p)
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    md = enc.call("APIobjGetMenuData",{obj=o,menuID='Tool_Menu'}) 
    props = enc.call("APIgetPropsList",{tags={"tool"}})
    if md.pos < length(props) then
      md.pos = md.pos+1
    end
    enc.call("APIobjSetMenuData",{obj=o,menuID='Tool_Menu',data=md})
    enc.call("APIrebuildButtons",{obj=o})
  end
end
function CMscrollUp(o,p)
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    md = enc.call("APIobjGetMenuData",{obj=o,menuID='Tool_Menu'}) 
    props = enc.call("APIgetPropsList",{tags={"tool"}})
    if md.pos > 0 then
      md.pos = md.pos-1
    end
    enc.call("APIobjSetMenuData",{obj=o,menuID='Tool_Menu',data=md})
    enc.call("APIrebuildButtons",{obj=o})
  end
end
function PMscrollDown(o,p)
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    md = enc.call("APIobjGetMenuData",{obj=o,menuID='Prop_Menu'}) 
    props = enc.call("APIgetPropsList",{tags={"untagged","basic"}})
    if md.pos < length(props) then
      md.pos = md.pos+1
    end
    enc.call("APIobjSetMenuData",{obj=o,menuID='Prop_Menu',data=md})
    enc.call("APIrebuildButtons",{obj=o})
  end
end
function PMscrollUp(o,p)
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    md = enc.call("APIobjGetMenuData",{obj=o,menuID='Prop_Menu'}) 
    props = enc.call("APIgetPropsList",{tags={"untagged","basic"}})
    if md.pos > 0 then
      md.pos = md.pos-1
    end
    enc.call("APIobjSetMenuData",{obj=o,menuID='Prop_Menu',data=md})
    enc.call("APIrebuildButtons",{obj=o})
  end
end

function length(t)
  local count = 0
  for k,v in pairs(t) do
    count = count+1
  end
  return count
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