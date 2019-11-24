--[[Auto Decoder
by Tipsy Hobbit//STEAM_0:1:13465982

Will automatically decode cards as they enter your hand.
For Stephen//STEAM_0:0:46861528
]]

save = {}
save["owner"] = "None"
save["locked"] = false
function onLoad(saved_data)
	if saved_data ~= nil and saved_data ~= "" then
    loaded_data = JSON.decode(saved_data)
		save["owner"] = loaded_data.owner
		save["locked"] = loaded_data.locked
	end

	if save["locked"] == true then
		self.setLock(true)
		self.interactable = false
		self.editButton({index=0,font_color={1,0,0,1}})
	end

	self.clearButtons()
	self.createButton({
	label=save["owner"], click_function='lock', function_owner=self,
	position={0,0.1,0}, height=110, width=400, font_size=100,rotation={0,0,0}
	})
end

function onSave()
	dts = {}
	save["locked"] = self.interactable
	dts["owner"] = save.owner
	return JSON.encode(dts)
end

function lock(obj,ply)
	save["owner"] = ply
	if self.interactable then
		self.setLock(true)
		self.interactable = false
		self.editButton({index=0,label="Locked",font_color={1,0,0,1}})
	else
		self.setLock(false)
		self.interactable = true
		self.editButton({index=0,label=save["owner"],font_color={0,0,0,1}})
	end
end

function onObjectDropped(c,object)
  local enc = Global.getVar('Encoder')
  if enc ~= nil and c == save["owner"] and self.interactable == false then
		if enc.call("APIobjectExist",{obj=object}) == true then
			for k=1,Player[c].getHandCount() do
				for i,v in pairs(Player[c].getHandObjects(k)) do
					if v == object then
						enc.call("APIdisableEncoding",{obj=object})
					end
				end
			end
		end
  end
end