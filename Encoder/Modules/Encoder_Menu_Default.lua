--[[Basic Menu
by Tipsy Hobbit//STEAM_0:1:13465982
The basic menu style, default for the encoder.
If no menu has been registered, then the encoder will spawn this from the github.
]]
pID="Default_Menu"
UPDATE_URL='https://raw.githubusercontent.com/Jophire/Tabletop-Simulator-Workshop-Items/master/Encoder/Modules/Encoder_Menu_Default.lua'
version = '1.0'
function onload()
  Wait.condition(registerModule,function() return Global.getVar('Encoder') ~= nil and true or false end)
end
function registerModule()
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    menu={
      styleID=pID,
      funcOwner=self
    }
    enc.call("APIregisterMenu",menu)
  end
end
function createMenu(t)
  local o = t.obj
  local p = t.ply
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