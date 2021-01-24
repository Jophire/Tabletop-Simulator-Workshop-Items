
MPID="ENCODER_DEBUG_MENU"

function onload()
  buildUI()
end

function buildUI()
  xmlM=[[<Panel id="]]..MPID..[[" version="1">]]
  xmlI=''
  for k,v in pairs(Player.getColors()) do
    if v ~= 'Grey' then
    print(MPID..v.."Display")
    xmlI = xmlI..[[
      <Panel id="]]..MPID..v..[[Bar" visibility="]]..v..[[" width="200" height="10" position="0 0" color="Black" allowDragging="True" returnToOriginalPositionWhenReleased="False" tooltip="DEBUG BAR">
      <Panel id="]]..MPID..v..[[Display" visibility="]]..v..[[" width="200" height="350" position="0 -175" color="Black">
        <Text id="]]..MPID..v..[[Text" color="White" text="" alignment="UpperLeft" horizontalOverflow="Wrap" verticalOverflow="Overflow"/>
      </Panel>    
      </Panel>
    ]]
    end
  end
  xmlM = xmlM..xmlI..[[</Panel>]]
  x = UI.getXml()
  if string.find(x,MPID) then
    UI.setValue(MPID,xmlI)
    print('Updating Debug Display')
  else
    UI.setXml(x..xmlM)
  end
end

function onObjectHover(ply,obj)
  enc = Global.getVar('Encoder')
  if enc ~= nil and obj~=nil then
    if enc.call("APIobjectExists",{obj=obj}) then
      data = enc.call("APIobjGetAllData",{obj=obj})
      for k,v in pairs(enc.call('APIlistMenus')) do
        table.insert(data,enc.call("APIobjGetMenuData",{obj=obj,menuID=v}))
      end
      UI.setAttribute(MPID..ply.."Text","text",printOutData(data))
      UI.show(MPID..ply.."Display")
    end
    if obj.getVar("pID") ~= nil then
      pID = obj.getVar("pID")
      if enc.call("APIpropertyExists",{propID=pID}) then
        data = enc.call("APIgetProp",{propID=pID})
        UI.setAttribute(MPID..ply.."Text","text",printOutData(data))
        UI.show(MPID..ply.."Display")
      end 
    end
  else
    UI.hide(MPID..ply.."Display")
  end
end

function printOutData(data,ind)
  if ind == nil then
    ind = ''
  end
  txt=''
  for k,v in pairs(data) do
    --print(type(v))
    if type(v) == 'table' then
      txt = txt..ind..k..":table{\n"..printOutData(v,ind.."  ").."}\n"
    elseif type(v) == 'boolean' then
      txt = txt..ind..k..":"..type(v).." = "..(v and 'true' or 'false').."\n"
    elseif type(v) == 'function' then
      txt = txt..ind..k..":function\n"
    elseif type(v) == 'userdata' then
      txt = txt..ind..k..":userData ".." is nil?"..(v~=nil and 'false' or 'true').."\n"
    elseif v~= nil then
      txt = txt..ind..k..":"..type(v).." = "..v.."\n"
    elseif v==nil then
      txt = txt..ind..k..":"..type(v).." = nil\n"
    end
  end
  return txt
end