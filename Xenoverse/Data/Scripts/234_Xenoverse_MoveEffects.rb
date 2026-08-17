#===============================================================================
# REMINDER: all move effects from here should use function codes from 133 onwards
# unless they're overrides
#===============================================================================
################################################################################
# OHKO for ABGUILLOTINE
################################################################################
class PokeBattle_Move_133 < PokeBattle_Move
	def pbAccuracyCheck(attacker,opponent)
		return true
	end
	
	def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
		damage=pbEffectFixedDamage(opponent.totalhp,attacker,opponent,hitnum,alltargets,showanimation)
		if opponent.isFainted?
			@battle.pbDisplay(_INTL("It's a one-hit KO!"))
		end
		return damage
	end
end
################################################################################
# Starburst (astro move effect)
#   -changes category based on highest damage
################################################################################
class PokeBattle_Move_134 < PokeBattle_Move
	def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
		@category=1
		damageSpec=pbCalcDamage(attacker,opponent)
		@category=0
		damagePhys=pbCalcDamage(attacker,opponent)
		if damagePhys>damageSpec
			echoln "Stronger physical"
			@category=0
			damage = damagePhys
		else
			echoln "Stronger special"
			@category=1
			damage = damageSpec
		end
		if opponent.damagestate.typemod!=0
			pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
		end
		damage=pbReduceHPDamage(damage,attacker,opponent)
		pbEffectMessages(attacker,opponent)
		pbOnDamageLost(damage,attacker,opponent)
		return damage
	end
end
################################################################################
# Astral Lance
#   -can't miss + critical hit assured
################################################################################
class PokeBattle_Move_135 < PokeBattle_Move
	def pbAccuracyCheck(attacker,opponent)
		return true
	end
	def pbIsCritical?(attacker,opponent)
		return true
	end
end
################################################################################
# Increases the user's and its ally's Defense and Special Defense by 1 stage
# each, if they have Plus or Minus. (Magnetic Flux)
################################################################################
class PokeBattle_Move_136 < PokeBattle_Move
	def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
		didsomething=false
		for i in [attacker,attacker.pbPartner]
			next if !i || i.fainted?
			next if !i.hasWorkingAbility(:PLUS) && !i.hasWorkingAbility(:MINUS)
			next if !i.pbCanIncreaseStatStage?(PBStats::DEFENSE,false)&&#attacker,false,self) &&
			!i.pbCanIncreaseStatStage?(PBStats::SPDEF,false)#attacker,false,self)
			pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation) if !didsomething
			didsomething=true
			showanim=true
			if i.pbCanIncreaseStatStage?(PBStats::DEFENSE,false)#attacker,false,self)
				i.pbIncreaseStat(PBStats::DEFENSE,1,false,showanim)#attacker,false,self,showanim)
				showanim=false
			end
			if i.pbCanIncreaseStatStage?(PBStats::SPDEF,false)#attacker,false,self)
				i.pbIncreaseStat(PBStats::SPDEF,1,false,showanim)#attacker,false,self,showanim)
				showanim=false
			end
		end
		if !didsomething
			@battle.pbDisplay(_INTL("But it failed!"))
			return -1
		end
		return 0
	end
end
################################################################################
# Celebrate
################################################################################
class PokeBattle_Move_138 < PokeBattle_Move	
	def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
		pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
		@battle.pbDisplay(_INTL("Congratulations, {1}!",$Trainer.name))
		return 0
	end
end
################################################################################
# Nuzzle
################################################################################
class PokeBattle_Move_139 < PokeBattle_Move	
	def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
		ex = super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
		return -1 if !opponent.pbCanParalyze?(true)
		typemod=pbTypeModifier(@type,attacker,opponent)
		if typemod==0
			@battle.pbDisplay(_INTL("It doesn't affect {1}...",opponent.pbThis(true)))
			return -1
		end
		# pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
		opponent.pbParalyze(attacker)
		@battle.pbDisplay(_INTL("{1} is paralyzed!  It may be unable to move!",opponent.pbThis))
		return 0
	end
end
##########################################################################
# Decreases the target's Attack and Special Attack by 1 stage each. (Noble Roar)
################################################################################
class PokeBattle_Move_13A < PokeBattle_Move
	def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
		# Replicates def pbCanReduceStatStage? so that certain messages aren't shown
		# multiple times
		if opponent.effects[PBEffects::Substitute]>0 && !ignoresSubstitute?(attacker)
			@battle.pbDisplay(_INTL("{1}'s attack missed!",attacker.pbThis))
			return -1
		end
		if opponent.pbTooLow?(PBStats::ATTACK) &&
			opponent.pbTooLow?(PBStats::SPATK)
			@battle.pbDisplay(_INTL("{1}'s stats won't go any lower!",opponent.pbThis))
			return -1
		end
		if opponent.pbOwnSide.effects[PBEffects::Mist]>0
			@battle.pbDisplay(_INTL("{1} is protected by Mist!",opponent.pbThis))
			return -1
		end
		if !attacker.hasMoldBreaker
			if opponent.hasWorkingAbility(:CLEARBODY) ||
				opponent.hasWorkingAbility(:WHITESMOKE)
				@battle.pbDisplay(_INTL("{1}'s {2} prevents stat loss!",opponent.pbThis,
						PBAbilities.getName(opponent.ability)))
				return -1
			end
		end
		pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
		ret=-1; showanim=true
		if !attacker.hasMoldBreaker && opponent.hasWorkingAbility(:HYPERCUTTER)
			abilityname=PBAbilities.getName(opponent.ability)
			@battle.pbDisplay(_INTL("{1}'s {2} prevents Attack loss!",opponent.pbThis,abilityname))
		elsif opponent.pbReduceStat(PBStats::ATTACK,1,false,showanim)#attacker,false,self,showanim)
			ret=0; showanim=false
		end
		if opponent.pbReduceStat(PBStats::SPATK,1,false,showanim)#attacker,false,self,showanim)
			ret=0; showanim=false
		end
		return ret
	end
