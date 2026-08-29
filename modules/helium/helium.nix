{ config, pkgs, ... }:

{
  environment.etc."helium/policies/managed/webapp-policies.json".text = builtins.toJSON {
    DeveloperToolsAvailability = 2;
    BackgroundModeEnabled = false;
    BrowserSignin = 0;
    SyncDisabled = true;
    PasswordManagerEnabled = false;
    TranslateEnabled = false;
    DefaultBrowserSettingEnabled = false;
    ExtensionInstallBlocklist = [ "*" ];
  };
}
