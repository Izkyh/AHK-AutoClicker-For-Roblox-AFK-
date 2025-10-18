; Ghost Clicker v4.3 - ROBLOX Edition
; Optimized for Roblox with Direct Window mode (Most Reliable!)

#SingleInstance Force
#Requires AutoHotkey v2.0+
SetMouseDelay(-1)
CoordMode("Mouse", "Screen")
SetTitleMatchMode(2)
SetControlDelay(-1)
DetectHiddenWindows(true)
SendMode("Event")

global app := ""

class GhostClicker {
    targetWindow := ""
    targetWindowId := ""
    clickDelay := 800
    loopClicker := true
    stop := false
    clickerIsOn := false
    gui := ""
    clickerData := Map()
    guiControls := Map()
    gameMode := true
    randomMovement := false
    
    __New() {
        Loop 10 {
            this.clickerData[A_Index] := {
                enabled: false,
                actionType: "mouse",
                x: 0,
                y: 0,
                keyName: "",
                clicks: 1,
                posSet: false
            }
        }
        this.CreateGUI()
    }
    
    CreateGUI() {
        this.gui := Gui("+AlwaysOnTop -MinimizeBox", "Ghost Clicker Pro v4.3")
        this.gui.BackColor := "0x1E1E1E"
        this.gui.SetFont("s10", "Segoe UI")
        
        ; Header with gradient effect
        this.gui.SetFont("s12 Bold", "Segoe UI")
        headerText := this.gui.Add("Text", "x10 y10 w460 h35 Center c0xFFFFFF Background0x2D2D30", "🎮 GHOST CLICKER PRO")
        this.gui.SetFont("s10", "Segoe UI")
        
        ; Status Bar
        this.guiControls["Status"] := this.gui.Add("Text", "x10 y50 w460 h30 Center Border c0x00FF00 Background0x252526", "✅ Ready to Start")
        
        ; Target Window Section
        this.gui.Add("GroupBox", "x10 y90 w460 h75 c0xCCCCCC", "🎯 Target Window")
        this.gui.Add("Button", "x20 y110 w100 h30 Background0x0E639C c0xFFFFFF", "Set Target").OnEvent("Click", (*) => this.SetLocation())
        this.guiControls["TargetWindow"] := this.gui.Add("Edit", "x130 y110 w250 h30 ReadOnly Background0x3C3C3C c0xFFFFFF", "")
        this.gui.Add("Button", "x390 y110 w70 h30 Background0x5A5A5A c0xFFFFFF", "Clear").OnEvent("Click", (*) => this.ClearTarget())
        
        ; Quick Setup Section
        this.gui.Add("GroupBox", "x10 y175 w460 h120 c0xCCCCCC", "⚡ Quick AFK Setup")
        
        ; Row 1
        this.gui.Add("Button", "x20 y195 w140 h35 Background0x0E639C c0xFFFFFF", "🎯 WASD Auto").OnEvent("Click", (*) => this.QuickSetupWASD())
        this.gui.Add("Button", "x170 y195 w140 h35 Background0x0E639C c0xFFFFFF", "🏃 Walk Forward").OnEvent("Click", (*) => this.QuickSetupForward())
        this.gui.Add("Button", "x320 y195 w140 h35 Background0x0E639C c0xFFFFFF", "⌨️ Auto Jump").OnEvent("Click", (*) => this.QuickSetupJump())
        
        ; Row 2
        this.gui.Add("Button", "x20 y235 w140 h35 Background0x0E639C c0xFFFFFF", "🖱️ Click Spam").OnEvent("Click", (*) => this.QuickSetupClick())
        this.gui.Add("Button", "x170 y235 w140 h35 Background0x0E639C c0xFFFFFF", "🔄 Auto Spin").OnEvent("Click", (*) => this.QuickSetupSpin())
        this.gui.Add("Button", "x320 y235 w140 h35 Background0x4EC9B0 c0x000000", "⚡ All Actions").OnEvent("Click", (*) => this.QuickSetupAll())
        
        ; Settings Section
        this.gui.Add("GroupBox", "x10 y305 w460 h80 c0xCCCCCC", "⚙️ Settings")
        
        this.gui.Add("Text", "x20 y330 c0xFFFFFF", "Delay (ms):")
        this.guiControls["ClickDelay"] := this.gui.Add("Edit", "x100 y327 w70 h25 Background0x3C3C3C c0xFFFFFF Number", this.clickDelay)
        this.guiControls["ClickDelay"].OnEvent("Change", (*) => this.UpdateSettings())
        
        this.gui.Add("Text", "x190 y330 c0xFFFFFF", "Hold (ms):")
        this.guiControls["KeyHoldTime"] := this.gui.Add("Edit", "x265 y327 w70 h25 Background0x3C3C3C c0xFFFFFF Number", "100")
        
        this.guiControls["LoopClicker"] := this.gui.Add("CheckBox", "x20 y357 c0xFFFFFF Checked", "🔄 Loop Forever")
        this.guiControls["LoopClicker"].OnEvent("Click", (*) => this.UpdateSettings())
        
        this.guiControls["RandomMovement"] := this.gui.Add("CheckBox", "x160 y357 c0xFFFFFF", "🎲 Random Timing")
        this.guiControls["RandomMovement"].OnEvent("Click", (*) => this.UpdateSettings())
        
        this.guiControls["GameMode"] := this.gui.Add("CheckBox", "x300 y357 c0xFFFFFF Checked", "🎮 Game Mode")
        this.guiControls["GameMode"].OnEvent("Click", (*) => this.ToggleGameMode())
        
        ; Manual Actions Section
        this.gui.Add("GroupBox", "x10 y395 w460 h175 c0xCCCCCC", "🛠️ Manual Actions (Advanced)")
        
        currentY := 420
        Loop 5 {
            this.CreateClickerRow(A_Index, 20, currentY)
            currentY += 28
        }
        
        ; Control Buttons
        this.gui.Add("Button", "x10 y580 w150 h45 Background0x16825D c0xFFFFFF", "▶️ START").OnEvent("Click", (*) => this.StartClicker())
        this.gui.Add("Button", "x170 y580 w110 h45 Background0xC50F1F c0xFFFFFF", "⏹️ STOP").OnEvent("Click", (*) => this.StopClicker())
        this.gui.Add("Button", "x290 y580 w85 h45 Background0x5A5A5A c0xFFFFFF", "🧪 Test").OnEvent("Click", (*) => this.TestMode())
        this.gui.Add("Button", "x385 y580 w85 h45 Background0x3C3C3C c0xFFFFFF", "❌ Exit").OnEvent("Click", (*) => this.Exit())
        
        ; Footer
        this.gui.Add("Text", "x10 y635 w460 h20 Center c0x888888", "Hotkeys: F1=Start | F2=Stop | Ctrl+Shift+F2=Emergency Stop")
        this.gui.Add("Text", "x10 y655 w460 h20 Center c0x888888", "💡 Tip: Use WASD Auto or All Actions for best results")
        
        this.gui.Show("w480 h685")
        this.gui.OnEvent("Close", (*) => this.Exit())
        this.UpdateSettings()
    }
    