end
################################################################################
# Heals the user for an amount equal to the target's effective Attack stat
# Lowers the target's Attack by 1 stage
################################################################################
class PokeBattle_Move_13B < PokeBattle_Move
	def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
		if attacker.effects[PBEffects::HealBlock]>0
			bob="heal"
			bob=_INTL("use {1}",name) if !opponent.pbCanReduceStatStage?(PBStats::ATTACK,false)#true,false,attacker)
			@battle.pbDisplay(_INTL("{1} can't {2} because of Heal Block!",attacker.pbThis,bob))
			return -1 if !opponent.pbCanReduceStatStage?(PBStats::ATTACK,false)#true,false,attacker)
		elsif attacker.hp==attacker.totalhp
			@battle.pbDisplay(_INTL("{1}'s HP is full!",attacker.pbThis))
			return -1 if !opponent.pbCanReduceStatStage?(PBStats::ATTACK,false)#true,false,attacker)
		else
			if opponent.pbCanReduceStatStage?(PBStats::ATTACK,false)
				oatk=opponent.attack
				attacker.pbRecoverHP(oatk,true)
				@battle.pbDisplay(_INTL("{1}'s HP was restored.",attacker.pbThis))
			else
				@battle.pbDisplay(_INTL("But it failed!"))
			end
		end
		if opponent.pbCanReduceStatStage?(PBStats::ATTACK,true)#true,false,attacker)
			opponent.pbReduceStat(PBStats::ATTACK,1,true)#,true,false,attacker)
		end
		return 0
	end
end
################################################################################
# Decreases the target's Special Attack by 2 stages. (Eerie Impulse)
################################################################################
class PokeBattle_Move_13D < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
		echoln "args #{attacker} #{opponent}"
    return super(attacker,opponent,hitnum,alltargets,showanimation) if pbIsDamaging?
    return -1 if pbTypeImmunityByAbility(pbType(@type,attacker,opponent),attacker,opponent)
    return -1 if !opponent.pbCanReduceStatStage?(PBStats::SPATK,false)#attacker,true,self)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=opponent.pbReduceStat(PBStats::SPATK,2,false)#attacker,false,self)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    if opponent.pbCanReduceStatStage?(PBStats::SPATK,false)#attacker,false,self)
      opponent.pbReduceStat(PBStats::SPATK,2,false)#attacker,false,self)
    end
  end
end

################################################################################
# Decreases the Attack, Special Attack and Speed of all poisoned opponents by 1
# stage each. (Venom Drench)
################################################################################
class PokeBattle_Move_140 < PokeBattle_Move
	def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
		didsomething=false
		for i in [attacker.pbOpposing1,attacker.pbOpposing2]
			echoln i.status
			echoln i.status != PBStatuses::POISON
			echoln !i.status== PBStatuses::POISON
			next if !i || i.fainted?
			next if i.status != PBStatuses::POISON
			next if !i.pbCanReduceStatStage?(PBStats::ATTACK,false)&&#attacker,false,self) &&
			!i.pbCanReduceStatStage?(PBStats::SPATK,false)&&#attacker,false,self) &&
			!i.pbCanReduceStatStage?(PBStats::SPEED,false)#attacker,false,self)
			pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation) if !didsomething
			didsomething=true
			showanim=true
			if i.pbCanReduceStatStage?(PBStats::ATTACK,true)#attacker,false,self)
				i.pbReduceStat(PBStats::ATTACK,1,true)#attacker,false,self,showanim)
				showanim=false
			end
			if i.pbCanReduceStatStage?(PBStats::SPATK,true)#attacker,false,self)
				i.pbReduceStat(PBStats::SPATK,1,true)#attacker,false,self,showanim)
				showanim=false
			end
			if i.pbCanReduceStatStage?(PBStats::SPEED,true)#attacker,false,self)
				i.pbReduceStat(PBStats::SPEED,1,true)#attacker,false,self,showanim)
				showanim=false
			end
		end
		if !didsomething
			@battle.pbDisplay(_INTL("But it failed!"))
			return -1
		end
		return 0
	end
end
################################################################################
# Reverses all stat changes of the target. (Topsy-Turvy)
################################################################################
class PokeBattle_Move_141 < PokeBattle_Move
	def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
		nonzero=false
		for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,
				PBStats::SPATK,PBStats::SPDEF,PBStats::ACCURACY,PBStats::EVASION]
			if opponent.stages[i]!=0
				nonzero=true; break
			end
		end
		if !nonzero
			@battle.pbDisplay(_INTL("But it failed!"))
			return -1
		end
		pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
		for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,
				PBStats::SPATK,PBStats::SPDEF,PBStats::ACCURACY,PBStats::EVASION]
			opponent.stages[i]*=-1
		end
		@battle.pbDisplay(_INTL("{1}'s stats were reversed!",opponent.pbThis))
		return 0
	end
end
################################################################################
# Gives target the Ghost type. (Trick-or-Treat)
################################################################################
class PokeBattle_Move_142 < PokeBattle_Move
	def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
		if (opponent.effects[PBEffects::Substitute]>0 && !ignoresSubstitute?(attacker)) ||
			!hasConst?(PBTypes,:GHOST) || opponent.pbHasType?(:GHOST) ||
			isConst?(opponent.ability,PBAbilities,:MULTITYPE)
			@battle.pbDisplay(_INTL("But it failed!"))  
			return -1
		end
		pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
		opponent.effects[PBEffects::Type3]=getConst(PBTypes,:GHOST)
		typename=PBTypes.getName(getConst(PBTypes,:GHOST))
		@battle.pbDisplay(_INTL("{1} transformed into the {2} type!",opponent.pbThis,typename))
		return 0
	end
end
################################################################################
# Gives target the Grass type. (Forest's Curse)
################################################################################
class PokeBattle_Move_143 < PokeBattle_Move
	def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
		if opponent.effects[PBEffects::Substitute]>0 && !ignoresSubstitute?(attacker)
			@battle.pbDisplay(_INTL("But it failed!"))  
			return -1
		end
		return -1 if pbTypeImmunityByAbility(pbType(@type,attacker,opponent),attacker,opponent)
		if opponent.effects[PBEffects::LeechSeed]>=0
			@battle.pbDisplay(_INTL("{1} evaded the attack!",opponent.pbThis))
			return -1
		end
		if !hasConst?(PBTypes,:GRASS) || opponent.pbHasType?(:GRASS) ||
			isConst?(opponent.ability,PBAbilities,:MULTITYPE)
			@battle.pbDisplay(_INTL("But it failed!"))  
			return -1
		end
		pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
		opponent.effects[PBEffects::Type3]=getConst(PBTypes,:GRASS)
		typename=PBTypes.getName(getConst(PBTypes,:GRASS))
		@battle.pbDisplay(_INTL("{1} transformed into the {2} type!",opponent.pbThis,typename))
		return 0
	end
