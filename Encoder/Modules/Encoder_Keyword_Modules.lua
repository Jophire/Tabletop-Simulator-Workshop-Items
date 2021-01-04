--[[Keyword Abilities Module
by Tipsy Hobbit//STEAM_0:1:13465982
This module adds keyword abilities.
]]
pID = "MTG_Keyword_Abilites"
UPDATE_URL='https://raw.githubusercontent.com/Jophire/Tabletop-Simulator-Workshop-Items/master/Encoder/Modules/Encoder_Keyword_Modules.lua'
version = '1.7'
KeywordList={
  mtg_tramplecounter={name="Trample",des=":This creature can deal excess combat damage to player or planeswalker it's attacking.",val='number',def=0},
  mtg_firststrikecounter={name="First Strike",des=":This creature deals combat damage before creatures without first strike.",val='number',def=0},
  mtg_doublestrikecounter={name="Double Strike",des=":This creature deals both first-strike and regular combat damage.",val='number',def=0},
  mtg_laststrikecounter={name="Last Strike",des=":This creature deals combat damage after creatures without last strike.",val='number',def=0},
  mtg_molassesstrikecounter={name="Molasses Strike",des=":This creature deals both last-strike and regular combat damage.",val='number',def=0},
  mtg_deathtouchcounter={name="Deathtouch",des=":Any amount of damage this deals to a creature is enough to destroy it.",val='number',def=0},
  mtg_hexproofcounter={name="Hexproof",des=":This permanent can't be the target of spells or abilities your opponents control.",val='number',def=0},
  mtg_flyingcounter={name="Flying",des=":This creature can't be blocked except by creatures with flying and/or reach.",val='number',def=0},
  mtg_reachcounter={name="Reach",des=":This creature can block creatures with flying.",val='number',def=0},
  mtg_vigilancecounter={name="Vigilance",des=":Attacking doesn't cause this creature to tap.",val='number',def=0},
  mtg_menacecounter={name="Menace",des=":This creature can't be blocked except by two or more creatures.",val='number',def=0},
  mtg_lifelinkcounter={name="Lifelink",des=":Damage dealt by this creature also causes you to gain that much life.",val='number',def=0},
  mtg_indestructiblecounter={name="Indestructible",des=":Effects that say 'destroy' don’t destroy this.",val='number',def=0},
  mtg_defendercounter={name="Defender",des=":This creature can't attack.",val='number',def=0},
  mtg_hastecounter={name="Haste",des=":This creature does not suffer from summoning sickness.",val='number',def=0}
}


function onload()
  self.createButton({
  label="+", click_function='registerModule', function_owner=self,
  position={0,0.2,-0.5}, height=100, width=100, font_size=100,
  rotation={0,0,0},tooltip="Version: "..version
  })
  Wait.condition(registerModule,function() return Global.getVar('Encoder') ~= nil and true or false end)
end

function registerModule(obj,ply)
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    values={}
    for k,v in pairs(KeywordList) do
      table.insert(values,k)
    end
    properties = {
    propID = pID,
    name = "Keyword Abilities",
    values = values,
    funcOwner = self,
    tags="basic,counter",
    activateFunc ='callEditor'
    }
    enc.call("APIregisterProperty",properties)
    for k,v in pairs(KeywordList) do
      value = {
      valueID = k,
      validType = v.val,
      desc = v.des,
      default = v.def
      }
      enc.call("APIregisterValue",value)
      local g = k
      _G['toggleStatus'..g] = function(o,p,a) toggleStatus(o,p,a,g) end
    end
  end
end

function toggleStatus(obj,ply,alt,val)
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    data = enc.call("APIobjGetValueData",{obj=obj,valueID=val})
    if KeywordList[val].val == 'boolean' then
      if data[val] ~= true then
      data[val] = true
      else
        data[val] = false
      end
    elseif KeywordList[val].val == 'color' then
      if data[val] ~= '' then
      data[val] = ''
      else
        data[val] = KeywordList[val].func ~= nil and KeywordList[val].func() or ply
      end
    elseif KeywordList[val].val == 'number' then
      if data[val] == nil then
        data[val] = KeywordList[val].def
      end
      if alt ~= true then
        data[val] = data[val]+1
      else
        data[val] = data[val]-1
      end
    end
    enc.call("APIobjSetValueData",{obj=obj,valueID=val,data=data})
    enc.call("APIrebuildButtons",{obj=obj})
  end