    CreateClickerRow(index, x, y) {
        this.guiControls["Clicker_" . index] := this.gui.Add("CheckBox", "x" . x . " y" . y . " w30 c0xFFFFFF", "#" . index)
        this.guiControls["Clicker_" . index].OnEvent("Click", (*) => this.UpdateSettings())
        
        this.guiControls["ActionType_" . index] := this.gui.Add("DropDownList", "x" . (x+35) . " y" . (y-2) . " w70 Background0x3C3C3C c0xFFFFFF", ["Mouse", "Key"])
        this.guiControls["ActionType_" . index].Choose(1)
        this.guiControls["ActionType_" . index].OnEvent("Change", (*) => this.UpdateActionType(index))
        
        this.gui.Add("Button", "x" . (x+110) . " y" . (y-1) . " w45 h23 Background0x5A5A5A c0xFFFFFF", "Set").OnEvent("Click", (*) => this.SetPositionOrKey(index))
        this.guiControls["Pos_" . index] := this.gui.Add("Edit", "x" . (x+160) . " y" . (y-1) . " w140 h23 ReadOnly Background0x3C3C3C c0xFFFFFF", "Not Set")
        
        this.gui.Add("Text", "x" . (x+305) . " y" . y . " c0xFFFFFF", "x")
        this.guiControls["NoClicks_" . index] := this.gui.Add("Edit", "x" . (x+320) . " y" . (y-1) . " w35 h23 Number Background0x3C3C3C c0xFFFFFF", "1")
        this.guiControls["NoClicks_" . index].OnEvent("Change", (*) => this.UpdateSettings())
        
        this.gui.Add("Text", "x" . (x+360) . " y" . y . " c0x888888", "times")
    }
    
