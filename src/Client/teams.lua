local teams = {}

function teams.getTeams()
	local teams = {} -- team, players, max, color
	for _, team in pairs(game.Teams:GetChildren()) do
		if team ~= game.Teams.Neutral then
			table.insert(teams, {
				team = team,
				players = #team:GetPlayers(),
				max = team.max.Value,
				color = team.TeamColor
			})
		end
	end
	return teams
end

return teams