
function onload()
  self.createButton({
    label=self.getName(), click_function='donothing', function_owner=self,
    position={0,0.1,0}, height=0, width=0, font_size=200,
    rotation={0,0,0}, font_color={1,1,1}
    })

end
test=0
function onCollisionEnter(c)
  test = 0
  for k,v in pairs(c) do
    print(k)
    print(v)
  end
  obj = c.collision_object
  enc = Global.getVar('Encoder')
  if enc ~= nil and self.held_by_color == nil then
    print('Test'..test)
    test=test+1
    encoded = enc.call('APIobjectExists',{obj=obj})
    if encoded == true then
      d = JSON.decode(self.getDescription())
      cd = enc.call('APIobjGetAllData',{obj=obj})
      print('Test'..test)
      test=test+1
      for k,v in pairs(d) do
        if enc.call('APIvalueExists',{valueID=k}) then
          if cd[k] == nil then
            cd[k] = enc.call('APIobjGetValueData',{obj=obj,valueID=k})[k]
            print('Test'..test)
            test=test+1
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
      print('Test'..test)
      test=test+1
      enc.call('APIobjSetAllData',{obj=obj,data=cd})
      enc.call("APIrebuildButtons",{obj=obj})
      print('Test'..test)
      test=test+1
      self.destruct()
    end
  end
end