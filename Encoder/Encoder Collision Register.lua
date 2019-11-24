--[[Collision Encoder
Encodes objects as they are dropped on top of the encoding plate.
by Tipsy Hobbit 
]]

function onload()

end

function onCollisionEnter(co)
  enc = Global.getVar('Encoder')
  if enc ~= nil then
    object = co.collision_object
    if object.tag ~= "Surface" then
      enc.call("APIaddObject",{obj=object})
    end
  end
end