
function onload()
  self.createButton({
    label=self.getName(), click_function='donothing', function_owner=self,
    position={0,0.1,0}, height=0, width=0, font_size=200,
    rotation={0,0,0}, font_color={1,1,1}
    })

end

function onCollisionEnter(c)
  obj = c.collision_object
  enc = Global.getVar('Encoder')
  if enc ~= nil and self.held_by_color == nil then
    encoded = enc.call('APIobjectExists',{obj=obj})
    if encoded == true then
      d = JSON.decode(self.getDescription())
      cd = enc.call('APIobjGetAllData',{obj=obj})
      for k,v in pairs(d) do
        if enc.call('APIvalueExists',{valueID=k}) then
          if cd[k] == nil then
            cd[k] = enc.call('APIobjGetValueData',{obj=obj,valueID=k})[k]
          end
          _,_,m,n = string.find(v,'([%+%-%*%/=])(%d*)')
          n = tonumber(n)
          --print(m.."  "..n)
          if m == '+' then
            cd[k] = cd[k]+n
          elseif m == '-' then
            cd[k] = cd[k]-n
          elseif m == '*' then
            cd[k] = cd[k]*n
          elseif m == '/' then
            if n ~= 0 then
              cd[k] = cd[k]/n
            end
          elseif m == '=' then
            cd[k] = n
          else
            print(m..' is not a recognized operator.')
          end
        end
      end
      enc.call('APIobjSetAllData',{obj=obj,data=cd})
      enc.call("APIrebuildButtons",{obj=obj})
      self.destruct()
    end
  end
end