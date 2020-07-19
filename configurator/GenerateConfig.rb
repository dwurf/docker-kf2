require 'erb'
require 'yaml'

require './Game.rb'
require './Map.rb'
require './MapList.rb'

#Generate map list
#Get the official map list then add any custom ones to the end of the array
gameconfig = YAML.load(IO.read("/home/steam/game.yml"))
maplist = YAML.load_file("DefaultMaps.yml")
if gameconfig.key?("custommaps")
  if gameconfig["custommaps"] != []
    puts "Found #{gameconfig["custommaps"].length} custom map configs"
    maplist.concat(gameconfig["custommaps"])
  end
end

gamehash = {
"maplist" => maplist
}

game = Game.new(gamehash)

IO.write("#{ENV['HOME']}/kf2server/KFGame/Config/LinuxServer-KFGame.ini",game.renderGameConfig())
IO.write("#{ENV['HOME']}/kf2server/KFGame/Config/LinuxServer-KFEngine.ini",game.renderEngineConfig())
puts "Wrote Server Config Successfully!"