    ; ============ QUICK SETUP FUNCTIONS ============
    
    QuickSetupWASD() {
        if (!this.ValidateTarget()) {
            return
        }
        
        keys := ["w", "a", "s", "d"]
        Loop 4 {
            this.clickerData[A_Index].enabled := true
            this.clickerData[A_Index].actionType := "keyboard"
            this.clickerData[A_Index].keyName := keys[A_Index]
            this.clickerData[A_Index].posSet := true
            this.clickerData[A_Index].clicks := 1
            
            this.guiControls["Clicker_" . A_Index].Value := true
            this.guiControls["ActionType_" . A_Index].Choose(2)
            this.guiControls["Pos_" . A_Index].Text := keys[A_Index]
        }
        
        this.clickDelay := 800
        this.guiControls["ClickDelay"].Text := this.clickDelay
        this.guiControls["RandomMovement"].Value := true
        this.randomMovement := true
        
        MsgBox("✅ WASD Auto Setup Complete!`n`nCharacter will move in W-A-S-D pattern`nDelay: 800ms per key`n`n🟢 Click START to begin!", "Setup Complete", "Iconi")
        this.UpdateStatus("✅ WASD Auto Ready!")
    }
    
    QuickSetupForward() {
        if (!this.ValidateTarget()) {
            return
        }
        
        this.clickerData[1].enabled := true
        this.clickerData[1].actionType := "keyboard"
        this.clickerData[1].keyName := "w"
        this.clickerData[1].posSet := true
        this.clickerData[1].clicks := 1
        
        this.guiControls["Clicker_1"].Value := true
        this.guiControls["ActionType_1"].Choose(2)
        this.guiControls["Pos_1"].Text := "w"
        
        this.clickDelay := 500
        this.guiControls["ClickDelay"].Text := this.clickDelay
        
        MsgBox("✅ Forward Movement Setup!`n`nCharacter will walk forward (W key)`nDelay: 500ms`n`n🟢 Click START!", "Setup Complete", "Iconi")
        this.UpdateStatus("✅ Forward Movement Ready!")
    }
    
    QuickSetupJump() {
        if (!this.ValidateTarget()) {
            return
        }
        
        this.clickerData[1].enabled := true
        this.clickerData[1].actionType := "keyboard"
        this.clickerData[1].keyName := "Space"
        this.clickerData[1].posSet := true
        this.clickerData[1].clicks := 1
        
        this.guiControls["Clicker_1"].Value := true
        this.guiControls["ActionType_1"].Choose(2)
        this.guiControls["Pos_1"].Text := "Space"
        
        this.clickDelay := 2000
        this.guiControls["ClickDelay"].Text := this.clickDelay
        
        MsgBox("✅ Auto Jump Setup!`n`nCharacter will jump every 2 seconds`n`n🟢 Click START!", "Setup Complete", "Iconi")
        this.UpdateStatus("✅ Auto Jump Ready!")
    }
    