end
################################################################################
# Damage is multiplied by Flying's effectiveness against the target. Does double
# damage and has perfect accuracy if the target is Minimized. (Flying Press)
################################################################################
class PokeBattle_Move_144 < PokeBattle_Move
	def pbModifyDamage(damagemult,attacker,opponent)
		type=getConst(PBTypes,:FLYING) || -1
		if type>=0
			mult=PBTypes.getCombinedEffectiveness(type,
				opponent.type1,opponent.type2,opponent.effects[PBEffects::Type3])
			return ((damagemult*mult)/8).round
		end
		return damagemult
	end
	
	def pbEffectMessages(attacker,opponent,ignoretype=false)
		if opponent.damagestate.critical
			@battle.pbDisplay(_INTL("Un colpo critico!"))
		end
		if !pbIsMultiHit
			mult = PBTypes.getCombinedEffectiveness(getConst(PBTypes,:FLYING),
				opponent.type1,opponent.type2,opponent.effects[PBEffects::Type3])
			if opponent.damagestate.typemod>8 || mult>8#>4
				@battle.pbDisplay(_INTL("È superefficace!"))
			elsif (opponent.damagestate.typemod>=1 && opponent.damagestate.typemod<8) && (mult>=1 && mult<8)#<4
				@battle.pbDisplay(_INTL("Non è molto efficace..."))
			end
		end
		if opponent.damagestate.endured
			@battle.pbDisplay(_INTL("{1} endured the hit!",opponent.pbThis))
		elsif opponent.damagestate.sturdy
			@battle.pbDisplay(_INTL("{1} hung on with Sturdy!",opponent.pbThis))
		elsif opponent.damagestate.focussashused
			@battle.pbDisplay(_INTL("{1} hung on using its Focus Sash!",opponent.pbThis))
		elsif opponent.damagestate.focusbandused
			@battle.pbDisplay(_INTL("{1} hung on using its Focus Band!",opponent.pbThis))
		end
	end
	
	def tramplesMinimize?(param=1)
		return true if param==1 && USENEWBATTLEMECHANICS # Perfect accuracy
		return true if param==2 # Double damage
		return false
	end
end
#===============================================================================
# User is protected against damaging moves this round. Decreases the Attack of
# the user of a stopped contact move by 2 stages. (King's Shield)
#===============================================================================
class PokeBattle_Move_14B < PokeBattle_Move
	def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
		if attacker.effects[PBEffects::KingsShield]
			@battle.pbDisplay(_INTL("But it failed!"))
			return -1
		end
		ratesharers=[
			0xAA,   # Detect, Protect
			0xAB,   # Quick Guard
			0xAC,   # Wide Guard
			0xE8,   # Endure
			0x14B,  # King's Shield
			0x14C,   # Spiky Shield
			0x173    # Baneful Bunker
		]
		if !ratesharers.include?(PBMoveData.new(attacker.previousMove).function)
			attacker.effects[PBEffects::ProtectRate]=1
		end
		unmoved=false
		for poke in @battle.battlers
			next if poke.index==attacker.index
			if @battle.choices[poke.index][0]==1 && # Chose a move
				!poke.hasMovedThisRound?
				unmoved=true; break
			end
		end
		if !unmoved ||
			(USENEWBATTLEMECHANICS &&
				@battle.pbRandom(65536)>=(65536/attacker.effects[PBEffects::ProtectRate]).floor)
			attacker.effects[PBEffects::ProtectRate]=1
			@battle.pbDisplay(_INTL("But it failed!"))
			return -1
		end
		pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
		attacker.effects[PBEffects::KingsShield]=true
		attacker.effects[PBEffects::ProtectRate]*=2
		@battle.pbDisplay(_INTL("{1} protected itself!",attacker.pbThis))
		return 0
	end
end



#===============================================================================
# User is protected against moves that target it this round. Damages the user of
# a stopped contact move by 1/8 of its max HP. (Spiky Shield)
#===============================================================================
class PokeBattle_Move_14C < PokeBattle_Move
	def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
		if attacker.effects[PBEffects::SpikyShield]
			@battle.pbDisplay(_INTL("But it failed!"))
			return -1
		end
		ratesharers=[
			0xAA,   # Detect, Protect
			0xAB,   # Quick Guard
			0xAC,   # Wide Guard
			0xE8,   # Endure
			0x14B,  # King's Shield
			0x14C,   # Spiky Shield
			0x173    # Baneful Bunker
		]
		if !ratesharers.include?(PBMoveData.new(attacker.previousMove).function)
			attacker.effects[PBEffects::ProtectRate]=1
		end
		unmoved=false
		for poke in @battle.battlers
			next if poke.index==attacker.index
			if @battle.choices[poke.index][0]==1 && # Chose a move
				!poke.hasMovedThisRound?
				unmoved=true; break
			end
		end
		if !unmoved ||
			@battle.pbRandom(65536)>=(65536/attacker.effects[PBEffects::ProtectRate]).floor
			attacker.effects[PBEffects::ProtectRate]=1
			@battle.pbDisplay(_INTL("But it failed!"))
			return -1
		end
		pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
		attacker.effects[PBEffects::SpikyShield]=true
		attacker.effects[PBEffects::ProtectRate]*=2
		@battle.pbDisplay(_INTL("{1} protected itself!",attacker.pbThis))
		return 0
	end
