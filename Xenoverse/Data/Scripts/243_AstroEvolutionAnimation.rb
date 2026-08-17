def pbAstroEvolution(species)
    evo=PokemonEvolutionScene.new
    pokemon = PokeBattle_Pokemon.new(species,10,$Trainer)
    newspecies = PokeBattle_Pokemon.new(species,10,$Trainer)
    newspecies.forcedForm = 3
    evo.pbStartAstroScreen(pokemon,newspecies)
    evo.pbAstroEvolution
    evo.pbEndScreen
end
  
def pbGetFirstItem()
  echo $Trainer.party[0].item
end