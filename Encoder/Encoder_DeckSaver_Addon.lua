--[[
  Encoder Decksaver/loader Module
]]


function onObjectLeaveContainer(deck, card)
  if deck.getTable("load") ~= nil then
    local deckList = deck.getTable("load")
    if deckList[card.getName()] ~= nil then
      corParams = {ca=card,da=deckList[card.getName()]}
      startLuaCoroutine(self,'delayedAdd')
    end
  end
end

function delayedAdd()
  local card = corParams.ca
  local data = corParams.da
  corParams = {}
  local check = card.getGUID()
  while card.getGUID() == check and encodedObjects[card.getGUID()] ~= nil do
    waitFrames(5)
  end
  waitFrames(5)
  
  if encodedObjects[card.getGUID()] == nil then
    encodedObjects[card.getGUID()] = data
    encodedObjects[card.getGUID()].this = card
    verifyTableInteg(card)
    createButtons(card)
  end
  return 1
end

function createLoader()
  procobjects, rcds = getCards()
  tempTable = {}
  local s = 0
  local script = "load = {}\n"
  if rcds==0 then
  else
    for i,v in pairs(procobjects) do
      if v.tag == 'Deck' then
        for j,k in pairs(v.getObjects()) do
          if encodedObjects[k.guid] ~= nil then
            u = encodedObjects[k.guid]
          
            local cParams = {}
            cParams.position = {v.getPosition().x+2, v.getPosition().y+2*j, v.getPosition().z}
            cParams.callback = "prepCard"
            cParams.callback_owner = self
            cParams.flip = true
            cParams.guid = k.guid
            cParams.index = k.index
            cParams.top = true
                       
            v.takeObject(cParams)
          
            script = script.."load[\""..u.name.."\"] = {this=\"\""
            script = script..",base={power="..u.base.power
            script = script..",toughness="..u.base.toughness
            script = script.."},coun={plusP="..u.coun.plusP
            script = script..",plusT="..u.coun.plusT
            script = script.."},loyalty="..u.loyalty
            script = script..",toggle={base="..u.toggle.base
            script = script..",coun="..u.toggle.coun
            script = script..",loyalty="..u.toggle.loyalty
            script = script..",editing="..u.toggle.editing
            script = script.."},name=\""..u.name.."\"}\n"
            s = s+1
          end
        end
        if s > 0 then
          v.setLuaScript(script)
        end
      end
    end
  end
end

function prepCard(obj,params)
  obj.resting = true
  obj.setName(params.card.name)
  local timer = 0
  while(obj.getName() ~= params.card.name and timer < 1000) do
    timer = timer +1
  end
  obj.putObject(params.deck)
end

function waitFrames(num_frames)
    for i=0, num_frames, 1 do
        coroutine.yield(0)
    end
    num_frames = 1
    return 1
end