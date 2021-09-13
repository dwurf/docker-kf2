class Game
  attr_accessor :maplist

  def initialize(gamehash)
    @maplist = MapList.new(gamehash["maplist"])
  end

  def renderGameConfig()
    template = File.read("LinuxServer-KFGame.ini.erb")
    return ERB.new(template).result(binding)
  end

  def renderEngineConfig()
    template = File.read("LinuxServer-KFEngine.ini.erb")
    return ERB.new(template).result(binding)
  end
end