end
################################################################################
# Two turn attack. Skips first turn, increases the user's Special Attack,
# Special Defense and Speed by 2 stages each second turn. (Geomancy)
################################################################################
class PokeBattle_Move_14E < PokeBattle_Move
	def pbTwoTurnAttack(attacker)
		@immediate=false
		if !@immediate && attacker.hasWorkingItem(:POWERHERB)
			@immediate=true
		end
		return false if @immediate
		return attacker.effects[PBEffects::TwoTurnAttack]==0
	end
	
	def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
		if @immediate || attacker.effects[PBEffects::TwoTurnAttack]>0
			pbShowAnimation(@id,attacker,opponent,1,alltargets,showanimation) # Charging anim
			@battle.pbDisplay(_INTL("{1} is absorbing power!",attacker.pbThis))
		end
		if @immediate
			@battle.pbCommonAnimation("UseItem",attacker,nil)
			@battle.pbDisplay(_INTL("{1} became fully charged due to its Power Herb!",attacker.pbThis))
			attacker.pbConsumeItem
		end
		return 0 if attacker.effects[PBEffects::TwoTurnAttack]>0
		if !attacker.pbCanIncreaseStatStage?(PBStats::SPATK,false)&&#attacker,false,self) &&
			!attacker.pbCanIncreaseStatStage?(PBStats::SPDEF,false)&&#,attacker,false,self) &&
			!attacker.pbCanIncreaseStatStage?(PBStats::SPEED,false)#,attacker,false,self)
			@battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",attacker.pbThis))
			return -1
		end
		pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
		showanim=true
		if attacker.pbCanIncreaseStatStage?(PBStats::SPATK,false)#attacker,false,self)
			attacker.pbIncreaseStat(PBStats::SPATK,2,false)#attacker,false,self,showanim)
			showanim=false
		end
		if attacker.pbCanIncreaseStatStage?(PBStats::SPDEF,false)#attacker,false,self)
			attacker.pbIncreaseStat(PBStats::SPDEF,2,false)#attacker,false,self,showanim)
			showanim=false
		end
		if attacker.pbCanIncreaseStatStage?(PBStats::SPEED,false)#attacker,false,self)
			attacker.pbIncreaseStat(PBStats::SPEED,2,false)#attacker,false,self,showanim)
			showanim=false
		end
		return 0
	end
end
################################################################################
# If this move KO's the target, increases the user's Attack by 2 stages.
# (Fell Stinger)
################################################################################
class PokeBattle_Move_150 < PokeBattle_Move
	def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
		ret=super(attacker,opponent,hitnum,alltargets,showanimation)
		if opponent.damagestate.calcdamage>0 && opponent.fainted?
			if attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,true)#attacker,false,self)
				attacker.pbIncreaseStat(PBStats::ATTACK,2,true)#attacker,false,self)
			end
		end
		return ret
	end
end
################################################################################
# Entry hazard. Lays stealth rocks on the opposing side. (Sticky Web)
################################################################################
class PokeBattle_Move_153 < PokeBattle_Move
	def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
		if attacker.pbOpposingSide.effects[PBEffects::StickyWeb]
			@battle.pbDisplay(_INTL("But it failed!"))
			return -1
		end
		magicbounced = false
		for i in 0...@battle.battlers.length
			magicbounced = true if attacker.pbIsOpposing?(@battle.battlers[i].index) && @battle.battlers[i].hasWorkingAbility(:MAGICBOUNCE)
		end
		if magicbounced  #magic bounce
			pbShowAnimation(@id,attacker,attacker,hitnum,alltargets,showanimation)
			attacker.pbOpposingSide.effects[PBEffects::StickyWeb]=true
			if !@battle.pbIsOpposing?(attacker.index)
				@battle.pbDisplay(_INTL("A sticky web has been laid out beneath your team's feet!"))
			else
				@battle.pbDisplay(_INTL("A sticky web has been laid out beneath the opposing team's feet!"))
			end
		else
			pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
			attacker.pbOpposingSide.effects[PBEffects::StickyWeb]=true
			if !@battle.pbIsOpposing?(attacker.index)
				@battle.pbDisplay(_INTL("A sticky web has been laid out beneath the opposing team's feet!"))
			else
				@battle.pbDisplay(_INTL("A sticky web has been laid out beneath your team's feet!"))
			end
		end
		return 0
	end
end
################################################################################
# Heals the target status condition, and if it doesn't fail, it heals the user.
#	(Purify)
################################################################################
class PokeBattle_Move_15B < PokeBattle_Move
	def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=false)
		if opponent.status!=PBStatuses::BURN &&
			opponent.status!=PBStatuses::POISON &&
			opponent.status!=PBStatuses::PARALYSIS &&
			opponent.status!=PBStatuses::SLEEP &&
			opponent.status!=PBStatuses::FROZEN
			@battle.pbDisplay(_INTL("But it failed!"))
			return -1
		else
			t=opponent.status
			opponent.pbCureStatus(false)
			if t==PBStatuses::BURN
				@battle.pbDisplay(_INTL("{1}'s Purify cured {2}'s burn!",attacker.pbThis,opponent.pbThis))  
			elsif t==PBStatuses::POISON
				@battle.pbDisplay(_INTL("{1}'s Purify cured {2}'s poison!",attacker.pbThis,opponent.pbThis))  
			elsif t==PBStatuses::PARALYSIS
				@battle.pbDisplay(_INTL("{1}'s Purify cured {2}'s paralysis",attacker.pbThis,opponent.pbThis))
			elsif t==PBStatuses::SLEEP
				@battle.pbDisplay(_INTL("{1}'s Purify woke {2} up!",attacker.pbThis,opponent.pbThis))
			elsif t==PBStatuses::FROZEN
				@battle.pbDisplay(_INTL("{1}'s Purify thawed {2} out!",attacker.pbThis,opponent.pbThis))
			end
			pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
			attacker.pbRecoverHP(((attacker.totalhp+1)/2).floor,true)
			@battle.pbDisplay(_INTL("{1}'s HP was restored.",attacker.pbThis))
			return 0
		end
	end
end
################################################################################
# Fails unless user has consumed a berry at some point. (Belch)
################################################################################
class PokeBattle_Move_158 < PokeBattle_Move
	def pbMoveFailed(attacker,opponent)
		return !attacker.pokemon || !attacker.pokemon.belch
	end
end
################################################################################
# Stomping Tantrum
################################################################################
class PokeBattle_Move_162 < PokeBattle_Move
	def pbBaseDamage(basedmg,attacker,opponent)
		return basedmg*2 if attacker.effects[PBEffects::LastMoveFailed]
		return basedmg
	end
