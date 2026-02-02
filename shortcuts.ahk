#Requires AutoHotkey v2.0

; Win + b → Google Chrome
#b:: {
    Run("chrome.exe")
}

; Win + Enter → Command Prompt
#Enter:: {
    Run("cmd.exe")
}

; Ctrl + q → Close active window
^q:: {
    WinClose("A")
}

; Win + Shift + v → VS Code
#+v:: {
    Run("code")
}

; Win + f → Downloads folder
#f:: {
    Run("explorer.exe C:\Users\" A_Username "\Downloads")
}

; Win + Shift + Enter → Ubuntu in Windows Terminal
  #+Enter:: {
      Run('wt.exe -p "Ubuntu 22.04.5 LTS"')
  }