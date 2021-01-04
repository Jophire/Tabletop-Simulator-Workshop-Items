--[[Simple Style
by Tipsy Hobbit//STEAM_0:1:13465982
A simple double button style.
]]
pID="Basic_Style"
UPDATE_URL='https://raw.githubusercontent.com/Jophire/Tabletop-Simulator-Workshop-Items/master/Encoder/Modules/Encoder_Style_Default.lua'
version = '1.0'

function onload()
  Wait.condition(registerModule,function() return Global.getVar('Encoder') ~= nil and true or false end)
end

default = {
  click_function=nil, --Not optional, must be passed in by the originating module.
  function_owner=nil, --Not optional
  label='',
  position={0,0.28,0},
  rotation={0,0,0},
  scale={1,1,1},
  width=60,
  height=60,
  font_size=10,
  color= {0,0,0,1},
  font_color= {1,1,1,1},
  hover_color= {0.3,0.3,0.3,1},
  press_color= {0.6,0.6,0.6,1},
  tooltip=""
}

function registerModule()
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    style={
      styleID=pID,
      name = '',
      desc = '',
      styleTable=JSON.encode(default)
    }
    enc.call("APIregisterStyle",style)
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