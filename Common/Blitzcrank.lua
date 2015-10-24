if GetObjectName(myHero) ~= "Blitzcrank" then return end

if (FileExist(COMMON_PATH.."Deftlib.lua")) then
require('Deftlib')
else
PrintChat("You need Deftlib to use this Script, please download it and reload the script!")
end

local BlitzcrankMenu = MenuConfig("Blitzcrank", "Blitzcrank")
BlitzcrankMenu:TargetSelector("ts", "Target Selector", DAMAGE_MAGICAL, 1000, TARGET_LESS_CAST)

BlitzcrankMenu:Menu("Combo", "Combo")
BlitzcrankMenu.Combo:Boolean("Q", "Use Q", true)
BlitzcrankMenu.Combo:Boolean("W", "Use W", true)
BlitzcrankMenu.Combo:Boolean("E", "Use E", true)
BlitzcrankMenu.Combo:Boolean("AutoE", "Auto E after Grab", true)
BlitzcrankMenu.Combo:Boolean("R", "Use R", true)

BlitzcrankMenu:Menu("AutoGrab", "Auto Grab")
BlitzcrankMenu.AutoGrab:Slider("min", "Min Distance", 200, 100, 400, 1)
BlitzcrankMenu.AutoGrab:Slider("max", "Max Distance", 975, 400, 975, 1)
BlitzcrankMenu.AutoGrab:Menu("Enemies", "Enemies to Auto-Grab")

BlitzcrankMenu:Menu("Harass", "Harass")
BlitzcrankMenu.Harass:Boolean("Q", "Use Q", true)
BlitzcrankMenu.Harass:Boolean("E", "Use E", true)
BlitzcrankMenu.Harass:Slider("Mana", "if Mana % is More than", 30, 0, 80, 1)

BlitzcrankMenu:Menu("Killsteal", "Killsteal")
BlitzcrankMenu.Killsteal:Boolean("Q", "Killsteal with Q", true)
BlitzcrankMenu.Killsteal:Boolean("R", "Killsteal with R", true)

BlitzcrankMenu:Menu("Misc", "Misc")
BlitzcrankMenu.Misc:Boolean("Autoignite", "Auto Ignite", true)
BlitzcrankMenu.Misc:Boolean("Autolvl", "Auto level", true)
BlitzcrankMenu.Misc:List("Autolvltable", "Priority", 1, {"Q-E-W", "Q-W-E", "W-Q-E"})

BlitzcrankMenu:Menu("Drawings", "Drawings")
BlitzcrankMenu.Drawings:Boolean("Q", "Draw Q Range", true)
BlitzcrankMenu.Drawings:Boolean("R", "Draw R Range", true)
BlitzcrankMenu.Drawings:Boolean("Stats", "Draw Statistics", true)
BlitzcrankMenu.Drawings:ColorPick("color", "Color Picker", {255,255,255,255})
	
local InterruptMenu = MenuConfig("Interrupt", "Interrupt")
InterruptMenu:Menu("SupportedSpells", "Supported Spells")
InterruptMenu.SupportedSpells:Boolean("Q", "Use Q", true)
InterruptMenu.SupportedSpells:Boolean("R", "Use R", true)

local MissedGrabs = 0
local SuccesfulGrabs = 0
local Percent = 0
local TotalGrabs = MissedGrabs + SuccesfulGrabs

GoS:DelayAction(function()

  local str = {[_Q] = "Q", [_W] = "W", [_E] = "E", [_R] = "R"}

  for i, spell in pairs(CHANELLING_SPELLS) do
    for _,k in pairs(GoS:GetEnemyHeroes()) do
    	local added = false
        if spell["Name"] == GetObjectName(k) then
        InterruptMenu:Boolean(GetObjectName(k).."Inter", "On "..GetObjectName(k).." "..(type(spell.Spellslot) == 'number' and str[spell.Spellslot]), true)
        added = true
        end
        if not added then
        InterruptMenu:Info("bullshit", "No Interruptable Spells Found")
        end
    end
  end
  
  for _,k in pairs(GoS:GetEnemyHeroes()) do
  BlitzcrankMenu.AutoGrab.Enemies:Boolean(GetObjectName(k).."AutoGrab", "On "..GetObjectName(k).." ", false)
  end
		
end, 1)

OnProcessSpellComplete(function(unit, spell)
    if GetObjectType(unit) == Obj_AI_Hero and GetTeam(unit) ~= GetTeam(myHero) then
      if CHANELLING_SPELLS[spell.name] then
        if GoS:IsInDistance(unit, 975) and IsReady(_Q) and GetObjectName(unit) == CHANELLING_SPELLS[spell.name].Name and InterruptMenu[GetObjectName(unit).."Inter"]:Value() and InterruptMenu.SupportedSpells.Q:Value() then
        Cast(_Q,unit)
        elseif GoS:IsInDistance(unit, 600) and IsReady(_R) and GetObjectName(unit) == CHANELLING_SPELLS[spell.name].Name and InterruptMenu[GetObjectName(unit).."Inter"]:Value() and InterruptMenu.SupportedSpells.R:Value() then
        CastSpell(_R)
        end
      end
    end
	
    if unit == myHero and spell.name == "RocketGrab" then
    MissedGrabs = MissedGrabs + 1
    end
end)

OnUpdateBuff(function(unit,buff)
        if buff.Name == "rocketgrab2" and GetObjectType(unit) == Obj_AI_Hero and GetTeam(unit) ~= GetTeam(myHero) then
	    SuccesfulGrabs = SuccesfulGrabs + 1
	    MissedGrabs = MissedGrabs - 1
		
	    if BlitzcrankMenu.Combo.AutoE:Value() then
	    CastSpell(_E)
	    end
	end
end)

