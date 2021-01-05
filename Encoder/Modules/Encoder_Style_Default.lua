--[[Simple Styles
by Tipsy Hobbit//STEAM_0:1:13465982
A simple double button style.
]]
--UPDATE_URL='https://raw.githubusercontent.com/Jophire/Tabletop-Simulator-Workshop-Items/master/Encoder/Modules/Encoder_Style_Default.lua'

sv={pos=0,dir='x',max_x=7,max_y=3}
STYLE={}

function onload(sd)
  if sd ~= nil and sd ~= '' then
    sv = JSON.decode(sd)
  end
  
  
  STYLE.proto = {
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
  STYLE.mt = {}
  STYLE.mt.__index = STYLE.proto
  function STYLE.new(o)
    for k,v in pairs(STYLE.proto) do
      if o[k] == nil then
        o[k] = v
      end
    end
    return o
  end

  styles ={
  fire = STYLE.new{color={51/255,3/255,3/255,1},font_color={244/255,182/255,66/255,1},hover_color= {197/255,39/255,15/255,0.9},press_color= {101/255,7/255,7/255,0.7}},
  sage = STYLE.new{color={77/255,93/255,83/255,1},font_color={143/255,151/255,121/255,1},hover_color={115/255,134/255,120/255},press_color={120/255,134/255,107/255,1}}
  }
  Wait.condition(registerModule,function() return Global.getVar('Encoder') ~= nil and true or false end)
end
function onsave()
  return JSON.encode(sv)
end


function registerModule()
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    for k,v in pairs(styles) do
      local style={
        styleID=k,
        name = k,
        desc = '',
        styleTable=v
      }
      enc.call("APIregisterStyle",style)
    end
    createButtons()
  end
end

function createButtons()
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    styleList = enc.call("APIlistStyles",nil)
    local x = 0
    local y = 0
    local count = 1
    for k,v in pairs(styleList) do
      --print(k)
      if sv.pos <= count and count < sv.pos+sv.max_x*sv.max_y then
        if dir == 'y' then
          x = count%sv.max_x
          y = math.ceil(count/sv.max_x)-1
        else
          x = count%sv.max_y
          y = math.ceil(count/sv.max_y)-1
        end
        
        t = enc.call("APIgetStyleTable",{styleID=k})
        t.position = {x*1,1.1,y*1}
        t.function_owner = self
        t.click_function = 'setStyle'..k
        t.tooltip = v
        t.width = 500
        t.height = 500
        t.font_size = t.font_size*20
        t.label = "▣"
        self.createButton(t)
        local n = k
        _G['setStyle'..n] = function(obj,ply)
          local en = Global.getVar('Encoder')
          if en ~= nil then
            en.call("APIsetGlobalStyle",{styleID=n})
          end
        end
      end
      count = count+1
    end
  end
end
