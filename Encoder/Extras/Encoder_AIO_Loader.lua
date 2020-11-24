--By Tipsy Hobbit
mod_name = "Encoder_Loader"
postfix = ''
version = 0.1
version_string = "Better version control through WebRequest and Github!"
target_URL = "https://raw.githubusercontent.com/Jophire/Tabletop-Simulator-Workshop-Items/master/Encoder/Encoder%20Core.lua"

--Might be needed, not sure yet.
saveData = ""
wr = nil

--On object load, check what this item is.
function onLoad(sd)
	if mod_name == "Encoder_Loader" then
		saveData = sd
		WebRequest.get(target_URL,self,"startUnpacking")
	end
end
function startUnpacking(webRequest)
	wr = webRequest
	startLuaCoroutine(self,"UnpackMod")
end

function UnpackMod()
	while wr.download_progress < 1 do
		waitFrames(3)
		print("Downloading")
	end
	js = JSON.decode(self.getJSON())

	js["LuaScript"] = wr.text
	js["LuaScriptState"] = saveData
		
	spawnObjectJSON({json=JSON.encode(js)})
	self.destruct()
	return 1
end

function waitFrames(num_frames)
  for i=0, num_frames, 1 do
    if destroying == true then
      i = num_frames+1
    else
      coroutine.yield(0)
    end
  end
  return 1
end