end
################################################################################
# For 5 rounds, lowers power of physical and special attacks against the user's side. 
# (Aurora Veil)
################################################################################
class PokeBattle_Move_167 < PokeBattle_Move
	def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
		if @battle.pbWeather==PBWeather::HAIL
			pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
			attacker.pbOwnSide.effects[PBEffects::LightScreen]+=5
			attacker.pbOwnSide.effects[PBEffects::Reflect]+=5
			if !@battle.pbIsOpposing?(attacker.index)
				@battle.pbDisplay(_INTL("Aurora Veil raised your team's defenses!"))
			else
				@battle.pbDisplay(_INTL("Aurora Veil raised the opposing team's defenses!"))
			end
		else
			@battle.pbDisplay(_INTL("But it failed!"))
			return -1
		end
		return 0
	end
end
#===============================================================================
# Target cannot use sound-based moves for 2 more rounds. (Throat Chop)
#===============================================================================
class PokeBattle_Move_16C < PokeBattle_Move
	def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
		ret=super(attacker,opponent,hitnum,alltargets,showanimation)
		if opponent.damagestate.calcdamage>0 && !(opponent.fainted? || opponent.damagestate.substitute)
			if opponent.effects[PBEffects::ThroatChop]==0
				@battle.pbDisplay(_INTL("The effects of {1} prevent {2} from using certain moves!",@name,opponent.pbThis(true)))
			end
			opponent.effects[PBEffects::ThroatChop] = 3
		end
		return ret
	end
=begin
	def pbAdditionalEffect(user,target)
		echoln "TRYING TO INFLICT THROATCHOP"
		return if target.fainted? || target.damageState.substitute
		echoln "INFLICTED THROATCHOP"
		if target.effects[PBEffects::ThroatChop]==0
			@battle.pbDisplay(_INTL("The effects of {1} prevent {2} from using certain moves!",@name,target.pbThis(true)))
		end
		target.effects[PBEffects::ThroatChop] = 3
	end
=end
end
################################################################################
# Freezes the target. (Freeze-Dry)
# (Superclass's pbTypeModifier): Effectiveness against Water-type is 2x.
################################################################################
class PokeBattle_Move_16D < PokeBattle_Move
	def pbAdditionalEffect(attacker,opponent)
		return if opponent.damagestate.substitute
		if opponent.pbCanFreeze?(attacker,false,self)
			opponent.pbFreeze
		end
	end
end
################################################################################
# Attacks and makes the attacker lose the fire type. (BurnUp)
################################################################################
class PokeBattle_Move_16E < PokeBattle_Move
	def pbMoveFailed(user,targets)
		if !user.pbHasType?(:FIRE)
			@battle.pbDisplay(_INTL("But it failed!"))
			return true
		end
		return false
	end
	
	def pbEffect(user,target,hitnum=0,alltargets=nil,showanimation=true)
		ret = super(user,target,hitnum,alltargets,showanimation)
		if !user.effects[PBEffects::BurnUp]
			user.effects[PBEffects::BurnUp] = true
			#make the user lose its fire type
			if user.type1==user.type2 #it's only fire type
				user.type1=getConst(PBTypes,:NORMAL)
				user.type2=user.type1
			elsif isConst?(user.type1,PBTypes,:FIRE) #changes only its primary type
				user.type1=getConst(PBTypes,:NORMAL)
			elsif isConst?(user.type2,PBTypes,:FIRE) #loses the type entirely
				user.type2=user.type1
			end
			@battle.scene.pbDisplay(_INTL("{1} burned itself out!",user.pbThis))
			#return 0
		end
		return ret
		#return -1
	end
end
################################################################################
# The hit in the next turn will be a critical hit for sure. (Laser Focus)
################################################################################
class PokeBattle_Move_170 < PokeBattle_Move
	def pbMoveFailed(user,targets)
		if user.effects[PBEffects::LaserFocus]
			@battle.pbDisplay(_INTL("But it failed!"))
			user.effects[PBEffects::LaserFocus]=false if user.effects[PBEffects::LaserFocus]
			return true
		end
		return false
	end
	
	def pbEffect(user,target,hitnum=0,alltargets=nil,showanimation=true)
		return -1 if user.effects[PBEffects::LaserFocus]
		user.effects[PBEffects::LaserFocus]=true
		@battle.pbDisplay(_INTL("{1} concentrated intensely!",user.pbThis))
		return 0
		#return -1
	end
end
#===============================================================================
# This round, target becomes the target of attacks that have single targets.
# (Spotlight)
#===============================================================================
class PokeBattle_Move_171 < PokeBattle_Move
	def pbEffect(user,target,hitnum=0,alltargets=nil,showanimation=true)
		if target.effects[PBEffects::FollowMe] == true
			@battle.pbDisplay(_INTL("But it failed!"))
			return -1
		end
		target.effects[PBEffects::FollowMe] = true
		@battle.pbDisplay(_INTL("{1} became the center of attention!",target.pbThis))
		return 0
	end
end
################################################################################
# Heals user by an amount depending on the weather. (Shore Up)
################################################################################
class PokeBattle_Move_172 < PokeBattle_Move
	def isHealingMove?
		return true
	end
	
	def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
		if attacker.hp==attacker.totalhp
			@battle.pbDisplay(_INTL("{1}'s HP is full!",attacker.pbThis))
			return -1
		end
		hpgain=0
		if @battle.pbWeather==PBWeather::SANDSTORM
			hpgain=(attacker.totalhp*2/3).floor
		else
			hpgain=(attacker.totalhp/2).floor
		end
		pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
		attacker.pbRecoverHP(hpgain,true)
		@battle.pbDisplay(_INTL("{1}'s HP was restored.",attacker.pbThis))
		return 0
	end
