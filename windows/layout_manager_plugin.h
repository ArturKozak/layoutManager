#ifndef FLUTTER_PLUGIN_LAYOUT_MANAGER_PLUGIN_H_
#define FLUTTER_PLUGIN_LAYOUT_MANAGER_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace layout_manager {

class LayoutManagerPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  LayoutManagerPlugin();

  virtual ~LayoutManagerPlugin();

  // Disallow copy and assign.
  LayoutManagerPlugin(const LayoutManagerPlugin&) = delete;
  LayoutManagerPlugin& operator=(const LayoutManagerPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace layout_manager

#endif  // FLUTTER_PLUGIN_LAYOUT_MANAGER_PLUGIN_H_
