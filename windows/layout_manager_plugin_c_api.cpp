#include "include/layout_manager/layout_manager_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "layout_manager_plugin.h"

void LayoutManagerPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  layout_manager::LayoutManagerPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
