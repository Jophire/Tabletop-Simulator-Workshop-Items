--[[Untapper Tool
by Tipsy Hobbit//STEAM_0:1:13465982

Allows you to create a scripted zone which will
untap all cards within it and align them to your hand.
]]

save = {}
save["zone"] = nil
save["corner"] = nil
save["owner"] = nil
save["locked"] = false
function onLoad(saved_data)
	if saved_data ~= nil and saved_data ~= "" then
    loaded_data = JSON.decode(saved_data)
		save["zone"] = getObjectFromGUID(loaded_data.zone)
		save["corner"] = getObjectFromGUID(loaded_data.corner)
		save["owner"] = loaded_data.owner
		save["locked"] = loaded_data.locked
	end
	if save["corner"] == nil then
		createCorner()
	else
		finalizeCorner(save["corner"])
	end
	if save["locked"] == true then
		self.setLock(true)
		save["corner"].setLock(true)
		self.interactable = false
		save["corner"].interactable = false
		save["corner"].editButton({index=0,font_color={1,0,0,1},function_owner=self})
	end

	self.clearButtons()
	self.createButton({
	label="", click_function='unTap', function_owner=self,
	position={0,0.0,0}, height=240, width=240, font_size=1,rotation={0,0,0}
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
	if save.corner ~= nil then
		dts["corner"] = save.corner.getGUID()
		save["locked"] = self.interactable
	end
	dts["owner"] = save.owner
	return JSON.encode(dts)
end

function createCorner()
	params = {}
	params.type = "BlockSquare"
	params.position = vec_add(self.getPosition(),vec_mult(self.getTransformRight(),2))
	params.rotation = self.getRotation()
	params.scale = {0.25, 0.25, 0.25} 
	params.callback = 'finalizeCorner'
	params.callback_owner = self
	save["corner"] = spawnObject(params)
end

function finalizeCorner(obj)
	save["corner"] = obj
	obj.setColorTint({1,1,1,1})
	obj.clearButtons()
	obj.createButton({
	label="⌂", click_function='createZone', function_owner=self,
	position={0,0.55,0}, height=400, width=400, font_size=360,rotation={0,0,0},color={0,0,0,1},font_color={1,1,1,1}
	})
end

function createZone(obj,ply)
	if self.interactable then
		self.setLock(true)
		save["corner"].setLock(true)
		self.interactable = false
		save["corner"].interactable = false
		save["corner"].editButton({index=0,font_color={1,0,0,1}})
	else
		self.setLock(false)
		save["corner"].setLock(false)
		self.interactable = true
		save["corner"].interactable = true
		save["corner"].editButton({index=0,font_color={1,1,1,1}})
	end
	
	save["owner"] = ply
	if save["zone"] == nil then
		params = {}
		params.type = "scriptingTrigger"
		params.position = self.getPosition()
		params.rotation = self.getRotation()
		params.scale = {1, 4.35, 1} 
		save["zone"] = spawnObject(params)
	end
	hrot = Player[save["owner"]].getHandTransform(1).rotation
	
	self.setRotation({hrot.x,hrot.y+180,hrot.z})
	save["corner"].setRotation({hrot.x,hrot.y+180,hrot.z})
	spos = self.getPosition()
	cpos = save["corner"].getPosition()
	save["zone"].setPosition(vec_add(vec_add(spos,vec_mult(vec_sub(cpos,spos),0.5)),{x=0,y=-0.25,z=0}))
	save["zone"].setRotation({hrot.x,hrot.y+180,hrot.z})
	scale = vec_mult(self.positionToLocal(cpos),self.getScale())
	save["zone"].setScale({scale.x,2,scale.z})
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


function vec_add(va,vb)
	return {x=va.x+vb.x,y=va.y+vb.y,z=va.z+vb.z}
end
function vec_sub(va,vb)
	return {x=va.x-vb.x,y=va.y-vb.y,z=va.z-vb.z}
end
function vec_mult(va,vb)
	if type(vb) ~= 'table' then
		return {x=va.x*vb,y=va.y*vb,z=va.z*vb}
	else
		return {x=va.x*vb.x,y=va.y*vb.y,z=va.z*vb.z}
	end
end
function vec_div(va,vb)
	if type(vb) ~= 'table' then
		return {x=va.x/vb,y=va.y/vb,z=va.z/vb}
	else
		return {x=va.x/vb.x,y=va.y/vb.y,z=va.z/vb.z}
	end
end
function vec_norm(va)
	norm = length(va)
	return {x=va.x/norm,y=va.y/norm,z=va.z/norm}
end
function distance(va,vb)
	return length(vec_sub(vb,va))
end
function length(va)
	return math.sqrt(math.pow(va.x,2)+math.pow(va.y,2)+math.pow(va.z,2))
end

