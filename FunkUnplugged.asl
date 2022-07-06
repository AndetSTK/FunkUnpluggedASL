//Credit to Ero for ASLHelper + setup

state("FunkUnplugged")
{
}

startup
{
	vars.Log = (Action<object>)(output => print("[Funk Unplugged] "));

	var bytes = File.ReadAllBytes(@"Components\Livesplit.ASLHelper.bin");
	var type = Assembly.Load(bytes).GetType("ASLHelper.Unity");
	vars.Helper = Activator.CreateInstance(type, timer, this);
	vars.Helper.GameName = "FunkUnplugged";
}

init
{
	vars.Helper.TryOnLoad = (Func<dynamic, bool>)(mono =>
	{
		var gameController = mono.GetClass("GameController");
		var progressionData  = mono.GetClass("ProgressionData");
		var levelData = mono.GetClass("LevelData");
		var loadingScreenManager = mono.GetClass("LoadingScreenManager");

		vars.Helper["levelName"] = gameController.MakeString("controller", "currentLevelData", levelData["levelName"]);
		vars.Helper["sceneToLoad"] = loadingScreenManager.Make<int>("sceneToLoad");

		vars.levels = new List<string>();

		for (int i = 1; i <= 4; i++)
		{
			for (int j = 1; j <= 3; j++)
			{
				vars.levels.Add("WLD" + i + "LVL" + j + "Complete");
			}
			vars.levels.Add("World" + i + "BossComplete");
		}
		
		for (int i = 0; i < vars.levels.Count; i++)
		{
			vars.Helper[vars.levels[i]] = gameController.Make<bool>("controller", "progressionData", progressionData[vars.levels[i]]);
		}

		return true;
	});
	
	vars.Helper.Load();
}

update
{
	if (!vars.Helper.Update())
		return false;
}

start
{
	return (vars.Helper["levelName"].Current == "GameIntroSceneFromTrain") && (vars.Helper["levelName"].Old != vars.Helper["levelName"].Current);
}

split
{
	for (int i = 0; i < vars.levels.Count; i++)
	{
		if (!vars.Helper[vars.levels[i]].Old && vars.Helper[vars.levels[i]].Current)
		{
			return true;
		}
	}
}

isLoading
{
	return (vars.Helper["levelName"].Current == "RockhallaHub") ^ (vars.Helper["sceneToLoad"].Current == 1);
}

exit
{
	vars.Helper.Dispose();
}

shutdown
{
	vars.Helper.Dispose();
}