    QuickSetupClick() {
        if (!this.ValidateTarget()) {
            return
        }
        
        MsgBox("After clicking OK, you have 3 seconds to click where you want to spam clicks.`n`nExample: Button, NPC, etc.", "Quick Setup", "Iconi T3")
        Sleep(3000)
        
        MouseGetPos(&x, &y)
        
        this.clickerData[1].enabled := true
        this.clickerData[1].actionType := "mouse"
        this.clickerData[1].x := x
        this.clickerData[1].y := y
        this.clickerData[1].posSet := true
        this.clickerData[1].clicks := 1
        
        this.guiControls["Clicker_1"].Value := true
        this.guiControls["ActionType_1"].Choose(1)
        this.guiControls["Pos_1"].Text := x . "," . y
        
        this.clickDelay := 500
        this.guiControls["ClickDelay"].Text := this.clickDelay
        
        MsgBox("✅ Click Spam Setup!`n`nWill click at: " . x . "," . y . "`nEvery 500ms`n`n🟢 Click START!", "Setup Complete", "Iconi")
        this.UpdateStatus("✅ Click Spam Ready!")
    }
    
    QuickSetupSpin() {
        if (!this.ValidateTarget()) {
            return
        }
        
        this.clickerData[1].enabled := true
        this.clickerData[1].actionType := "keyboard"
        this.clickerData[1].keyName := "a"
        this.clickerData[1].posSet := true
        this.clickerData[1].clicks := 1
        
        this.clickerData[2].enabled := true
        this.clickerData[2].actionType := "keyboard"
        this.clickerData[2].keyName := "d"
        this.clickerData[2].posSet := true
        this.clickerData[2].clicks := 1
        
        this.guiControls["Clicker_1"].Value := true
        this.guiControls["ActionType_1"].Choose(2)
        this.guiControls["Pos_1"].Text := "a"
        
        this.guiControls["Clicker_2"].Value := true
        this.guiControls["ActionType_2"].Choose(2)
        this.guiControls["Pos_2"].Text := "d"
        
        this.clickDelay := 500
        this.guiControls["ClickDelay"].Text := this.clickDelay
        
        MsgBox("✅ Auto Spin Setup!`n`nCharacter will spin left-right (A-D keys)`n`n🟢 Click START!", "Setup Complete", "Iconi")
        this.UpdateStatus("✅ Auto Spin Ready!")
    }
    
    QuickSetupAll() {
        if (!this.ValidateTarget()) {
            return
        }
        
        actions := [{key: "w", name: "Forward"}, {key: "a", name: "Left"}, 
                    {key: "d", name: "Right"}, {key: "Space", name: "Jump"}]
        
        Loop 4 {
            this.clickerData[A_Index].enabled := true
            this.clickerData[A_Index].actionType := "keyboard"
            this.clickerData[A_Index].keyName := actions[A_Index].key
            this.clickerData[A_Index].posSet := true
            this.clickerData[A_Index].clicks := 1
            
            this.guiControls["Clicker_" . A_Index].Value := true
            this.guiControls["ActionType_" . A_Index].Choose(2)
            this.guiControls["Pos_" . A_Index].Text := actions[A_Index].key
        }
        
        this.clickDelay := 1000
        this.guiControls["ClickDelay"].Text := this.clickDelay
        this.guiControls["RandomMovement"].Value := true
        this.randomMovement := true
        
        MsgBox("✅ All Actions Setup!`n`nW → A → D → Space → Loop`nMaximum activity mode!`n`n🟢 Click START!", "Setup Complete", "Iconi")
        this.UpdateStatus("✅ All Actions Ready!")
    }
    
    ValidateTarget() {
        if (this.targetWindowId == "") {
            MsgBox("❌ Please set target window first!`n`nClick 'Set Target' then click on the Roblox window", "Error", "Icon!")
            return false
        }
        return true
    }
    
    ; ============ CORE FUNCTIONS ============
    