end

function toggleEditor(obj,ply)
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    enc.call("APIsetEditing",{obj=obj,propID=pID})
    enc.call("APIrebuildButtons",{obj=obj})
  end
end
function callEditor(obj,ply)
  enc.call("APItoggleProperty",{obj=obj,propID=pID})
  if enc.call("APIobjIsPropEnabled",{obj=obj,propID=pID}) then
    toggleEditor(obj,nil)
  end
end
function toggleEditClose(obj,ply)
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    enc.call("APIclearEditing",{obj=obj})
    enc.call("APIrebuildButtons",{obj=obj})
  end
end

function createButtons(t)
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    data = enc.call("APIobjGetPropData",{obj=t.obj,propID=pID})
    flip = enc.call("APIgetFlip",{obj=t.obj})
    scaler = {x=1,y=1,z=1}--t.obj.getScale()
    editing = enc.call("APIgetEditing",{obj=t.obj})
    
    tooltip = "Abilities:\n"
    for k,v in pairs(data) do
      if KeywordList[k].val == 'boolean' and v == true then
        tooltip = tooltip..KeywordList[k].name..KeywordList[k].des..'\n'
      elseif KeywordList[k].val == 'color' and v ~= '' then
        tooltip = tooltip..KeywordList[k].name..string.gsub(KeywordList[k].des,'%%Color%%',v)..'\n'
      elseif KeywordList[k].val == 'number' and v ~= 0 then
        tooltip = tooltip..v.." "..KeywordList[k].name..KeywordList[k].des..'\n'
      end
    end
      
    if editing == nil then     
      temp = "Abilities"
      barSize,fsize,offset_x,offset_y = enc.call('APIformatButton',{str=temp,font_size=90,max_len=90,xJust=0,yJust=0})
      t.obj.createButton({
      label=temp, click_function='toggleEditor', function_owner=self,
      position={(-0+offset_x)*flip*scaler.x,0.28*flip*scaler.z,(-0.9+offset_y)*scaler.y}, height=160, width=barSize, font_size=fSize,
      rotation={0,0,90-90*flip}, tooltip=tooltip,color={r=1,g=1,b=1,a=0.4}
      })
    elseif editing == pID then
      temp = "Abilities"
      barSize,fsize,offset_x,offset_y = enc.call('APIformatButton',{str=temp,font_size=90,max_len=90,xJust=0,yJust=0})
      t.obj.createButton({
      label=temp, click_function='toggleEditClose', function_owner=self,
      position={(-0+offset_x)*flip*scaler.x,0.28*flip*scaler.z,(-1.2+offset_y)*scaler.y}, height=170, width=barSize, font_size=fsize,
      rotation={0,0,90-90*flip}, tooltip=tooltip
      })
      i = 1
      for k,v in pairs(data) do
        if (KeywordList[k].val == 'boolean' and v == true) or KeywordList[k].val == 'color' and v ~= '' or KeywordList[k].val == 'number' and v ~= 0 then
          temp =KeywordList[k].name
          barSize,fsize,offset_x,offset_y = enc.call('APIformatButton',{str=temp,font_size=90,max_len=90,xJust=0,yJust=0})
          t.obj.createButton({
          label= temp, click_function='toggleStatus'..k, function_owner=self,
          position={-0*flip,0.28*flip*scaler.z,(-1.2+offset_y+i*0.25)*scaler.y}, height=160, width=barSize, font_size=fsize,
          rotation={0,0,90-90*flip}, color={r=0,g=0,b=0}, font_color={r=1,g=0,b=0},tooltip=v.." "..KeywordList[k].des
          })
        else
          temp =KeywordList[k].name
          barSize,fsize,offset_x,offset_y = enc.call('APIformatButton',{str=temp,font_size=90,max_len=90,xJust=0,yJust=0})
          t.obj.createButton({
          label= temp, click_function='toggleStatus'..k, function_owner=self,
          position={-0*flip,0.28*flip*scaler.z,(-1.2+offset_y+i*0.25)*scaler.y}, height=160, width=barSize, font_size=fsize,
          rotation={0,0,90-90*flip}, color={r=0,g=0,b=0}, font_color={r=1,g=1,b=1},tooltip=v.." "..KeywordList[k].des
          })
        end
        i = i+1
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