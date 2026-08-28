// UpdateUrl: https://github.com/oJumpy/BOIII-T7-Zombies-AutoTimers

state("blackops3", "BO3 Steam")
{
    int levelTime : 0xA5502C0;
    int levelTimeOffHost : 0x3448598;  
    int round_counter : 0xA55BDEC;
    int roundOffHost : 0x1140DC30;     
    byte super30_round_counter : 0xA55BDEC;
    int super30_level_time : 0xA6424FC;
    string13 super30_map_name : 0x179DF840;
    string13 currentMap : 0x940C5E8;
    byte is_paused : 0x347EE08;
    int resetTime : 0x176F9358;
    int resetThreshold : 0x176F9340;
    int resetTimeEntities : 0x176F935C;
    int resetThresholdEntities : 0x176F9344;
    int darknessAddr : 0x10B315E4;
    byte100 trapData : 0xA55BDF1;
    byte36 trapDataOld : 0xA55BDF1;
    byte flogger : 0x4713774;
    byte DeathRay : 0x473A269;
    int entity : 0x176F9B98;
    int RagsSlams : 0x36751E0;
    int ValksKill : 0x4D286F0; 
    byte8 childGSCStructPtr : 0x51A3580;
    byte8 childCSCStructPtr : 0x51A3680;
    int GSpawnAddr : 0xA549DF4;
    ulong GSpawnFreeListHead : 0xA549DF8;
    int GSpawnFakeAddr : 0xA549E18;
    byte8 SquidAnimError : 0x3674AA0;
    int animError : 0x51A3814;
    int FrameTime : 0x168ED8A8;
    int MemTree : 0x50DC280;
    int StringAddr : 0x176F9B94;

    ulong ParticipationPtr : 0x51A3580;

    float velX : 0x3675218;
    float velY : 0x367521C;
    float velZ : 0x3675220;
}

state("boiii", "BOIII Community")
{
    int levelTime : "blackops3.exe", 0xA5502C0;
    int levelTimeOffHost : "blackops3.exe", 0x3448598;
    int round_counter : "blackops3.exe", 0xA55BDEC;
    int roundOffHost : "blackops3.exe", 0x1140DC30;
    string13 currentMap : "blackops3.exe", 0x940C5E8;
    byte super30_round_counter : "blackops3.exe", 0xA55BDEC;
    int super30_level_time : "blackops3.exe", 0xA6424FC;
    string13 super30_map_name : "blackops3.exe", 0x179DF840;
    byte is_paused : "blackops3.exe", 0x347EE08;
    int resetTime : "blackops3.exe", 0x176F9358;
    int resetThreshold : "blackops3.exe", 0x176F9340;
    int resetTimeEntities : "blackops3.exe", 0x176F935C;
    int resetThresholdEntities : "blackops3.exe", 0x176F9344;
    int darknessAddr : "blackops3.exe", 0x10B315E4;

    byte100 trapData : "blackops3.exe", 0xA55BDF1;
    byte36 trapDataOld : "blackops3.exe", 0xA55BDF1;
    byte flogger : "blackops3.exe", 0x4713774;
    byte DeathRay : "blackops3.exe", 0x473A269;
    int entity : "blackops3.exe", 0x176F9B98;
    int RagsSlams : "blackops3.exe", 0x36751E0;
    int ValksKill : "blackops3.exe", 0x4D286F0;
    byte8 childGSCStructPtr : "blackops3.exe", 0x51A3580;
    byte8 childCSCStructPtr : "blackops3.exe", 0x51A3680;
    int GSpawnAddr : "blackops3.exe", 0xA549DF4;
    ulong GSpawnFreeListHead : "blackops3.exe", 0xA549DF8;
    int GSpawnFakeAddr : "blackops3.exe", 0xA549E18;
    byte8 SquidAnimError : "blackops3.exe", 0x3674AA0;
    byte8 RawSoundManagerPtr : "blackops3.exe", 0x3674AA0;
    int FrameTime : "blackops3.exe", 0x168ED8A8;
    int MemTree : "blackops3.exe", 0x50DC280;
    int StringAddr : "blackops3.exe", 0x176F9B94;

    ulong ParticipationPtr : "blackops3.exe", 0x51A3580;

    float velX : "blackops3.exe", 0x3675218;
    float velY : "blackops3.exe", 0x367521C;
    float velZ : "blackops3.exe", 0x3675220;
}