    ToggleGameMode() {
        this.gameMode := this.guiControls["GameMode"].Value
        this.UpdateStatus(this.gameMode ? "🎮 Game Mode ON" : "📱 Standard Mode")
    }
    
    UpdateSettings() {
        try {
            delayText := this.guiControls["ClickDelay"].Text
            if (delayText != "" && IsNumber(delayText)) {
                this.clickDelay := Max(50, Integer(delayText))
            }
            
            this.loopClicker := this.guiControls["LoopClicker"].Value
            this.randomMovement := this.guiControls["RandomMovement"].Value
            
            Loop 5 {
                this.clickerData[A_Index].enabled := this.guiControls["Clicker_" . A_Index].Value
                actionTypeIndex := this.guiControls["ActionType_" . A_Index].Value
                this.clickerData[A_Index].actionType := (actionTypeIndex == 1) ? "mouse" : "keyboard"
                
                clickText := this.guiControls["NoClicks_" . A_Index].Text
                if (clickText != "" && IsNumber(clickText)) {
                    this.clickerData[A_Index].clicks := Max(1, Integer(clickText))
                }
            }
        }
    }
    
    UpdateActionType(index) {
        this.clickerData[index].posSet := false
        this.guiControls["Pos_" . index].Text := "Not Set"
    }
    
    UpdateStatus(message) {
        if (this.guiControls.Has("Status")) {
            this.guiControls["Status"].Text := message
            
            ; Change color based on status
            if (InStr(message, "RUNNING") || InStr(message, "Ready")) {
                this.guiControls["Status"].Opt("c0x00FF00")
            } else if (InStr(message, "Error") || InStr(message, "STOP")) {
                this.guiControls["Status"].Opt("c0xFF0000")
            } else if (InStr(message, "Starting")) {
                this.guiControls["Status"].Opt("c0xFFFF00")
            } else {
                this.guiControls["Status"].Opt("c0x00FFFF")
            }
        }
    }
    
    SetLocation() {
        if (this.clickerIsOn) {
            MsgBox("Please stop the clicker first!", "Error", "Icon!")
            return
        }
        
        this.UpdateStatus("🎯 Setting target...")
        ToolTip("Click on the Roblox window in 3 seconds...", 50, 50)
        Sleep(3000)
        ToolTip("CLICK NOW!", 50, 50)
        
        while (!GetKeyState("LButton", "P")) {
            Sleep(10)
        }
        
        MouseGetPos(, , &winId)
        
        try {
            if (winId && winId != 0) {
                winTitle := WinGetTitle("ahk_id " . winId)
                if (winTitle != "") {
                    this.targetWindow := winTitle
                    this.targetWindowId := String(winId)
                    this.guiControls["TargetWindow"].Text := winTitle
                    
                    if (InStr(winTitle, "Roblox") || InStr(winTitle, "roblox")) {
                        this.guiControls["GameMode"].Value := true
                        this.ToggleGameMode()
                        ToolTip("✅ Roblox detected! Ready to go!", 50, 50)
                        this.UpdateStatus("✅ Roblox Set! Use Quick Setup →")
                    } else {
                        ToolTip("✅ Target window set!", 50, 50)
                        this.UpdateStatus("✅ Target Window Set!")
                    }
                }
            }
        } catch Error as e {
            ToolTip("❌ Error: " . e.Message, 50, 50)
        }
        
        SetTimer(() => ToolTip(), -3000)
    }
    
    ClearTarget() {
        this.targetWindow := ""
        this.targetWindowId := ""
        this.guiControls["TargetWindow"].Text := ""
        this.UpdateStatus("Target Cleared")
    }
    
    SetPositionOrKey(index) {
        if (!this.ValidateTarget()) {
            return
        }
        
        actionType := this.guiControls["ActionType_" . index].Text
        if (actionType == "Mouse") {
            this.SetPosition(index)
        } else {
            this.SetKey(index)
        }
    }
    
