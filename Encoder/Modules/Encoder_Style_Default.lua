--[[Simple Styles
by Tipsy Hobbit//STEAM_0:1:13465982
A simple double button style.
]]
--UPDATE_URL='https://raw.githubusercontent.com/Jophire/Tabletop-Simulator-Workshop-Items/master/Encoder/Modules/Encoder_Style_Default.lua'

sv={pos=0,dir='x',max_x=11,max_y=7,max=0}
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
  fire = STYLE.new{color={51,3,3,1},font_color={244,182,66,1},hover_color= {197,39,15,0.9},press_color= {101,7,7,0.7}},
  sage = STYLE.new{color={77,93,83,1},font_color={143,151,121,1},hover_color={115,134,120,1},press_color={120,134,107,1}}
  }
  normal = true
  for k,v in pairs(styles) do
    for h,j in pairs(v) do
      normal = true
      for i=1, #j do
        if j[i] > 1 then
          normal = false
        end
      end
      if normal == false then
        for i=1, 3 do
          styles[k][h][i] = j[i]/255
        end
      end
    end
  end
  
  for i=0,100 do
    local color = {math.random(),math.random(),math.random(),math.random(5,10)/10}
    local font_color = {math.random(),math.random(),math.random(),math.random(5,10)/10}
    local hover_color = {math.random(),math.random(),math.random(),math.random(5,10)/10}
    local press_color = {math.random(),math.random(),math.random(),math.random(5,10)/10}
    styles['r'..i..'r'] = STYLE.new{color=color,font_color=font_color,hover_color=hover_color,press_color=press_color}
  end
    
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
    local bw = 1000
    local bh = 1000
    local bf = 500
    self.clearButtons()
    sty = STYLE.new(enc.call("APIgetStyleTable",nil))
    sty.position = sv.dir == 'x' and {sv.max_x/2*2,0.1,-9} or {-2,1.1,sv.max_y/2*2}
    sty.function_owner = self
    sty.click_function = 'cycUp'
    sty.tooltip = sv.pos
    sty.width = bw
    sty.height = bh
    sty.font_size = bf
    sty.label = sv.dir == 'x' and "+" or "+"
    self.createButton(sty)
    
    sty.position = sv.dir == 'x' and {sv.max_x/2*-2,0.1,-9} or {-2,1.1,sv.max_y/2*-2}
    sty.function_owner = self
    sty.click_function = 'cycDown'
    sty.tooltip = sv.pos
    sty.width = bw
    sty.height = bh
    sty.font_size = bf
    sty.label = sv.dir == 'x' and "-" or "-"
    self.createButton(sty)
  
    styleList = enc.call("APIlistStyles",nil)
    local x = 0
    local y = 0
    local count = 0---(sv.max_x*sv.max_y)
    for k,v in pairs(styleList) do
      --print(k)
      if sv.pos <= count and count < sv.pos+sv.max_x*sv.max_y+(sv.dir=='x' and sv.max_y or sv.max_x) then
        if dir == 'y' then
          x = count%sv.max_x
          y = math.ceil((count-sv.pos)/sv.max_x)-sv.max_y/2
        else
          y = count%sv.max_y
          x = math.floor((count-sv.pos)/sv.max_y)-sv.max_x/2
        end
        
        t = enc.call("APIgetStyleTable",{styleID=k})
        t.position = {x*bw/500,0.1,y*bh/500-3}
        t.function_owner = self
        t.click_function = 'setStyle'..k
        t.tooltip = v
        t.width = bw
        t.height = bh
        t.font_size = bf
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
    sv.max = count
  end
end

function cycUp(obj,ply)
  if sv.pos < sv.max then
    sv.pos =sv.pos+(sv.dir =='x' and sv.max_y or sv.max_x)
  else
    sv.pos = 0
  end
  createButtons()
end

function cycDown(obj,ply)
  if sv.pos > 0 then
    sv.pos = sv.pos-(sv.dir =='x' and sv.max_y or sv.max_x)
  else
    sv.pos = sv.max ---sv.max_x*sv.max_y+(sv.dir=='x' and sv.max%sv.max_y or sv.max%sv.max_x)
  end
  createButtons()
end
