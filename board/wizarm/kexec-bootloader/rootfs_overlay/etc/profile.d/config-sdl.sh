# X11 mode-switching requires XRandR
export SDL_VIDEO_X11_XRANDR=1
# No mouse is ok
export SDL_NOMOUSE=1
# Inhibit framebuffer mode-switching
export SDL_FB_BROKEN_MODES=1
