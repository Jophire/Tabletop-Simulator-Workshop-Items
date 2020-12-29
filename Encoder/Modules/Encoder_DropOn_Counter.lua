
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
        _,_,action,value = string.find(v,'([%+%-%*%/=])(.*)')
        _,_,typ,value = string.find(value,'([snbcv]):(.*)')
        if typ == 'v' then
          _,_,guid,value = string.find(value,'(.-):(.*)')
        end
        if enc.call('APIvalueExists',{valueID=k}) then
          if cd[k] == nil then
            cd[k] = enc.call("APIobjGetValueData",{obj=obj,valueID=k})[k]
          end
          if typ == 'n' then
            value = tonumber(value)
            if action == '+' then
              cd[k] = cd[k]+value
            elseif action == '-' then
              cd[k] = cd[k]-value
            elseif action == '*' then
              cd[k] = cd[k]*value
            elseif action == '/' then
              if value ~= 0 then
                cd[k] = cd[k]/value
              end
            elseif action == '=' then
              cd[k] = value
            else
              error(action..' is not a recognized operator for value type '..typ..'.')
            end
          elseif typ == 'b' then 
            if action == '=' then
              cd[k] = value == 'true' and true or false
            else
              error(action..' is not a recognized operator for value type '..typ..'.')
            end
          elseif typ == 's' then
            if action == '+' then
              cd[k] = cd[k]..value
            elseif action == '=' then
              cd[k] = value
            else
              error(action..' is not a recognized operator for value type '..typ..'.')
            end
          elseif typ == 'c' then
            if action == '=' then
              cd[k] = value
            else
              error(action..' is not a recognized operator for value type '..typ..'.')
            end
          elseif typ == 'v' then
            if Player[guid] ~= nil then
              value = enc.call('APIplyGetValueData',{color=guid,valueID=value})
            else
              value = enc.call('APIobjGetValueData',{obj=getObjectFromGUID(guid),valueID=value})
            end
            if type(value) == 'number' then
              if action == '+' then
                cd[k] = cd[k]+value
              elseif action == '-' then
                cd[k] = cd[k]-value
              elseif action == '*' then
                cd[k] = cd[k]*value
              elseif action == '/' then
                if value ~= 0 then
                  cd[k] = cd[k]/value
                end
              elseif action == '=' then
                cd[k] = value
              else
                error(action..' is not a recognized operator for value type '..typ..'.')
              end
            elseif type(value) == 'string' then
              if action == '=' then
                cd[k] = value
              else
                error(action..' is not a recognized operator for value type '..typ..'.')
              end
            end
          end
        else
          error(value..' is not a recognized value.')
        end
        if enc.call('APIpropertyExists',{propID=k}) then
          if enc.call('APIobjIsPropEnabled',{obj=obj,propID=k}) ~= value then
            enc.call('APItoggleProperty',{obj=obj,propID=k})
          end
        end
      end
      enc.call('APIobjSetAllData',{obj=obj,data=cd})
      enc.call("APIrebuildButtons",{obj=obj})
      self.destruct()
    end
  end
end