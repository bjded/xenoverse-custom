def pbPositionNearMsgWindow(cmdwindow,msgwindow,side)
	return if !cmdwindow
	if msgwindow
		height=[cmdwindow.height,Graphics.height-msgwindow.height].min
		if cmdwindow.height!=height
			cmdwindow.height=height
		end
		cmdwindow.y=msgwindow.y-cmdwindow.height
		if cmdwindow.y<0
			cmdwindow.y=msgwindow.y+msgwindow.height
			if cmdwindow.y+cmdwindow.height>Graphics.height
				cmdwindow.y=msgwindow.y-cmdwindow.height
			end
		end
		case side
		when :left
			cmdwindow.x=msgwindow.x
		when :right
			cmdwindow.x=msgwindow.x+msgwindow.width-cmdwindow.width
		else
			cmdwindow.x=msgwindow.x+msgwindow.width-cmdwindow.width
		end
	else
		cmdwindow.height=Graphics.height if cmdwindow.height>Graphics.height
		cmdwindow.x=502-cmdwindow.width
		cmdwindow.y=280-cmdwindow.height
	end
end