if SERVER then
  util.AddNetworkString("lms_statistics_result")
  hook.Add("TTTEndRound", "ttt_lms_statistics", function(result)
    net.Start("lms_statistics_result")
    net.WriteString(result)
    net.Broadcast()
  end)
end

if CLIENT then
  local LmsLabel
  local LastInno = false

  hook.Add("StatisticsDrawGui", "ttt_lms_statistics", function(panel)
    LmsLabel = vgui.Create("DLabel", panel)
    LmsLabel:SetPos(0,0)
    LmsLabel:SetSize(panel:GetWide(), panel:GetTall())
    LmsLabel:SetTextColor(Color(255,255,255))
    LmsLabel:SetFont("StatisticsHudHint")
  end)

  function LastInnoStanding()
    LastInno = true
  end

  net.Receive("lms_statistics_result",function()
    local result = net.ReadString()
    if (result == LocalPlayer():GetTeam()) and (LastInno) and (isfunction(AddYourStatisticsAddon)) then
      LocalPlayer():SetPData("lms_WonAsLMS", LocalPlayer():GetPData("lms_WonAsLMS", 0) +1)
    end
    LastInno = false
  end)

  function LMSStatisticsIntegration(visible)
    LmsLabel:SetVisible(visible)
    LmsLabel:SetText("Times you guessed that you are on your own: " .. LocalPlayer():GetPData("lms_GuessedRight", 0) .. "\n↳  You won a total of " .. LocalPlayer():GetPData("lms_WonAsLMS", 0) .. " rounds after calling LMS correctly" .. "\n\nTimes you guessed wrong: " .. LocalPlayer():GetPData("lms_GuessedWrong", 0) .. "\n\n------------------\n\nTimes you revealed yourself: " .. LocalPlayer():GetPData("lms_Revealed", 0))
  end

  hook.Add("TTT2FinishedLoading", "ttt_lms_statistics", function()
    if isfunction(AddYourStatisticsAddon) then
      AddYourStatisticsAddon("Last Man Standing", LMSStatisticsIntegration)
    end
  end)
end
