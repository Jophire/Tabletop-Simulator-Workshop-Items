
MPID="ENCODER_DEBUG_MENU"

function onload()
  xml=[[<Panel id="]]..MPID..[[" version="1">]]
  for k,v in pairs(Player.getColors()) do
    if v ~= 'Grey' then
    print(MPID..v.."Display")
    xml = xml..[[
      <Panel id="]]..MPID..v..[[Bar" visibility="]]..v..[[" width="200" height="10" position="0 0" color="Black" allowDragging="True" returnToOriginalPositionWhenReleased="False" text="DEBUG BAR">
      <Panel id="]]..MPID..v..[[Display" visibility="]]..v..[[" width="200" height="350" position="0 -175" color="Black">
        <Text id="]]..MPID..v..[[Text" color="White" text="" alignment="UpperLeft" horizontalOverflow="Wrap" verticalOverflow="Overflow"/>
      </Panel>    
      </Panel>
    ]]
    end
  end
  xml = xml..[[</Panel>]]
  UI.setXml(xml)
  --buildUI(xml)
end

function buildUI(wr)
  x = UI.getXml()
  if string.find(x,MPID) then
  else
    UI.setXml(x..wr)
  end
end

function onObjectHover(ply,obj)
  enc = Global.getVar('Encoder')
  if enc ~= nil and obj~=nil then
    if enc.call("APIobjectExists",{obj=obj}) then
      data = enc.call("APIobjGetAllData",{obj=obj})
      UI.setAttribute(MPID..ply.."Text","text",printOutData(data))
      UI.show(MPID..ply.."Display")
    end
    if obj.getVar("pID") ~= nil then
      data = enc.getTable("Properties")
      data = data[obj.getVar("pID")]
      UI.setAttribute(MPID..ply.."Text","text",printOutData(data))
      UI.show(MPID..ply.."Display")
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