#===============================================================================
#  Legacy all-target animation bridges
#-------------------------------------------------------------------------------
#  The Elite Battle global selector has no Dragon or Normal all-target animation
#  and otherwise falls through to Tackle. Twister and Swift already have legacy
#  animations in Data/move2anim.dat/PkmnAnimations.rxdata, so use those
#  animations specifically.
#===============================================================================
class PokeBattle_Scene
  def pbMoveAnimationSpecific061(userindex,targetindex,hitnum=0,multihit=false)
    animid=pbFindAnimation(61,userindex,hitnum)
    return false if !animid
    animations=load_data("Data/PkmnAnimations.rxdata")
    animation=animations[animid[0]]
    return false if !animation
    user=@battle.battlers[userindex]
    target=@battle.battlers[targetindex]
    name=PBMoves.getName(61)
    pbSaveShadows {
      if animid[1]
        pbAnimationCore(animation,target,user,true,name)
      else
        pbAnimationCore(animation,user,target,false,name)
      end
    }
    return true
  end

  def pbMoveAnimationSpecific299(userindex,targetindex,hitnum=0,multihit=false)
    animid=pbFindAnimation(299,userindex,hitnum)
    return false if !animid
    animations=load_data("Data/PkmnAnimations.rxdata")
    animation=animations[animid[0]]
    return false if !animation
    user=@battle.battlers[userindex]
    target=@battle.battlers[targetindex]
    name=PBMoves.getName(299)
    pbSaveShadows {
      if animid[1]
        pbAnimationCore(animation,target,user,true,name)
      else
        pbAnimationCore(animation,user,target,false,name)
      end
    }
    return true
  end
end
