package;

#if desktop
import Discord.DiscordClient;
#end

import flixel.FlxSubState;
import flixel.util.FlxGradient;
import flixel.text.FlxText;
import flixel.FlxObject;
import flixel.effects.FlxFlicker;
import flixel.util.FlxTimer;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.net.curl.CURLCode;
import MainVariables._variables;
import flixel.tweens.FlxEase;

using StringTools;

class PAGE3settings extends MusicBeatSubstate
{

    var menuItems:FlxTypedGroup<FlxSprite>;
    var optionShit:Array<String> = ['page', 'iconZoom', 'cameraZoom', 'cameraSpeed', 'score', 'misses', 'accuracy', 'nps', 'rating', 'timing', 'combo', 'songPos'];

    private var grpSongs:FlxTypedGroup<Alphabet>;
    var selectedSomethin:Bool = false;
    var curSelected:Int = 0;
    var camFollow:FlxObject;

    var ResultText:FlxText = new FlxText(20, 69, FlxG.width, "", 48);
    var ExplainText:FlxText = new FlxText(20, 69, FlxG.width/2, "", 48);

    var pause:Int = 0;

    var camLerp:Float = 0.32;

    var sco:Float;
    var mis:Float;
    var acc:Float;
    var rat:Float;
    var tim:Float;
    var com:Float;
    var pos:Float;
    var nps:Float;

    public function new()
    {
        super();

        persistentDraw = persistentUpdate = true;
        destroySubStates = false;

        menuItems = new FlxTypedGroup<FlxSprite>();
        add(menuItems);
        
		var tex = Paths.getSparrowAtlas('Options_Buttons');

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite(800, 30 + (i * 160));
			menuItem.frames = tex;
            menuItem.animation.addByPrefix('idle', optionShit[i] + " idle", 24, true);
            menuItem.animation.addByPrefix('select', optionShit[i] + " select", 24, true);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItems.add(menuItem);
			menuItem.scrollFactor.set();
            menuItem.antialiasing = true;
            menuItem.scrollFactor.x = 0;
            menuItem.scrollFactor.y = 1;

            menuItem.x = 2000;
            FlxTween.tween(menuItem, { x: 800}, 0.15, { ease: FlxEase.expoInOut });
        }

        camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);
        
        changeItem();

        createResults();

        updateResults();

        FlxG.camera.follow(camFollow, null, camLerp);

        #if desktop
			DiscordClient.changePresence("Settings page: GFX", null);
		#end
    }

    function updateResults():Void
        {
            if (_variables.scoreDisplay)
                sco = 1;
            else
                sco = 0;

            if (_variables.songPosition)
                pos = 1;
            else
                pos = 0;

            if (_variables.missesDisplay)
                mis = 1;
            else
                mis = 0;

            if (_variables.accuracyDisplay)
                acc = 1;
            else
                acc = 0;

            if (_variables.ratingDisplay)
                rat = 1;
            else
                rat = 0;

            if (_variables.timingDisplay)
                tim = 1;
            else
                tim = 0;

            if (_variables.comboDisplay)
                com = 1;
            else
                com = 0;

            if (_variables.nps)
                nps = 1;
            else
                nps = 0;

        }

        function createResults():Void
            {
                add(ResultText);
                ResultText.scrollFactor.x = 0;
                ResultText.scrollFactor.y = 0;
                ResultText.setFormat("VCR OSD Mono", 48, FlxColor.WHITE, CENTER);
                ResultText.x = -400;
                ResultText.y = 350;
                ResultText.setBorderStyle(OUTLINE, 0xFF000000, 5, 1);
                ResultText.alpha = 0;
                FlxTween.tween(ResultText, { alpha: 1}, 0.15, { ease: FlxEase.expoInOut });
        
                add(ExplainText);
                ExplainText.scrollFactor.x = 0;
                ExplainText.scrollFactor.y = 0;
                ExplainText.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, CENTER);
                ExplainText.alignment = LEFT;
                ExplainText.x = 20;
                ExplainText.y = 624;
                ExplainText.setBorderStyle(OUTLINE, 0xFF000000, 5, 1);
                ExplainText.alpha = 0;
                FlxTween.tween(ExplainText, { alpha: 1}, 0.15, { ease: FlxEase.expoInOut });
            }

    override function update(elapsed:Float)
        {
            super.update(elapsed);

            if (!selectedSomethin)
                {
                    if (controls.UP_P)
                    {
                        FlxG.sound.play(Paths.sound('scrollMenu'), _variables.svolume/100);
                        changeItem(-1);
                    }
        
                    if (controls.DOWN_P)
                    {
                        FlxG.sound.play(Paths.sound('scrollMenu'), _variables.svolume/100);
                        changeItem(1);
                    }
			
				if (controls.LEFT_P)
                    {
                        changePress(-1);
                    }
        
                if (controls.RIGHT_P)
                    {
                        changePress(1);
                    }
                
                    if (controls.BACK)
                        {
                            FlxG.sound.play(Paths.sound('cancelMenu'), _variables.svolume/100);
                            selectedSomethin = true;

                            #if desktop
			                    DiscordClient.changePresence("Back to the main menu I go!", null);
		                    #end
    
                            menuItems.forEach(function(spr:FlxSprite)
                                {
                                    spr.animation.play('idle');
                                    FlxTween.tween(spr, { x: -1000}, 0.15, { ease: FlxEase.expoIn });
                                });
                            
                            FlxTween.tween(FlxG.camera, { zoom: 7}, 0.5, { ease: FlxEase.expoIn, startDelay: 0.2 });
                            FlxTween.tween(ResultText, { alpha: 0}, 0.15, { ease: FlxEase.expoIn });
                            FlxTween.tween(ExplainText, { alpha: 0}, 0.15, { ease: FlxEase.expoIn });
    
                            new FlxTimer().start(0.3, function(tmr:FlxTimer)
                                {
                                    FlxG.switchState(new MainMenuState());
                                });
                        }
                    }
            
            switch (optionShit[curSelected])
            {
                case "score":
                    ResultText.text = Std.string(_variables.scoreDisplay).toUpperCase();
                    ExplainText.text = "SCORE DISPLAY:\nSet your score display visible or invisible.";
                case "misses":
                    ResultText.text = Std.string(_variables.missesDisplay).toUpperCase();
                    ExplainText.text = "MISS COUNTER:\nSet your miss counter visible or invisible.";
                case "accuracy":
                    ResultText.text = Std.string(_variables.accuracyDisplay).toUpperCase();
                    ExplainText.text = "ACCURACY DISPLAY:\nSet your accuracy display visible or invisible.";
                case "page":
                    ResultText.text = "GFX";
                    ExplainText.text = "Previous Page: SFX \nNext Page: GAMEPLAY";
                case "rating":
                    ResultText.text = Std.string(_variables.ratingDisplay).toUpperCase();
                    ExplainText.text = "RATING DISPLAY:\nSet your rating display of your note hits visible or invisible.";
                case "combo":
                    ResultText.text = Std.string(_variables.comboDisplay).toUpperCase();
                    ExplainText.text = "COMBO COUNTER:\nSet your combo counter of hit notes visible or invisible.";
                case "timing":
                    ResultText.text = Std.string(_variables.timingDisplay).toUpperCase();
                    ExplainText.text = "TIMING DISPLAY:\nSet your timing display of your note hits visible or invisible.";
                case "iconZoom":
                    ResultText.text = _variables.iconZoom+"x";
                    ExplainText.text = "ICON ZOOM:\nChange how zoomed in character icons become after a beat. The more, the bigger zoom.";
                case "cameraZoom":
                    ResultText.text = _variables.cameraZoom+"x";
                    ExplainText.text = "CAMERA ZOOM:\nChange how zoomed in the camera becomes after a beat. The more, the bigger zoom.";
                case "cameraSpeed":
                    ResultText.text = _variables.cameraSpeed+"x";
                    ExplainText.text = "CAMERA SPEED:\nChange how fast should the camera go to follow a character. The more, the faster camera goes.";
                case "songPos":
                    ResultText.text = Std.string(_variables.songPosition).toUpperCase();
                    ExplainText.text = "SONG POSITION DISPLAY:\nSet your song position display visible or invisible.";
                case "nps":
                    ResultText.text = Std.string(_variables.nps).toUpperCase();
                    ExplainText.text = "NOTES PER SECOND DISPLAY:\nSet your display of notes pressed per second visible or invisible.";
            }

            menuItems.forEach(function(spr:FlxSprite)
                {
                    spr.scale.set(FlxMath.lerp(spr.scale.x, 0.8, camLerp/(_variables.fps/60)), FlxMath.lerp(spr.scale.y, 0.8, 0.4/(_variables.fps/60)));
                    
                    if (spr.ID == curSelected)
                    {
                        camFollow.y = FlxMath.lerp(camFollow.y, spr.getGraphicMidpoint().y, camLerp/(_variables.fps/60));
                        camFollow.x = spr.getGraphicMidpoint().x;
                        spr.scale.set(FlxMath.lerp(spr.scale.x, 1.1, camLerp/(_variables.fps/60)), FlxMath.lerp(spr.scale.y, 1.1, 0.4/(_variables.fps/60)));
                    }

                    spr.updateHitbox();
                });
        }

    function changeItem(huh:Int = 0)
        {
            curSelected += huh;
        
            if (curSelected >= menuItems.length)
                curSelected = 0;
            if (curSelected < 0)
                curSelected = menuItems.length - 1;

            menuItems.forEach(function(spr:FlxSprite)
                {
                    spr.animation.play('idle');
        
                    if (spr.ID == curSelected)
                    {
                        spr.animation.play('select'); 
                    }
            
                    spr.updateHitbox();
                });
        }

	function changePress(Change:Int = 0)
		{
			switch (optionShit[curSelected])
			{
                case 'page':
                    FlxG.sound.play(Paths.sound('scrollMenu'), _variables.svolume/100);
                    selectedSomethin = true;
        
                    menuItems.forEach(function(spr:FlxSprite)
                        {
                            spr.animation.play('idle');
                            FlxTween.tween(spr, { x: -1000}, 0.15, { ease: FlxEase.expoIn });
                        });

                    FlxTween.tween(ResultText, { alpha: 0}, 0.15, { ease: FlxEase.expoIn });
                    FlxTween.tween(ExplainText, { alpha: 0}, 0.15, { ease: FlxEase.expoIn });
    
                    new FlxTimer().start(0.2, function(tmr:FlxTimer)
                        {
                            if (Change == 1)
                                openSubState(new PAGE4settings());
                            else
                                openSubState(new PAGE2settings());
                        });
                case "score":
                    sco += Change;
                    if (sco > 1)
                        sco = 0;
                    if (sco < 0)
                        sco = 1;
        
                    if (sco == 0)
                        _variables.scoreDisplay = false;
                    else
                        _variables.scoreDisplay = true;
        
                    FlxG.sound.play(Paths.sound('scrollMenu'), _variables.svolume/100);
                case "misses":
                    mis += Change;
                    if (mis > 1)
                        mis = 0;
                    if (mis < 0)
                        mis = 1;
        
                    if (mis == 0)
                        _variables.missesDisplay = false;
                    else
                        _variables.missesDisplay = true;
            
                    FlxG.sound.play(Paths.sound('scrollMenu'), _variables.svolume/100);
                case "songPos":
                    pos += Change;
                    if (pos > 1)
                        pos = 0;
                    if (pos < 0)
                        pos = 1;
            
                    if (pos == 0)
                        _variables.songPosition = false;
                    else
                        _variables.songPosition = true;
                
                    FlxG.sound.play(Paths.sound('scrollMenu'), _variables.svolume/100);
                case "accuracy":
                    acc += Change;
                    if (acc > 1)
                        acc = 0;
                    if (acc < 0)
                        acc = 1;
                
                    if (acc == 0)
                        _variables.accuracyDisplay = false;
                    else
                        _variables.accuracyDisplay = true;
            
                    FlxG.sound.play(Paths.sound('scrollMenu'), _variables.svolume/100);
                case "rating":
                    rat += Change;
                    if (rat > 1)
                        rat = 0;
                    if (rat < 0)
                        rat = 1;
            
                    if (rat == 0)
                        _variables.ratingDisplay = false;
                    else
                        _variables.ratingDisplay = true;
            
                    FlxG.sound.play(Paths.sound('scrollMenu'), _variables.svolume/100);
                case "timing":
                    tim += Change;
                    if (tim > 1)
                        tim = 0;
                    if (tim < 0)
                        tim = 1;
            
                    if (tim == 0)
                        _variables.timingDisplay = false;
                    else
                        _variables.timingDisplay = true;
                
                    FlxG.sound.play(Paths.sound('scrollMenu'), _variables.svolume/100);
                case "combo":
                    com += Change;
                    if (com > 1)
                        com = 0;
                    if (com < 0)
                        com = 1;
                
                    if (com == 0)
                        _variables.comboDisplay = false;
                    else
                        _variables.comboDisplay = true;
                
                    FlxG.sound.play(Paths.sound('scrollMenu'), _variables.svolume/100);
                case "nps":
                    nps += Change;
                    if (nps > 1)
                        nps = 0;
                    if (nps < 0)
                        nps = 1;
                    
                    if (nps == 0)
                        _variables.nps = false;
                    else
                        _variables.nps = true;
                    
                    FlxG.sound.play(Paths.sound('scrollMenu'), _variables.svolume/100);
                case "iconZoom":
                    _variables.iconZoom += Change/4;
                    if (_variables.iconZoom < 0)
                        _variables.iconZoom = 0;
    
                    FlxG.sound.play(Paths.sound('scrollMenu'), _variables.svolume/100);
                case "cameraZoom":
                    _variables.cameraZoom += Change/4;
                    if (_variables.cameraZoom < 0)
                        _variables.cameraZoom = 0;
        
                    FlxG.sound.play(Paths.sound('scrollMenu'), _variables.svolume/100);
                case "cameraSpeed":
                    _variables.cameraSpeed += Change/10;
                    if (_variables.cameraSpeed < 0.1)
                        _variables.cameraSpeed = 0.1;
            
                    FlxG.sound.play(Paths.sound('scrollMenu'), _variables.svolume/100);
			}

            new FlxTimer().start(0.2, function(tmr:FlxTimer)
                {
                    MainVariables.Save();
                });
		}

    override function openSubState(SubState:FlxSubState)
        {
            super.openSubState(SubState);
        }
}