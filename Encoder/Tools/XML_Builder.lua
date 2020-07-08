function onLoad()
	-- Lets not write over existing XML UI elements.
	local txt = UI.getXml().."\n"
	local g = "GUID_HERE"
  txt = [[<Panel id="Encoder" active="true" visibilty="" version="VERSION_NUMBER">]]
	for v,k in pairs(Player.getColors()) do
      txt = txt..[[
      <Panel id="]]..k..[[Menu" active="True" visibility="Safety|]]..k..[[" width="198" height="30" position="-700 400" color="white" allowDragging="true" returnToOriginalPositionWhenReleased="False">
        <Button id="]]..k..[[DroplistBut" onClick="]]..g..[[/minimize" width="30" height="30" color="white" position="-60 0" fontStyle="bold" fontSize="15">_</Button>
        <Button id="]]..k..[[MenuBut" onClick="]]..g..[[/minimize" width="30" height="30" color="white" position="-85 0" fontStyle="bold" fontSize="15">X</Button>
        <Text position="20 0" fontStyle="bold" fontSize="15">Encoder Menu</Text>
        <Panel id="]]..k..[[Droplist" active="False" height="30" position="0 -30" color="white">
          <TableLayout autoCalculateHeight="True">
            <Row preferredHeight="30"><Cell><Button id="]]..k..[[PropListBut" onClick="]]..g..[[/minimize" fontStyle="normal" fontSize="15" >Properties</Button></Cell></Row>
            <Row preferredHeight="206" id="]]..k..[[PropList" active="False">
              <VerticalScrollView width="200" height="205" color="white" verticalScrollbarVisibility="AutoHideAndExpandViewport">
                <TableLayout autoCalculateHeight="True">]]
                [[</TableLayout>
              </VerticalScrollView>
            </Row>
            <Row preferredHeight="30"><Cell><Button id="]]..k..[[ToolListBut" onClick="]]..g..[[/minimize" fontStyle="normal" fontSize="15">Tools</Button></Cell></Row>
            <Row preferredHeight="206" id="]]..k..[[ToolList" active="False">
              <VerticalScrollView width="200" height="205" color="white" verticalScrollbarVisibility="AutoHideAndExpandViewport">
                <TableLayout autoCalculateHeight="True">]]
                [[</TableLayout>
              </VerticalScrollView>
            </Row>
          </TableLayout>
        </Panel>
      </Panel>	
      ]]
  end
  txt=txt..[[</Panel>]]
  UI.setXml(txt)
  Wait.frames(function() 
  	Notes.editNotebookTab({index=0,title="Custom Data",body=JSON.encode_pretty(UI.getXmlTable()),color='Grey'})
  end,
  1
  )
end