end
################################################################################
# User is protected against damaging moves this round. Poisons the 
# user of a stopped contact move. (Baneful Bunker)
################################################################################
class PokeBattle_Move_173 < PokeBattle_Move
	def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
		if attacker.effects[PBEffects::BanefulBunker]
			@battle.pbDisplay(_INTL("But it failed!"))
			return -1
		end
		ratesharers=[
			0xAA,   # Detect, Protect
			0xAB,   # Quick Guard
			0xAC,   # Wide Guard
			0xE8,   # Endure
			0x14B,  # King's Shield
			0x14C,   # Spiky Shield
			0x173    # Baneful Bunker
		]
		if !ratesharers.include?(PBMoveData.new(attacker.previousMove).function)
			attacker.effects[PBEffects::ProtectRate]=1
		end
		unmoved=false
		for poke in @battle.battlers
			next if poke.index==attacker.index
			if @battle.choices[poke.index][0]==1 && # Chose a move
				!poke.hasMovedThisRound?
				unmoved=true; break
			end
		end
		if !unmoved || @battle.pbRandom(65536)>=(65536/attacker.effects[PBEffects::ProtectRate]).floor
			attacker.effects[PBEffects::ProtectRate]=1
			@battle.pbDisplay(_INTL("But it failed!"))
			return -1
		end
		pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
		attacker.effects[PBEffects::BanefulBunker]=true
		attacker.effects[PBEffects::ProtectRate]*=2
		@battle.pbDisplay(_INTL("{1} protected itself!",attacker.pbThis))
		return 0
	end
end
################################################################################
# Inflicts damage to the target. If the target is burned, the burn is healed.
# (Sparkling Aria)
################################################################################
class PokeBattle_Move_174 < PokeBattle_Move
	def pbEffectAfterHit(attacker,opponent,turneffects)
		if !opponent.isFainted? && opponent.damagestate.calcdamage>0 &&
			!opponent.damagestate.substitute && opponent.status==PBStatuses::BURN
			opponent.pbCureStatus
		end
	end
end
################################################################################
# Helps allies with Minus or Plus increasing Atk and SpAtk
# (Gear Up)
################################################################################
class PokeBattle_Move_175 < PokeBattle_Move
	def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
		didsomething=false
		for i in [attacker,attacker.pbPartner]
			next if !i || i.fainted?
			next if !i.hasWorkingAbility(:PLUS) && !i.hasWorkingAbility(:MINUS)
			next if !i.pbCanIncreaseStatStage?(PBStats::ATTACK,false)&&#attacker,false,self) &&
			!i.pbCanIncreaseStatStage?(PBStats::SPATK,false)#attacker,false,self)
			pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation) if !didsomething
			didsomething=true
			showanim=true
			if i.pbCanIncreaseStatStage?(PBStats::ATTACK,false)#attacker,false,self)
				i.pbIncreaseStat(PBStats::ATTACK,1,false,showanim)#attacker,false,self,showanim)
				showanim=false
			end
			if i.pbCanIncreaseStatStage?(PBStats::SPATK,false)#attacker,false,self)
				i.pbIncreaseStat(PBStats::SPATK,1,false,showanim)#attacker,false,self,showanim)
				showanim=false
			end
		end
		if !didsomething
			@battle.pbDisplay(_INTL("But it failed!"))
			return -1
		end
		return 0
	end
end
################################################################################
# Counters a physical move used against the user this round, with an explosion.
# (Shell Trap)
################################################################################
class PokeBattle_Move_176 < PokeBattle_Move
	def pbAddTarget(targets,attacker)
    if attacker.effects[PBEffects::ShellTrap]>=0 &&
       attacker.pbIsOpposing?(attacker.effects[PBEffects::ShellTrap])
      if !attacker.pbAddTarget(targets,@battle.battlers[attacker.effects[PBEffects::ShellTrap]])
        attacker.pbRandomTarget(targets)
      end
    end
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.effects[PBEffects::Counter]<=0 || !opponent
      @battle.pbDisplay(_INTL("Shell Trap failed!"))
      return -1
    end
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)#pbEffectFixedDamage(150,attacker,opponent,hitnum,alltargets,showanimation)
    return ret
  end
end
################################################################################
# Steals target's stat boosts, then attacks
################################################################################
class PokeBattle_Move_177 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.stages[1]>0 || opponent.stages[2]>0 || opponent.stages[3]>0 ||
       opponent.stages[4]>0 || opponent.stages[5]>0 || opponent.stages[6]>0 ||
       opponent.stages[7]>0
      stolenstats=[0,0,0,0,0,0,0,0]
      for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,PBStats::SPATK,
								PBStats::SPDEF,PBStats::ACCURACY,PBStats::EVASION]
        stolenstats[i]=opponent.stages[i]*1 if opponent.stages[i]>0
        opponent.stages[i]=0 if opponent.stages[i]>0
      end
      @battle.pbDisplay(_INTL("{1} stole {2}'s stat boosts!",attacker.pbThis,opponent.pbThis(true)))
      showanim=true
      for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,PBStats::SPATK,
								PBStats::SPDEF,PBStats::ACCURACY,PBStats::EVASION]
        if attacker.pbCanIncreaseStatStage?(i,false) && stolenstats[i]>0
          attacker.pbIncreaseStat(i,stolenstats[i],showanim,true)
          showanim=false
        end
      end
    end
    # actually attack now
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    return ret
  end
end
################################################################################
# All Normal-type moves become Electric-type for the rest of the round.
# (Ion Deluge)
################################################################################
class PokeBattle_Move_178 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    unmoved=false
    for poke in @battle.battlers
      next if poke.index==attacker.index
      if @battle.choices[poke.index][0]==1 && # Chose a move
         !poke.hasMovedThisRound?
        unmoved=true; break
      end
    end
    if !unmoved || @battle.field.effects[PBEffects::IonDeluge]
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    @battle.field.effects[PBEffects::IonDeluge]=true
    @battle.pbDisplay(_INTL("The Ion Deluge started!"))
    return 0
  end
end
################################################################################
# Target can no longer switch out or flee, as long as the user remains active.
################################################################################
class PokeBattle_Move_179 < PokeBattle_Move
  def pbEffectAfterHit(attacker,opponent,turneffects)
		if @basedamage <=0
			if opponent.effects[PBEffects::MeanLook]>=0 ||
				 opponent.effects[PBEffects::Substitute]>0
				#@battle.pbDisplay(_INTL("But it failed!"))
				return
			end
		end
    pbShowAnimation(@id,attacker,opponent,0,nil,true)
    opponent.effects[PBEffects::MeanLook]=attacker.index
    @battle.pbDisplay(_INTL("{1} can't escape now!",opponent.pbThis))
    return 
  end
