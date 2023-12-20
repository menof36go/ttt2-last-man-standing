if SERVER then
  util.AddNetworkString("ttt_lms_result")
  hook.Add("TTTEndRound", "ttt_lms_statistics", function(result)
    net.Start("ttt_lms_result")
    net.WriteString(result)
    net.Broadcast()
  end)
end

if CLIENT then
  local LmsLabel
  local pl = LocalPlayer()
  if not IsValid(pl) then return end
  
  LastInnoStanding = false

  hook.Add("StatisticsDrawGui", "ttt_lms_statistics", function(panel)
    LmsLabel = vgui.Create("DLabel", panel)
    LmsLabel:SetPos(0,0)
    LmsLabel:SetSize(panel:GetWide(), panel:GetTall())
    LmsLabel:SetTextColor(Color(255,255,255))
    LmsLabel:SetFont("StatisticsHudHint")
  end)

  net.Receive("ttt_lms_result",function()
    local result = net.ReadString()
    if (result == pl:GetTeam()) and (LastInnoStanding) and (isfunction(AddYourStatisticsAddon)) then
      pl:SetPData("lms_WonAsLMS", pl:GetPData("lms_WonAsLMS", 0) +1)
    end
    LastInnoStanding = false
  end)

  function LMSStatisticsIntegration(visible)
    LmsLabel:SetVisible(visible)
    LmsLabel:SetText("Times you guessed right that you are on your own: " .. pl:GetPData("lms_GuessedRight", 0) .. "\nYou won a total of " .. pl:GetPData("lms_WonAsLMS", 0) .. " rounds after calling LMS correctly" .. "\n\nTimes you guessed wrong: " .. pl:GetPData("lms_GuessedWrong", 0) .. "\n\n------------------\n\nTimes you revealed yourself: " .. pl:GetPData("lms_Revealed", 0))
  end

  hook.Add("TTT2FinishedLoading", "ttt_lms_statistics", function()
    local PDEntries = {"lms_GuessedRight", "lms_GuessedWrong", "lms_WonAsLMS", "lms_Revealed"}
    if isfunction(AddYourStatisticsAddon) then
      AddYourStatisticsAddon("Last Man Standing", LMSStatisticsIntegration, PDEntries)
    end
  end)
end
