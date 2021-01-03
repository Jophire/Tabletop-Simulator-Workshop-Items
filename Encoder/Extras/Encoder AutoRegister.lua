--[[
  Auto Property Register
  Place on table anywhere.
  Make sure you are using at least version 1 of my new encoder.
  Will automatically register any properties as they are dropped on the table.
  By: Tipsy Hobbit
]]--

cour = false
rotate = false
function onLoad()
  enc = Global.getVar("Encoder")
  if enc ~= nil then
    startLuaCoroutine(self,'Float')
  end
  self.createButton({
  label="☺", click_function='rotation', function_owner=self,
  position={0,0.07,0}, height=50, width=50, font_size=100,
  rotation={0,0,0},tooltip="☺",color={0,0,0,1},font_color={0.4,0,0,1}
  })
	self.createButton({
  label="Coroutine: False", click_function='courActive', function_owner=self,
  position={0,-0.1,0}, height=70, width=500, font_size=60,
  rotation={0,0,180},tooltip="Enable/Disable the coroutine.",color={0,0,0,1},font_color={1,1,1,1}
  })
  
  Wait.condition(registerModules,function() if Global.getVar("Encoder") ~= nil then return true else return false end end)
  
end

function registerModules()
  enc = Global.getVar("Encoder")
  if enc ~= nil then
    for k,v in pairs(enc.getTable("Properties")) do
      if v.funcOwner ~= nil then
        v.funcOwner.call("registerModule")
      end
    end
  end
end

function courActive()
	if cour == true then
		cour = false
		self.editButton({index=1,label="Coroutine: False"})
	else
		cour = true
		self.editButton({index=1,label="Coroutine: True"})
		startLuaCoroutine(self,'Float')
	end
end

function onObjectDropped(c,object)
  local enc = Global.getVar('Encoder')
  if enc ~= nil then
    if object.getVar("doNotEncode") == nil then
      if object.getVar("pID") ~= nil then
        object.call("registerModule")
        object.setLock(true)
				
				start = 0
				modules = tableMerge(enc.getTable("Properties"),enc.getTable("Menus"))
				count = 0
				
				startPos = addVectors(self.getPosition(),multVectors(self.getTransformUp(),1))
				start = rotate and start-2*math.pi/50 or start;
				rev = 1
				radius = 1.5
				ao = 2*math.pi/(((2*math.pi*radius)/1.05)-1)
		
				enc.setRotation({self.getRotation().x+0,self.getRotation().y+start*2,self.getRotation().z+0})
				enc.setPositionSmooth(startPos,false,false)
				enc.setLock(true)
				enc.setScale(multVectors(self.getScale(),0.675))
				
				for k,v in pairs(modules) do
					if v.funcOwner ~= nil then
						v.funcOwner.setRotation(self.getRotation())
						offset = {x=math.cos(start*rev+ao*count*rev)*(radius),y=0,z=math.sin(start*rev+ao*count*rev)*(radius)}
						v.funcOwner.setPositionSmooth(addVectors(startPos,offset), false, false)
						v.funcOwner.setScale(multVectors(self.getScale(),0.315))
						count = count+1
						if count >= (2*math.pi*radius)/1.05-1 then
							radius = radius + 1.1
							ao = 2*math.pi/(((2*math.pi*radius)/1.05-1))
							rev=-rev
						end
					end
				end
      end
    end
  end
end

function Float()
  enc = Global.getVar("Encoder")
  start = 0
  while self ~= nil and cour == true do
    if enc ~= nil then
      modules = tableMerge(enc.getTable("Properties"),enc.getTable("Menus"))
      count = 0
			
			startPos = addVectors(self.getPosition(),multVectors(self.getTransformUp(),1))
			start = rotate and start-2*math.pi/50 or start;
			rev = 1
			radius = 1.5
			ao = 2*math.pi/(((2*math.pi*radius)/1.05)-1)
	
			enc.setRotation({self.getRotation().x+0,self.getRotation().y+start*2,self.getRotation().z+0})
			enc.setPositionSmooth(startPos,false,false)
			enc.setLock(true)
			enc.setScale(multVectors(self.getScale(),0.675))
      
			for k,v in pairs(modules) do
        if v.funcOwner ~= nil then
          v.funcOwner.setRotation(self.getRotation())
          offset = {x=math.cos(start*rev+ao*count*rev)*(radius),y=0,z=math.sin(start*rev+ao*count*rev)*(radius)}
          v.funcOwner.setPositionSmooth(addVectors(startPos,offset), false, false)
					v.funcOwner.setScale(multVectors(self.getScale(),0.315))
          count = count+1
					if count >= (2*math.pi*radius)/1.05-1 then
						radius = radius + 1.1
						ao = 2*math.pi/(((2*math.pi*radius)/1.05-1))
						rev=-rev
					end
        end
      end
    end
    waitFrames(10)
  end
  return 1
end

function rotation()
  if rotate ~= true then
    rotate = true
  else
    rotate = false
  end
end

function addVectors(a,b)
return {x=a['x']+b['x'],y=a['y']+b['y'],z=a['z']+b['z']}
end
function multVectors(a,b)
  if type(b) ~= "table" then
    b={x=b,y=b,z=b}
  end
  return {x=a['x']*b['x'],y=a['y']*b['y'],z=a['z']*b['z']}
end
function tableMerge(t1, t2)
    local t3 = t1
    for k,v in pairs(t2) do
        if type(v) == "table" then
            if type(t3[k] or false) == "table" then
                tableMerge(t1[k] or {}, t2[k] or {})
            else
                t3[k] = v
            end
        else
            t3[k] = v
        end
    end
    return t3
end
function waitFrames(num_frames)
    for i=0, num_frames, 1 do
        coroutine.yield(0)
    end
    num_frames = 1
    return 1
end