end
################################################################################
# Inflicts damage and lower the target attacks by one stage.
################################################################################
class PokeBattle_Move_180 < PokeBattle_Move
	def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
		ex = super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
		return -1 if !opponent.pbCanReduceStatStage?(PBStats::ATTACK,true)
		ret=opponent.pbReduceStat(PBStats::ATTACK,1,false)
		return ret ? 0 : -1
	end
end
################################################################################
# Inflicts damage and lowers the target special attack by one stage. (Snarl)
################################################################################
class PokeBattle_Move_181 < PokeBattle_Move
	def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
		ex = super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
		return -1 if !opponent.pbCanReduceStatStage?(PBStats::SPATK,true)
		# pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
		ret=opponent.pbReduceStat(PBStats::SPATK,1,false)
		return ret ? 0 : -1
	end
	
	def pbAdditionalEffect(attacker,opponent)
		if opponent.pbCanReduceStatStage?(PBStats::SPATK,false)
			opponent.pbReduceStat(PBStats::SPATK,1,false)
		end
		return true
	end
end
################################################################################
# Randomly transforms into an X Pokemon. (X Transform)
################################################################################
class PokeBattle_Move_205 < PokeBattle_Move
	def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
		blacklist=[]
		if attacker.effects[PBEffects::Transform]
			@battle.pbDisplay(_INTL("But it failed!"))
			return -1
		end
		pool = XENODEX.clone
		pool.delete(PBSpecies::MEWTWOX)
		pool.delete(PBSpecies::BISHARPX)
		pool.delete(PBSpecies::RAICHUX)
		pool.delete(PBSpecies::TYRANITARX)
		pool.delete(PBSpecies::SCOVILEX)

		#remove self
		pool.delete(PBSpecies::DITTOX)
		x = PokeBattle_Pokemon.new(pool[@battle.pbRandom(pool.length)],attacker.level,$Trainer)
		#x = PokeBattle_Battler.new(attacker.battle,attacker.index)
		#x.pbInitialize(xp,attacker.index,false)
		pbShowAnimation(@id,attacker,attacker,hitnum,alltargets,true)
		@battle.scene.pbChangePokemon(attacker,x)
		attacker.effects[PBEffects::Transform]=true
		attacker.species=x.species
		attacker.type1=x.type1
		attacker.type2=x.type2
		#    attacker.ability=opponent.ability
		attacker.attack=x.attack
		attacker.defense=x.defense
		attacker.speed=x.speed
		attacker.spatk=x.spatk
		attacker.spdef=x.spdef
		#for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,
		#		PBStats::SPATK,PBStats::SPDEF,PBStats::EVASION,PBStats::ACCURACY]
		#	attacker.stages[i]=x.stages[i]
		#end
		for i in 0...4
			attacker.moves[i]=PokeBattle_Move.pbFromPBMove(
				@battle,PBMove.new(x.moves[i].id))
			attacker.moves[i].pp=5 if attacker.moves[i].pp>5
			attacker.moves[i].totalpp=5 if attacker.moves[i].totalpp>5
		end
		attacker.effects[PBEffects::Disable]=0
		attacker.effects[PBEffects::DisableMove]=0
		@battle.pbDisplay(_INTL("{1} transformed into {2}!",attacker.pbThis,x.name))
		return 0
	end
end
################################################################################
# After being set, it deals 1/10th hp damage to all non-water or poison Pokémon
# on the field. Can be cleared using Defog. (Acid Rain)
################################################################################
class PokeBattle_Move_300 < PokeBattle_Move
	def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
		if @battle.field.effects[PBEffects::AcidRain]
			@battle.pbDisplay(_INTL("But it failed!"))
			return -1
		end
		pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
		@battle.field.effects[PBEffects::AcidRain]=true
		@battle.pbDisplay(_INTL("La Pioggia Acida cade su tutto il campo!"))
		return 0
	end
end
################################################################################
# Weakens Electric, Grass, Fire and Water attacks. (Dragon Endurance)
################################################################################
class PokeBattle_Move_301 < PokeBattle_Move
	def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
		pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
		for i in 0...4
			#To all non-opposing allies
			if !attacker.pbIsOpposing?(i)
				attacker.effects[PBEffects::DragonEndurance]=5
			end
		end
		attacker.effects[PBEffects::DragonEndurance]=5
		@battle.pbDisplay(_INTL("Il tuo team è rafforzato dal Dragoscudo!"))
		return 0
	end
end
################################################################################
# Creates an hazard that lowers the defences of the opponents. (Velvet Scales)
################################################################################
class PokeBattle_Move_302 < PokeBattle_Move
	def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
		if attacker.pbOpposingSide.effects[PBEffects::VelvetScales]
			@battle.pbDisplay(_INTL("But it failed!"))
			return -1
		end
		pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
		attacker.pbOpposingSide.effects[PBEffects::VelvetScales]=true
		if !@battle.pbIsOpposing?(attacker.index)
			@battle.pbDisplay(_INTL("Delle Squame Velliche coprono il campo del tuo avversario!"))
		else
			@battle.pbDisplay(_INTL("Delle Squame Velliche coprono il tuo campo!"))
		end
		return 0
	end
end
################################################################################
# Creates an hazard on your side of the field that heals your team over time.
# (Hawthorns)
################################################################################
class PokeBattle_Move_303 < PokeBattle_Move
	def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
		if attacker.pbOwnSide.effects[PBEffects::Hawthorns]
			@battle.pbDisplay(_INTL("But it failed!"))
			return -1
		end
		pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
		attacker.pbOwnSide.effects[PBEffects::Hawthorns]=true
		if !@battle.pbIsOpposing?(attacker.index)
			@battle.pbDisplay(_INTL("Delle piante di Biancospino coprono il tuo campo!"))
		else
			@battle.pbDisplay(_INTL("Delle piante di Biancospino coprono il campo del tuo avversario!"))
		end
		return 0
	end
end
################################################################################
# Creates an hazard on your opponent's field that increases the enemy speed but 
# lowers their accuracy.
# (Scorched Ashes)
################################################################################
class PokeBattle_Move_304 < PokeBattle_Move
	def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
		if attacker.pbOpposingSide.effects[PBEffects::ScorchedAshes]
			@battle.pbDisplay(_INTL("But it failed!"))
			return -1
		end
		pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
		attacker.pbOpposingSide.effects[PBEffects::ScorchedAshes]=true
		if !@battle.pbIsOpposing?(attacker.index)
			@battle.pbDisplay(_INTL("Delle ceneri arse ricoprono il campo del tuo avversario!"))
		else
			@battle.pbDisplay(_INTL("Delle ceneri arse ricoprono il tuo campo!"))
		end
		return 0
	end
