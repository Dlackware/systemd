for i in HighContrast Adwaita ; do
  if [ -e usr/share/icons/$theme/icon-theme.cache ]; then
    if [ -x /usr/bin/gtk-update-icon-cache ]; then
      /usr/bin/gtk-update-icon-cache usr/share/icons/$theme >/dev/null 2>&1
    fi
  fi
done