    SetPosition(index) {
        ToolTip("Click position in 2 seconds...", 50, 50)
        Sleep(2000)
        ToolTip("CLICK NOW!", 50, 50)
        
        while (!GetKeyState("LButton", "P")) {
            Sleep(10)
        }
        
        MouseGetPos(&x, &y)
        this.clickerData[index].x := x
        this.clickerData[index].y := y
        this.clickerData[index].posSet := true
        this.guiControls["Pos_" . index].Text := x . "," . y
        
        ToolTip("✅ Position set!", 50, 50)
        SetTimer(() => ToolTip(), -2000)
    }
    
    SetKey(index) {
        ToolTip("Press a key for #" . index . " (ESC to cancel)...", 50, 50)
        
        try {
            ih := InputHook("L1 T10")
            ih.Start()
            ih.Wait()
            
            keyName := ih.Input != "" ? ih.Input : ih.EndKey
            
            if (keyName != "" && keyName != "Escape") {
                this.clickerData[index].keyName := keyName
                this.clickerData[index].posSet := true
                this.guiControls["Pos_" . index].Text := keyName
                ToolTip("✅ Key set: " . keyName, 50, 50)
            }
        }
        
        SetTimer(() => ToolTip(), -2000)
    }
    
    StartClicker() {
        if (this.clickerIsOn) {
            this.UpdateStatus("❌ Already Running!")
            return
        }
        
        if (!this.ValidateSetup()) {
            return
        }
        
        this.UpdateStatus("🟡 Starting...")
        this.RunClicker()
    }
    
    StopClicker() {
        this.stop := true
        this.UpdateStatus(this.clickerIsOn ? "🛑 Stopping..." : "⭕ Stopped")
    }
    
    ValidateSetup() {
        hasEnabled := false
        Loop 5 {
            if (this.clickerData[A_Index].enabled) {
                hasEnabled := true
                if (!this.clickerData[A_Index].posSet) {
                    MsgBox("❌ Please set position/key for #" . A_Index . "!`n`nOr use Quick Setup for instant configuration!", "Error", "Icon!")
                    return false
                }
            }
        }
        
        if (!hasEnabled) {
            MsgBox("❌ Enable at least 1 action!`n`n💡 Use Quick Setup for easy configuration!", "Error", "Icon!")
            return false
        }
        
        if (this.targetWindowId == "") {
            MsgBox("❌ Please set target window first!", "Error", "Icon!")
            return false
        }
        
        return true
    }
    
    RunClicker() {
        this.stop := false
        this.clickerIsOn := true
        
        this.UpdateStatus("🟢 RUNNING - Active Mode")
        ToolTip("🟢 AFK MODE ACTIVE!`n" . this.targetWindow . "`n`nPress F2 to stop", 100, 100)
        
        try {
            cycleCount := 0
            while (!this.stop && (this.loopClicker || cycleCount == 0)) {
                cycleCount++
                this.UpdateStatus("🟢 RUNNING - Cycle #" . cycleCount)
                this.ExecuteActions()
                
                if (this.clickDelay > 0) {
                    delay := this.randomMovement ? Random(this.clickDelay * 0.8, this.clickDelay * 1.2) : this.clickDelay
                    Sleep(delay)
                }
            }
        } catch Error as e {
            this.UpdateStatus("❌ Error: " . e.Message)
            MsgBox("Error: " . e.Message, "Clicker Error", "Icon!")
        }
        
        this.clickerIsOn := false
        this.UpdateStatus("⭕ STOPPED")
        ToolTip("⭕ AFK STOPPED", 100, 100)
        SetTimer(() => ToolTip(), -2000)
    }
    
    ExecuteActions() {
        Loop 5 {
            if (this.stop) {
                return
            }
            
            if (this.clickerData[A_Index].enabled && this.clickerData[A_Index].posSet) {
                this.ExecuteAction(A_Index)
            }
        }
    }
    
