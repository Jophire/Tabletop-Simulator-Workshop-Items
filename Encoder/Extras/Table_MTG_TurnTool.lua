--[[ Phases Mod ]]


timerID= nil
delay = 10
current = 1
phases = {
  {phase="Begining",step="Untap",delay=delay,func=function(ply,num) end},
  {phase="Begining",step="Upkeep",delay=delay,func=function(ply,num) end},
  {phase="Begining",step="Draw",delay=delay,func=function(ply,num) end},
  {phase="First",step="Main",delay=delay,func=function(ply,num) end},
  {phase="Combat",step="Begining of Combat",delay=delay,func=function(ply,num) end},
  {phase="Combat",step="Declare Attackers",delay=delay,func=function(ply,num) end},
  {phase="Combat",step="Declare Blockers",delay=delay,func=function(ply,num) end},
  {phase="Combat",step="First Strike Damage",delay=delay,func=function(ply,num) end},
  {phase="Combat",step="Normal Damage",delay=delay,func=function(ply,num) end},
  {phase="Combat",step="Last Strike Damage",delay=delay,func=function(ply,num) end},
  {phase="Combat",step="Combat Cleanup",delay=delay,func=function(ply,num) end},
  {phase="Second",step="Main",delay=delay,func=function(ply,num) end},
  {phase="End",step="Step",delay=delay,func=function(ply,num) end},
  {phase="End",step="Cleanup",delay=delay,func=function(ply,num) end}
}

XML_ID = 'Phase_Table'

function onload()
  buildUI()
  --registerValues()
end

function buildUI()
  guid = self.guid
  xmlI=''
  for k,v in pairs(Player.getColors()) do
    if v ~= 'Grey' and v ~= 'Black' then
    xmlI = xmlI..[[
      <Panel id="]]..XML_ID..v..[[" visibility="]]..v..[[" width="0" height="0" position="0 434">
        <Panel id="]]..XML_ID..v..[[Turn" width="280" height="55" color="#00000080" outlineSize="2 -2">
          <Panel color="#00000040" outline="#FF0000FF" outlineSize="0 0" position="-120 00" width="40" height="40">
            <Text id="]]..XML_ID..v..[[Timer" text="" color="#FFFFFFFF" fontSize="30" fontStyle="Bold" verticalOverflow="Overflow"/>
          </Panel>
          <Button id="]]..XML_ID..v..[[Next" onClick="]]..guid..[[/nextStep(1)" position="120 0" width="40" height="40"
           text="Next
Step" verticalOverflow="Overflow"/>
        </Panel>
        <Button id="]]..XML_ID..v..[[Response" onClick="]]..guid..[[/freeze()" 
        position="0 0" width="198" height="55" color="#282828" textColor="#FFFFFF" fontSize="30" fontStyle="Bold"
         text="RESPONSE" verticalOverflow="Overflow"/>
        <Text id="]]..XML_ID..v..[[Phase" text="" color="#FFFFFF" fontSize="30" fontStyle="Bold" position="0 -40" verticalOverflow="Overflow" horizontalOverflow="Overflow"/>
        <Text id="]]..XML_ID..v..[[Step" text="" color="#FFFFFF" fontSize="25" position="0 -60" verticalOverflow="Overflow" horizontalOverflow="Overflow"/>
      </Panel>
    ]]
    end
  end
  xmlM = [[<Panel id="]]..XML_ID..[[" version="1">]]..xmlI..[[</Panel>]]
  x = UI.getXml()
  if string.find(x,XML_ID) then
    UI.setValue(XML_ID,xmlI)
    print('Updating Debug Display')
  else
    UI.setXml(x..xmlM)
  end
  Wait.frames(function() 
  for k,v in pairs(Player.getColors()) do
    if v ~= 'Grey' and v ~= 'Black' then
      UI.hide(XML_ID..v.."Turn")
      UI.hide(XML_ID..v.."Response")
    end
  end
  end
  , 1)
end

function onPlayerChangeColor(ply)
  if Turns.enable == false then
    for k,v in pairs(Player.getColors()) do
      if v ~= 'Grey' and v ~= 'Black' then
        UI.hide(XML_ID..v)
      end
    end
  end
end

function onPlayerTurn(ply)
  current = 1
  for k,v in pairs(Player.getColors()) do
    if v ~= 'Grey' and v ~= 'Black' then
      UI.show(XML_ID..v)
      if v == ply.color then
        UI.hide(XML_ID..v.."Response")
        UI.show(XML_ID..v.."Turn")
      else
        UI.hide(XML_ID..v.."Turn")
        UI.show(XML_ID..v.."Response")
      end
    end
  end
  nextStep(ply,0,0)
end

function nextStep(ply,val,alt)
  if timerID ~= nil then
    Wait.stop(timerID)
  end
  if type(val) == 'string' then
    val = tonumber(val)
  end
  current = current+val
  if current > #phases then
    current = 1
  end
  local k = phases[current].delay
  if k > 0 then
    countTo(k,-1,0,function(c)
      for m,n in pairs(Player.getColors()) do
        if n ~= "Grey" and v ~= 'Black' then
          UI.setAttribute(XML_ID..n.."Timer","text",c) 
        end
      end
      end)
  end
  for m,n in pairs(Player.getColors()) do
    if n ~= "Grey" and v ~= 'Black' then
    UI.setAttribute(XML_ID..n.."Phase","text",phases[current].phase)
    UI.setAttribute(XML_ID..n.."Step","text",phases[current].step)
    end
  end
end

function countTo(n,a,t,f)
  if t==nil then
    t = 0
  end
  if f==nil then
    f = 1
  end
  f(n)
  if n > t then
    timerID = Wait.time(function() countTo(n+a,a,t,f) end,math.abs(a))
  end
end