OnDraw(function(myHero)
local col = BlitzcrankMenu.Drawings.color:Value()	
TotalGrabs = MissedGrabs + SuccesfulGrabs
Percentage = ((SuccesfulGrabs*100)/TotalGrabs)

if BlitzcrankMenu.Drawings.Q:Value() then DrawCircle(GoS:myHeroPos(),975,1,0,col) end
if BlitzcrankMenu.Drawings.R:Value() then DrawCircle(GoS:myHeroPos(),600,1,0,col) end
if BlitzcrankMenu.Drawings.Stats:Value() then 
DrawText("Percentage Grab done : " .. tostring(math.ceil(Percentage)) .. "%",12,0,30,0xff00ff00)
DrawText("Grab Done : "..tostring(SuccesfulGrabs),12,0,40,0xff00ff00)
DrawText("Grab Miss : "..tostring(MissedGrabs),12,0,50,0xff00ff00)
DrawText("Total Grabs : "..tostring(TotalGrabs),12,0,60,0xff00ff00)
end

end)

OnTick(function(myHero)

    if IOW:Mode() == "Combo" then
	
		local target = BlitzcrankMenu.ts:GetTarget()
		
                if IsReady(_Q) and GoS:ValidTarget(target, 975) and BlitzcrankMenu.Combo.Q:Value() then
                Cast(_Q,target)
	        end
                          
                if target and GetCurrentMana(myHero) >= 200 and IsReady(_W) and IsReady(_Q) and GoS:GetDistance(target) <= 1275 and GoS:GetDistance(target) >= 975 and BlitzcrankMenu.Combo.W:Value() then
                CastSpell(_W)
                elseif target and IsReady(_W) and GoS:GetDistance(target) > 150 and GoS:GetDistance(target) <= 400 then
		CastSpell(_W)
		end
			
                if IsReady(_E) and GoS:IsInDistance(target, 250) and BlitzcrankMenu.Combo.E:Value() then
                CastSpell(_E)
		end
		              
		if IsReady(_R) and GoS:ValidTarget(target, 600) and BlitzcrankMenu.Combo.R:Value() and 100*GetCurrentHP(target)/GetMaxHP(target) < 60 then
                CastSpell(_R)
	        end
	                      
	end	
	
	if IOW:Mode() == "Harass" and 100*GetCurrentMana(myHero)/GetMaxMana(myHero) >= BlitzcrankMenu.Harass.Mana:Value() then
	
		local target = BlitzcrankMenu.ts:GetTarget()
		
                if IsReady(_Q) and GoS:ValidTarget(target, 975) and BlitzcrankMenu.Harass.Q:Value() then
                Cast(_Q,target)
	        end
		
		if IsReady(_E) and GoS:IsInDistance(target, 250) and BlitzcrankMenu.Harass.E:Value() then
                CastSpell(_E)
		end
		
	end
	
	for i,enemy in pairs(GoS:GetEnemyHeroes()) do
		
		if BlitzcrankMenu.AutoGrab.Enemies[GetObjectName(enemy).."AutoGrab"]:Value() and GoS:ValidTarget(enemy) then
		  if IsReady(_Q) and GoS:GetDistance(enemy) <= BlitzcrankMenu.AutoGrab.max:Value() and GoS:GetDistance(enemy) >= BlitzcrankMenu.AutoGrab.min:Value() then
		  Cast(_Q,enemy)
		  end
		end
		
		if Ignite and BlitzcrankMenu.Misc.Autoignite:Value() then
                  if IsReady(Ignite) and 20*GetLevel(myHero)+50 > GetCurrentHP(enemy)+GetDmgShield(enemy)+GetHPRegen(enemy)*2.5 and GoS:ValidTarget(enemy, 600) then
                  CastTargetSpell(enemy, Ignite)
                  end
                end
		
  	        if IsReady(_Q) and GoS:ValidTarget(enemy, 975) and BlitzcrankMenu.Killsteal.Q:Value() and GetCurrentHP(enemy)+GetMagicShield(enemy)+GetDmgShield(enemy) < GoS:CalcDamage(myHero, enemy, 0, 55*GetCastLevel(myHero,_Q)+25+GetBonusAP(myHero) + Ludens()) then 
                Cast(_Q,enemy)
                elseif IsReady(_R) and GoS:ValidTarget(enemy, 600) and BlitzcrankMenu.Killsteal.R:Value() and GetCurrentHP(enemy)+GetMagicShield(enemy)+GetDmgShield(enemy) < GoS:CalcDamage(myHero, enemy, 0, 125*GetCastLevel(myHero,_R)+125+GetBonusAP(myHero) + Ludens()) then
                CastSpell(_R)
	        end
		
	end

if BlitzcrankMenu.Misc.Autolvl:Value() then    
   if BlitzcrankMenu.Misc.Autolvltable:Value() == 1 then leveltable = {_Q, _E, _W, _Q, _Q , _R, _Q , _E, _Q , _E, _R, _E, _E, _W, _W, _R, _W, _W}
   elseif BlitzcrankMenu.Misc.Autolvltable:Value() == 2 then leveltable = {_Q, _E, _W, _Q, _Q, _R, _Q, _W, _Q, _W, _R, _W, _W, _E, _E, _R, _E, _E}
   elseif BlitzcrankMenu.Misc.Autolvltable:Value() == 3 then leveltable = {_Q, _E, _W, _W, _W, _R, _W, _Q, _W, _Q, _R, _Q, _Q, _E, _E, _R, _E, _E}
   end
GoS:DelayAction(function() LevelSpell(leveltable[GetLevel(myHero)]) end, math.random(1000,3000))
end

end)
