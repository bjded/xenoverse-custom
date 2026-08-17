################################################################################
#	SPRITE_COMPOSITION CLASS
#	
#	Version 1.0 (Build 2)
#	18/12/2015
#	Scripter: Fuji
################################################################################

class IgnoreArg
	attr_accessor	:value
	
	def intialize(value)
		@value = value
	end
end

def _IGN(value)
	return IgnoreArg.new(value)
end

class Sprite_Composition
	attr_reader		:visible
	attr_reader		:x
	attr_reader		:y
	attr_reader		:z
	attr_reader		:ox
	attr_reader		:oy
	attr_reader		:zoom_x
	attr_reader		:zomm_y
	attr_reader		:angle
	attr_reader		:mirror
	attr_reader		:bush_depth
	attr_reader		:opacity
	attr_reader		:blend_type
	attr_reader		:color
	attr_reader		:tone
	attr_accessor	:sprites
	attr_reader		:params
	attr_reader		:type
	
	def initialize(arr=nil,hash=false,viewport=nil)
		@viewport = viewport
		@params ={}
		@disposed = false
		@visible = false
		@x = 0
		@y = 0
		@z = 0
		@ox = 0
		@oy = 0
		@zoom_x = 1.0
		@zoom_y = 1.0
		@angle = 0.0
		@mirror = false
		@bush_depth = 0
		@opacity = 255
		@blend_type = 0
		@color = nil	# To be corrected
		@tone = nil		# To be corrected
		if arr == nil
			if hash
				@sprites ={}
			else
				@sprites =[]
			end
		else
			@type = arr.class.name
			@sprites = arr
		end
	end
	
	def dispose
		if (@sprites.is_a?(Hash))
			@sprites.each_value {|sprite| sprite.dispose}
		else
			@sprites.each {|sprite| sprite.dispose}
		end
		@disposed = true
	end
	
	def disposed?; return @disposed; end;
	def viewport; return @viewport; end;
	
	def flash(color,duration)
		if (@sprites.is_a?(Hash))
			@sprites.each_value {|sprite| sprite.flash(color,duration)}
		else
			@sprites.each {|sprite| sprite.flash(color,duration)}
		end
		@disposed = true
	end
	
	def update
		if (@sprites.is_a?(Hash))
			@sprites.each_value {|sprite| sprite.update}
		else
			@sprites.each {|sprite| sprite.update}
		end
		@disposed = true
	end
	
	def visible=(value)
		if (@sprites.is_a?(Hash))
			@sprites.each_value {|sprite| sprite.visible = value}
		else
			@sprites.each {|sprite| sprite.visible = value}
		end
		@visible = value
	end
	
	def x=(value)
		relValue = value - @x
		if (@sprites.is_a?(Hash))
			@sprites.each_value {|sprite| sprite.x += relValue}
		else
			@sprites.each {|sprite| sprite.x += relValue}
		end
		@x = value
	end
	
	def y=(value)
		relValue = value - @y
		if (@sprites.is_a?(Hash))
			@sprites.each_value {|sprite| sprite.y += relValue}
		else
			@sprites.each {|sprite| sprite.y += relValue}
		end
		@y = value
	end
	
	def z=(value)
		relValue = value - @z
		if (@sprites.is_a?(Hash))
			@sprites.each_value {|sprite| sprite.z += relValue}
		else
			@sprites.each {|sprite| sprite.z += relValue}
		end
		@z = value
	end
	
	def ox=(value)
		relValue = value - @ox
		if (@sprites.is_a?(Hash))
			@sprites.each_value {|sprite| sprite.ox += relValue}
		else
			@sprites.each {|sprite| sprite.ox += relValue}
		end
		@ox = value
	end
	
	def oy=(value)
		relValue = value - @oy
		if (@sprites.is_a?(Hash))
			@sprites.each_value {|sprite| sprite.oy += relValue}
		else
			@sprites.each {|sprite| sprite.oy += relValue}
		end
		@oy = value
	end
	
	def zoom_x=(value)
		relValuerelValue = value - @zoom_x
		if (@sprites.is_a?(Hash))
			@sprites.each_value {|sprite| sprite.zoom_x += relValuerelValue}
		else
			@sprites.each {|sprite| sprite.zoom_x += relValuerelValue}
		end
		@zoom_x = value
	end
	
	def zoom_y=(value)
		relValue = value - @zoom_y
		if (@sprites.is_a?(Hash))
			@sprites.each_value {|sprite| sprite.zoom_y += relValue}
		else
			@sprites.each {|sprite| sprite.zoom_y += relValue}
		end
		@zoom_y = value
	end
	
	def angle=(value)
		relValue = value - @angle
		if (@sprites.is_a?(Hash))
			@sprites.each_value {|sprite| sprite.angle += relValue}
		else
			@sprites.each {|sprite| sprite.angle += relValue}
		end
		@angle = value
	end
	
	def mirror=(value)
		if (@sprites.is_a?(Hash))
			@sprites.each_value {|sprite| sprite.mirror = @mirror}
		else
			@sprites.each {|sprite| sprite.mirror = @mirror}
		end
		@mirror = value
	end
	
	def bush_depth=(value)
		relValue = value - @bush_depth
		if (@sprites.is_a?(Hash))
			@sprites.each_value {|sprite| sprite.bush_depth += relValue}
		else
			@sprites.each {|sprite| sprite.bush_depth += relValue}
		end
		@bush_depth = value
	end
	
	def opacity=(value)
		relValue = value - @opacity
		if (@sprites.is_a?(Hash))
			@sprites.each_value {|sprite| sprite.opacity += relValue}
		else
			@sprites.each {|sprite| sprite.opacity += relValue}
		end
		@opacity = value
	end
	
	def blend_type=(value)
		if (@sprites.is_a?(Hash))
			@sprites.each_value {|sprite| sprite.blend_type = @blend_type}
		else
			@sprites.each {|sprite| sprite.blend_type = @blend_type}
		end
		@blend_type = value
	end
	
	def color=(value)
		if (@sprites.is_a?(Hash))
			@sprites.each_value {|sprite| sprite.color = @color}
		else
			@sprites.each {|sprite| sprite.color = @color}
		end
		@color = value
	end
	
	def tone=(value)
		if (@sprites.is_a?(Hash))
			@sprites.each_value {|sprite| sprite.tone = @tone}
		else
			@sprites.each {|sprite| sprite.tone = @tone}
		end
		@tone = value
	end
	
	# NB: Always use the same number of arguments for each method
	def method(method,*args)
		index = 0
		relativeParams = []
		args.each do |arg|
			if arg.is_a?(IgnoreArg)
				relativeParams.push(arg.value)
			else
				paramName = method + index.to_s
				@params[paramName] = 0 if @params[paramName] == nil
				relativeParams.push(arg - @params[paramName])
				@params[paramName] = arg
				index += 1
			end
		end
		if (@sprites.is_a?(Hash))
			@sprites.each_value {|sprite| sprite.send(method.to_sym,*relativeParams)}
		else
			@sprites.each {|sprite| sprite.send(method.to_sym,*relativeParams)}
		end
	end
	
	# Use this method if the starting value of a relative argument is not 0
	def setStartingArgValue(method,position,value)
		@params[method + index.to_s] = value
	end
end
