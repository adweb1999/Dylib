#include <substrate.h>
#include <Foundation/Foundation.h>
#include <UIKit/UIKit.h>
#include <objc/runtime.h>

extern bool g_ESP_Enabled;
extern bool g_Aimbot_Enabled;
extern bool g_SpeedHack;
extern float g_SpeedMultiplier;
extern bool g_GodMode;
extern bool g_InfiniteAmmo;
extern bool g_NoRecoil;
extern bool g_NoSpread;
extern bool g_RapidFire;
extern bool g_WallHack;
extern bool g_FlyMode;
extern bool g_Vehicle_Speed;
extern float g_Vehicle_SpeedMultiplier;
extern bool g_Vehicle_GodMode;
extern bool g_AntiBan;
extern bool g_RemoveAds;
extern bool g_FreeShopping;
extern bool g_XP_Multiplier;
extern float g_XP_MultiplierValue;

%hook PlayerController
- (void)updateMovement:(float)deltaTime {
    if (g_SpeedHack) {
        deltaTime *= g_SpeedMultiplier;
    }
    %orig(deltaTime);
}
- (float)getMaxSpeed {
    float speed = %orig;
    if (g_SpeedHack) {
        speed *= g_SpeedMultiplier;
    }
    return speed;
}
- (bool)isGodMode {
    if (g_GodMode) return true;
    return %orig;
}
- (void)takeDamage:(float)damage {
    if (g_GodMode) return;
    %orig(damage);
}
%end

%hook WeaponController
- (void)fireWeapon {
    if (g_RapidFire) {
        %orig;
        %orig;
        %orig;
    } else {
        %orig;
    }
}
- (float)getRecoil {
    if (g_NoRecoil) return 0.0f;
    return %orig;
}
- (float)getSpread {
    if (g_NoSpread) return 0.0f;
    return %orig;
}
- (int)getAmmoCount {
    if (g_InfiniteAmmo) return 999;
    return %orig;
}
- (void)consumeAmmo:(int)amount {
    if (g_InfiniteAmmo) return;
    %orig(amount);
}
%end

%hook VehicleController
- (float)getMaxSpeed {
    float speed = %orig;
    if (g_Vehicle_Speed) {
        speed *= g_Vehicle_SpeedMultiplier;
    }
    return speed;
}
- (void)updateVehiclePhysics:(float)deltaTime {
    if (g_Vehicle_Speed) {
        deltaTime *= g_Vehicle_SpeedMultiplier;
    }
    %orig(deltaTime);
}
- (bool)isVehicleGodMode {
    if (g_Vehicle_GodMode) return true;
    return %orig;
}
- (void)takeVehicleDamage:(float)damage {
    if (g_Vehicle_GodMode) return;
    %orig(damage);
}
%end

%hook AntiCheatManager
- (void)checkForCheats {
    if (g_AntiBan) return;
    %orig;
}
- (void)reportSuspiciousActivity:(NSString*)activity {
    if (g_AntiBan) return;
    %orig(activity);
}
- (void)sendBanReport {
    if (g_AntiBan) return;
    %orig;
}
%end

%hook AdManager
- (void)showBannerAd {
    if (g_RemoveAds) return;
    %orig;
}
- (void)showInterstitialAd {
    if (g_RemoveAds) return;
    %orig;
}
- (void)showRewardedAd {
    if (g_RemoveAds) return;
    %orig;
}
- (bool)areAdsEnabled {
    if (g_RemoveAds) return false;
    return %orig;
}
%end

%hook ShopManager
- (bool)canPurchaseItem:(NSString*)itemId price:(int)price {
    if (g_FreeShopping) return true;
    return %orig(itemId, price);
}
- (void)deductCurrency:(int)amount {
    if (g_FreeShopping) return;
    %orig(amount);
}
%end

%hook XPManager
- (void)addXP:(int)amount {
    if (g_XP_Multiplier) {
        amount *= (int)g_XP_MultiplierValue;
    }
    %orig(amount);
}
- (int)getXPMultiplier {
    if (g_XP_Multiplier) return (int)g_XP_MultiplierValue;
    return %orig;
}
%end

%hook NetworkManager
- (void)sendPacket:(NSData*)data {
    if (g_AntiBan) {
        NSMutableData* modifiedData = [data mutableCopy];
        %orig(modifiedData);
    } else {
        %orig(data);
    }
}
%end
