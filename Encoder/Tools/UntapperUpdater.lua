--'Untapper updater'

scr=[[--Untapper Tool
--by Tipsy Hobbit//STEAM_0:1:13465982
--
--Allows you to create a scripted zone which will
--untap all cards within it and align them to your hand.


save = {}
save["zone"] = nil
save["owner"] = nil
function onLoad(saved_data)
	if saved_data ~= nil and saved_data ~= "" then
    loaded_data = JSON.decode(saved_data)
		save["zone"] = getObjectFromGUID(loaded_data.zone)
		save["owner"] = loaded_data.owner
	end
	self.clearButtons()
	self.createButton({
	label="", click_function='unTap', function_owner=self,
	position={0,0.0,0}, height=1300, width=1300, font_size=1,rotation={0,0,0}
	})
  registerModule()
end
function registerModule()
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    value = {
    valueID = 'mtg_exert',
    validType = 'boolean',
    desc = "MTG: This creature is currently exerted and won't untap during the players next untap step.",
    default = false
    }
    enc.call("APIregisterValue",value)
    value = {
    valueID = 'mtg_frozen',
    validType = 'boolean',
    desc = 'MTG: This creature is currently frozen, not untapping during the owners untap step.',
    default = false
    }
    enc.call("APIregisterValue",value)
  end
end
function onSave()
	dts = {}
	if save.zone ~= nil then
		dts["zone"] = save.zone.getGUID()
	end
	dts["owner"] = save.owner
	return JSON.encode(dts)
end
function unTap()
	enc = Global.getVar("Encoder")
	local ry = save["zone"].getRotation()
	local rr = nil
	local untaps = true
	for k,v in pairs(save["zone"].getObjects()) do
		untaps = true
		if v.tag == 'Card' or v.tag == 'Deck' then
			if enc ~= nil then
				if enc.call("APIobjectExists",{obj=v}) then
					data = enc.call("APIobjGetAllData",{obj=v})
					if data["mtg_frozen"] ~= nil then
						if data["mtg_frozen"] == true then
							untaps = false
						end
					end
					if data["mtg_exert"] ~= nil then
						if data["mtg_exert"] == true then
							untaps = false
							data["mtg_exert"] = false
							enc.call("APIobjSetAllData",{obj=v,data=data})
              enc.call("APIobjDisableProp",{obj=v,propID='mtg_exert'})
							enc.call("APIrebuildButtons",{obj=v})
						end
					end
				end
			end
			if untaps == true then
				rr = v.getRotation()
				v.setRotation({x=rr.x,y=ry.y,z=rr.z})
			end
		end
	end
end
]]

function onCollisionExit(c)
  obj = c.collision_object
  if obj.getLuaScript() ~= nil then
    if string.find(obj.getLuaScript(),'Untapper Tool') then
      obj.setLuaScript(scr)
      obj.reload()
      self.destruct()
    end
  end
end