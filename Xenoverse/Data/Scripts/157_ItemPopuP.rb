#---------------------------------------------------------------------
# Help-14's Gen-V Receive Item Scene script, Please give him credits if you are
# using this script. Slighty edited by mustafa505 for compatible use in Pokemon
# Essentials v13,
# Dont forget to credit Help-14
# Slightly edited by Black Eternity (again)
#---------------------------------------------------------------------
def pbReceiveItemPop(item,quantity=1)
item=getID(PBItems,item) if !item.is_a?(Integer)
itemname=PBItems.getName(item)
Kernel.pbMessage(_INTL("{1} ottiene {2}!",$Trainer.name,itemname))
if $PokemonBag.pbStoreItem(item)
bg=Sprite.new
pbMEPlay("Item_Get")
bg.bitmap=BitmapCache.load_bitmap("Graphics/Pictures/ReceiveItem1")
bg.x=(Graphics.width-bg.bitmap.width)/2
bg.y=(Graphics.height-bg.bitmap.height)/2
bg.opacity=255
sprite=Sprite.new
sprite.bitmap=BitmapCache.load_bitmap(sprintf("Graphics/Icons/item%03d.png",$ItemData[item][0]))
sprite.x=Graphics.width / 2 - sprite.bitmap.width #/ 2
sprite.y=Graphics.height / 2 - sprite.bitmap.height# / 2
sprite.zoom_x=2
sprite.zoom_y=2
2.times do
5.times do
sprite.x+=1
pbWait(3)
end
10.times do
sprite.x-=1
pbWait(3)
end
5.times do
sprite.x+=1
pbWait(3)
end
end
pbWait(5)
sprite.dispose
bg.dispose
case $ItemData[item][ITEMPOCKET]
when 1
Kernel.pbMessage(_INTL("{1} sistema {2} nella tasca Strumenti.",$Trainer.name,itemname))
when 2
Kernel.pbMessage(_INTL("{1} sistema {2} nella tasca Medicine.",$Trainer.name,itemname))
when 3
Kernel.pbMessage(_INTL("{1} sistema {2} nella tasca Poke Balls.",$Trainer.name,itemname))
when 4
Kernel.pbMessage(_INTL("{1} sistema {2} nella tasca MT/MN.",$Trainer.name,itemname))
when 5
Kernel.pbMessage(_INTL("{1} sistema {2} nella tasca Bacche.",$Trainer.name,itemname))
when 6
Kernel.pbMessage(_INTL("{1} sistema {2} nella tasca Mail.",$Trainer.name,itemname))
when 7
Kernel.pbMessage(_INTL("{1} sistema {2} nella tasca Oggetti di battaglia.",$Trainer.name,itemname))
when 8
Kernel.pbMessage(_INTL("{1} sistema {2} nella tasca Strumenti chiave.",$Trainer.name,itemname))
end
return true
else
return false
end
end