    ExecuteAction(index) {
        data := this.clickerData[index]
        
        Loop data.clicks {
            if (this.stop) {
                return
            }
            
            try {
                if (data.actionType == "mouse") {
                    this.DoClick(data.x, data.y)
                } else {
                    this.DoKey(data.keyName)
                }
            } catch {
                ; Silent fail
            }
        }
    }
    
    ; ============ INPUT METHODS - DIRECT WINDOW (MOST RELIABLE) ============
    
    DoClick(x, y) {
        try {
            ; Direct window activation + click (MOST RELIABLE for Roblox)
            WinActivate("ahk_id " . this.targetWindowId)
            Sleep(50)
            
            ; Store old position
            MouseGetPos(&oldX, &oldY)
            
            ; Move and click
            MouseMove(x, y, 0)
            Sleep(30)
            Click()
            Sleep(30)
            
            ; Restore position
            MouseMove(oldX, oldY, 0)
        }
    }
    
    DoKey(keyName) {
        holdTime := this.guiControls["KeyHoldTime"].Text
        holdMs := (holdTime != "" && IsNumber(holdTime)) ? Integer(holdTime) : 100
        
        try {
            ; DIRECT WINDOW (BEST for Roblox!)
            ; Activate window
            WinActivate("ahk_id " . this.targetWindowId)
            Sleep(30)
            
            ; Send key with explicit hold
            Send("{" . keyName . " down}")
            Sleep(holdMs)
            Send("{" . keyName . " up}")
        } catch {
            ; Fallback
            try {
                WinActivate("ahk_id " . this.targetWindowId)
                Sleep(50)
                sendKey := (StrLen(keyName) == 1) ? keyName : "{" . keyName . "}"
                Send(sendKey)
            }
        }
    }
    
    TestMode() {
        if (!this.ValidateSetup()) {
            return
        }
        
        msg := "🧪 TEST PREVIEW`n`n"
        msg .= "Target: " . this.targetWindow . "`n"
        msg .= "Mode: Direct Window (Most Reliable)`n"
        msg .= "Delay: " . this.clickDelay . "ms" . (this.randomMovement ? " ±20%" : "") . "`n"
        msg .= "Loop: " . (this.loopClicker ? "YES" : "No") . "`n`n"
        
        msg .= "ACTIONS:`n"
        count := 0
        Loop 5 {
            if (this.clickerData[A_Index].enabled && this.clickerData[A_Index].posSet) {
                count++
                data := this.clickerData[A_Index]
                if (data.actionType == "mouse") {
                    msg .= "#" . A_Index . ": Click (" . data.x . "," . data.y . ") x" . data.clicks . "`n"
                } else {
                    msg .= "#" . A_Index . ": Key '" . data.keyName . "' x" . data.clicks . "`n"
                }
            }
        }
        
        if (count > 0) {
            msg .= "`n✅ Total: " . count . " actions"
            msg .= "`n`n🔥 Ready to START!"
        } else {
            msg .= "❌ No actions configured!"
        }
        
        MsgBox(msg, "Test Preview", "Iconi")
    }
    
    Exit() {
        this.stop := true
        ExitApp()
    }
}

; Initialize
try {
    app := GhostClicker()
} catch Error as err {
    MsgBox("Error: " . err.Message, "Initialization Failed", "Icon!")
    ExitApp()
}

; ============ HOTKEYS ============

F1:: {
    global app
    if (app && IsObject(app)) {
        app.StartClicker()
    }
}

F2:: {
    global app
    if (app && IsObject(app)) {
        app.StopClicker()
    }
}

; Emergency stop
^+F2:: {
    global app
    if (app && IsObject(app)) {
        app.StopClicker()
        app.UpdateStatus("🛑 EMERGENCY STOP!")
        ToolTip("🛑 EMERGENCY STOP!", 300, 300)
        SetTimer(() => ToolTip(), -2000)
    }
}

; Force exit
^+Esc:: {
    global app
    if (app && IsObject(app)) {
        app.Exit()
    } else {
        ExitApp()
    }
}