end
################################################################################
# Creates an aura that boosts ANY kind of healing on your side of the field.
# (Benevolence)
################################################################################
class PokeBattle_Move_305 < PokeBattle_Move
	def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
		if attacker.pbOwnSide.effects[PBEffects::Benevolence] > 0
			@battle.pbDisplay(_INTL("But it failed!"))
			return -1
		end
		pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
		attacker.pbOwnSide.effects[PBEffects::Benevolence] = 3 + @battle.pbRandom(3)
		if !@battle.pbIsOpposing?(attacker.index)
			@battle.pbDisplay(_INTL("Un'aura rinvigorente rincuora i tuoi Pokémon!"))
		else
			@battle.pbDisplay(_INTL("Un'aura rinvigorente rincuora i Pokémon del tuo avversario!"))
		end
		return 0
	end
end

################################################################################
# Gives priority to the move your ally will do.
# (Cheering)
################################################################################
class PokeBattle_Move_306 < PokeBattle_Move
	def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
		if attacker.pbPartner.isFainted? ||
			attacker.pbPartner.effects[PBEffects::Cheering]
			@battle.pbDisplay(_INTL("But it failed!"))  
			return -1
		end
		pbShowAnimation(@id,attacker,attacker.pbPartner,hitnum,alltargets,showanimation)
		attacker.pbPartner.effects[PBEffects::Cheering]=true
		@battle.pbDisplay(_INTL("{1} is cheering for {2}!",attacker.pbThis,attacker.pbPartner.pbThis(true)))
		return 0
	end
end

################################################################################
# Weakens Dragon, Fighting, Bug and Dark attacks. 
# (Magic Wall)
################################################################################
class PokeBattle_Move_307 < PokeBattle_Move
	def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
		pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
		for i in 0...4
			#To all non-opposing allies
			if !attacker.pbIsOpposing?(i)
				attacker.effects[PBEffects::MagicWall]=5
			end
		end
		attacker.effects[PBEffects::MagicWall]=5
		@battle.pbDisplay(_INTL("Il tuo team è rafforzato dal Magiscudo!"))
		return 0
	end
end
################################################################################
# Weakens Water, Flying and Fairy attacks.
# (Sound Barrier)
################################################################################
class PokeBattle_Move_308 < PokeBattle_Move
	def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
		pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
		for i in 0...4
			#To all non-opposing allies
			if !attacker.pbIsOpposing?(i)
				attacker.effects[PBEffects::SoundBarrier]=5
			end
		end
		attacker.effects[PBEffects::SoundBarrier]=5
		@battle.pbDisplay(_INTL("Il tuo team è protetto dal Fonoscudo!"))
		return 0
	end
end
################################################################################
# Damage is multiplied by Flying's effectiveness against the target. Does double
# damage and has perfect accuracy if the target is Minimized. (Flavor Test)
################################################################################
class PokeBattle_Move_309 < PokeBattle_Move

	def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
		ret=super(attacker,opponent,hitnum,alltargets,showanimation)
		if opponent.damagestate.calcdamage>0
			hpgain=(attacker.boss ? ((opponent.damagestate.hplost+1)/10) : (opponent.damagestate.hplost+1)/10).floor
			if opponent.hasWorkingAbility(:LIQUIDOOZE)
				attacker.pbReduceHP(hpgain,true)
				@battle.pbDisplay(_INTL("{1} sucked up the liquid ooze!",attacker.pbThis))
			elsif attacker.effects[PBEffects::HealBlock]==0
				hpgain=(hpgain*1.3).floor if attacker.hasWorkingItem(:BIGROOT)
				attacker.pbRecoverHP(hpgain,true)
				@battle.pbDisplay(_INTL("{1} had its energy drained!",opponent.pbThis))
			end
		end
		return ret
	end

	def pbModifyDamage(damagemult,attacker,opponent)
		type=getConst(PBTypes,:ICE) || -1
		if type>=0
			mult=PBTypes.getCombinedEffectiveness(type,
				opponent.type1,opponent.type2,opponent.effects[PBEffects::Type3])
			return ((damagemult*mult)/8).round
		end
		return damagemult
	end
	
	def pbEffectMessages(attacker,opponent,ignoretype=false)
		if opponent.damagestate.critical
			@battle.pbDisplay(_INTL("Un colpo critico!"))
		end
		if !pbIsMultiHit
			mult = PBTypes.getCombinedEffectiveness(getConst(PBTypes,:ICE),
				opponent.type1,opponent.type2,opponent.effects[PBEffects::Type3])
			if opponent.damagestate.typemod>8 || mult>8#>4
				@battle.pbDisplay(_INTL("È superefficace!"))
			elsif (opponent.damagestate.typemod>=1 && opponent.damagestate.typemod<8) && (mult>=1 && mult<8)#<4
				@battle.pbDisplay(_INTL("Non è molto efficace..."))
			end
		end
		if opponent.damagestate.endured
			@battle.pbDisplay(_INTL("{1} endured the hit!",opponent.pbThis))
		elsif opponent.damagestate.sturdy
			@battle.pbDisplay(_INTL("{1} hung on with Sturdy!",opponent.pbThis))
		elsif opponent.damagestate.focussashused
			@battle.pbDisplay(_INTL("{1} hung on using its Focus Sash!",opponent.pbThis))
		elsif opponent.damagestate.focusbandused
			@battle.pbDisplay(_INTL("{1} hung on using its Focus Band!",opponent.pbThis))
		end
	end
	
	def tramplesMinimize?(param=1)
		return true if param==1 && USENEWBATTLEMECHANICS # Perfect accuracy
		return true if param==2 # Double damage
		return false
	end
end
################################################################################
# Fails if the target doesn't have an item. (Poltergeist)
################################################################################
class PokeBattle_Move_320 < PokeBattle_Move#PokeBattle_UnimplementedMove
	def pbMoveFailed(attacker,opponent)
		return false if opponent.item != 0
		return true
	end
end