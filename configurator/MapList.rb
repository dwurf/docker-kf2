class MapList
  
  attr_accessor :maps

  def initialize(maparray)
    @maps = maparray.map do |item|
      Map.new(item)
    end
  end

  def renderSteamworksIds()
    template = %{[OnlineSubsystemSteamworks.KFWorkshopSteamworks]<% for map in @maps %><% for id in map.steamworksids %>
ServerSubscribedWorkshopItems=<%= id %><% end %><% end %>}
    return ERB.new(template).result(binding)
  end

  def renderSummaries()
    template = %{
<% for map in @maps %><%= map.renderSummary %><% end %>
    }
    return ERB.new(template).result(binding)
  end

  def renderMapCycles()
    mapnames = []
    for map in @maps do
      #Add all maps to mapcycle except the KF-Default map. This is not playable.
      if map.name != "KF-Default"
        mapnames.push("\"" + map.name + "\"")
      end
    end
    template = %{
GameMapCycles=(Maps=(<%= mapnames.join(",") %>))
    }
    return ERB.new(template).result(binding)
  end
end