startup {

    vars.snapshots_last_value = -1;
    vars.snapshots_consistent_reads = 0;
    vars.snapshots_last_delta = 0;
    vars.snapshots_last_seconds = double.MaxValue;

    vars.entities_last_value = -1;
    vars.entities_consistent_reads = 0;
    vars.entities_last_delta = 0;
    vars.entities_last_seconds = double.MaxValue;

    vars.entities_5min_history = new Queue<Tuple<int, int>>();
    vars.last_5min_sample_time = -1;

    vars.SaveSuper30Data = (Action)(() => {
        try 
        {
            List<string> allLines = new List<string>();
            if (File.Exists(vars.boxHitsFilePath))
            {
                allLines.AddRange(File.ReadAllLines(vars.boxHitsFilePath));
            }
            
            for (int i = allLines.Count - 1; i >= 0; i--)
            {
                if (allLines[i].StartsWith("Super30 Total Time:") || 
                    allLines[i].StartsWith("Super30 Map Index:") || 
                    allLines[i].StartsWith("Super30 Last Split:"))
                {
                    allLines.RemoveAt(i);
                }
            }
            
            allLines.Add(string.Format("Super30 Total Time: {0}", vars.super30_total_time));
            allLines.Add(string.Format("Super30 Map Index: {0}", vars.super30_map_index));
            allLines.Add(string.Format("Super30 Last Split: {0}", vars.super30_last_split_time));
            
            File.WriteAllLines(vars.boxHitsFilePath, allLines.ToArray());
            
            File.AppendAllText(vars.debugFilePath, string.Format("Saved Super30 data - Total: {0}, MapIndex: {1}, LastSplit: {2}\n", 
                vars.super30_total_time, vars.super30_map_index, vars.super30_last_split_time));
        }
        catch (Exception ex)
        {
            File.AppendAllText(vars.debugFilePath, "Error saving Super30 data: " + ex.Message + "\n");
        }
    });

    vars.SaveSuper30ChroniclesData = (Action)(() => {
        try 
        {
            List<string> allLines = new List<string>();
            if (File.Exists(vars.boxHitsFilePath))
            {
                allLines.AddRange(File.ReadAllLines(vars.boxHitsFilePath));
            }
            
            for (int i = allLines.Count - 1; i >= 0; i--)
            {
                if (allLines[i].StartsWith("Super30 Chronicles Total Time:") || 
                    allLines[i].StartsWith("Super30 Chronicles Map Index:") || 
                    allLines[i].StartsWith("Super30 Chronicles Last Split:"))
                {
                    allLines.RemoveAt(i);
                }
            }
            
            allLines.Add(string.Format("Super30 Chronicles Total Time: {0}", vars.super30_chronicles_total_time));
            allLines.Add(string.Format("Super30 Chronicles Map Index: {0}", vars.super30_chronicles_map_index));
            allLines.Add(string.Format("Super30 Chronicles Last Split: {0}", vars.super30_chronicles_last_split_time));
            
            File.WriteAllLines(vars.boxHitsFilePath, allLines.ToArray());
            
            File.AppendAllText(vars.debugFilePath, string.Format("Saved Super30 Chronicles data - Total: {0}, MapIndex: {1}, LastSplit: {2}\n", 
                vars.super30_chronicles_total_time, vars.super30_chronicles_map_index, vars.super30_chronicles_last_split_time));
        }
        catch (Exception ex)
        {
            File.AppendAllText(vars.debugFilePath, "Error saving Super30 Chronicles data: " + ex.Message + "\n");
        }
    });
    
    vars.debugFilePath = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments), "LiveSplit_Counters.txt");
    File.AppendAllText(vars.debugFilePath, "Script starting at " + DateTime.Now + "\n");

    settings.Add("Solo Timer", true);

    settings.Add("Coop Timer", false);
    settings.SetToolTip("Coop Timer", "Use for Coop, so you can pause the timer");

    settings.Add("Enable Splits", true);

    settings.Add("Super 30", false);
    settings.Add("Super 30 Chronicles", false); 

    settings.Add("Options", true);
        settings.Add("Reset Value", false, "Reset Value", "Options");
        settings.Add("Reset Timer", false, "Reset Timer", "Options");
        settings.Add("Entities", false, "Entities", "Options");
        settings.Add("com_frametime", false, "com_frametime", "Options");
        settings.Add("com_frametime_timer", false, "Frame Timer", "Options");
        settings.Add("Darkness", false, "Darkness", "Options");
        settings.Add("ViewAngles", false, "ViewAngles", "Options");
        settings.Add("Velocity", false, "Velocity Meter", "Options");

    settings.Add("Errors Trackers", true);
        settings.Add("Child GSC Variable", false, "Child GSC Variable", "Errors Trackers");
        settings.Add("GSC Threads", false, "GSC Threads", "Errors Trackers"); 
        settings.Add("Child CSC Variable", false, "Child CSC Variable", "Errors Trackers");
        settings.Add("CSC Threads", false, "CSC Threads", "Errors Trackers");

        settings.Add("MemTree", false, "MemTree", "Errors Trackers");
        settings.Add("BG Strings", false, "BG_Cache Strings", "Errors Trackers");
        settings.Add("Grenades Left", false, "Grenades Left", "Errors Trackers");
        settings.Add("G-Spawn", false, "G-Spawn", "Errors Trackers");
        settings.Add("G-SpawnFake", false, "G-SpawnFake", "Errors Trackers");
        settings.Add("Sound Error", false, "Sound Error", "Errors Trackers");
        settings.Add("Hitmarkers", false, "Hitmarkers", "Errors Trackers");

    settings.Add("Counters", false);
        settings.Add("Nade Counter", false, "Nade Counter", "Counters");
        settings.Add("Hitmarkers Per Hour", false, "Hitmarkers Per Hour", "Counters");
            settings.Add("Predict Hours", false, "Predict Hours", "Hitmarkers Per Hour");
        settings.Add("Rags Slams Counter", false, "Rags Slams Counter", "Counters");
        settings.Add("Valk Counter", false, "Valk Counter", "Counters");

    settings.Add("Clear Counters", false);
         settings.SetToolTip("Clear Counters", "This will reset all Counters back to 0");

    settings.Add("Trap Timers", true);
        settings.Add("giant", false, "The Giant", "Trap Timers");
            settings.Add("bridge", false, "Bridge", "giant");
            settings.Add("jugtrap", false, "Kuda", "giant");
            settings.Add("mkder", true, "VMP", "giant");
        settings.Add("de", false, "Der Eisendrache", "Trap Timers");
            settings.Add("courtyard", true, "Courtyard", "de");
            settings.Add("deathray", true, "Death Ray", "de");
        settings.Add("zns", false, "Zetsubou no Shima", "Trap Timers");
            settings.Add("planetrap", true, "Propeller Trap", "zns");
            settings.Add("fantrap", true, "Fan Trap", "zns");
        settings.Add("gk", false, "Gorod Krovi", "Trap Timers");
            settings.Add("bunker", true, "Bunker", "gk");
        settings.Add("rev", false, "Revelations", "Trap Timers");
            settings.Add("camptrap", true, "Verruckt Trap", "rev");
        settings.Add("verruckt", false, "Verruckt", "Trap Timers");
            settings.Add("doubletap", true, "Double Tap", "verruckt");
            settings.Add("speedcola", true, "Speed Cola", "verruckt");
        settings.Add("shino", false, "Shi No Numa", "Trap Timers");
            settings.Add("comm", false, "Comm Room", "shino");
            settings.Add("doc", false, "Doctor's Quarters", "shino");
            settings.Add("fishing", false, "Fishing Hut", "shino");
            settings.Add("storage", true, "Storage", "shino");
            settings.Add("flogger", true, "Flogger", "shino");
        settings.Add("kino", false, "Kino Der Toten", "Trap Timers");
            settings.Add("kinoft", false, "Fire Trap", "kino");
            settings.Add("m8room", true, "M8", "kino");
        settings.Add("ascension", false, "Ascension", "Trap Timers");
            settings.Add("vesper", false, "Stamin-Up", "ascension");
            settings.Add("kn", false, "Mule Kick", "ascension");

    settings.Add("Debuggers", true);
    settings.Add("GSC Debugger", true, "GSC Debugger", "Debuggers");
        settings.Add("GSC_UNDEFINED", false, "GSC Undefined", "GSC Debugger");
        settings.Add("GSC_POINTER", false, "GSC Pointers", "GSC Debugger");
        settings.Add("GSC_STRING", false, "GSC Strings", "GSC Debugger");
        settings.Add("GSC_ISTRING", false, "GSC IStrings", "GSC Debugger");
        settings.Add("GSC_VECTOR", false, "GSC Vectors", "GSC Debugger");
        settings.Add("GSC_HASH", false, "GSC Hashes", "GSC Debugger");
        settings.Add("GSC_FLOAT", false, "GSC Floats", "GSC Debugger");
        settings.Add("GSC_INTEGER", false, "GSC Integers", "GSC Debugger");
        settings.Add("GSC_CODEPOS", false, "GSC Code Pos", "GSC Debugger");
        settings.Add("GSC_PRECODEPOS", false, "GSC Pre-Code Pos", "GSC Debugger");
        settings.Add("GSC_FUNCTION", false, "GSC Functions", "GSC Debugger");
        settings.Add("GSC_STACK", false, "GSC Stacks", "GSC Debugger");
        settings.Add("GSC_ANIMATION", false, "GSC Animations", "GSC Debugger");
        settings.Add("GSC_DEV_CODEPOS", false, "GSC Dev Code Pos", "GSC Debugger");
        settings.Add("GSC_INC_CODEPOS", false, "GSC Included Code Pos", "GSC Debugger");
        settings.Add("GSC_THREAD_15", false, "GSC Active Threads", "GSC Debugger");
        settings.Add("GSC_NOTIFY_THREAD", false, "GSC Notify Threads", "GSC Debugger");
        settings.Add("GSC_TIME_THREAD", false, "GSC Time Threads", "GSC Debugger");
        settings.Add("GSC_CHILD_THREAD", false, "GSC Child Threads", "GSC Debugger");
        settings.Add("GSC_CLASS", false, "GSC Classes", "GSC Debugger");
        settings.Add("GSC_STRUCT", false, "GSC Structs", "GSC Debugger");
        settings.Add("GSC_REMOVED_THREAD", false, "GSC Removed Threads", "GSC Debugger");
        settings.Add("GSC_DELEGATE", false, "GSC Delegates", "GSC Debugger");

    settings.Add("CSC Debugger", true, "CSC Debugger", "Debuggers");
        settings.Add("CSC_UNDEFINED", false, "CSC Undefined", "CSC Debugger");
        settings.Add("CSC_POINTER", false, "CSC Pointers", "CSC Debugger");
        settings.Add("CSC_STRING", false, "CSC Strings", "CSC Debugger");
        settings.Add("CSC_ISTRING", false, "CSC IStrings", "CSC Debugger");
        settings.Add("CSC_VECTOR", false, "CSC Vectors", "CSC Debugger");
        settings.Add("CSC_HASH", false, "CSC Hashes", "CSC Debugger");
        settings.Add("CSC_FLOAT", false, "CSC Floats", "CSC Debugger");
        settings.Add("CSC_INTEGER", false, "CSC Integers", "CSC Debugger");
        settings.Add("CSC_CODEPOS", false, "CSC Code Pos", "CSC Debugger");
        settings.Add("CSC_PRECODEPOS", false, "CSC Pre-Code Pos", "CSC Debugger");
        settings.Add("CSC_FUNCTION", false, "CSC Functions", "CSC Debugger");
        settings.Add("CSC_STACK", false, "CSC Stacks", "CSC Debugger");
        settings.Add("CSC_ANIMATION", false, "CSC Animations", "CSC Debugger");
        settings.Add("CSC_DEV_CODEPOS", false, "CSC Dev Code Pos", "CSC Debugger");
        settings.Add("CSC_INC_CODEPOS", false, "CSC Included Code Pos", "CSC Debugger");
        settings.Add("CSC_THREAD_15", false, "CSC Active Threads", "CSC Debugger");
        settings.Add("CSC_NOTIFY_THREAD", false, "CSC Notify Threads", "CSC Debugger");
        settings.Add("CSC_TIME_THREAD", false, "CSC Time Threads", "CSC Debugger");
        settings.Add("CSC_CHILD_THREAD", false, "CSC Child Threads", "CSC Debugger");
        settings.Add("CSC_CLASS", false, "CSC Classes", "CSC Debugger");
        settings.Add("CSC_STRUCT", false, "CSC Structs", "CSC Debugger");
        settings.Add("CSC_REMOVED_THREAD", false, "CSC Removed Threads", "CSC Debugger");
        settings.Add("CSC_DELEGATE", false, "CSC Delegates", "CSC Debugger");

    vars.currentTextValues = new Dictionary<string, string>();
    
    vars.SetTextColor = (Action<string, object, System.Drawing.Color?>)((text1, text2, color) => 
    {
        string textValue = text2 != null ? text2.ToString() : "";
        vars.currentTextValues[text1] = textValue;

        var textSettings = timer.Layout.Components.Where(x => x.GetType().Name == "TextComponent")
            .Select(x => x.GetType().GetProperty("Settings").GetValue(x, null));
        var textSetting = textSettings.FirstOrDefault(x => (x.GetType().GetProperty("Text1").GetValue(x, null) as string) == text1);
        
        if (textSetting == null && !string.IsNullOrEmpty(textValue))
        {
            try 
            {
                var textComponentAssembly = Assembly.LoadFrom("Components\\LiveSplit.Text.dll");
                var textComponent = Activator.CreateInstance(textComponentAssembly.GetType("LiveSplit.UI.Components.TextComponent"), timer);
                timer.Layout.LayoutComponents.Add(new LiveSplit.UI.Components.LayoutComponent("LiveSplit.Text.dll", textComponent as LiveSplit.UI.Components.IComponent));

                textSetting = textComponent.GetType().GetProperty("Settings", BindingFlags.Instance | BindingFlags.Public).GetValue(textComponent, null);
                textSetting.GetType().GetProperty("Text1").SetValue(textSetting, text1);
            }
            catch (Exception ex)
            {
                
            }
        }

        if (textSetting != null)
        {
            textSetting.GetType().GetProperty("Text2").SetValue(textSetting, textValue);

            try
            {
                var textColorProp = textSetting.GetType().GetProperty("TextColor");
                var overrideTextColorProp = textSetting.GetType().GetProperty("OverrideTextColor");
                var timeColorProp = textSetting.GetType().GetProperty("TimeColor");
                var overrideTimeColorProp = textSetting.GetType().GetProperty("OverrideTimeColor");

                if (color.HasValue)
                {
                    if (overrideTextColorProp != null) overrideTextColorProp.SetValue(textSetting, true);
                    if (textColorProp != null) textColorProp.SetValue(textSetting, color.Value);
                    if (overrideTimeColorProp != null) overrideTimeColorProp.SetValue(textSetting, true);
                    if (timeColorProp != null) timeColorProp.SetValue(textSetting, color.Value);
                }
                else
                {
                    if (overrideTextColorProp != null) overrideTextColorProp.SetValue(textSetting, false);
                    if (overrideTimeColorProp != null) overrideTimeColorProp.SetValue(textSetting, false);
                }
            }
            catch (Exception ex)
            {

            }
        }
    });

    vars.SetText = (Action<string, object>)((text1, text2) => 
    {
        vars.SetTextColor(text1, text2, null);
    });
    vars.RemoveText = (Action<string>)((text1) => 
        {
        try 
        {
            var layoutComponentsList = timer.Layout.LayoutComponents as System.Collections.IList;
            if (layoutComponentsList != null)
            {
                for (int i = layoutComponentsList.Count - 1; i >= 0; i--)
                {
                    var layoutComponent = layoutComponentsList[i];
                    if (layoutComponent == null) continue;

                    var componentProp = layoutComponent.GetType().GetProperty("Component");
                    if (componentProp != null)
                    {
                        var comp = componentProp.GetValue(layoutComponent, null);
                        if (comp != null && comp.GetType().Name == "TextComponent")
                        {
                            var settingsProp = comp.GetType().GetProperty("Settings");
                            if (settingsProp != null)
                            {
                                var settingsObj = settingsProp.GetValue(comp, null);
                                if (settingsObj != null)
                                {
                                    var text1Prop = settingsObj.GetType().GetProperty("Text1");
                                    if (text1Prop != null)
                                    {
                                        var text1Val = text1Prop.GetValue(settingsObj, null) as string;
                                        if (text1Val == text1)
                                        {
                                            layoutComponentsList.RemoveAt(i);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            
        }
        
        
        if (vars.currentTextValues.ContainsKey(text1))
            vars.currentTextValues.Remove(text1);
    });

        vars.RemoveAllTexts = (Action)(() => {
        
        var keysToRemove = new List<string>();
        foreach (var key in vars.currentTextValues.Keys)
        {
            keysToRemove.Add(key);
        }
        
        foreach (var key in keysToRemove)
        {
            vars.RemoveText(key);
        }
    });

    vars.SetTextComponent = (Action<string, string>)((id, text) => {
        vars.SetText(id, text);
    });

    vars.boxHitsFilePath = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments), "LiveSplit_Counters.txt");

        vars.ragsSlamsCounter = 0;
        vars.nadeCounter = 0;
        vars.valksCounter = 0;
        vars.hitmarkerCounter = 0;

    
    if (File.Exists(vars.boxHitsFilePath)) 
    {
        string[] lines = File.ReadAllLines(vars.boxHitsFilePath);
        foreach (string line in lines)
        {
            if (line.StartsWith("Rags Slams:")) vars.ragsSlamsCounter = int.Parse(line.Split(':')[1].Trim());
            if (line.StartsWith("Nade Count:")) vars.nadeCounter = int.Parse(line.Split(':')[1].Trim());
            if (line.StartsWith("Valk Count:")) vars.valksCounter = int.Parse(line.Split(':')[1].Trim());
            if (line.StartsWith("Hitmarker Count:")) vars.hitmarkerCounter = int.Parse(line.Split(':')[1].Trim());

            if (line.StartsWith("Super30 Total Time:")) vars.super30_total_time = int.Parse(line.Split(':')[1].Trim());
            if (line.StartsWith("Super30 Map Index:")) vars.super30_map_index = int.Parse(line.Split(':')[1].Trim());
            if (line.StartsWith("Super30 Last Split:")) vars.super30_last_split_time = int.Parse(line.Split(':')[1].Trim());

            if (line.StartsWith("Super30 Chronicles Total Time:")) vars.super30_chronicles_total_time = int.Parse(line.Split(':')[1].Trim());
            if (line.StartsWith("Super30 Chronicles Map Index:")) vars.super30_chronicles_map_index = int.Parse(line.Split(':')[1].Trim());
            if (line.StartsWith("Super30 Chronicles Last Split:")) vars.super30_chronicles_last_split_time = int.Parse(line.Split(':')[1].Trim());
        }
    }
    else
    {
        
    }

    File.AppendAllText(vars.debugFilePath, string.Format("Loaded values - Nades: {0}\n", vars.nadeCounter));

    vars.super30_total_time = 0;
    vars.super30_last_split_time = 0;
    vars.super30_map_order = new string[] { "zm_zod", "zm_factory", "zm_castle", "zm_island", "zm_stalingrad", "zm_genesis" };
    vars.super30_map_index = 0;
    vars.super30_map_done = false;
    vars.super30_running = false;
    vars.super30_last_level_time = 0;
    
    vars.super30_chronicles_total_time = 0;
    vars.super30_chronicles_last_split_time = 0;
    vars.super30_chronicles_map_order = new string[] { "zm_prototype", "zm_asylum", "zm_sumpf", "zm_theater", "zm_cosmodrome", "zm_temple", "zm_moon", "zm_tomb" };
    vars.super30_chronicles_map_index = 0;
    vars.super30_chronicles_map_done = false;
    vars.super30_chronicles_running = false;

    vars.MemMAXTreeValue = 0;
    vars.StringMaxValue = 0;
    vars.luaVMMaxValue = 0;
    vars.UsedMaxStringsValue = 0;
    vars.FreeMaxListValue = 0;

    vars.maxChildValue = 0;
    vars.CSCmaxChildValue = 0;
    vars.activeThreads = 0;   
    vars.maxActiveThreads = 0;
    vars.activeCSCThreads = 0;     
    vars.maxActiveCSCThreads = 0;   
    
    vars.maxTypeCounts = new Dictionary<string, int>();

    vars.UpdateDetailedText = (Action<bool, string, string, int>)((isEnabled, settingKey, displayName, count) => 
    {
        var maxDict = (Dictionary<string, int>)vars.maxTypeCounts;
        
        if (isEnabled)
        {
            if (!maxDict.ContainsKey(settingKey)) maxDict[settingKey] = 0;
            if (count > maxDict[settingKey]) maxDict[settingKey] = count;
            vars.SetText(displayName + ":", count.ToString() + " Max: " + maxDict[settingKey].ToString());
        }
        else 
        {
            vars.RemoveText(displayName + ":");
        }
    });

    vars.currentChildValue = 0;
    vars.currentCSCValue = 0;
    vars.currentSoundValue = 0;
    vars.maxSoundValue = 0;
    vars.currentRawPtrValue = 0;
    vars.maxRawPtrValue = 0;
    vars.maxBGStringsValue = 0;      
    vars.currentBGStringsValue = 0;  

    vars.cscPointers = 0;
    vars.cscIntegers = 0;
    vars.cscStructs = 0;

    if (File.Exists(vars.boxHitsFilePath))
    {
        string[] lines = File.ReadAllLines(vars.boxHitsFilePath);
        foreach (string line in lines)
        {
            if (line.StartsWith("GSC Max Value:")) 
                vars.maxChildValue = int.Parse(line.Split(':')[1].Trim());
            if (line.StartsWith("BG Strings Max:")) 
                vars.maxBGStringsValue = int.Parse(line.Split(':')[1].Trim());
            if (line.StartsWith("CSC Max Value:")) 
                vars.CSCmaxChildValue = int.Parse(line.Split(':')[1].Trim());
            if (line.StartsWith("GSC Current Value:")) 
                vars.currentChildValue = int.Parse(line.Split(':')[1].Trim());
            if (line.StartsWith("CSC Current Value:")) 
                vars.currentCSCValue = int.Parse(line.Split(':')[1].Trim());
            if (line.StartsWith("Sound Error Max:")) 
                vars.maxSoundValue = int.Parse(line.Split(':')[1].Trim());
        }
    }

    vars.gameJustStarted = true;

    vars.ignoreNextHit = false; 

    vars.trapStarts = new Dictionary<string, int>();
    vars.trapActive = new Dictionary<string, bool>();
    vars.cachedTrapTexts = new Dictionary<string, string>();
    
    foreach (string trapID in new string[] { "bunker", "kinoft", "m8room", "camptrap", "comm", "doc", "fishing", "storage", "flogger", "bridge", "jugtrap", "mkder", "doubletap", "speedcola", "vesper", "kn", "courtyard", "planetrap", "fantrap", "deathray" })
    {
        vars.trapStarts[trapID] = -2020;
        vars.trapActive[trapID] = false;
        vars.cachedTrapTexts[trapID] = "0:00.00";
    }

    vars.cachedResetText = "";
    vars.cachedRemainingText = "";
    vars.cachedDarknessText = "";
    vars.cachedFrameTimeText = "";
    vars.lastResetValue = -1;
    vars.consistentReads = 0;
    vars.lastDelta = 0;
    vars.cachedResetTimer = "0:00";

    vars.cachedGSCText = "";
    vars.cachedCSCText = "";

    vars.hitmarkerStartTime = 0;
    vars.hitmarkersPerHour = 0.0;
    vars.hitmarkersAtStart = 0;
    vars.predictedHitmarkers = 0;

    vars.predictionHours = 0; 
    vars.hasAskedForHours = false;
    
    if (File.Exists(vars.boxHitsFilePath))
    {
        string[] lines = File.ReadAllLines(vars.boxHitsFilePath);
        foreach (string line in lines)
        {
            if (line.StartsWith("HPH Start Time:")) 
                vars.hitmarkerStartTime = int.Parse(line.Split(':')[1].Trim());
            if (line.StartsWith("HPH Start Count:")) 
                vars.hitmarkersAtStart = int.Parse(line.Split(':')[1].Trim());
            if (line.StartsWith("HPH Rate:")) 
                vars.hitmarkersPerHour = double.Parse(line.Split(':')[1].Trim());
            if (line.StartsWith("HPH Prediction Hours:")) 
            {
                vars.predictionHours = int.Parse(line.Split(':')[1].Trim());

                if (vars.predictionHours >= 45 && vars.predictionHours <= 60)
                {
                    vars.hasAskedForHours = true;
                }
            }
        }
    }

    vars.roundHitmarkers = new Dictionary<int, int>();
    vars.lastTrackedRound = 0;

    if (File.Exists(vars.boxHitsFilePath))
    {
        string[] lines = File.ReadAllLines(vars.boxHitsFilePath);
        foreach (string line in lines)
        {
            if (line.StartsWith("Hitmarkers At Round:"))
            {
                
                string roundData = line.Substring("Hitmarkers At Round:".Length);
                string[] roundEntries = roundData.Split('/');

                foreach (string entry in roundEntries)
                {
                    if (entry.Contains('-'))
                    {
                        string[] parts = entry.Split('-');
                        if (parts.Length == 2)
                        {
                            int round = 0;
                            int hitmarkers = 0;
                            if (int.TryParse(parts[0], out round) && int.TryParse(parts[1], out hitmarkers))
                            {
                                vars.roundHitmarkers[round] = hitmarkers;
                            }
                        }
                    }
                }
            }
        }
    }

    vars.SaveRoundData = (Action)(() => {
        try 
        {
            var allLines = new List<string>();
            if (File.Exists(vars.boxHitsFilePath))
            {
                allLines.AddRange(File.ReadAllLines(vars.boxHitsFilePath));
            }
            for (int i = allLines.Count - 1; i >= 0; i--)
            {
                if (allLines[i].StartsWith("Hitmarkers At Round:"))
                {
                    allLines.RemoveAt(i);
                }
            }
            
            var roundKeys = new List<int>(vars.roundHitmarkers.Keys);
            roundKeys.Sort();
            string roundData = "Hitmarkers At Round: ";
            for (int i = 0; i < roundKeys.Count; i++)
            {
                int round = roundKeys[i];
                roundData += round.ToString() + "-" + vars.roundHitmarkers[round].ToString();
                if (i < roundKeys.Count - 1)
                    roundData += " / ";
            }

            allLines.Add(roundData);
            File.WriteAllLines(vars.boxHitsFilePath, allLines.ToArray());
        }
        catch (Exception ex)
        {
            
        }
    });

    vars.lastTrapData = new byte[100];
    vars.trapDataMonitorEnabled = false;
    vars.trapDataMonitorPrinted = false;

    vars.fixedOffsetGameTime = null;
    vars.shownConflictWarning = false;
    vars.shownChroniclesConflictWarning = false;

    vars.trueTime = 0;
    vars.offhost_startTime = 0;
    vars.offhost_trueTime = 0;
    vars.smoothOffHostTime = 0;
    vars.lastChangeTime = DateTime.Now;

    vars.ViewAnglesOffsets = new int[] {
        0x16D03D80, 0x16D03EA8, 0x16D0BCB0, 0x16D0D180, 0x16D10C78, 0x16D11808, 0x16D12960, 0x16D13740,
        0x16D142D0, 0x16D14E60, 0x16D159F0, 0x16D16580, 0x16D17110, 0x16D17CA0, 0x16D18CD0, 0x16D37270,
        0x16D30F00, 0x16D31278, 0x16D37020, 0x16D37148, 0x16D038E0, 0x16D08780, 0x16D08D48, 0x16D08E70,
        0x16D090C0, 0x16D11930, 0x16D11A58, 0x16D11B80, 0x16D134F0, 0x16D19988, 0x16D19AB0, 0x16D19BD8,
        0x16D19D00, 0x16D19E28, 0x16D19F50, 0x16D1A078, 0x16D1A1A0, 0x16D1A2C8, 0x16D1A3F0, 0x16D1C0D8,
        0x16D1C578, 0x16D30938, 0x16D30A60, 0x16D30B88, 0x16D30CB0, 0x16D30DD8, 0x16D31028, 0x16D31150,
        0x16D313A0, 0x16D35C78, 0x16D38178, 0x16D38618, 0x16D38AB8, 0x16D38F58, 0x16D393F8, 0x16D39E60,
        0x16D3B330, 0x16D3B7D0, 0x16D0EF90, 0x16D00AA0, 0x16D0D870, 0x16D28D80, 0x16D0DF60, 0x16D00038,
        0x16D0F680, 0x16D0E400, 0x16D29910, 0x16D2A5C8, 0x16D150B0, 0x16D0E528, 0x16D1CFE0, 0x16D22A10,
        0x16D1D230, 0x16D0E2D8
    };

    vars.cameraYawValue = 0.0f;
    vars.validViewAnglesYawAddr = IntPtr.Zero;
    vars.viewAnglesInitDone = false;

    vars.grenadesLeft = -1;
    vars.lastGrenadesLeft = -1;
    vars.grenadesLeftFactor = 20.3;

    vars.participationIndex = -1;
    vars.participationLastMap = "";
    vars.participationSnapshots = new Dictionary<int, int>();
    vars.participationStreaks = new Dictionary<int, int>();
    vars.participationValueOffsets = new Dictionary<int, int>();
    vars.participationMissedHits = 0;

    vars.maxSpeed2D = 0.0;
    vars.lastMaxSpeedTime = DateTime.Now;
}

init{

    if (vars.gameJustStarted)
    {
        vars.maxChildValue = 0;
        vars.CSCmaxChildValue = 0;
        vars.currentChildValue = 0;
        vars.currentCSCValue = 0;
        vars.gameJustStarted = false;
    }

    try 
    {
        if (vars.lcCache != null)
        {
            var keysToRemove = new List<string>();
            foreach (var key in vars.lcCache.Keys)
            {
                keysToRemove.Add(key);
            }
        
            foreach (var key in keysToRemove)
            {
                if (vars.lcCache.ContainsKey(key))
                {
                    var lcToRemove = vars.lcCache[key];
                    var layoutComponentsList = timer.Layout.LayoutComponents as System.Collections.IList;
                    if (layoutComponentsList != null && layoutComponentsList.Contains(lcToRemove))
                    {
                        layoutComponentsList.Remove(lcToRemove);
                    }
                    vars.lcCache.Remove(key);
                }
            }
        }
    }
    catch (Exception ex)
    {
        
    }
    
    string MD5Hash;
    using (var md5 = System.Security.Cryptography.MD5.Create())
    using (var s = File.Open(modules.First().FileName, FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
    MD5Hash = md5.ComputeHash(s).Select(x => x.ToString("X2")).Aggregate((a, b) => a + b);

    switch (MD5Hash)
        {
            case "5377ADAB3FEC9EE10696C37F12768039":
                version = "BO3 Steam";
                break;
            case "970FFA6F74BC381EFF8CC3C4B31573B4":
                version = "BOIII Community v1.0.6";
                MessageBox.Show("This BOIII Client v1.0.6 version is outdated.", "LiveSplit Auto Splitter - Outdated BOIII Client Version");
                break; 
            case "FDA9C73020FA283CAC2DC7C0D61C2E37":
                version = "BOIII Community v1.0.8";
                break;
            case "5526FF0593387B4EE94EADCB23852D09":
                version = "BOIII Community v1.0.9";
                break;
            case "0E53EDCFFF1E8DE0541461CD336096E4":
                version = "BOIII Community v1.1.2";
                break;
            case "2D331C5A5979DA0F2AE36D114BD97AF1":
                version = "BOIII Community v1.1.5";
                break;
            case "DA8FF93FEA868152E0AA1C13886A8E44":
                version = "BOIII Community v1.1.6";
                break;
            default:
                version = "Unknown";
                
                break;
        }

    string exeName = Path.GetFileName(modules.First().FileName).ToLower();

    switch (exeName)
    {
        case "blackops3.exe":
            version = "Steam BO3";
            break;
        case "boiii.exe":
            version = "BOIII Community";
            break;
        case "boiii_dirty.exe":
            version = "boiii_dirty";
            break;
        case "boiii-develop.exe":
            version = "boiii-develop";
            break;
        default:
            version = "Unknown";
            MessageBox.Show("This game version is currently not supported.\nIf it is correct, make sure your EXE file name is set to just `boiii.exe`", "LiveSplit Auto Splitter - Unsupported Game Version");
            break;
    }

    timer.CurrentTimingMethod = TimingMethod.GameTime;
    
    refreshRate = 50;
    
    if (settings["Trap Timers"])
    {
        vars.trapStarts = new Dictionary<string, int>();
        foreach (string trapID in new string[] { "bunker", "kinoft", "m8room", "camptrap", "comm", "doc", "fishing", "storage", "flogger", "bridge", "jugtrap", "mkder", "doubletap", "speedcola", "vesper", "kn", "courtyard", "planetrap", "fantrap", "deathray" })
        {
            vars.trapStarts[trapID] = -2020;
        }
    }

    vars.FloggertrapStart = -1540;
    vars.DeathRayStart = -1500;

    if (settings["Solo Timer"])
    {
        vars.fixedOffsetGameTime = 0;
    }
    else if (settings["Coop Timer"])
    {
        vars.timer_start = 0;
    }

    if (settings["Options"])
    {
        vars.startTime = current.levelTime;
        vars.startReset = current.resetTime;
        vars.elapsedReset = 9999999;
        vars.elapsedTime = 1;
    }

    vars.startFrameTime = current.FrameTime;
    vars.decryptedClientActivePtr = 0UL; 
}

update {
    if (!vars.shownConflictWarning && settings["Super 30"] && settings["Solo Timer"])
    {
        vars.shownConflictWarning = true;
        MessageBox.Show(
            "Warning: Super 30 and Solo Timer cannot be enabled at the same time.\n\n" +
            "Please disable one of them to prevent script errors.",
            "LiveSplit Auto Splitter - Conflicting Settings",
            MessageBoxButtons.OK,
            MessageBoxIcon.Warning
        );
    }
    
    if (!vars.shownChroniclesConflictWarning && settings["Super 30 Chronicles"] && settings["Solo Timer"])
    {
        vars.shownChroniclesConflictWarning = true;
        MessageBox.Show(
            "Warning: Super 30 Chronicles and Solo Timer cannot be enabled at the same time.\n\n" +
            "Please disable one of them to prevent script errors.",
            "LiveSplit Auto Splitter - Conflicting Settings",
            MessageBoxButtons.OK,
            MessageBoxIcon.Warning
        );
    }

    if (!settings["Super 30"] || !settings["Solo Timer"])
    {
        vars.shownConflictWarning = false;
    }
    
    if (!settings["Super 30 Chronicles"] || !settings["Solo Timer"])
    {
        vars.shownChroniclesConflictWarning = false;
    }
        
    if (!vars.trapDataMonitorEnabled && current.levelTime > 0 && current.trapData != null)
    {
        for (int i = 0; i < 100; i++)
        {
            vars.lastTrapData[i] = current.trapData[i];
        }
        vars.trapDataMonitorEnabled = true;
    }
    
    if (vars.trapDataMonitorEnabled && current.trapData != null)
    {
        bool anyChange = false;
        string changes = "";
        
        for (int i = 0; i < 100; i++)
        {
            byte currentByte = current.trapData[i];
            byte lastByte = vars.lastTrapData[i];
            
            if (currentByte != lastByte)
            {
                anyChange = true;
                changes += string.Format("Byte {0}: {1:X2} -> {2:X2} | ", i, lastByte, currentByte);
                vars.lastTrapData[i] = currentByte;
            }
        }
        
        
        if (anyChange && !vars.trapDataMonitorPrinted)
        {
            vars.trapDataMonitorPrinted = true;
        }
        else if (!anyChange)
        {
            vars.trapDataMonitorPrinted = false;
        }
    }

    
    if (old.currentMap != "core_frontend" && current.currentMap == "core_frontend")
    {
        
        vars.gameJustStarted = true;
    }

    if (settings["Solo Timer"])
    {
        if (old.round_counter == 0 && current.round_counter == 1)
        {
            vars.fixedOffsetGameTime = current.levelTime;
        }
        vars.trueTime = current.levelTime - vars.fixedOffsetGameTime;
    }

    if (settings["Options"])
    {
        int entityChangeThreshold = 3;
    
        if (Math.Abs(old.entity - current.entity) >= entityChangeThreshold)
        {
            vars.elapsedTime = vars.startTime - current.levelTime;
            vars.elapsedReset = vars.startReset - current.resetTime;
    
            vars.startTime = current.levelTime;
            vars.startReset = current.resetTime;
        }

    
    if (settings["Reset Value"])
    {
        long dynamicMax = 2147483646L - current.resetThreshold;
        long remainingReset = dynamicMax - current.resetTime;

        string display = current.resetTime.ToString() + " | " + remainingReset.ToString();

        if (!vars.currentTextValues.ContainsKey("Reset:") || vars.currentTextValues["Reset:"] != display)
        {
            vars.SetText("Reset:", display);
        }
    }
    else
    {
        vars.RemoveText("Reset:");
    }

    if (settings["Entities"])
    {
        string resetText = current.entity.ToString(); 
        vars.SetText("Entities:", resetText);
    }
    else
    {
        vars.RemoveText("Entities:");
    }

    if (settings["com_frametime"])
    {
            vars.cachedFrameTimeText = current.FrameTime.ToString() + " / 2147483647";
        vars.SetText("com_frametime:", vars.cachedFrameTimeText);
    }
    else
    {
        vars.RemoveText("com_frametime:");
    }

    if (settings["com_frametime_timer"])
    {
        
        long remainingTicks = 2147483647L - (long)current.FrameTime;

        
        int days = (int)(remainingTicks / (1000 * 60 * 60 * 24));
        int hours = (int)((remainingTicks % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
        int minutes = (int)((remainingTicks % (1000 * 60 * 60)) / (1000 * 60));
        int seconds = (int)((remainingTicks % (1000 * 60)) / 1000);
        int hundredths = (int)((remainingTicks % 1000) / 10); 

        string formattedTime;
        if (days > 0)
        {
            formattedTime = string.Format("{0}d {1}h {2}m {3}s", days, hours, minutes, seconds);
        }
        else if (hours > 0)
        {
            formattedTime = string.Format("{0}h {1}m {2}s", hours, minutes, seconds);
        }
        else if (minutes > 0)
        {
            formattedTime = string.Format("{0}m {1}s.{2:D2}", minutes, seconds, hundredths);
        }
        else
        {
            formattedTime = string.Format("{0}.{1:D2}s", seconds, hundredths);
        }

        vars.SetText("Frame Timer:", formattedTime);
    }
    else
    {
        vars.RemoveText("Frame Timer:");
    }

    
    
    
    
    
    

    try 
    {
        byte[] pointerBytes = current.childGSCStructPtr;
        if (pointerBytes != null && pointerBytes.Length == 8)
        {
            ulong childBase = BitConverter.ToUInt64(pointerBytes, 0);

            if (childBase >= 0x10000 && childBase <= 0x7FFFFFFFFFFF)
            {
                ulong finalAddress = childBase + 0x18;
                byte[] valueBytes = game.ReadBytes((IntPtr)finalAddress, 4);
                if (valueBytes != null && valueBytes.Length == 4)
                {
                    int childValue = BitConverter.ToInt32(valueBytes, 0);
                    vars.currentChildValue = childValue;

                    if (childValue > vars.maxChildValue)
                    {
                        vars.maxChildValue = childValue;
                    }

                    int remainingVars = 130000 - childValue;
                    vars.grenadesLeft = (int)(remainingVars / vars.grenadesLeftFactor);
                }

                bool runGSC = settings["GSC Threads"] || settings["GSC Debugger"] || 
                          settings["GSC_UNDEFINED"] || settings["GSC_POINTER"] || settings["GSC_STRING"] || 
                          settings["GSC_ISTRING"] || settings["GSC_VECTOR"] || settings["GSC_HASH"] || 
                          settings["GSC_FLOAT"] || settings["GSC_INTEGER"] || settings["GSC_CODEPOS"] || 
                          settings["GSC_PRECODEPOS"] || settings["GSC_FUNCTION"] || settings["GSC_STACK"] || 
                          settings["GSC_ANIMATION"] || settings["GSC_DEV_CODEPOS"] || settings["GSC_INC_CODEPOS"] || 
                          settings["GSC_THREAD_15"] || settings["GSC_NOTIFY_THREAD"] || settings["GSC_TIME_THREAD"] || 
                          settings["GSC_CHILD_THREAD"] || settings["GSC_CLASS"] || settings["GSC_STRUCT"] || 
                          settings["GSC_REMOVED_THREAD"] || settings["GSC_DELEGATE"];

            if (runGSC)
                {
                    byte[] varHeap = game.ReadBytes((IntPtr)childBase, 8320000);

                    if (varHeap != null && varHeap.Length == 8320000)
                    {
                        int[] gscTypeCounts = new int[25];
                        for (int i = 0; i < 130000; i++)
                        {
                            int typeOffset = (i * 64) + 8;
                            int varType = BitConverter.ToInt32(varHeap, typeOffset);
                            if (varType >= 0 && varType < 25) gscTypeCounts[varType]++;
                        }

                        int activeThreadCount = gscTypeCounts[15] + gscTypeCounts[16] + gscTypeCounts[17] + gscTypeCounts[18];
                        vars.activeThreads = activeThreadCount;
                        if (activeThreadCount > vars.maxActiveThreads) vars.maxActiveThreads = activeThreadCount;

                        vars.UpdateDetailedText(settings["GSC_UNDEFINED"], "GSC_UNDEFINED", "GSC Undefined", gscTypeCounts[0]);
                        vars.UpdateDetailedText(settings["GSC_POINTER"], "GSC_POINTER", "GSC Pointers", gscTypeCounts[1]);
                        vars.UpdateDetailedText(settings["GSC_STRING"], "GSC_STRING", "GSC Strings", gscTypeCounts[2]);
                        vars.UpdateDetailedText(settings["GSC_ISTRING"], "GSC_ISTRING", "GSC IStrings", gscTypeCounts[3]);
                        vars.UpdateDetailedText(settings["GSC_VECTOR"], "GSC_VECTOR", "GSC Vectors", gscTypeCounts[4]);
                        vars.UpdateDetailedText(settings["GSC_HASH"], "GSC_HASH", "GSC Hashes", gscTypeCounts[5]);
                        vars.UpdateDetailedText(settings["GSC_FLOAT"], "GSC_FLOAT", "GSC Floats", gscTypeCounts[6]);
                        vars.UpdateDetailedText(settings["GSC_INTEGER"], "GSC_INTEGER", "GSC Integers", gscTypeCounts[7]);
                        vars.UpdateDetailedText(settings["GSC_CODEPOS"], "GSC_CODEPOS", "GSC CodePos", gscTypeCounts[8]);
                        vars.UpdateDetailedText(settings["GSC_PRECODEPOS"], "GSC_PRECODEPOS", "GSC PreCodePos", gscTypeCounts[9]);
                        vars.UpdateDetailedText(settings["GSC_FUNCTION"], "GSC_FUNCTION", "GSC Functions", gscTypeCounts[10]);
                        vars.UpdateDetailedText(settings["GSC_STACK"], "GSC_STACK", "GSC Stacks", gscTypeCounts[11]);
                        vars.UpdateDetailedText(settings["GSC_ANIMATION"], "GSC_ANIMATION", "GSC Animations", gscTypeCounts[12]);
                        vars.UpdateDetailedText(settings["GSC_DEV_CODEPOS"], "GSC_DEV_CODEPOS", "GSC DevCodePos", gscTypeCounts[13]);
                        vars.UpdateDetailedText(settings["GSC_INC_CODEPOS"], "GSC_INC_CODEPOS", "GSC IncCodePos", gscTypeCounts[14]);
                        vars.UpdateDetailedText(settings["GSC_THREAD_15"], "GSC_THREAD_15", "GSC Active Threads", gscTypeCounts[15]);
                        vars.UpdateDetailedText(settings["GSC_NOTIFY_THREAD"], "GSC_NOTIFY_THREAD", "GSC Notify Threads", gscTypeCounts[16]);
                        vars.UpdateDetailedText(settings["GSC_TIME_THREAD"], "GSC_TIME_THREAD", "GSC Time Threads", gscTypeCounts[17]);
                        vars.UpdateDetailedText(settings["GSC_CHILD_THREAD"], "GSC_CHILD_THREAD", "GSC Child Threads", gscTypeCounts[18]);
                        vars.UpdateDetailedText(settings["GSC_CLASS"], "GSC_CLASS", "GSC Classes", gscTypeCounts[19]);
                        vars.UpdateDetailedText(settings["GSC_STRUCT"], "GSC_STRUCT", "GSC Structs", gscTypeCounts[20]);
                        vars.UpdateDetailedText(settings["GSC_REMOVED_THREAD"], "GSC_REMOVED_THREAD", "GSC Removed Threads", gscTypeCounts[21]);
                        vars.UpdateDetailedText(settings["GSC_DELEGATE"], "GSC_DELEGATE", "GSC Delegates", gscTypeCounts[22]);
                    }
                }
                else
                {
                    string[] gscNames = { "Undefined", "Pointers", "Strings", "IStrings", "Vectors", "Hashes", "Floats", "Integers", "CodePos", "PreCodePos", "Functions", "Stacks", "Animations", "DevCodePos", "IncCodePos", "Active Threads", "Notify Threads", "Time Threads", "Child Threads", "Classes", "Structs", "Removed Threads", "Delegates" };
                    foreach(string name in gscNames) vars.RemoveText("GSC " + name + ":");
                }
            }
        }
    }
    catch (Exception ex)
    {

    }

    if (settings["Child GSC Variable"])
    {
        vars.cachedGSCText = vars.currentChildValue.ToString() + " Max: " + vars.maxChildValue.ToString() + " / 130000";
        vars.SetText("Child GSC:", vars.cachedGSCText);
    }
    else
    {
        vars.RemoveText("Child GSC:");
    }

    if (settings["GSC Threads"])
    {
        string threadText = vars.activeThreads.ToString() + " Max: " + vars.maxActiveThreads.ToString();
        vars.SetText("GSC Threads:", threadText);
    }
    else
    {
        vars.RemoveText("GSC Threads:");
    }

    try 
    {
        byte[] soundPtrBytes = current.SquidAnimError;
        if (soundPtrBytes != null && soundPtrBytes.Length == 8)
        {
            ulong soundBase = BitConverter.ToUInt64(soundPtrBytes, 0);
            
            if (soundBase >= 0x10000 && soundBase <= 0x7FFFFFFFFFFF)
            {
                ulong counterAddress = soundBase + 0x218;
                
                byte[] counterBytes = game.ReadBytes((IntPtr)counterAddress, 4);
                if (counterBytes != null && counterBytes.Length == 4)
                {
                    int soundValue = BitConverter.ToInt32(counterBytes, 0);
                    vars.currentSoundValue = soundValue;
                    
                    if (soundValue > vars.maxSoundValue)
                    {
                        vars.maxSoundValue = soundValue;
                    }
                }
            }
        }
    }
    catch (Exception ex)
    {
        
    }

    if (settings["Grenades Left"])
    {
        string display;
        if (vars.grenadesLeft >= 0)
            display = vars.grenadesLeft.ToString();
        else if (vars.grenadesLeft == -1)
            display = "Updating...";
        else
            display = "Error";

        if (!vars.currentTextValues.ContainsKey("Grenades Left:") || 
            vars.currentTextValues["Grenades Left:"] != display)
        {
            vars.SetText("Grenades Left:", display);
            vars.lastGrenadesLeft = vars.grenadesLeft;
        }
    }
    else
    {
        vars.RemoveText("Grenades Left:");
    }

    if (settings["Hitmarkers"] || settings["Hitmarkers Per Hour"])
    {
        var vDict = (IDictionary<string, object>)vars;
        if (!vDict.ContainsKey("participationSnapshots") || vars.participationSnapshots == null)
            vars.participationSnapshots = new Dictionary<int, int>();
        if (!vDict.ContainsKey("participationStreaks") || vars.participationStreaks == null)
            vars.participationStreaks = new Dictionary<int, int>();
        if (!vDict.ContainsKey("participationValueOffsets") || vars.participationValueOffsets == null)
            vars.participationValueOffsets = new Dictionary<int, int>();
        if (!vDict.ContainsKey("participationDebugTick"))
            vars.participationDebugTick = 0;
        if (!vDict.ContainsKey("lastParticipationVal"))
            vars.lastParticipationVal = -1;

        var snapshots = (Dictionary<int, int>)vars.participationSnapshots;
        var streaks = (Dictionary<int, int>)vars.participationStreaks;
        var valOffsets = (Dictionary<int, int>)vars.participationValueOffsets;

        string[] validZombieMaps = new string[] {
            "zm_zod", "zm_factory", "zm_castle", "zm_island", "zm_stalingrad", 
            "zm_genesis", "zm_prototype", "zm_asylum", "zm_sumpf", "zm_theater", 
            "zm_cosmodrome", "zm_temple", "zm_moon", "zm_tomb"
        };

        bool isValidZombieMap = Array.IndexOf(validZombieMaps, current.currentMap) != -1;
        bool isGameplayActive = isValidZombieMap && current.round_counter >= 1;

        if (current.currentMap != vars.participationLastMap)
        {
            vars.participationIndex = -1;
            vars.participationLastMap = current.currentMap;
            snapshots.Clear();
            streaks.Clear();
            valOffsets.Clear();
            vars.lastParticipationVal = -1;
            if (isValidZombieMap || current.currentMap == "core_frontend")
            {
            }
        }

        if (current.levelTime == 0 && old.levelTime > 0)
        {
            vars.hitmarkerCounter = 0;
            vars.lastParticipationVal = -1;
        }

        if (vars.participationIndex != -1)
        {
            int subOffset = valOffsets.ContainsKey(vars.participationIndex) ? valOffsets[vars.participationIndex] : 0x00;
            ulong currentEntry = current.ParticipationPtr + (ulong)(vars.participationIndex * 0x40) + (ulong)subOffset;
            
            int currentVal = game.ReadValue<int>((IntPtr)currentEntry);
            int f1 = game.ReadValue<int>((IntPtr)(currentEntry + 4));
            int f3 = game.ReadValue<int>((IntPtr)(currentEntry + 12));

            bool isValidVal = (currentVal >= 0 && currentVal <= 19);
            bool isValidStruct = (f1 == 1024 && f3 == 76);

            if (!isValidVal || !isValidStruct)
            {
                vars.participationIndex = -1;
                snapshots.Clear();
                streaks.Clear();
                valOffsets.Clear();
                vars.lastParticipationVal = -1;
            }
            else
            {
                if ((int)vars.lastParticipationVal != -1)
                {
                    int lastVal = (int)vars.lastParticipationVal;
                    int delta = (currentVal - lastVal + 20) % 20;

                    if (delta >= 1 && delta <= 5)
                    {
                        vars.hitmarkerCounter = (int)vars.hitmarkerCounter + delta;
                        vars.lastParticipationVal = currentVal;
                    }
                }
                else
                {
                    vars.lastParticipationVal = currentVal;
                }

                snapshots[vars.participationIndex] = currentVal;
            }
        }

        if (vars.participationIndex == -1 && current.ParticipationPtr != 0 && isGameplayActive)
        {
            int startIdx = 50000;
            int countIdx = 170000;
            int stride = 0x40;
            int bufferSize = countIdx * stride + 0x1AC;

            ulong scanBaseAddr = current.ParticipationPtr + (ulong)(startIdx * stride);
            byte[] buffer = game.ReadBytes((IntPtr)scanBaseAddr, bufferSize);

            vars.participationDebugTick = (int)vars.participationDebugTick + 1;

            if (buffer != null && buffer.Length >= bufferSize)
            {
                int patternMatchesCount = 0;
                int[] candidateSubOffsets = new int[] { 0x00, 0x10, 0x18, 0x20, 0x28, 0x30 };

                for (int k = 0; k < countIdx; k++)
                {
                    int entryOffset = k * stride;
                    int index = startIdx + k;

                    foreach (int subOffset in candidateSubOffsets)
                    {
                        int checkOffset = entryOffset + subOffset;
                        if (checkOffset + 16 > buffer.Length) continue;

                        int val = BitConverter.ToInt32(buffer, checkOffset);
                        int f1 = BitConverter.ToInt32(buffer, checkOffset + 4);
                        int f2 = BitConverter.ToInt32(buffer, checkOffset + 8);
                        int f3 = BitConverter.ToInt32(buffer, checkOffset + 12);

                        if (val >= 0 && val <= 19 && f1 == 1024 && f3 == 76)
                        {
                            patternMatchesCount++;
                            int key = index * 100 + subOffset;

                            int prevVal = snapshots.ContainsKey(key) ? snapshots[key] : -1;

                            if (prevVal != -1)
                            {
                                int delta = (val - prevVal + 20) % 20;

                                if (delta >= 1 && delta <= 3)
                                {
                                    int streak = streaks.ContainsKey(key) ? streaks[key] + 1 : 1;
                                    streaks[key] = streak;


                                    if (streak >= 2)
                                    {
                                        vars.participationIndex = index;
                                        valOffsets[index] = subOffset;
                                        vars.lastParticipationVal = val;

                                        ulong matchedAddress = scanBaseAddr + (ulong)entryOffset + (ulong)subOffset;
                                        break;
                                    }
                                }
                                else if (delta != 0)
                                {
                                    streaks[key] = 0;
                                }
                            }

                            snapshots[key] = val;
                        }
                    }

                    if (vars.participationIndex != -1)
                        break;
                }
            }
        }

        if (settings["Hitmarkers"])
        {
            vars.SetText("_Hitmarkers:", vars.hitmarkerCounter.ToString());
        }
        else
        {
            vars.RemoveText("_Hitmarkers:");
        }
    }
    else
    {
        vars.RemoveText("_Hitmarkers:");
        vars.participationIndex = -1;

        var vDict = (IDictionary<string, object>)vars;
        if (vDict.ContainsKey("participationSnapshots") && vars.participationSnapshots != null) 
            ((Dictionary<int, int>)vars.participationSnapshots).Clear();
        if (vDict.ContainsKey("participationStreaks") && vars.participationStreaks != null) 
            ((Dictionary<int, int>)vars.participationStreaks).Clear();
        if (vDict.ContainsKey("participationValueOffsets") && vars.participationValueOffsets != null) 
            ((Dictionary<int, int>)vars.participationValueOffsets).Clear();
    }

    if (settings["Sound Error"])
    {
        string soundText = vars.currentSoundValue.ToString() + " Max: " + vars.maxSoundValue.ToString();
        vars.SetText("Sound Error:", soundText);
    }
    else
    {
        vars.RemoveText("Sound Error:");
    }

    try 
    {
        byte[] ptrBytes = current.SquidAnimError;
        if (ptrBytes != null && ptrBytes.Length == 8)
        {
            ulong soundBase = BitConverter.ToUInt64(ptrBytes, 0);
            
            if (soundBase >= 0x10000 && soundBase <= 0x7FFFFFFFFFFF)
            {
                byte[] valueBytes = game.ReadBytes((IntPtr)soundBase, 4);
                if (valueBytes != null && valueBytes.Length == 4)
                {
                    int rawValue = BitConverter.ToInt32(valueBytes, 0);
                    vars.currentRawPtrValue = rawValue;
                    
                    if (rawValue > vars.maxRawPtrValue)
                    {
                        vars.maxRawPtrValue = rawValue;
                    }
                }
            }
        }
    }
    catch (Exception ex)
    {
        
    }
 
    if (current.levelTime == 0)
    {
        vars.CSCmaxChildValue = 0;
        vars.currentCSCValue = 0;
        vars.maxSoundValue = 0;
        vars.maxRawPtrValue = 0;
    }

    try 
    {
        byte[] pointerBytes = current.childCSCStructPtr;
        if (pointerBytes != null && pointerBytes.Length == 8)
        {
            ulong childBase = BitConverter.ToUInt64(pointerBytes, 0);
            
            if (childBase >= 0x10000 && childBase <= 0x7FFFFFFFFFFF)
            {
                ulong finalAddress = childBase + 0x18;
                byte[] valueBytes = game.ReadBytes((IntPtr)finalAddress, 4);
                if (valueBytes != null && valueBytes.Length == 4)
                {
                    int childValue = BitConverter.ToInt32(valueBytes, 0);
                    vars.currentCSCValue = childValue;
                    
                    if (childValue > vars.CSCmaxChildValue)
                    {
                        vars.CSCmaxChildValue = childValue;
                    }
                }

                bool runCSC = settings["CSC Threads"] || settings["CSC Debugger"] || 
                          settings["CSC_UNDEFINED"] || settings["CSC_POINTER"] || settings["CSC_STRING"] || 
                          settings["CSC_ISTRING"] || settings["CSC_VECTOR"] || settings["CSC_HASH"] || 
                          settings["CSC_FLOAT"] || settings["CSC_INTEGER"] || settings["CSC_CODEPOS"] || 
                          settings["CSC_PRECODEPOS"] || settings["CSC_FUNCTION"] || settings["CSC_STACK"] || 
                          settings["CSC_ANIMATION"] || settings["CSC_DEV_CODEPOS"] || settings["CSC_INC_CODEPOS"] || 
                          settings["CSC_THREAD_15"] || settings["CSC_NOTIFY_THREAD"] || settings["CSC_TIME_THREAD"] || 
                          settings["CSC_CHILD_THREAD"] || settings["CSC_CLASS"] || settings["CSC_STRUCT"] || 
                          settings["CSC_REMOVED_THREAD"] || settings["CSC_DELEGATE"];

            if (runCSC)
                {
                    byte[] cscVarHeap = game.ReadBytes((IntPtr)childBase, 4160000);

                    if (cscVarHeap != null && cscVarHeap.Length == 4160000)
                    {
                        int[] cscTypeCounts = new int[25];
                        for (int i = 0; i < 65000; i++)
                        {
                            int typeOffset = (i * 64) + 8;
                            int varType = BitConverter.ToInt32(cscVarHeap, typeOffset);
                            if (varType >= 0 && varType < 25) cscTypeCounts[varType]++;
                        }

                        int activeCSCThreadCount = cscTypeCounts[15] + cscTypeCounts[16] + cscTypeCounts[17] + cscTypeCounts[18];
                        vars.activeCSCThreads = activeCSCThreadCount;
                        if (activeCSCThreadCount > vars.maxActiveCSCThreads) vars.maxActiveCSCThreads = activeCSCThreadCount;

                        vars.UpdateDetailedText(settings["CSC_UNDEFINED"], "CSC_UNDEFINED", "CSC Undefined", cscTypeCounts[0]);
                        vars.UpdateDetailedText(settings["CSC_POINTER"], "CSC_POINTER", "CSC Pointers", cscTypeCounts[1]);
                        vars.UpdateDetailedText(settings["CSC_STRING"], "CSC_STRING", "CSC Strings", cscTypeCounts[2]);
                        vars.UpdateDetailedText(settings["CSC_ISTRING"], "CSC_ISTRING", "CSC IStrings", cscTypeCounts[3]);
                        vars.UpdateDetailedText(settings["CSC_VECTOR"], "CSC_VECTOR", "CSC Vectors", cscTypeCounts[4]);
                        vars.UpdateDetailedText(settings["CSC_HASH"], "CSC_HASH", "CSC Hashes", cscTypeCounts[5]);
                        vars.UpdateDetailedText(settings["CSC_FLOAT"], "CSC_FLOAT", "CSC Floats", cscTypeCounts[6]);
                        vars.UpdateDetailedText(settings["CSC_INTEGER"], "CSC_INTEGER", "CSC Integers", cscTypeCounts[7]);
                        vars.UpdateDetailedText(settings["CSC_CODEPOS"], "CSC_CODEPOS", "CSC CodePos", cscTypeCounts[8]);
                        vars.UpdateDetailedText(settings["CSC_PRECODEPOS"], "CSC_PRECODEPOS", "CSC PreCodePos", cscTypeCounts[9]);
                        vars.UpdateDetailedText(settings["CSC_FUNCTION"], "CSC_FUNCTION", "CSC Functions", cscTypeCounts[10]);
                        vars.UpdateDetailedText(settings["CSC_STACK"], "CSC_STACK", "CSC Stacks", cscTypeCounts[11]);
                        vars.UpdateDetailedText(settings["CSC_ANIMATION"], "CSC_ANIMATION", "CSC Animations", cscTypeCounts[12]);
                        vars.UpdateDetailedText(settings["CSC_DEV_CODEPOS"], "CSC_DEV_CODEPOS", "CSC DevCodePos", cscTypeCounts[13]);
                        vars.UpdateDetailedText(settings["CSC_INC_CODEPOS"], "CSC_INC_CODEPOS", "CSC IncCodePos", cscTypeCounts[14]);
                        vars.UpdateDetailedText(settings["CSC_THREAD_15"], "CSC_THREAD_15", "CSC Active Threads", cscTypeCounts[15]);
                        vars.UpdateDetailedText(settings["CSC_NOTIFY_THREAD"], "CSC_NOTIFY_THREAD", "CSC Notify Threads", cscTypeCounts[16]);
                        vars.UpdateDetailedText(settings["CSC_TIME_THREAD"], "CSC_TIME_THREAD", "CSC Time Threads", cscTypeCounts[17]);
                        vars.UpdateDetailedText(settings["CSC_CHILD_THREAD"], "CSC_CHILD_THREAD", "CSC Child Threads", cscTypeCounts[18]);
                        vars.UpdateDetailedText(settings["CSC_CLASS"], "CSC_CLASS", "CSC Classes", cscTypeCounts[19]);
                        vars.UpdateDetailedText(settings["CSC_STRUCT"], "CSC_STRUCT", "CSC Structs", cscTypeCounts[20]);
                        vars.UpdateDetailedText(settings["CSC_REMOVED_THREAD"], "CSC_REMOVED_THREAD", "CSC Removed Threads", cscTypeCounts[21]);
                        vars.UpdateDetailedText(settings["CSC_DELEGATE"], "CSC_DELEGATE", "CSC Delegates", cscTypeCounts[22]);
                    }
                }
                else
                {
                    string[] cscNames = { "Undefined", "Pointers", "Strings", "IStrings", "Vectors", "Hashes", "Floats", "Integers", "CodePos", "PreCodePos", "Functions", "Stacks", "Animations", "DevCodePos", "IncCodePos", "Active Threads", "Notify Threads", "Time Threads", "Child Threads", "Classes", "Structs", "Removed Threads", "Delegates" };
                    foreach(string name in cscNames) vars.RemoveText("CSC " + name + ":");
                }
            }
        }
    }
    catch (Exception ex)
    {
    }

    if (settings["Child CSC Variable"])
    {
        vars.cachedCSCText = vars.currentCSCValue.ToString() + " Max: " + vars.CSCmaxChildValue.ToString() + " / 65000";
        vars.SetText("Child CSC:", vars.cachedCSCText);
    }
    else
    {
        vars.RemoveText("Child CSC:");
    }

    if (settings["CSC Threads"])
    {
        string cscThreadText = vars.activeCSCThreads.ToString() + " Max: " + vars.maxActiveCSCThreads.ToString();
        vars.SetText("CSC Threads:", cscThreadText);
    }
    else
    {
        vars.RemoveText("CSC Threads:");
    }

    if (settings["MemTree"])
    {
        if (current.levelTime == 0)
        {
            vars.MemMAXTreeValue = 0;
        }

        if (current.MemTree > vars.MemMAXTreeValue)
            {
                vars.MemMAXTreeValue = current.MemTree;
            }

        string resetText = current.MemTree.ToString() + " Max: " + vars.MemMAXTreeValue.ToString() + " / 130000";
        vars.SetText("MemTree:", resetText);
    }
    else
    {
        vars.RemoveText("MemTree:");
    }

    if (settings["BG Strings"])
    {
        if (current.levelTime == 0)
        {
            vars.maxBGStringsValue = 0;
        }

        try 
        {
            IntPtr moduleBase = game.MainModule.BaseAddress;
            IntPtr baseAddr = moduleBase + 0x3766D20;
            
            int arraySize = 2049 * 1032;
            byte[] buffer = game.ReadBytes(baseAddr, arraySize);

            if (buffer != null && buffer.Length == arraySize)
            {
                int activeCount = 0;
                for (int i = 1; i <= 2048; i++)
                {
                    int slotOffset = i * 1032;
                    int hashOffset = slotOffset + 1024;
                    int hash = BitConverter.ToInt32(buffer, hashOffset);

                    if (hash != 0)
                    {
                        activeCount++;
                    }
                }

                vars.currentBGStringsValue = activeCount;
                if (activeCount > vars.maxBGStringsValue)
                {
                    vars.maxBGStringsValue = activeCount;
                }
            }
        }
        catch (Exception ex)
        {
        }

        string bgStringsText = vars.currentBGStringsValue.ToString() +  " / 2046";
        vars.SetText("BG Strings:", bgStringsText);
    }
    else
    {
        vars.RemoveText("BG Strings:");
    }

    if (settings["G-Spawn"])
    {
        int numFree = 0;
        ulong currentFree = current.GSpawnFreeListHead;

        while (currentFree != 0 && numFree < 1024)
        {
            numFree++;
            currentFree = game.ReadValue<ulong>((IntPtr)(currentFree + 1200));
        }

        int activeEntities = current.GSpawnAddr - numFree;

        string gspawnText = activeEntities.ToString() + " Max: " + current.GSpawnAddr.ToString() + " / 1022";
        vars.SetText("G-Spawn:", gspawnText);
    }
    else
    {
        vars.RemoveText("G-Spawn:");
    }

    if (settings["G-SpawnFake"])
    {
        string resetText = current.GSpawnFakeAddr.ToString() + " / 1024"; 
        vars.SetText("G_SpawnFake:", resetText);
    }
    else
    {
        vars.RemoveText("G_SpawnFake:");
    }

    if (current.levelTime == 0)
    {
        vars.hitmarkerCounter = 0;
        vars.ignoreNextHit = false;
    }

    if (settings["Hitmarkers Per Hour"])
    {
    
    if (settings["Predict Hours"] && !vars.hasAskedForHours)
    {
        
        try 
        {
            
            Form prompt = new Form()
            {
                Width = 350,
                Height = 180,
                FormBorderStyle = FormBorderStyle.FixedDialog,
                Text = "Set Prediction Hours",
                StartPosition = FormStartPosition.CenterScreen
            };
            
            Label textLabel = new Label() { 
                Left = 20, 
                Top = 20, 
                Width = 300, 
                Text = "Enter number of hours to predict hitmarkers (45-60):" 
            };
            
            
            NumericUpDown inputBox = new NumericUpDown() { 
                Left = 20, 
                Top = 50, 
                Width = 100, 
                Minimum = 45, 
                Maximum = 60, 
                Value = 48 
            };
            
            Button confirmation = new Button() { 
                Text = "OK", 
                Left = 230, 
                Top = 110, 
                Width = 80, 
                DialogResult = DialogResult.OK 
            };
            
            confirmation.Click += (sender, e) => { 
                vars.predictionHours = (int)inputBox.Value;
                prompt.Close(); 
            };
            
            prompt.Controls.Add(textLabel);
            prompt.Controls.Add(inputBox);
            prompt.Controls.Add(confirmation);
            prompt.AcceptButton = confirmation;
            
            
            prompt.ShowDialog();
            
            
            vars.hasAskedForHours = true;
            
            
            if (File.Exists(vars.boxHitsFilePath))
            {
                
                string[] allLinesArray = File.ReadAllLines(vars.boxHitsFilePath);
                List<string> allLines = new List<string>();
                foreach (string line in allLinesArray)
                {
                    allLines.Add(line);
                }
                
                
                for (int i = allLines.Count - 1; i >= 0; i--)
                {
                    if (allLines[i].StartsWith("HPH Prediction Hours:"))
                    {
                        allLines.RemoveAt(i);
                    }
                }
                
                
                allLines.Add("HPH Prediction Hours: " + vars.predictionHours);
                File.WriteAllLines(vars.boxHitsFilePath, allLines.ToArray());
            }
        }
        catch (Exception ex)
        {
            
            vars.predictionHours = 48;
            vars.hasAskedForHours = true;
        }
    }
    
    
    if (current.levelTime < vars.hitmarkerStartTime)
    {
        vars.hitmarkerStartTime = current.levelTime;
        vars.hitmarkersAtStart = vars.hitmarkerCounter;
    }

    
    if (vars.hitmarkerStartTime == 0)
    {
        vars.hitmarkerStartTime = current.levelTime;
        vars.hitmarkersAtStart = vars.hitmarkerCounter;
    }

    
    double elapsedSeconds = (current.levelTime - vars.hitmarkerStartTime) * 0.05;
    double elapsedHours = elapsedSeconds / 3600.0;

    
    int hitmarkersInPeriod = vars.hitmarkerCounter - vars.hitmarkersAtStart;

    
    if (elapsedHours > 0.001)
    {
        vars.hitmarkersPerHour = hitmarkersInPeriod / elapsedHours;

        
        if (settings["Predict Hours"])
        {
            
            
            if (vars.predictionHours < 45 || vars.predictionHours > 60)
            {
                vars.predictionHours = 48;
            }
            
            vars.predictedHitmarkers = vars.hitmarkerCounter + (int)(vars.hitmarkersPerHour * (vars.predictionHours - elapsedHours));
            
            
            string displayText = string.Format("{0} HPH | {1}h: {2}", 
                (int)vars.hitmarkersPerHour, 
                vars.predictionHours, 
                vars.predictedHitmarkers);
            vars.SetText("HPH:", displayText);
        }
        else
        {
            vars.hasAskedForHours = true;
            
            string displayText = string.Format("{0} HPH", (int)vars.hitmarkersPerHour);
            vars.SetText("HPH:", displayText);
        }
    }
    else
    {
        vars.hitmarkersPerHour = 0;
        if (settings["Predict Hours"])
        {
            
            if (vars.predictionHours < 45 || vars.predictionHours > 60)
            {
                vars.predictionHours = 48;
            }
            
            string displayText = string.Format("0 HPH | {0}h: {1}", vars.predictionHours, vars.hitmarkerCounter);
            vars.SetText("HPH:", displayText);
        }
        else
        {
            vars.SetText("HPH:", "0 HPH");
        }
    }
    }
    else
    {
        vars.RemoveText("HPH:");
    }

    if (!settings["Predict Hours"] && vars.hasAskedForHours)
    {
        vars.hasAskedForHours = false;
    }

    
    if (settings["Rags Slams Counter"])
    {
        if (old.RagsSlams == 0 && current.RagsSlams == 45)
        {
            vars.ragsSlamsCounter++; 
        }

        
        vars.SetText("Rags Slams Counter:", vars.ragsSlamsCounter);
    }
    else
    {
        vars.RemoveText("Rags Slams Counter:");
    }

    if (settings["Nade Counter"])
    {
        
        if (current.RagsSlams == 38 && old.RagsSlams != 38)
        {
            vars.nadeCounter++; 
            
        }

        
        vars.SetText("Nade Counter:", vars.nadeCounter);
    }
    else
    {
        vars.RemoveText("Nade Counter:");
    }

    if (settings["Valk Counter"])
    {
        if (current.round_counter < 8 || (current.round_counter == 8 && current.levelTime == 0))
        {
            vars.valksCounter = 0;
        }

        if (current.ValksKill != old.ValksKill)
        {
            vars.valksCounter++; 
        }

        vars.SetText("Valk Counter:", vars.valksCounter);
    }
    else
    {
        vars.RemoveText("Valk Counter:");
    }

    
    if (settings["Reset Timer"])
    {
        if (current.levelTime > 0)
        {
            if (current.round_counter == 1 && old.round_counter == 0)
            {
                if (vars.entities_5min_history != null) vars.entities_5min_history.Clear();
                vars.last_5min_sample_time = -1;
            }

            if (vars.last_5min_sample_time == -1 || current.levelTime >= vars.last_5min_sample_time + 20)
            {
                vars.entities_5min_history.Enqueue(Tuple.Create(current.levelTime, current.resetTimeEntities));
                vars.last_5min_sample_time = current.levelTime;

                while (vars.entities_5min_history.Count > 1)
                {
                    Tuple<int, int> oldest = (Tuple<int, int>)vars.entities_5min_history.Peek();
                    if (current.levelTime - oldest.Item1 > 6000)
                    {
                        vars.entities_5min_history.Dequeue();
                    }
                    else
                    {
                        break;
                    }
                }
            }
        }

        int snapshotsValue = current.resetTime;
        if (snapshotsValue > 0)
        {
            if (vars.snapshots_last_value == -1)
            {
                vars.snapshots_last_value = snapshotsValue;
            }
            else
            {
                int resetDelta = snapshotsValue - vars.snapshots_last_value;

                if (vars.snapshots_last_delta > 0 && resetDelta > 0)
                {
                    double ratio = (double)resetDelta / (double)vars.snapshots_last_delta;
                    if (ratio > 1.8 && ratio < 2.2)
                    {
                        resetDelta = resetDelta / 2;
                    }
                }

                if (resetDelta > 0)
                {
                    vars.snapshots_consistent_reads++;

                    if (vars.snapshots_consistent_reads >= 3)
                    {
                        long dynamicMax = 2147483646L - current.resetThreshold;
                        long remaining = dynamicMax - (long)snapshotsValue;

                        if (resetDelta < 1000000)
                        {
                            double remainingFrames = (double)remaining / (double)resetDelta;
                            vars.snapshots_last_seconds = remainingFrames * 0.05;
                            vars.snapshots_consistent_reads = 0;
                        }
                    }
                    vars.snapshots_last_delta = resetDelta;
                }
                else if (resetDelta < 0)
                {
                    vars.snapshots_consistent_reads = 0;
                    vars.snapshots_last_seconds = double.MaxValue;
                }

                vars.snapshots_last_value = snapshotsValue;
            }
        }

        int entitiesValue = current.resetTimeEntities;
        if (entitiesValue > 0)
        {
            if (vars.entities_last_value == -1)
            {
                vars.entities_last_value = entitiesValue;
            }
            else
            {
                int resetDelta = entitiesValue - vars.entities_last_value;

                if (vars.entities_last_delta > 0 && resetDelta > 0)
                {
                    double ratio = (double)resetDelta / (double)vars.entities_last_delta;
                    if (ratio > 1.8 && ratio < 2.2)
                    {
                        resetDelta = resetDelta / 2;
                    }
                }

                if (resetDelta > 0)
                {
                    vars.entities_consistent_reads++;

                    if (vars.entities_consistent_reads >= 3)
                    {
                        long dynamicMax = 2147483646L - current.resetThresholdEntities;
                        long remaining = dynamicMax - (long)entitiesValue;

                        if (resetDelta < 1000000)
                        {
                            double effectiveDelta = (double)resetDelta;

                            if (vars.entities_5min_history.Count > 1)
                            {
                                Tuple<int, int> oldest = (Tuple<int, int>)vars.entities_5min_history.Peek();
                                int deltaTicks = current.levelTime - oldest.Item1;
                                int deltaEnt = current.resetTimeEntities - oldest.Item2;

                                if (deltaTicks >= 6000 && deltaEnt > 0)
                                {
                                    effectiveDelta = (double)deltaEnt / (double)deltaTicks;
                                }
                            }

                            double remainingFrames = (double)remaining / effectiveDelta;
                            vars.entities_last_seconds = remainingFrames * 0.05;
                            vars.entities_consistent_reads = 0;
                        }
                    }
                    vars.entities_last_delta = resetDelta;
                }
                else if (resetDelta < 0)
                {
                    vars.entities_consistent_reads = 0;
                    vars.entities_last_seconds = double.MaxValue;
                }

                vars.entities_last_value = entitiesValue;
            }
        }

        double remainingSeconds = Math.Min(vars.snapshots_last_seconds, vars.entities_last_seconds);

        if (remainingSeconds < double.MaxValue && remainingSeconds > 0)
        {
            int hours = (int)(remainingSeconds / 3600);
            int minutes = (int)((remainingSeconds - (hours * 3600)) / 60);
            int seconds = (int)(remainingSeconds - (hours * 3600) - (minutes * 60));

            string formattedResetText;
            if (hours > 0)
            {
                formattedResetText = string.Format("{0}:{1:D2}:{2:D2}", hours, minutes, seconds);
            }
            else if (minutes > 0)
            {
                formattedResetText = string.Format("{0}:{1:D2}", minutes, seconds);
            }
            else
            {
                formattedResetText = string.Format("{0}", seconds);
            }

            vars.cachedResetTimer = formattedResetText;
            vars.SetText("Reset Timer:", formattedResetText);
        }
        else
        {
            if (!string.IsNullOrEmpty(vars.cachedResetTimer))
            {
                vars.SetText("Reset Timer:", vars.cachedResetTimer);
            }
        }
    }
    else
    {
        vars.RemoveText("Reset Timer:");
        vars.snapshots_last_value = -1;
        vars.snapshots_consistent_reads = 0;
        vars.snapshots_last_delta = 0;
        vars.snapshots_last_seconds = double.MaxValue;

        vars.entities_last_value = -1;
        vars.entities_consistent_reads = 0;
        vars.entities_last_delta = 0;
        vars.entities_last_seconds = double.MaxValue;

        if (vars.entities_5min_history != null) vars.entities_5min_history.Clear();
        vars.last_5min_sample_time = -1;
    }
    }

    
    if (settings["Darkness"])
    {
            long remainingDarkness = 4194303L - current.darknessAddr;
            vars.cachedDarknessText = "(" + remainingDarkness.ToString() + ") " + current.darknessAddr.ToString() + " / 4194303";
        vars.SetText("Darkness:", vars.cachedDarknessText);
    }
    else
    {
        vars.RemoveText("Darkness:");
    }

    if (settings["Velocity"])
    {
        var vDict = (IDictionary<string, object>)vars;
        if (!vDict.ContainsKey("maxSpeed2D")) vars.maxSpeed2D = 0.0;
        if (!vDict.ContainsKey("lastMaxSpeedTime")) vars.lastMaxSpeedTime = DateTime.Now;

        double speed2D = Math.Sqrt((double)current.velX * current.velX + (double)current.velY * current.velY);
        DateTime now = DateTime.Now;

        if ((now - (DateTime)vars.lastMaxSpeedTime).TotalSeconds > 2.5)
        {
            vars.maxSpeed2D = speed2D;
            vars.lastMaxSpeedTime = now;
        }
        else if (speed2D > (double)vars.maxSpeed2D)
        {
            vars.maxSpeed2D = speed2D;
            vars.lastMaxSpeedTime = now;
        }

        string velText = string.Format("{0:F1} (Peak: {1:F1})", speed2D, vars.maxSpeed2D);
        vars.SetText("Velocity:", velText);
    }
    else
    {
        vars.RemoveText("Velocity:");
        var vDict = (IDictionary<string, object>)vars;
        if (vDict.ContainsKey("maxSpeed2D")) vars.maxSpeed2D = 0.0;
    }

    if (settings["Clear Counters"])
    {
        vars.ragsSlamsCounter = 0;
        vars.nadeCounter = 0;
        vars.valksCounter = 0;
        vars.hitmarkerCounter = 0;

        
        string[] lines = {
            "Rags Slams: 0",
            "Nade Count: 0",
            "Valk Count: 0",
            "Hitmarker Count: 0",
            "GSC Max Value: 0",
            "CSC Max Value: 0", 
            "GSC Current Value: 0",
            "CSC Current Value: 0"
        };
        File.WriteAllLines(vars.boxHitsFilePath, lines);

        vars.SetText("Counters Cleared!", "You can uncheck me!");
    }
    else
    {
        vars.RemoveText("Counters Cleared!");
    }


    
    if (settings["Trap Timers"])
    {
        var data = new Dictionary<string, Dictionary<string, object>>
        {
            
            {"bridge",     new Dictionary<string, object> { {"displayName", "Bridge Trap"}, {"byteOffset", 34}, {"bitMask", 0x08}}},
            {"jugtrap",    new Dictionary<string, object> { {"displayName", "Kuda Trap"}, {"byteOffset", 34}, {"bitMask", 0x02}}},
            {"mkder",      new Dictionary<string, object> { {"displayName", "VMP Trap"}, {"byteOffset", 34}, {"bitMask", 0x04}}},

            
            {"courtyard",  new Dictionary<string, object> { {"displayName", "Courtyard Trap"}, {"byteOffset", 66}, {"bitMask", 0x80}}},

            
            {"planetrap",  new Dictionary<string, object> { {"displayName", "Plane Trap"}, {"duration", 1200}, {"byteOffset", 42}, {"bitMask", 0x01}}},
            {"fantrap",    new Dictionary<string, object> { {"displayName", "Fan Trap"}, {"duration", 1200}, {"byteOffset", 58}, {"bitMask", 0x80}}},

            
            {"bunker",     new Dictionary<string, object> { {"displayName", "Bunker Trap"}, {"byteOffset", 45}, {"bitMask", 0x20}}},

            
            {"camptrap",   new Dictionary<string, object> { {"displayName", "Verruckt Trap"}, {"byteOffset", 58}, {"bitMask", 0x20}}},

            
            {"doubletap",  new Dictionary<string, object> { {"displayName", "Double Tap Trap"}, {"byteOffset", 37}, {"bitMask", 0x10}}},
            {"speedcola",  new Dictionary<string, object> { {"displayName", "Speed Cola Trap"}, {"byteOffset", 37}, {"bitMask", 0x08}}},

            
            {"comm",       new Dictionary<string, object> { {"displayName", "Comm Room Trap"}, {"byteOffset", 26}, {"bitMask", 0x40}}},
            {"doc",        new Dictionary<string, object> { {"displayName", "Doctor's Quarters Trap"}, {"byteOffset", 6}, {"bitMask", 0x10}}},
            {"fishing",    new Dictionary<string, object> { {"displayName", "Fishing Hut Trap"}, {"byteOffset", 6}, {"bitMask", 0x20}}},
            {"storage",    new Dictionary<string, object> { {"displayName", "Storage Trap"}, {"byteOffset", 26}, {"bitMask", 0x80}}},

            
            {"kinoft",     new Dictionary<string, object> { {"displayName", "Fire Trap"}, {"byteOffset", 2}, {"bitMask", 0x40}}},
            {"m8room",     new Dictionary<string, object> { {"displayName", "M8 Trap"}, {"byteOffset", 2}, {"bitMask", 0x20}}},

            
            {"vesper",     new Dictionary<string, object> { {"displayName", "Stamin-Up Trap"}, {"byteOffset", 10}, {"bitMask", 0x04}}},
            {"kn",         new Dictionary<string, object> { {"displayName", "Mule Kick Trap"}, {"byteOffset", 10}, {"bitMask", 0x08}}}
        };

        
        var altData = new Dictionary<string, Dictionary<string, object>>
        {
            {"bunker",     new Dictionary<string, object> { {"value", 176}, {"displayName", "Bunker Trap"} }},
            {"kinoft",     new Dictionary<string, object> { {"value", 2},   {"displayName", "Fire Trap"} }},
            {"m8room",     new Dictionary<string, object> { {"value", 3},   {"displayName", "M8 Trap"} }},
            {"camptrap",   new Dictionary<string, object> { {"value", 280}, {"displayName", "Verruckt Trap"} }},
            {"comm",       new Dictionary<string, object> { {"value", 147}, {"displayName", "Comm Room Trap"} }},
            {"doc",        new Dictionary<string, object> { {"value", 49},  {"displayName", "Doctor's Quarters Trap"} }},
            {"fishing",    new Dictionary<string, object> { {"value", 48},  {"displayName", "Fishing Hut Trap"} }},
            {"storage",    new Dictionary<string, object> { {"value", 146}, {"displayName", "Storage Trap"} }},
            {"bridge",     new Dictionary<string, object> { {"value", 145}, {"displayName", "Bridge Trap"} }},
            {"jugtrap",    new Dictionary<string, object> { {"value", 147}, {"displayName", "Kuda Trap"} }},
            {"mkder",      new Dictionary<string, object> { {"value", 146}, {"displayName", "VMP Trap"} }},
            {"doubletap",  new Dictionary<string, object> { {"value", 153}, {"displayName", "Double Tap Trap"} }},
            {"speedcola",  new Dictionary<string, object> { {"value", 154}, {"displayName", "Speed Cola Trap"} }},
            {"vesper",     new Dictionary<string, object> { {"value", 28},  {"displayName", "Stamin-Up Trap"} }},
            {"kn",         new Dictionary<string, object> { {"value", 27},  {"displayName", "Mule Kick Trap"} }},
            {"courtyard",  new Dictionary<string, object> { {"value", 224}, {"displayName", "Courtyard Trap"} }},
            {"planetrap",  new Dictionary<string, object> { {"value", 164}, {"displayName", "Plane Trap"}, {"duration", 1200} }},
            {"fantrap",    new Dictionary<string, object> { {"value", 258}, {"displayName", "Fan Trap"}, {"duration", 1200} }}
        };

        foreach (string trapID in data.Keys)
        {
            var trapInfo = data[trapID];
            var altInfo = altData.ContainsKey(trapID) ? altData[trapID] : null;

            string trapDisplayName = (string)trapInfo["displayName"];
            int trapDuration = trapInfo.ContainsKey("duration") ? (int)trapInfo["duration"] : 2020;

            
            int primaryByteOffset = trapInfo.ContainsKey("byteOffset") ? (int)trapInfo["byteOffset"] : -1;
            int primaryBitMask = trapInfo.ContainsKey("bitMask") ? (int)trapInfo["bitMask"] : 0;

            bool primaryActive = false;
            bool primaryWasActive = false;

            if (primaryByteOffset >= 0 && primaryByteOffset < 100 && current.trapData != null && old.trapData != null)
            {
                primaryWasActive = (old.trapData[primaryByteOffset] & primaryBitMask) != 0;
                primaryActive = (current.trapData[primaryByteOffset] & primaryBitMask) != 0;
            }

            
            bool altActive = false;
            bool altWasActive = false;
            int altByteOffset = -1;
            int altBitMask = 0;

            if (altInfo != null && altInfo.ContainsKey("value"))
            {
                int trapValue = (int)altInfo["value"];
                altByteOffset = trapValue / 8;
                altBitMask = 0x80 >> (trapValue % 8);

                
                if (altInfo.ContainsKey("duration"))
                {
                    trapDuration = (int)altInfo["duration"];
                }

                if (altByteOffset >= 0 && altByteOffset < 36 && current.trapDataOld != null && old.trapDataOld != null)
                {
                    altWasActive = (old.trapDataOld[altByteOffset] & altBitMask) != 0;
                    altActive = (current.trapDataOld[altByteOffset] & altBitMask) != 0;
                }
            }
            
            bool isActive = primaryActive || altActive;
            bool wasActive = primaryWasActive || altWasActive;

            
            string activeSource = "";
            if (!wasActive && isActive)
            {
                if (primaryActive && !primaryWasActive)
                    activeSource = " (primary trapData)";
                else if (altActive && !altWasActive)
                    activeSource = " (alt trapDataOld)";
            }

            
            if (!wasActive && isActive)
            {
                vars.trapStarts[trapID] = current.levelTime;
                vars.trapActive[trapID] = true;
                
            }

            
            if (vars.trapActive[trapID])
            {
                
                bool currentlyActive = primaryActive || altActive;

                if (!currentlyActive && current.levelTime - vars.trapStarts[trapID] >= trapDuration)
                {
                    vars.trapActive[trapID] = false;
                }
            }

            
            if (vars.trapActive[trapID] && settings[trapID])
            {
                
                int remainingTime = trapDuration - (current.levelTime - vars.trapStarts[trapID]);
                if (remainingTime < 0) remainingTime = 0;

                
                int totalMilliseconds = remainingTime * 50;
                int minutes = totalMilliseconds / (1000 * 60);
                int seconds = (totalMilliseconds % (1000 * 60)) / 1000;
                int hundredths = (totalMilliseconds % 1000) / 10;

                string formattedTime = string.Format("{0}:{1:D2}.{2:D2}", minutes, seconds, hundredths);
                vars.cachedTrapTexts[trapID] = formattedTime;

                System.Drawing.Color? timerColor = null;
                if (trapDuration >= 2000 && remainingTime <= 1210)
                {
                    timerColor = System.Drawing.Color.Red;
                }

                vars.SetTextColor(trapDisplayName, vars.cachedTrapTexts[trapID], timerColor);
            }
            else if (settings[trapID])
            {
                
                vars.SetTextColor(trapDisplayName, "0:00.00", null);
            }
            else
            {
                
                vars.RemoveText(trapDisplayName);
            }
        }
    }
    else
    {
        
        var trapData = new Dictionary<string, string>
        {
            {"bunker", "Bunker Trap"}, {"kinoft", "Fire Trap"}, {"m8room", "M8 Trap"}, {"camptrap", "Verruckt Trap"},
            {"comm", "Comm Room Trap"}, {"doc", "Doctor's Quarters Trap"}, {"fishing", "Fishing Hut Trap"}, {"storage", "Storage Trap"},
            {"bridge", "Bridge Trap"}, {"jugtrap", "Kuda Trap"}, {"mkder", "VMP Trap"}, {"doubletap", "Double Tap Trap"},
            {"speedcola", "Speed Cola Trap"}, {"vesper", "Stamin-Up Trap"}, {"kn", "Mule Kick Trap"}, {"courtyard", "Courtyard Trap"},
            {"planetrap", "Plane Trap"}, {"fantrap", "Fan Trap"}
        };

        foreach (string trapDisplayName in trapData.Values)
        {
            vars.RemoveText(trapDisplayName);
        }
        
        vars.RemoveText("Death Ray Trap");
    }


    if (settings["flogger"])
    {
        string trapDisplayName = "Flogger Trap";

        
        if (vars.FloggertrapStart == -1540)
        {
            vars.SetText(trapDisplayName, "0:00.00"); 
        }

        if (old.flogger > current.flogger)
        {
            vars.FloggertrapStart = current.levelTime; 
        }

        
        if (vars.FloggertrapStart != -1540 && current.levelTime - vars.FloggertrapStart < 1540)
        {
            int remainingTime = 1540 - (current.levelTime - vars.FloggertrapStart);
            int totalMilliseconds = remainingTime * 50;
            int minutes = totalMilliseconds / (1000 * 60);
            int seconds = (totalMilliseconds % (1000 * 60)) / 1000;
            int hundredths = (totalMilliseconds % 1000) / 10;

            
            string formattedTime = string.Format("{0}:{1:D2}:{2:D2}", minutes, seconds, hundredths);

            
            vars.SetText(trapDisplayName, formattedTime);
        }
        else if (vars.FloggertrapStart != -1540)
        {
            
            vars.FloggertrapStart = -1540;
            vars.SetText(trapDisplayName, "0:00.00");
        }
    }
    else
    {
        
        vars.RemoveText("Flogger Trap");
    }

    if (settings["deathray"])
    {
        string trapDisplayName = "Death Ray Trap";
        int trapDuration = 1500;
        
        if (vars.DeathRayStart == null)
        {
            vars.DeathRayStart = -1500;
        }
        
        if (vars.DeathRayStart == -1500)
        {
            vars.SetText(trapDisplayName, "0:00.00");
        }
        
        if (old.DeathRay == 0 && current.DeathRay == 1)
        {
            vars.DeathRayStart = current.levelTime;
        }
        
        if (vars.DeathRayStart != -1500 && current.levelTime - vars.DeathRayStart < trapDuration)
        {
            int remainingTime = trapDuration - (current.levelTime - vars.DeathRayStart);
            if (remainingTime < 0) remainingTime = 0;
            
            int totalMilliseconds = remainingTime * 50;
            int minutes = totalMilliseconds / (1000 * 60);
            int seconds = (totalMilliseconds % (1000 * 60)) / 1000;
            int hundredths = (totalMilliseconds % 1000) / 10;
            
            string formattedTime = string.Format("{0}:{1:D2}.{2:D2}", minutes, seconds, hundredths);
            vars.SetText(trapDisplayName, formattedTime);
        }
        else if (vars.DeathRayStart != -1500)
        {
            vars.DeathRayStart = -1500;
            vars.SetText(trapDisplayName, "0:00.00");
        }
    }
    else
    {
        vars.RemoveText("Death Ray Trap");
    }

    
    if (current.round_counter != old.round_counter)
    {
        int currentRound = current.round_counter;

        if (currentRound % 10 == 0 && currentRound >= 10 && currentRound <= 250 && currentRound != vars.lastTrackedRound)
        {
            vars.roundHitmarkers[currentRound] = vars.hitmarkerCounter;
            vars.lastTrackedRound = currentRound;
            vars.SaveRoundData();
        }
    }

    if (settings["Super 30"])
    {
        if (vars.super30_running)
        {
            string currentMap = current.super30_map_name;
            int currentRound = (int)current.super30_round_counter;
            int oldRound = (int)old.super30_round_counter;

            if (currentRound < oldRound && !vars.super30_map_done)
            {
                if (currentMap == "core_frontend" || 
                    (vars.super30_map_index < vars.super30_map_order.Length - 1 && 
                     currentMap == vars.super30_map_order[vars.super30_map_index + 1]))
                {
                    vars.super30_map_done = true;
                    vars.super30_map_index++;
                }
                else
                {
                }
            }

            if (currentMap == "core_frontend")
            {
                vars.super30_map_done = false;
            }

            if (vars.super30_map_done || (vars.super30_map_index < vars.super30_map_order.Length && 
                currentMap != vars.super30_map_order[vars.super30_map_index]))
            {
                return false;
            }

            if (vars.super30_last_split_time > 0 && currentRound == 1 && currentRound > oldRound)
            {
                vars.super30_total_time = vars.super30_last_split_time;
            }

            if (currentRound >= 1)
            {
                vars.super30_total_time += current.super30_level_time - old.super30_level_time;
            }
        }
    }

    if (settings["Super 30 Chronicles"])
    {
        if (vars.super30_chronicles_running)
        {
            string currentMap = current.super30_map_name;
            int currentRound = (int)current.super30_round_counter;
            int oldRound = (int)old.super30_round_counter;
            
            if (currentRound < oldRound && !vars.super30_chronicles_map_done)
            {
                vars.super30_chronicles_map_done = true;
                vars.super30_chronicles_map_index++;
                
                if (vars.SaveSuper30ChroniclesData != null)
                {
                    vars.SaveSuper30ChroniclesData();
                }
            }
            
            if (currentMap == "core_frontend")
            {
                vars.super30_chronicles_map_done = false;
            }

            if (vars.super30_chronicles_map_done || currentMap != vars.super30_chronicles_map_order[vars.super30_chronicles_map_index])
            {
                return false;
            }

            if (vars.super30_chronicles_last_split_time > 0 && currentRound == 1 && currentRound > oldRound)
            {
                vars.super30_chronicles_total_time = vars.super30_chronicles_last_split_time;
            }

            if (currentRound >= 1)
            {
                vars.super30_chronicles_total_time += current.super30_level_time - old.super30_level_time;
                
                if (currentMap == "zm_cosmodrome" && currentRound == 1 && currentRound > oldRound)
                {
                    vars.super30_chronicles_total_time += 8000;
                }
            }
        }
    }

    if (settings["ViewAngles"])
    {
        var vDict = (IDictionary<string, object>)vars;
        if (!vDict.ContainsKey("decryptedClientActivePtr") || vars.decryptedClientActivePtr == null)
            vars.decryptedClientActivePtr = 0UL;

        string[] validZombieMaps = new string[] {
            "zm_zod", "zm_factory", "zm_castle", "zm_island", "zm_stalingrad", 
            "zm_genesis", "zm_prototype", "zm_asylum", "zm_sumpf", "zm_theater", 
            "zm_cosmodrome", "zm_temple", "zm_moon", "zm_tomb"
        };

        bool isValidMap = Array.IndexOf(validZombieMaps, current.currentMap) != -1;

        if (isValidMap && current.currentMap != "core_frontend")
        {
            try
            {
                IntPtr moduleBase = game.MainModule.BaseAddress;
                foreach (ProcessModule module in game.Modules)
                {
                    if (module.ModuleName.ToLower() == "blackops3.exe")
                    {
                        moduleBase = module.BaseAddress;
                        break;
                    }
                }

                ulong decryptedClientActive = (ulong)vars.decryptedClientActivePtr;

                if (decryptedClientActive == 0UL)
                {
                    bool foundValid = false;
                    HashSet<ulong> testedBases = new HashSet<ulong>();

                    int[] offsets = (int[])vars.ViewAnglesOffsets;
                    foreach (int offset in offsets)
                    {
                        ulong fullAddress = game.ReadValue<ulong>((IntPtr)(moduleBase + offset));
                        if (fullAddress == 0UL) continue;

                        ulong baseAddress = fullAddress & 0xFFFFFFFFFFFF0000;
                        if (testedBases.Contains(baseAddress)) continue;
                        testedBases.Add(baseAddress);

                        ulong yawAddress = baseAddress + 0x7E4C;
                        ulong stringAddress = yawAddress - 0x198;

                        byte[] stringBytes = game.ReadBytes((IntPtr)stringAddress, 30);
                        if (stringBytes != null && stringBytes.Length >= 6)
                        {
                            bool hasValidString = false;
                            for (int i = 0; i <= stringBytes.Length - 6; i++)
                            {
                                if (stringBytes[i] == 0x6D && stringBytes[i+1] == 0x61 && 
                                    stringBytes[i+2] == 0x70 && stringBytes[i+3] == 0x73 && 
                                    stringBytes[i+4] == 0x2F)
                                {
                                    hasValidString = true;
                                    break;
                                }
                            }

                            if (hasValidString)
                            {
                                float testValue = game.ReadValue<float>((IntPtr)yawAddress);
                                if (!float.IsNaN(testValue) && !float.IsInfinity(testValue) && Math.Abs(testValue) < 15000000)
                                {
                                    vars.decryptedClientActivePtr = baseAddress;
                                    decryptedClientActive = baseAddress;
                                    foundValid = true;
                                    break;
                                }
                            }
                        }
                    }

                    if (!foundValid)
                    {
                        int tableStart = 0x16D00000;
                        int tableLength = 0x80000;
                        byte[] tableBytes = game.ReadBytes((IntPtr)(moduleBase + tableStart), tableLength);

                        if (tableBytes != null && tableBytes.Length == tableLength)
                        {
                            for (int offset = 0; offset < tableLength - 8; offset += 8)
                            {
                                ulong fullAddress = BitConverter.ToUInt64(tableBytes, offset);
                                if (fullAddress < 0x10000000000UL || fullAddress > 0x7FFFFFFFFFFF) continue;

                                ulong baseAddress = fullAddress & 0xFFFFFFFFFFFF0000;
                                if (testedBases.Contains(baseAddress)) continue;
                                testedBases.Add(baseAddress);

                                ulong yawAddress = baseAddress + 0x7E4C;
                                ulong stringAddress = yawAddress - 0x198;

                                byte[] stringBytes = game.ReadBytes((IntPtr)stringAddress, 30);
                                if (stringBytes != null && stringBytes.Length >= 6)
                                {
                                    bool hasValidString = false;
                                    for (int i = 0; i <= stringBytes.Length - 6; i++)
                                    {
                                        if (stringBytes[i] == 0x6D && stringBytes[i+1] == 0x61 && 
                                            stringBytes[i+2] == 0x70 && stringBytes[i+3] == 0x73 && 
                                            stringBytes[i+4] == 0x2F)
                                        {
                                            hasValidString = true;
                                            break;
                                        }
                                    }

                                    if (hasValidString)
                                    {
                                        float testValue = game.ReadValue<float>((IntPtr)yawAddress);
                                        if (!float.IsNaN(testValue) && !float.IsInfinity(testValue) && Math.Abs(testValue) < 15000000)
                                        {
                                            vars.decryptedClientActivePtr = baseAddress;
                                            decryptedClientActive = baseAddress;
                                            foundValid = true;
                                            int matchedOffset = tableStart + offset;
                                            break;
                                        }
                                    }
                                }
                            }
                        }
                    }

                    if (!foundValid)
                    {
                        vars.SetText("ViewAngles:", "Loading...");
                    }
                }

                if (decryptedClientActive != 0UL)
                {
                    ulong yawAddress = decryptedClientActive + 0x7E4C;
                    float yawVal = game.ReadValue<float>((IntPtr)yawAddress);

                    if (!float.IsNaN(yawVal) && !float.IsInfinity(yawVal) && Math.Abs(yawVal) < 15000000)
                    {
                        vars.cameraYawValue = yawVal;
                        string displayText;
                        if (yawVal <= -1000000.0f)
                        {
                            displayText = string.Format("Turn Left | {0:F2}", yawVal);
                        }
                        else if (yawVal >= 1000000.0f)
                        {
                            displayText = string.Format("Turn Right | {0:F2}", yawVal);
                        }
                        else
                        {
                            displayText = string.Format("{0:F2}", yawVal);
                        }

                        vars.SetText("ViewAngles:", displayText);
                    }
                    else
                    {
                        vars.decryptedClientActivePtr = 0UL;
                        vars.SetText("ViewAngles:", "Re-aligning");
                    }
                }
            }
            catch (Exception ex)
            {
                vars.SetText("ViewAngles:", "Error");
                vars.decryptedClientActivePtr = 0UL;
            }
        }
        else
        {
            vars.decryptedClientActivePtr = 0UL;
            vars.SetText("ViewAngles:", "In Menu");
        }
    }
    else
    {
        vars.RemoveText("ViewAngles:");
        vars.cameraYawValue = 0.0f;
        vars.decryptedClientActivePtr = 0UL;
    }
}

split
{
    if (!settings["Enable Splits"])
        return false;

    if (settings["Coop Timer"])
    {
        if (current.round_counter == old.round_counter + 1)
        {
            return true;
        }
    }
    else if (settings["Solo Timer"])
    {
        if (old.round_counter != 0 && current.round_counter == old.round_counter + 1)
        {
            return true;
        }
    }
    
    if (settings["Super 30"] && vars.super30_running)
    {
        int currentRound = (int)current.super30_round_counter;
        int oldRound = (int)old.super30_round_counter;
        string currentMap = current.super30_map_name;
        
        if (currentRound == 1 && currentRound > oldRound && currentMap != "zm_zod")
        {
            return false;
        }
        
        if (currentRound > oldRound && currentRound >= 1)
        {
            return true;
        }
    }

    if (settings["Super 30 Chronicles"] && vars.super30_chronicles_running)
    {
        int currentRound = (int)current.super30_round_counter;
        int oldRound = (int)old.super30_round_counter;
        string currentMap = current.super30_map_name;
        
        if (currentRound == 1 && currentRound > oldRound && currentMap != "zm_prototype")
        {
            return false;
        }
        
        if (currentRound > oldRound && currentRound >= 1)
        {
            return true;
        }
    }
    
    return false;
}

gameTime {
    string[] arrayMaps = {
        "zm_zod", "zm_factory", "zm_castle", "zm_island", "zm_stalingrad", 
        "zm_genesis", "zm_prototype", "zm_asylum", "zm_sumpf", "zm_theater", 
        "zm_cosmodrome", "zm_temple", "zm_moon", "zm_tomb"
    };

    int super30ChroniclesMs = 0;
    if (vars.super30_chronicles_total_time != null)
    {
        try { super30ChroniclesMs = Convert.ToInt32(vars.super30_chronicles_total_time); } catch {}
    }

    int super30Ms = 0;
    if (vars.super30_total_time != null)
    {
        try { super30Ms = Convert.ToInt32(vars.super30_total_time); } catch {}
    }

    int offhostMs = 0;
    var varsDict = (IDictionary<string, object>)vars;
    if (varsDict.ContainsKey("smoothOffHostTime") && varsDict["smoothOffHostTime"] != null)
    {
        try { offhostMs = Convert.ToInt32(vars.smoothOffHostTime); } catch {}
    }

    int soloMs = 0;
    if (vars.trueTime != null)
    {
        try { soloMs = Convert.ToInt32(vars.trueTime * 50); } catch {}
    }

    if (settings["Super 30"])
    {
        return new TimeSpan(0, 0, 0, 0, super30Ms);
    }
    if (settings["Super 30 Chronicles"])
    {
        return new TimeSpan(0, 0, 0, 0, super30ChroniclesMs);
    }

    if (current.currentMap == "zm_cosmodrome")
    {
        if (old.currentMap == "core_frontend")
        {
            if (settings["Solo Timer"])
            {
                return new TimeSpan(0, 0, 0, 0, soloMs + 8000);
            }
        }
        else
        {
            if (settings["Solo Timer"])
            {
                return new TimeSpan(0, 0, 0, 0, soloMs + 8000);
            }
        }
        return TimeSpan.Zero;
    }

    if (current.round_counter == 0)
    {
        return TimeSpan.Zero;
    }

    if (settings["Solo Timer"])
    {
        return new TimeSpan(0, 0, 0, 0, soloMs);
    }
}

start
{
    if (settings["Coop Timer"])
    {
        if (current.currentMap == "zm_cosmodrome" && vars.timer_start == 0)
        {
            vars.timer_start = 1;
            return true;
        }
        
        if (current.round_counter == 1 && vars.timer_start == 0)
        {
            System.Threading.Thread.Sleep(200); 
            vars.timer_start = 1;
            return true;
        }
    }
    else if (settings["Solo Timer"])
    {
        return true;
    }
    
    if (settings["Super 30"])
    {
        string currentMap = current.super30_map_name;
        int currentRound = (int)current.super30_round_counter;
        int oldRound = (int)old.super30_round_counter;
        
        if (currentMap == "zm_zod" && currentRound == 1 && currentRound > oldRound && !vars.super30_running)
        {
            vars.super30_running = true;
            vars.super30_map_index = 0;
            vars.super30_map_done = false;
            
            
            vars.super30_last_level_time = current.super30_level_time;
            return true;
        }
    }

    if (settings["Super 30 Chronicles"])
    {
        string currentMap = current.super30_map_name;
        int currentRound = (int)current.super30_round_counter;
        int oldRound = (int)old.super30_round_counter;
        
        if (currentMap == "zm_prototype" && currentRound == 1 && currentRound > oldRound && !vars.super30_chronicles_running)
        {
            vars.super30_chronicles_running = true;
            vars.super30_chronicles_map_index = 0;
            vars.super30_chronicles_map_done = false;
            
            return true;
        }
    }
    
    return false;
}

isLoading
{
    if (settings["Super 30"] || settings["Super 30 Chronicles"])
    {
        return true;
    }
    
    if (settings["Coop Timer"])
    {
        if (current.is_paused == 1)
        {
            return true;
        }
        return false;
    }

    if (settings["Solo Timer"])
    {
        return true;
    }
    
    return false;
}

reset
{
    if (!settings["Enable Splits"])
        return false;
        
    if (settings["Coop Timer"])
    {
        if (current.round_counter == 0 && old.round_counter != 0)
        {
            return true;
        }
    }
    else if (settings["Solo Timer"])
    {
        if (current.round_counter == 0 && old.round_counter != 0)
        {
            return true;
        }
    }
    
    if (settings["Super 30"])
    {
        if (current.super30_map_name == "core_frontend" && old.super30_map_name != "core_frontend")
        {
            if (vars.super30_map_index >= vars.super30_map_order.Length)
            {
                return true;
            }
        }
        
        if (current.super30_map_name == "core_frontend" && !vars.super30_running && vars.super30_total_time > 0)
        {
            return true;
        }
        
        if (current.super30_map_name == "zm_zod" && current.super30_round_counter == 0)
        {
            
            if (vars.super30_total_time > 0)
            {
                return true;
            }
        }
    }

    if (settings["Super 30 Chronicles"])
    {
        if (current.super30_map_name == "core_frontend" && old.super30_map_name != "core_frontend")
        {
            if (vars.super30_chronicles_map_index >= vars.super30_chronicles_map_order.Length)
            {
                return true;
            }
        }
        
        if (current.super30_map_name == "core_frontend" && !vars.super30_chronicles_running && vars.super30_chronicles_total_time > 0)
        {
            return true;
        }
        
        if (current.super30_map_name == "zm_prototype" && current.super30_round_counter == 0)
        {
            
            if (vars.super30_chronicles_total_time > 0)
            {
                return true;
            }
        }
    }
    
    return false;
}

onSplit
{
    if (settings["Super 30"])
    {
        vars.super30_last_split_time = vars.super30_total_time;
        File.AppendAllText(vars.debugFilePath, string.Format("onSplit - Saved last split time: {0}ms\n", vars.super30_last_split_time));
        
        if (vars.SaveSuper30Data != null)
        {
            vars.SaveSuper30Data();
        }
    }
    
    if (settings["Super 30 Chronicles"])
    {
        vars.super30_chronicles_last_split_time = vars.super30_chronicles_total_time;
        File.AppendAllText(vars.debugFilePath, string.Format("onSplit - Saved Chronicles last split time: {0}ms\n", vars.super30_chronicles_last_split_time));
        
        if (vars.SaveSuper30ChroniclesData != null)
        {
            vars.SaveSuper30ChroniclesData();
        }
    }
}

exit
{
}

shutdown
{
    vars.SaveRoundData();
    
    File.AppendAllText(vars.debugFilePath, string.Format("Saving values - Nades: {0}\n", vars.nadeCounter));
    
    string[] linesArray = {
        string.Format("Rags Slams: {0}", vars.ragsSlamsCounter),
        string.Format("Nade Count: {0}", vars.nadeCounter),
        string.Format("Valk Count: {0}", vars.valksCounter),
        string.Format("Hitmarker Count: {0}", vars.hitmarkerCounter),
        string.Format("GSC Max Value: {0}", vars.maxChildValue),
        string.Format("CSC Max Value: {0}", vars.CSCmaxChildValue),
        string.Format("BG Strings Max: {0}", vars.maxBGStringsValue), 
        string.Format("GSC Current Value: {0}", vars.currentChildValue),
        string.Format("CSC Current Value: {0}", vars.currentCSCValue),
        string.Format("Sound Error Max: {0}", vars.maxSoundValue),
        string.Format("HPH Start Time: {0}", vars.hitmarkerStartTime),
        string.Format("HPH Start Count: {0}", vars.hitmarkersAtStart),
        string.Format("HPH Rate: {0}", vars.hitmarkersPerHour),
        string.Format("HPH Prediction Hours: {0}", vars.predictionHours),

        string.Format("Super30 Total Time: {0}", vars.super30_total_time),
        string.Format("Super30 Map Index: {0}", vars.super30_map_index),
        string.Format("Super30 Last Split: {0}", vars.super30_last_split_time),

        string.Format("Super30 Chronicles Total Time: {0}", vars.super30_chronicles_total_time),
        string.Format("Super30 Chronicles Map Index: {0}", vars.super30_chronicles_map_index),
        string.Format("Super30 Chronicles Last Split: {0}", vars.super30_chronicles_last_split_time)
    };
    
    List<string> lines = new List<string>(linesArray);
    
    if (vars.predictedHitmarkers > 0)
    {
        lines.Add(string.Format("HPH Predicted {0}h: {1}", vars.predictionHours, vars.predictedHitmarkers));
    }
    
    File.WriteAllLines(vars.boxHitsFilePath, lines.ToArray());
}

onReset {
    vars.participationIndex = -1;

    vars.snapshots_last_value = -1;
    vars.snapshots_consistent_reads = 0;
    vars.snapshots_last_delta = 0;
    vars.snapshots_last_seconds = double.MaxValue;

    vars.entities_last_value = -1;
    vars.entities_consistent_reads = 0;
    vars.entities_last_delta = 0;
    vars.entities_last_seconds = double.MaxValue;

    if (vars.entities_5min_history != null)
    {
        vars.entities_5min_history.Clear();
    }
    vars.last_5min_sample_time = -1;

    if (settings["Sound Error"])
    {
        vars.maxSoundValue = 0;
    }

    if (settings["GSC Threads"])
    {
        vars.maxActiveThreads = 0;
    }

    if (settings["CSC Threads"])
    {
        vars.maxActiveCSCThreads = 0;
    }
    
    if (settings["BG Strings"])
    {
        vars.maxBGStringsValue = 0;
    }

    if (settings["Super 30"])
    {
        vars.super30_total_time = 0;
        vars.super30_last_split_time = 0;
        vars.super30_map_index = 0;
        vars.super30_map_done = false;
        vars.super30_running = false;
        vars.super30_last_level_time = 0;
    }
    
    if (settings["Super 30 Chronicles"])
    {
        vars.super30_chronicles_total_time = 0;
        vars.super30_chronicles_last_split_time = 0;
        vars.super30_chronicles_map_index = 0;
        vars.super30_chronicles_map_done = false;
        vars.super30_chronicles_running = false;
    }
    
    vars.FloggertrapStart = -1540;
    
    vars.DeathRayStart = -1500;
    
    if (vars.trapStarts != null)
    {
        foreach (string trapID in new string[] { "bunker", "kinoft", "m8room", "camptrap", "comm", "doc", "fishing", "storage", "bridge", "jugtrap", "mkder", "doubletap", "speedcola", "vesper", "kn", "courtyard", "planetrap", "fantrap" })
        {
            if (vars.trapStarts.ContainsKey(trapID))
            {
                vars.trapStarts[trapID] = -2020;
            }
            if (vars.trapActive != null && vars.trapActive.ContainsKey(trapID))
            {
                vars.trapActive[trapID] = false;
            }
        }
    }
    
    if (vars.trapStarts != null && vars.trapStarts.ContainsKey("deathray"))
    {
        vars.trapStarts["deathray"] = -2020;
    }
    if (vars.trapActive != null && vars.trapActive.ContainsKey("deathray"))
    {
        vars.trapActive["deathray"] = false;
    }
}