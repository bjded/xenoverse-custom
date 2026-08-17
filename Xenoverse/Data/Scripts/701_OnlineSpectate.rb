module CableClub  

  def self.handle_spectate(connection,ui)
    if Input.trigger?(Input::L)
      uid = pbEnterText("Target UID",0,50)
      do_spectate(connection,uid,ui) if uid != ""
    end
  end

  def self.do_spectate(connection,target_uid,ui)
    # Spectate code goes here
    connection.send do |writer|
      writer.sym(:getSpectateInfo)
      writer.int(target_uid)
    end
  
    $spectateUID = target_uid
  
    receivedInfo = false
    own_name = ""
    own_type = 0
    own_party = nil
  
    opp_name = ""
    opp_type = 0
    opp_party = nil
  
    battle_type = nil
  
    while (!receivedInfo)
      Graphics.update
      Input.update
      connection.updateExp([:spectateInfo,:disconnect]) do |record|
        case (type = record.sym)
        when :spectateInfo
          battle_type = record.sym
          own_name = record.str
          own_type = record.int
          own_party = parse_party(record)
          opp_name = record.str
          opp_type = record.int
          opp_party = parse_party(record)
          receivedInfo = true
        when :disconnect
          # RIPPE
        end
      end
    end
  
    $Trainer.backupParty  = $Trainer.party.map {|x| x.clone}
    bkName = $Trainer.name
    $Trainer.name = own_name
    $Trainer.party = own_party
    $Trainer.party.each do |pike|
      pike.level = 50
      pike.calcStats
    end
    pbHealAll # Avoids having to transmit damaged state.
    partner_party_clone = opp_party.map {|y| y.clone}
    partner_party_clone.each {|pkmn| 
      pkmn.heal
      pkmn.level = 50
      pkmn.calcStats
    }
  
    
    partner = PokeBattle_Trainer.new(opp_name, opp_type)
    uids = ["",""]
  
    $PokemonGlobal.nextBattleBack = $Trainer.online_battle_bg
    $PokemonGlobal.nextBattleBGM = $Trainer.online_battle_bgm
  
    scene = pbNewBattleScene
    battle = PokeBattle_SpectateCableClub.new(connection, 0, scene, partner_party_clone, partner, uids, ui)
    battle.fullparty1 = battle.fullparty2 = true
    battle.endspeech = ""
    battle.items = []
    battle.internalbattle = false
  
    case battle_type
    when :single
      battle.doublebattle = false
    when :double
      battle.doublebattle = true
    else
      raise "Unknown battle type: #{battle_type}"
    end
    trainerbgm = pbGetTrainerBattleBGM(partner)
    Events.onStartBattle.trigger(nil, nil)
    pbPrepareBattle(battle)
    exc = nil
    $onlinebattle = true
    ui.createBattleTimer
    result = 0
    pbBattleAnimation(trainerbgm, partner.trainertype, partner.name) {
      pbSceneStandby {
        # XXX: Hope we call rand in the same order in both clients...
        begin
          result = battle.pbStartBattle(true)
        rescue Connection::Disconnected => e
          scene.pbEndBattle(0)
          exc = $!
        rescue PokeBattle_Battle::BattleAbortedException => ex
          result = battle.decision
          echoln "result of the battle is #{result}"
        ensure
          $onlinebattle = false
          $Trainer.party = $Trainer.backupParty
          $Trainer.name = bkName
        end
      }
    }
    ui.deleteBattleTimer
    $onlinebattle = false
    @state = :enlisted if battle.disconnected
    $Trainer.party = $Trainer.backupParty
    $Trainer.name = bkName
    raise exc if exc
  end
end