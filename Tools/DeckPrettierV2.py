"""
Created by STEAM_0:1:13465982//Tipsy Hobbit
"""

import os, sys, time
from lxml import html
from pprint import pprint
from pathlib import *
import requests, json,re, string, urllib.parse

def is_sequence(arg):
    return (not hasattr(arg, "strip") and
            hasattr(arg, "__getitem__") or
            hasattr(arg, "__iter__")) 

def hex_to_rgb(value):
	"""Return (red, green, blue) for the color given as #rrggbb."""
	value = value.lstrip('#')
	lv = len(value)
	color = dict()
	for i in range(0, lv, lv // 3):
		color[int(i/2)]=int(value[i:i + lv // 3], 16)
	return color

def rgb_to_hex(red, green, blue):
    """Return color as #rrggbb for the given color values."""
    return '%02x%02x%02x' % (red, green, blue)

def string_to_color(arg):
	"""Returns color as a hex from Hexatridecimal string"""
	if len(alphNumPat.sub("",arg)) == 0:
		return 'ffffff'
	hexPat = (hex(int(alphNumPat.sub("",arg),36))+"ffffff")[2:8]
	return hexPat
	
def lightenColor(hex,ammount):
	"""De-saturates the hex color until its rgb values added together exceed 'ammount'."""
	color = hex_to_rgb(hex)
	while sum(color.values()) < ammount:
		for key,col in color.items():
			if col < 256:
				color[key] = (col+2)
	return rgb_to_hex(color[0],color[1],color[2])[0:6]

	
if len(sys.argv) == 1:
	sys.exit(1) """The target deck save to update"""
	
alphNumPat = re.compile('[\W_]+')
pow_touPat = re.compile('( *[\S]*\/[\S]*)')
loyaltyPat = re.compile(' \(Loyalty: \d*\)')
pathPat = re.compile('(.+\\\)')

"""So we don't have to recalculate colors every time."""
colorPath = pathPat.search(sys.argv[1]).group(0)+"colorMap.json"

colorMap = dict()
if os.path.isfile(colorPath) and os.access(colorPath, os.R_OK):
	pprint("Found existing color mappings...loading.")
	colorFile = open(colorPath)
	colorMap = json.load(colorFile)
	colorFile.close()
else:
	pprint("No color mappings found, creating new mappings.")

with open(sys.argv[1]) as deckFile:    
	data = json.load(deckFile)
	found = dict()
	notFound = dict()
	for cc in range(len(data['ObjectStates'])):
		for k in data['ObjectStates'][cc].get('ContainedObjects',dict()):
			if k['Name'] == 'Card':
				name = k['Nickname']
				if len(name) !=0 and name != 'Commander' and name != 'Token':
					name_inner = alphNumPat.sub("","".join(name.split()))
					color = 'ffffff'
					type = ""
					desc = ""
					if name_inner not in found:
						pprint('')
						pprint('################################################')
						pprint(name)
						searchString = "https://api.scryfall.com/cards/named?fuzzy="+urllib.parse.quote_plus(name)
						#if " " not in name:
						#	searchString+= '+![" "]'
						pprint(searchString)
						page = requests.get(searchString)
						cardData = page.json()
						#if 'Card' in page.url:
						type = cardData['type_line']
						pprint(type)
						if 'flavor_text' in cardData:
							desc = cardData['flavor_text']
							pprint(desc)
						else:
							desc = ""
							
						tyList = "\n[i]"
						if ' ' in type:
							for ty in type.split(' '):  #—
								ty = ty.lstrip()
								if ty not in colorMap:
									colorMap[ty] = lightenColor(string_to_color(ty),360)
								tyList += "["+colorMap[ty]+"]"+ty+" "
						else:
							if type not in colorMap:
								colorMap[type] = lightenColor(string_to_color(type),360)
							tyList += "["+colorMap[type]+"]"+type
						tyList += "[/i]"
						found[name_inner]={'type':tyList,'desc':desc}
						type = tyList
						time.sleep(0.2)
					else:
						type = found[name_inner]['type']
						desc = found[name_inner]['desc']
					k['Nickname'] = name+type+'[ffffff]'
					k['Description'] = '[ffffff]'+desc
	path = os.path.realpath(deckFile.name)
	pprint(path)
	newPath = path.replace(".json","Pretty.json")
	pprint(newPath)
	with open(newPath,'w') as writeFile:
		json.dump(data, writeFile)
	with open(colorPath,'w') as colorFile:
		json.dump(colorMap,colorFile,indent=2)
	