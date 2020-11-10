class Map
  attr_accessor :steamworksids,:name,:mapfilename,:screenshot, :partial

  def initialize(maphash)
    @name = maphash["name"] #The human-recognisable map name
    @steamworksids = maphash.key?("steamworksids") ? maphash["steamworksids"] : [] #The steamworks item id

    #The name of the .kfm file
    @mapfilename = maphash.key?("mapfilename") ? maphash["mapfilename"] : @name

    #The screenshot directory for the map select screen preview
    @screenshot = maphash.key?("screenshot") ? maphash["screenshot"] : "UI_MapPreview_TEX.UI_MapPreview_Placeholder"

    @playableInSurvival = maphash.key?("playableInSurvival") ? maphash["playableInSurvival"] : true
    @playableInWeekly = maphash.key?("playableInWeekly") ? maphash["playableInWeekly"] : true
    @playableInVsSurvival = maphash.key?("playableInVsSurvival") ? maphash["playableInVsSurvival"] : true
    @playableInEndless = maphash.key?("playableInEndless") ? maphash["playableInEndless"] : true
    @playableInObjective = maphash.key("playableInObjective") ? maphash["playableInObjective"] : true

    #Map accociation 0 = unused (I think)
    #Map association 1 = custom map
    #Map association 2 = official map
    @mapAssociation = maphash.key?("mapAssociation") ? maphash["mapAssociation"] : 1
  end

  def renderSummary()
    template = %{
[<%= @mapfilename %> KFMapSummary]
MapName=<%= @name %>
MapAssociation=<%= @mapAssociation %>
ScreenshotPathName=<%= @screenshot %>
bPlayableInSurvival=<%= @playableInSurvival %>
bPlayableInWeekly=<%= @playableInWeekly %>
bPlayableInVsSurvival=<%= @playableInVsSurvival %>
bPlayableInEndless=<%= @playableInEndless %>
bPlayableInObjective=<%= @playableInObjective %>
    }
    return ERB.new(template).result(binding)
  end
end

