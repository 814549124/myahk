; /tcond/ccond[text=cond,x=cond,y=cond,w=cond,h=cond,focus=]
; cond
;   reg:
;   start:
;   end:
;   contain:
;   equal:

; parseCond("reg:")
; MsgBox % searchEscapedPos("/aa/","/",2)
; MsgBox % searchEscapedsPos("/123abc/","ab",1)
ctns := searchControls("/sdy/contain:C")
for i,ctn in ctns
{
  MsgBox % ctn
}
; MsgBox % hitContain("abc","b")
; MsgBox % hitContain("abc","d")
; MsgBox % hitEqual("abc","abc")
; MsgBox % hitEqual("abc","abd")
; MsgBox % hitEqual("abc","ab")
return

searchControls(path) {
  pathObj := parsePath(path)
  titleCond := pathObj.title
  ; MsgBox % Format("{}--{}", titleCond.type,titleCond.val)
  WinGet wlist, List
  hitWid := []
  loop %wlist%
  {
    wid := (wlist%A_Index%)
    WinGetTitle title, ahk_id %wid%
    if hitCond(title,titleCond)
    {
      ; MsgBox % "???push" . wid
      hitWid.push(wid)
    }
    ; break
  }
  hitCtns := {}
  for i,wid in hitWid
  {
    WinGet cList, ControlList, ahk_id %wid%

    ControlGetFocus focusCtn, ahk_id %wid%
    getFocusControlErrorLevel := ErrorLevel
    Loop, Parse, cList, `n
    {
      ctn := A_LoopField
      if hitCond(ctn,pathObj.contrl)
      {
        isHit := true

        if pathObj.text
        {
          ControlGetText ctnText, ctn, ahk_id %wid%
          if hitCond(ctnText,pathObj.text) = false
          {
            isHit := false
          }
        }

        ControlGetPos x,y,w,h,ctn, ahk_id %wid%
        if pathObj.x
        {
          if not hitCond(x,pathObj.x)
          {
            isHit := false
          }
        }
        if pathObj.y
        {
          if not hitCond(y,pathObj.y)
          {
            isHit := false
          }
        }
        if pathObj.w
        {
          if not hitCond(w,pathObj.w)
          {
            isHit := false
          }
        }
        if pathObj.h
        {
          if not hitCond(h,pathObj.h)
          {
            isHit := false
          }
        }

        if pathObj.focus
        {
          if getFocusControlErrorLevel = 0
          {
            if focusCtn != ctn
            {
              isHit := false
            }
          }
          else
          {
            ; 无focus控件
            isHit := false
          }
        }

        if isHit
        {
          hitCtns.push(ctn)
        }
      }
    }
  }

  return hitCtns
} 
return

parseCond(cond) {
  if isStartWith(cond,"reg:") = True {
    ; ToolTip % "reg:"
    return {type: "reg",val: RegExReplace(cond, "reg:")}
  } else if isStartWith(cond,"start:") = True {
    ; ToolTip % "start:"
    return {type: "start",val: RegExReplace(cond, "start:")}
  } else if isStartWith(cond,"end:") = True {
    ; ToolTip % "end:"
    return {type: "end",val: RegExReplace(cond, "end:")}
  } else if isStartWith(cond,"contain:") = True {
    ; ToolTip % "contain:"
    return {type: "contain",val: RegExReplace(cond, "contain:")}
  } else {
  ; } else if isStartWith(cond,"equal:") = True {
    ; ToolTip % "equal:"
    return {type: "equal",val: RegExReplace(cond, "equal:")}
  }
}

isStartWith(txt,startWith) {
  return 1 = InStr(txt, startWith)
}

; escaped / [ ] = ,
parsePath(path) {
  pathObj := {}
  fppos := searchEscapedPos(path,"/",1)
  sppos := searchEscapedPos(path,"/",2)
  length := sppos - fppos - 1
  StringMid, title, % path, % fppos + 1,% length,
  pathObj.title := parseCond(title)
  fbpos := searchEscapedPos(path,"[",2)
  ; MsgBox % pathObj.title.type
  if fbpos = 0
  {
    StringMid, contrl, % path, % sppos + 1
  }
  else
  {
    slen := fbpos - sppos - 1
    StringMid, contrl, % path, % sppos + 1, % slen
  }
  ; MsgBox % contrl
  pathObj.contrl := parseCond(contrl)
  if RegExMatch(path, "text=(.*?)[,\]]", textM, fbpos) != 0
  {
    pathObj.text := parseCond(textM1)
  }
  if RegExMatch(path, "x=(.*?)[,\]]", xM, fbpos) != 0
  {
    pathObj.x := parseCond(xM1)
  }
  if RegExMatch(path, "y=(.*?)[,\]]", yM, fbpos) != 0
  {
    pathObj.y := parseCond(yM1)
  }
  if RegExMatch(path, "w=(.*?)[,\]]", wM, fbpos) != 0
  {
    pathObj.w := parseCond(wM1)
  }
  if RegExMatch(path, "h=(.*?)[,\]]", hM, fbpos) != 0
  {
    pathObj.h := parseCond(hM1)
  }
  if RegExMatch(path, "focus=(.*?)[,\]]", focusM, fbpos) != 0
  {
    pathObj.focus := parseCond(focusM1)
  }
  return pathObj
}

; escaped / [ ] = ,
isEscapedChar(char) {
  if Ord(char) = Ord("/") {
    return true
  } else if Ord(char) = Ord("[") {
    return true
  } else if Ord(char) = Ord("]") {
    return true
  } else if Ord(char) = Ord("=") {
    return true
  } else if Ord(char) = Ord(",") {
    return true    
  }
  return false
}

searchEscapedPos(txt,escaped,startPos := 1) {
  spos := startPos
  pos := 0
  escp := Format("\{}", escaped)

  while true 
  {
    pos := RegExMatch(txt, escp,,spos)
    ; MsgBox "pos" . %pos% . ":spos" . %spos%

    if pos = 0
      break
    if pos = 1
      return pos

    StringMid getC,% txt,% pos - 1,1,

    ; MsgBox % Format("aaa {1}",StrLen(getC))

    if Ord(getC) = Ord("\") 
    {
      ; MsgBox % Format("bbb {1}",getC)
      spos := pos + 1
      continue
    }

    return pos
  }
  
  return 0
}

hitCond(txt,cond) {
  if cond.type = "reg" {
    return hitReg(txt,cond.val)
  } else if cond.type = "start" {
    return hitStart(txt,cond.val)
  } else if cond.type = "end" {
    return hitEnd(txt,cond.val)
  } else if cond.type = "contain" {
    return hitContain(txt,cond.val)
  } else if cond.type = "equal" {
    return hitEqual(txt,cond.val)
  }
  return false
}

hitReg(txt,arg) {
  return RegExMatch(txt, arg) = 1
}

hitStart(txt,arg) {
  StringGetPos hpos, txt, arg
  return hpos = 0
}

hitEnd(txt,arg) {
  StringGetPos hpos, txt, arg
  return hpos = StringLen txt
}

hitContain(txt,arg) {
  hpos := InStr(txt, arg)
  ; MsgBox % Format("{} - {} - {}", hpos,txt,arg)
  return hpos != 0
}

hitEqual(txt,arg) {
  hit := hitContain(txt,arg)
  ; MsgBox % "hitEqual:" . hit
  if hit = false
  {
    return false
  }
  return StringLen txt = StringLen arg
}



#z::Exit
