after_install install_hook_scripts

install_hook_scripts() {
  # only install hooks after successfull node installation
  [ "$STATUS" = 0 ] || return

  nodenv-package-hooks install "$VERSION_NAME"
  echo "Installed postinstall/postuninstall package hooks for $VERSION_NAME"
}
