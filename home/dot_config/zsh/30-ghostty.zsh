if test -n "$GHOSTTY_RESOURCES_DIR"; then
  autoload -Uz -- "$GHOSTTY_RESOURCES_DIR"/shell-integration/zsh/ghostty-integration
  ghostty-integration
  unfunction ghostty-integration
fi
