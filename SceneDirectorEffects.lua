--
-- Scene Director Effects:
--
-- + None
-- + MoveFromRight
-- + MoveFromLeft
-- + MoveFromTop
-- + MoveFromBottom
-- + OverFromRight
-- + OverFromLeft
-- + OverFromTop
-- + OverFromBottom
-- + CrossFade
-- + FadeIn
-- + FadeOut
--
local SceneDirectorEffects = {
 
  None             = function(e)
    e.to.x         = 0
    e.to.y         = 0
    timer.performWithDelay(1, e.onComplete)
  end,
 
  MoveFromRight    = function(e) 
    e.to.x         = display.contentWidth
    e.to.y         = 0
    e.handle       = transition.to(e.to, { 
      x            = 0, 
      time         = e.time, 
      transition   = easing.inOutQuad,
      onComplete   = e.onComplete 
    })
    if (e.from) then
      transition.to(e.from, { 
        x          = -display.contentWidth, 
        time       = e.time,
        transition = easing.inOutQuad
    })
    end
  end,
  
  MoveFromLeft     = function(e)
    e.to.x         = -display.contentWidth
    e.to.y         = 0
    e.handle       = transition.to(e.to, { 
      x            = 0, 
      time         = e.time, 
      transition   = easing.inOutQuad,
      onComplete   = e.onComplete
    })
    if (e.from) then
      transition.to(e.from, { 
        x          = display.contentWidth,  
        time       = e.time,
        transition = easing.inOutQuad
    })
		end
  end,
  
  MoveFromTop      = function(e)
    e.to.x         = 0
    e.to.y         = -display.contentHeight
    e.handle       = transition.to(e.to, { 
      y            = 0, 
      time         = e.time, 
      transition   = easing.inOutQuad,
      onComplete   = e.onComplete
    })
    if (e.from) then
      transition.to(e.from, { 
        y          = display.contentHeight,  
        time       = e.time, 
        transition = easing.inOutQuad
    })
		end
  end,
  
  MoveFromBottom   = function(e)
    e.to.x         = 0
    e.to.y         = display.contentHeight
    e.handle       = transition.to(e.to, { 
      y            = 0, 
      time         = e.time, 
      transition   = easing.inOutQuad,
      onComplete   = e.onComplete
    })
    if (e.from) then
      transition.to(e.from, { 
        y          = -display.contentHeight,  
        time       = e.time, 
        transition = easing.inOutQuad
      })
		end
  end,
  
  OverFromRight    = function(e) 
    e.to.x         = display.contentWidth
    e.to.y         = 0
    e.handle       = transition.to(e.to, { 
      x            = 0, 
      time         = e.time, 
      transition   = easing.inOutQuad,
      onComplete   = e.onComplete 
    })
  end,

  OverFromLeft     = function(e) 
    e.to.x         = -display.contentWidth
    e.to.y         = 0
    e.handle       = transition.to(e.to, { 
      x            = 0, 
      time         = e.time, 
      transition   = easing.inOutQuad,
      onComplete   = e.onComplete 
    })
  end,
  
  OverFromTop      = function(e) 
    e.to.x         = 0
    e.to.y         = -display.contentHeight
    e.handle       = transition.to(e.to, { 
      y            = 0, 
      time         = e.time, 
      transition   = easing.inOutQuad,
      onComplete   = e.onComplete 
    })
  end,
  
  OverFromBottom   = function(e) 
    e.to.x         = 0
    e.to.y         = display.contentHeight
    e.handle       = transition.to(e.to, { 
      y            = 0, 
      time         = e.time, 
      transition   = easing.inOutQuad,
      onComplete   = e.onComplete 
    })
  end,
  
  Fade             = function(e) 
    e.to.x         = 0
    e.to.y         = 0
    e.to.alpha     = 0
    e.handle       = transition.to(e.from, { 
      alpha        = 0, 
      time         = e.time, 
      onComplete   = function() 
          e.handle   = transition.to(e.to, {
          alpha      = 1,
          time       = e.time,
          onComplete = e.onComplete
        })
      end
		})
  end,
 
  CrossFade        = function(e) 
    e.to.x         = 0
    e.to.y         = 0
    e.to.alpha     = 0
    e.handle       = transition.to(e.to, { 
      alpha        = 1, 
      time         = e.time, 
      onComplete   = e.onComplete 
    })
    if (e.from) then
      transition.to(e.from, { 
        alpha      = 0,  
        time       = e.time 
      })
		end
  end,
  
  FadeIn           = function(e) 
    e.to.x         = 0
    e.to.y         = 0
    e.to.alpha     = 0
    e.handle       = transition.to(e.to, { 
      alpha        = 1, 
      time         = e.time, 
      onComplete   = e.onComplete 
    })
  end,
  
  FadeOut          = function(e) 
    e.to.x         = 0
    e.to.y         = 0
    if (e.from) then 
      e.from:toFront()
      e.handle     = transition.to(e.from, { 
        alpha      = 0,  
        time       = e.time,
        onComplete = e.onComplete 
      })
		else
		  e.onComplete()
		end
  end,
}

return SceneDirectorEffects
