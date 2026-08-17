
#===============================================================================
#  Elite Battle system
#    by Luka S.J.
#  
#  additional classes and functions added to calcualte the positions of the
#  scene elements in the battle system.
#  Makes for smoother animation/movement and adds more depth to the system.
#===============================================================================                           
class Vector
  attr_reader :x
  attr_reader :y
  attr_reader :angle
  attr_reader :scale
  attr_reader :x2
  attr_reader :y2
  attr_accessor :zoom1
  attr_accessor :zoom2
  attr_accessor :inc
  attr_accessor :set
  
  def initialize(x=0,y=0,angle=0,scale=1,zoom1=1,zoom2=1)
    @x=x.to_f
    @y=y.to_f
    @angle=angle.to_f
    @scale=scale.to_f
    @zoom1=zoom1.to_f
    @zoom2=zoom2.to_f
    @inc=0.2
    @set=[@x,@y,@scale,@angle,@zoom1,@zoom2]
    @locked=false
    self.calculate
  end
  
  def calculate
    angle=@angle*(Math::PI/180)
    width=Math.cos(angle)*@scale
    height=Math.sin(angle)*@scale
    @x2=@x+width
    @y2=@y-height
  end
  
  def angle=(val)
    @angle=val
    self.calculate
  end
  
  def scale=(val)
    @scale=val
    self.calculate
  end
  
  def x=(val)
    @x=val
    @set[0]=val
    self.calculate
  end
  
  def y=(val)
    @y=val
    @set[1]=val
    self.calculate
  end
  
  def set(x,y,angle,scale,zoom1,zoom2)
    @set=[x,y,angle,scale,zoom1,zoom2]    
  end
  
  def add(field="",amount=0.0)
    case field
    when "x"
      @set[0]=@x+amount
    when "y"
      @set[1]=@y+amount
    when "angle"
      @set[2]=@angle+amount
    when "scale"
      @set[3]=@scale+amount
    when "zoom1"
      @set[4]=@zoom1+amount
    when "zoom2"
      @set[5]=@zoom2+amount
    end
  end
  
  def setXY(x,y)
    @set[0]=x
    @set[1]=y
  end
    
  def locked?
    return @locked
  end
  
  def lock
    @locked=!@locked
  end
  
  def update
    @x+=(@set[0]-@x)*@inc
    @y+=(@set[1]-@y)*@inc
    @angle+=(@set[2]-@angle)*@inc
    @scale+=(@set[3]-@scale)*@inc
    @zoom1+=(@set[4]-@zoom1)*@inc
    @zoom2+=(@set[5]-@zoom2)*@inc
    self.calculate
  end
  
end

def calculateCurve(x1,y1,x2,y2,x3,y3,frames=10)
  output=[]
  curve=[x1,y1,x2,y2,x3,y3,x3,y3]
  step=1.0/frames
  t=0.0
  frames.times do
    point=getCubicPoint2(curve,t)
    output.push([point[0],point[1]])
    t+=step
  end
  return output
end
