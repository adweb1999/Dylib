#include <imgui/imgui.h>
#include <imgui/imgui_impl_metal.h>
#include <imgui/imgui_impl_osx.h>
#include <Metal/Metal.h>
#include <MetalKit/MetalKit.h>
#include <UIKit/UIKit.h>
#include <Foundation/Foundation.h>
#include <objc/runtime.h>
#include <string>
#include <vector>
#include <chrono>
#include <cmath>

#define MENU_TITLE "OneState Mod Menu"
#define MENU_VERSION "v2.0"
#define AUTHOR "YourName"

bool g_MenuOpen = true;
bool g_LoggedIn = false;
bool g_ShowLogin = true;

// ========== ESP ==========
bool g_ESP_Enabled = false;
bool g_ESP_Box = false;
bool g_ESP_Skeleton = false;
bool g_ESP_Name = false;
bool g_ESP_Distance = false;
bool g_ESP_Health = false;
bool g_ESP_Team = false;
bool g_ESP_Lines = false;

// ========== AIMBOT ==========
bool g_Aimbot_Enabled = false;
bool g_Aimbot_Silent = false;
bool g_Aimbot_Lock = false;
bool g_Aimbot_FOV = false;
float g_Aimbot_FOV_Radius = 150.0f;
float g_Aimbot_Smooth = 0.5f;
int g_Aimbot_Bone = 0;

// ========== PLAYER ==========
bool g_SpeedHack = false;
float g_SpeedMultiplier = 2.0f;
bool g_GodMode = false;
bool g_InfiniteAmmo = false;
bool g_NoRecoil = false;
bool g_NoSpread = false;
bool g_RapidFire = false;
bool g_WallHack = false;
bool g_FlyMode = false;
bool g_Teleport = false;

// ========== VEHICLE ==========
bool g_Vehicle_Speed = false;
float g_Vehicle_SpeedMultiplier = 3.0f;
bool g_Vehicle_GodMode = false;
bool g_Vehicle_Fly = false;
bool g_Vehicle_InstantStop = false;
bool g_Vehicle_DriftMode = false;

// ========== MISC ==========
bool g_NoClip = false;
bool g_AntiBan = false;
bool g_RemoveAds = false;
bool g_UnlockAll = false;
bool g_FreeShopping = false;
bool g_XP_Multiplier = false;
float g_XP_MultiplierValue = 10.0f;

int g_SelectedTab = 0;
float g_MenuAlpha = 0.95f;
bool g_ShowWatermark = true;
bool g_RainbowMode = false;

char g_Username[64] = "";
char g_Password[64] = "";

ImVec4 g_Color_Primary = ImVec4(0.0f, 0.6f, 1.0f, 1.0f);
ImVec4 g_Color_Secondary = ImVec4(1.0f, 0.2f, 0.2f, 1.0f);
ImVec4 g_Color_Success = ImVec4(0.2f, 1.0f, 0.4f, 1.0f);
ImVec4 g_Color_Warning = ImVec4(1.0f, 0.8f, 0.0f, 1.0f);

id<MTLDevice> g_Device = nil;
id<MTLCommandQueue> g_CommandQueue = nil;
CAMetalLayer* g_MetalLayer = nil;

float g_RainbowHue = 0.0f;

void UpdateRainbow() {
    if (g_RainbowMode) {
        g_RainbowHue += 0.01f;
        if (g_RainbowHue > 1.0f) g_RainbowHue = 0.0f;
        float r = fabsf(sinf(g_RainbowHue * 6.283f));
        float g = fabsf(sinf((g_RainbowHue + 0.33f) * 6.283f));
        float b = fabsf(sinf((g_RainbowHue + 0.66f) * 6.283f));
        g_Color_Primary = ImVec4(r, g, b, 1.0f);
    }
}

void SetupImGuiStyle() {
    ImGuiStyle& style = ImGui::GetStyle();
    ImVec4* colors = style.Colors;

    colors[ImGuiCol_Text] = ImVec4(0.95f, 0.95f, 0.95f, 1.0f);
    colors[ImGuiCol_TextDisabled] = ImVec4(0.5f, 0.5f, 0.5f, 1.0f);
    colors[ImGuiCol_WindowBg] = ImVec4(0.06f, 0.06f, 0.1f, g_MenuAlpha);
    colors[ImGuiCol_ChildBg] = ImVec4(0.08f, 0.08f, 0.12f, 0.9f);
    colors[ImGuiCol_PopupBg] = ImVec4(0.08f, 0.08f, 0.12f, 0.95f);
    colors[ImGuiCol_Border] = ImVec4(0.0f, 0.4f, 0.8f, 0.5f);
    colors[ImGuiCol_BorderShadow] = ImVec4(0.0f, 0.0f, 0.0f, 0.0f);
    colors[ImGuiCol_FrameBg] = ImVec4(0.12f, 0.12f, 0.18f, 1.0f);
    colors[ImGuiCol_FrameBgHovered] = ImVec4(0.15f, 0.15f, 0.25f, 1.0f);
    colors[ImGuiCol_FrameBgActive] = ImVec4(0.2f, 0.2f, 0.35f, 1.0f);
    colors[ImGuiCol_TitleBg] = ImVec4(0.0f, 0.3f, 0.6f, 1.0f);
    colors[ImGuiCol_TitleBgActive] = ImVec4(0.0f, 0.5f, 1.0f, 1.0f);
    colors[ImGuiCol_TitleBgCollapsed] = ImVec4(0.0f, 0.2f, 0.4f, 0.75f);
    colors[ImGuiCol_MenuBarBg] = ImVec4(0.08f, 0.08f, 0.12f, 1.0f);
    colors[ImGuiCol_ScrollbarBg] = ImVec4(0.05f, 0.05f, 0.08f, 1.0f);
    colors[ImGuiCol_ScrollbarGrab] = ImVec4(0.0f, 0.4f, 0.8f, 1.0f);
    colors[ImGuiCol_ScrollbarGrabHovered] = ImVec4(0.0f, 0.5f, 1.0f, 1.0f);
    colors[ImGuiCol_ScrollbarGrabActive] = ImVec4(0.0f, 0.6f, 1.0f, 1.0f);
    colors[ImGuiCol_CheckMark] = ImVec4(0.0f, 0.6f, 1.0f, 1.0f);
    colors[ImGuiCol_SliderGrab] = ImVec4(0.0f, 0.5f, 1.0f, 1.0f);
    colors[ImGuiCol_SliderGrabActive] = ImVec4(0.0f, 0.7f, 1.0f, 1.0f);
    colors[ImGuiCol_Button] = ImVec4(0.0f, 0.4f, 0.8f, 1.0f);
    colors[ImGuiCol_ButtonHovered] = ImVec4(0.0f, 0.5f, 1.0f, 1.0f);
    colors[ImGuiCol_ButtonActive] = ImVec4(0.0f, 0.6f, 1.0f, 1.0f);
    colors[ImGuiCol_Header] = ImVec4(0.0f, 0.3f, 0.6f, 0.5f);
    colors[ImGuiCol_HeaderHovered] = ImVec4(0.0f, 0.4f, 0.8f, 0.7f);
    colors[ImGuiCol_HeaderActive] = ImVec4(0.0f, 0.5f, 1.0f, 0.9f);
    colors[ImGuiCol_Separator] = ImVec4(0.0f, 0.4f, 0.8f, 0.5f);
    colors[ImGuiCol_SeparatorHovered] = ImVec4(0.0f, 0.5f, 1.0f, 0.7f);
    colors[ImGuiCol_SeparatorActive] = ImVec4(0.0f, 0.6f, 1.0f, 1.0f);
    colors[ImGuiCol_ResizeGrip] = ImVec4(0.0f, 0.5f, 1.0f, 0.5f);
    colors[ImGuiCol_ResizeGripHovered] = ImVec4(0.0f, 0.6f, 1.0f, 0.7f);
    colors[ImGuiCol_ResizeGripActive] = ImVec4(0.0f, 0.7f, 1.0f, 1.0f);
    colors[ImGuiCol_Tab] = ImVec4(0.0f, 0.3f, 0.6f, 0.7f);
    colors[ImGuiCol_TabHovered] = ImVec4(0.0f, 0.5f, 1.0f, 0.9f);
    colors[ImGuiCol_TabActive] = ImVec4(0.0f, 0.6f, 1.0f, 1.0f);
    colors[ImGuiCol_TabUnfocused] = ImVec4(0.1f, 0.1f, 0.2f, 0.7f);
    colors[ImGuiCol_TabUnfocusedActive] = ImVec4(0.0f, 0.3f, 0.6f, 0.8f);
    colors[ImGuiCol_PlotLines] = ImVec4(0.0f, 0.5f, 1.0f, 1.0f);
    colors[ImGuiCol_PlotLinesHovered] = ImVec4(0.0f, 0.7f, 1.0f, 1.0f);
    colors[ImGuiCol_PlotHistogram] = ImVec4(0.0f, 0.6f, 1.0f, 0.7f);
    colors[ImGuiCol_PlotHistogramHovered] = ImVec4(0.0f, 0.8f, 1.0f, 1.0f);
    colors[ImGuiCol_TextSelectedBg] = ImVec4(0.0f, 0.5f, 1.0f, 0.5f);
    colors[ImGuiCol_DragDropTarget] = ImVec4(0.0f, 0.6f, 1.0f, 1.0f);
    colors[ImGuiCol_NavHighlight] = ImVec4(0.0f, 0.5f, 1.0f, 1.0f);
    colors[ImGuiCol_NavWindowingHighlight] = ImVec4(0.0f, 0.6f, 1.0f, 0.8f);
    colors[ImGuiCol_NavWindowingDimBg] = ImVec4(0.0f, 0.0f, 0.0f, 0.5f);
    colors[ImGuiCol_ModalWindowDimBg] = ImVec4(0.0f, 0.0f, 0.0f, 0.7f);

    style.WindowPadding = ImVec2(12, 12);
    style.FramePadding = ImVec2(8, 6);
    style.ItemSpacing = ImVec2(8, 6);
    style.ItemInnerSpacing = ImVec2(6, 4);
    style.TouchExtraPadding = ImVec2(0, 0);
    style.IndentSpacing = 20.0f;
    style.ScrollbarSize = 14.0f;
    style.GrabMinSize = 10.0f;
    style.WindowBorderSize = 1.5f;
    style.ChildBorderSize = 1.0f;
    style.PopupBorderSize = 1.0f;
    style.FrameBorderSize = 0.0f;
    style.TabBorderSize = 1.0f;
    style.WindowRounding = 8.0f;
    style.ChildRounding = 6.0f;
    style.FrameRounding = 6.0f;
    style.PopupRounding = 6.0f;
    style.ScrollbarRounding = 8.0f;
    style.GrabRounding = 6.0f;
    style.LogSliderDeadzone = 4.0f;
    style.TabRounding = 6.0f;
    style.AntiAliasedLines = true;
    style.AntiAliasedFill = true;
}

bool ValidateLocalLogin(const char* username, const char* password) {
    const char* validUser = "admin";
    const char* validPass = "123456";
    return (strcmp(username, validUser) == 0 && strcmp(password, validPass) == 0);
}

void RenderLoginScreen() {
    ImGuiIO& io = ImGui::GetIO();
    ImGui::SetNextWindowSize(ImVec2(420, 400), ImGuiCond_FirstUseEver);
    ImGui::SetNextWindowPos(ImVec2(io.DisplaySize.x / 2 - 210, io.DisplaySize.y / 2 - 200), ImGuiCond_FirstUseEver);

    ImGui::Begin("OneState Login", nullptr, 
        ImGuiWindowFlags_NoCollapse | 
        ImGuiWindowFlags_NoResize | 
        ImGuiWindowFlags_NoMove |
        ImGuiWindowFlags_NoScrollbar);

    ImGui::Dummy(ImVec2(0, 25));
    ImGui::PushFont(ImGui::GetFont());
    ImGui::SetWindowFontScale(1.8f);
    ImVec2 textSize = ImGui::CalcTextSize("OneState Mod Menu");
    ImGui::SetCursorPosX((ImGui::GetWindowWidth() - textSize.x * 1.8f) / 2);
    ImGui::TextColored(g_Color_Primary, "OneState Mod Menu");
    ImGui::SetWindowFontScale(1.0f);
    ImGui::PopFont();

    ImGui::SetCursorPosX((ImGui::GetWindowWidth() - ImGui::CalcTextSize("Premium Edition").x) / 2);
    ImGui::TextColored(ImVec4(0.5f, 0.5f, 0.5f, 1.0f), "Premium Edition");
    ImGui::Dummy(ImVec2(0, 25));

    ImGui::PushStyleColor(ImGuiCol_Separator, g_Color_Primary);
    ImGui::Separator();
    ImGui::PopStyleColor();
    ImGui::Dummy(ImVec2(0, 20));

    ImGui::TextColored(g_Color_Primary, "Username:");
    ImGui::PushStyleColor(ImGuiCol_FrameBg, ImVec4(0.1f, 0.1f, 0.15f, 1.0f));
    ImGui::PushStyleColor(ImGuiCol_FrameBgHovered, ImVec4(0.15f, 0.15f, 0.2f, 1.0f));
    ImGui::PushStyleColor(ImGuiCol_FrameBgActive, ImVec4(0.2f, 0.2f, 0.3f, 1.0f));
    ImGui::InputText("##username", g_Username, sizeof(g_Username));
    ImGui::PopStyleColor(3);
    ImGui::Dummy(ImVec2(0, 12));

    ImGui::TextColored(g_Color_Primary, "Password:");
    ImGui::PushStyleColor(ImGuiCol_FrameBg, ImVec4(0.1f, 0.1f, 0.15f, 1.0f));
    ImGui::PushStyleColor(ImGuiCol_FrameBgHovered, ImVec4(0.15f, 0.15f, 0.2f, 1.0f));
    ImGui::PushStyleColor(ImGuiCol_FrameBgActive, ImVec4(0.2f, 0.2f, 0.3f, 1.0f));
    ImGui::InputText("##password", g_Password, sizeof(g_Password), ImGuiInputTextFlags_Password);
    ImGui::PopStyleColor(3);
    ImGui::Dummy(ImVec2(0, 25));

    ImVec2 btnSize = ImVec2(ImGui::GetContentRegionAvail().x, 50);
    ImGui::PushStyleColor(ImGuiCol_Button, g_Color_Primary);
    ImGui::PushStyleColor(ImGuiCol_ButtonHovered, ImVec4(0.0f, 0.7f, 1.0f, 1.0f));
    ImGui::PushStyleColor(ImGuiCol_ButtonActive, ImVec4(0.0f, 0.8f, 1.0f, 1.0f));

    if (ImGui::Button("Login", btnSize)) {
        if (ValidateLocalLogin(g_Username, g_Password)) {
            g_LoggedIn = true;
            g_ShowLogin = false;
        }
    }

    ImGui::PopStyleColor(3);
    ImGui::Dummy(ImVec2(0, 15));

    ImGui::PushStyleColor(ImGuiCol_Button, ImVec4(0.3f, 0.3f, 0.4f, 1.0f));
    ImGui::PushStyleColor(ImGuiCol_ButtonHovered, ImVec4(0.4f, 0.4f, 0.5f, 1.0f));
    if (ImGui::Button("Skip Login (Offline Mode)", ImVec2(ImGui::GetContentRegionAvail().x, 35))) {
        g_LoggedIn = true;
        g_ShowLogin = false;
        strcpy(g_Username, "Guest");
    }
    ImGui::PopStyleColor(2);

    ImGui::Dummy(ImVec2(0, 10));
    ImGui::SetCursorPosX((ImGui::GetWindowWidth() - ImGui::CalcTextSize("Default: admin / 123456").x) / 2);
    ImGui::TextColored(ImVec4(0.3f, 0.3f, 0.3f, 1.0f), "Default: admin / 123456");

    ImGui::End();
}

void CustomToggle(const char* label, bool* value, ImVec4 activeColor = g_Color_Primary) {
    ImGui::PushStyleColor(ImGuiCol_FrameBg, ImVec4(0.2f, 0.2f, 0.3f, 1.0f));
    ImGui::PushStyleColor(ImGuiCol_FrameBgHovered, ImVec4(0.25f, 0.25f, 0.35f, 1.0f));
    ImGui::PushStyleColor(ImGuiCol_FrameBgActive, activeColor);
    ImGui::PushStyleColor(ImGuiCol_CheckMark, activeColor);
    ImGui::Checkbox(label, value);
    ImGui::PopStyleColor(4);
}

void CustomSlider(const char* label, float* value, float min, float max, const char* format = "%.2f") {
    ImGui::PushStyleColor(ImGuiCol_SliderGrab, g_Color_Primary);
    ImGui::PushStyleColor(ImGuiCol_SliderGrabActive, ImVec4(0.0f, 0.7f, 1.0f, 1.0f));
    ImGui::SliderFloat(label, value, min, max, format);
    ImGui::PopStyleColor(2);
}

void RenderESPTab() {
    ImGui::TextColored(g_Color_Primary, "ESP Settings");
    ImGui::PushStyleColor(ImGuiCol_Separator, g_Color_Primary);
    ImGui::Separator();
    ImGui::PopStyleColor();
    ImGui::Dummy(ImVec2(0, 8));

    CustomToggle("Enable ESP", &g_ESP_Enabled);
    if (g_ESP_Enabled) {
        ImGui::Indent(15);
        CustomToggle("Box ESP", &g_ESP_Box, g_Color_Success);
        CustomToggle("Skeleton ESP", &g_ESP_Skeleton, g_Color_Success);
        CustomToggle("Name ESP", &g_ESP_Name, g_Color_Success);
        CustomToggle("Distance ESP", &g_ESP_Distance, g_Color_Success);
        CustomToggle("Health Bar", &g_ESP_Health, g_Color_Success);
        CustomToggle("Team ESP", &g_ESP_Team, g_Color_Success);
        CustomToggle("Snap Lines", &g_ESP_Lines, g_Color_Success);
        ImGui::Unindent(15);
    }

    ImGui::Dummy(ImVec2(0, 15));
    ImGui::TextColored(g_Color_Primary, "ESP Colors");
    ImGui::PushStyleColor(ImGuiCol_Separator, g_Color_Primary);
    ImGui::Separator();
    ImGui::PopStyleColor();
    ImGui::Dummy(ImVec2(0, 8));

    static ImVec4 enemyColor = ImVec4(1.0f, 0.2f, 0.2f, 1.0f);
    static ImVec4 teamColor = ImVec4(0.2f, 0.8f, 1.0f, 1.0f);
    static ImVec4 boxColor = ImVec4(0.0f, 1.0f, 0.0f, 1.0f);

    ImGui::ColorEdit4("Enemy Color", (float*)&enemyColor);
    ImGui::ColorEdit4("Team Color", (float*)&teamColor);
    ImGui::ColorEdit4("Box Color", (float*)&boxColor);
}

void RenderAimbotTab() {
    ImGui::TextColored(g_Color_Primary, "Aimbot Settings");
    ImGui::PushStyleColor(ImGuiCol_Separator, g_Color_Primary);
    ImGui::Separator();
    ImGui::PopStyleColor();
    ImGui::Dummy(ImVec2(0, 8));

    CustomToggle("Enable Aimbot", &g_Aimbot_Enabled);
    if (g_Aimbot_Enabled) {
        ImGui::Indent(15);
        CustomToggle("Silent Aim", &g_Aimbot_Silent, g_Color_Success);
        CustomToggle("Lock Target", &g_Aimbot_Lock, g_Color_Success);
        CustomToggle("Show FOV", &g_Aimbot_FOV, g_Color_Success);

        ImGui::Dummy(ImVec2(0, 8));
        ImGui::Text("Aim Bone:");
        const char* bones[] = {"Head", "Neck", "Body", "Legs"};
        ImGui::Combo("##bone", &g_Aimbot_Bone, bones, IM_ARRAYSIZE(bones));

        ImGui::Dummy(ImVec2(0, 8));
        CustomSlider("FOV Radius", &g_Aimbot_FOV_Radius, 50.0f, 500.0f);
        CustomSlider("Smoothness", &g_Aimbot_Smooth, 0.0f, 1.0f);
        ImGui::Unindent(15);
    }

    ImGui::Dummy(ImVec2(0, 15));
    ImGui::TextColored(g_Color_Primary, "Weapon Settings");
    ImGui::PushStyleColor(ImGuiCol_Separator, g_Color_Primary);
    ImGui::Separator();
    ImGui::PopStyleColor();
    ImGui::Dummy(ImVec2(0, 8));

    CustomToggle("No Recoil", &g_NoRecoil);
    CustomToggle("No Spread", &g_NoSpread);
    CustomToggle("Rapid Fire", &g_RapidFire);
    CustomToggle("Infinite Ammo", &g_InfiniteAmmo);
}

void RenderPlayerTab() {
    ImGui::TextColored(g_Color_Primary, "Player Mods");
    ImGui::PushStyleColor(ImGuiCol_Separator, g_Color_Primary);
    ImGui::Separator();
    ImGui::PopStyleColor();
    ImGui::Dummy(ImVec2(0, 8));

    CustomToggle("God Mode", &g_GodMode);
    CustomToggle("Speed Hack", &g_SpeedHack);
    if (g_SpeedHack) {
        ImGui::Indent(15);
        CustomSlider("Speed Multiplier", &g_SpeedMultiplier, 1.0f, 10.0f);
        ImGui::Unindent(15);
    }

    CustomToggle("Wall Hack", &g_WallHack);
    CustomToggle("Fly Mode", &g_FlyMode);
    CustomToggle("No Clip", &g_NoClip);
    CustomToggle("Teleport", &g_Teleport);

    ImGui::Dummy(ImVec2(0, 15));
    ImGui::TextColored(g_Color_Primary, "XP & Money");
    ImGui::PushStyleColor(ImGuiCol_Separator, g_Color_Primary);
    ImGui::Separator();
    ImGui::PopStyleColor();
    ImGui::Dummy(ImVec2(0, 8));

    CustomToggle("XP Multiplier", &g_XP_Multiplier);
    if (g_XP_Multiplier) {
        ImGui::Indent(15);
        CustomSlider("Multiplier", &g_XP_MultiplierValue, 1.0f, 100.0f, "%.0fx");
        ImGui::Unindent(15);
    }
    CustomToggle("Free Shopping", &g_FreeShopping);
    CustomToggle("Unlock All", &g_UnlockAll);
}

void RenderVehicleTab() {
    ImGui::TextColored(g_Color_Primary, "Vehicle Mods");
    ImGui::PushStyleColor(ImGuiCol_Separator, g_Color_Primary);
    ImGui::Separator();
    ImGui::PopStyleColor();
    ImGui::Dummy(ImVec2(0, 8));

    CustomToggle("Vehicle Speed Hack", &g_Vehicle_Speed);
    if (g_Vehicle_Speed) {
        ImGui::Indent(15);
        CustomSlider("Speed Multiplier", &g_Vehicle_SpeedMultiplier, 1.0f, 10.0f);
        ImGui::Unindent(15);
    }

    CustomToggle("Vehicle God Mode", &g_Vehicle_GodMode);
    CustomToggle("Vehicle Fly", &g_Vehicle_Fly);
    CustomToggle("Instant Stop", &g_Vehicle_InstantStop);
    CustomToggle("Drift Mode", &g_Vehicle_DriftMode);
}

void RenderMiscTab() {
    ImGui::TextColored(g_Color_Primary, "Miscellaneous");
    ImGui::PushStyleColor(ImGuiCol_Separator, g_Color_Primary);
    ImGui::Separator();
    ImGui::PopStyleColor();
    ImGui::Dummy(ImVec2(0, 8));

    CustomToggle("Anti Ban", &g_AntiBan);
    CustomToggle("Remove Ads", &g_RemoveAds);

    ImGui::Dummy(ImVec2(0, 15));
    ImGui::TextColored(g_Color_Primary, "Menu Settings");
    ImGui::PushStyleColor(ImGuiCol_Separator, g_Color_Primary);
    ImGui::Separator();
    ImGui::PopStyleColor();
    ImGui::Dummy(ImVec2(0, 8));

    CustomSlider("Menu Opacity", &g_MenuAlpha, 0.5f, 1.0f);
    CustomToggle("Show Watermark", &g_ShowWatermark);
    CustomToggle("Rainbow Mode", &g_RainbowMode);

    ImGui::Dummy(ImVec2(0, 15));
    ImGui::TextColored(g_Color_Primary, "About");
    ImGui::PushStyleColor(ImGuiCol_Separator, g_Color_Primary);
    ImGui::Separator();
    ImGui::PopStyleColor();
    ImGui::Dummy(ImVec2(0, 5));

    ImGui::Text("Version: %s", MENU_VERSION);
    ImGui::Text("Author: %s", AUTHOR);
    ImGui::Text("Game: OneState");
    ImGui::Text("Mode: Offline (No API)");

    ImGui::Dummy(ImVec2(0, 10));
    if (ImGui::Button("Logout", ImVec2(120, 30))) {
        g_LoggedIn = false;
        g_ShowLogin = true;
        memset(g_Username, 0, sizeof(g_Username));
        memset(g_Password, 0, sizeof(g_Password));
    }
}

void RenderMainMenu() {
    ImGuiIO& io = ImGui::GetIO();

    if (g_ShowWatermark) {
        ImGui::SetNextWindowPos(ImVec2(10, 10), ImGuiCond_Always);
        ImGui::SetNextWindowSize(ImVec2(280, 70), ImGuiCond_Always);
        ImGui::Begin("##Watermark", nullptr, 
            ImGuiWindowFlags_NoTitleBar | 
            ImGuiWindowFlags_NoResize | 
            ImGuiWindowFlags_NoMove | 
            ImGuiWindowFlags_NoScrollbar | 
            ImGuiWindowFlags_NoBackground);

        ImGui::TextColored(g_Color_Primary, "OneState Mod Menu");
        ImGui::TextColored(ImVec4(0.5f, 0.5f, 0.5f, 1.0f), "%s | FPS: %.0f | Offline", MENU_VERSION, io.Framerate);

        ImGui::End();
    }

    ImGui::SetNextWindowSize(ImVec2(520, 620), ImGuiCond_FirstUseEver);
    ImGui::SetNextWindowPos(ImVec2(io.DisplaySize.x / 2 - 260, io.DisplaySize.y / 2 - 310), ImGuiCond_FirstUseEver);

    ImGui::Begin(MENU_TITLE, &g_MenuOpen, ImGuiWindowFlags_NoCollapse);

    ImGui::TextColored(g_Color_Primary, "Welcome, %s", g_Username);
    ImGui::SameLine();
    ImGui::TextColored(g_Color_Warning, "[Offline]");
    ImGui::PushStyleColor(ImGuiCol_Separator, g_Color_Primary);
    ImGui::Separator();
    ImGui::PopStyleColor();
    ImGui::Dummy(ImVec2(0, 8));

    const char* tabs[] = {"ESP", "Aimbot", "Player", "Vehicle", "Misc"};
    ImGui::PushStyleVar(ImGuiStyleVar_FramePadding, ImVec2(18, 10));

    for (int i = 0; i < IM_ARRAYSIZE(tabs); i++) {
        if (i > 0) ImGui::SameLine();

        ImVec4 tabColor = (g_SelectedTab == i) ? g_Color_Primary : ImVec4(0.15f, 0.15f, 0.2f, 1.0f);
        ImGui::PushStyleColor(ImGuiCol_Button, tabColor);

        if (ImGui::Button(tabs[i], ImVec2(90, 38))) {
            g_SelectedTab = i;
        }

        ImGui::PopStyleColor();
    }

    ImGui::PopStyleVar();
    ImGui::Dummy(ImVec2(0, 12));
    ImGui::PushStyleColor(ImGuiCol_Separator, g_Color_Primary);
    ImGui::Separator();
    ImGui::PopStyleColor();
    ImGui::Dummy(ImVec2(0, 8));

    switch (g_SelectedTab) {
        case 0: RenderESPTab(); break;
        case 1: RenderAimbotTab(); break;
        case 2: RenderPlayerTab(); break;
        case 3: RenderVehicleTab(); break;
        case 4: RenderMiscTab(); break;
    }

    ImGui::End();
}

void InitializeImGui() {
    IMGUI_CHECKVERSION();
    ImGui::CreateContext();
    ImGuiIO& io = ImGui::GetIO();

    io.ConfigFlags |= ImGuiConfigFlags_NavEnableKeyboard;
    io.ConfigFlags |= ImGuiConfigFlags_NavEnableGamepad;

    SetupImGuiStyle();

    UIWindow* keyWindow = [[UIApplication sharedApplication] keyWindow];
    UIViewController* rootVC = [keyWindow rootViewController];
    UIView* view = [rootVC view];

    for (CALayer* layer in [view.layer sublayers]) {
        if ([layer isKindOfClass:[CAMetalLayer class]]) {
            g_MetalLayer = (CAMetalLayer*)layer;
            break;
        }
    }

    if (g_MetalLayer) {
        g_Device = MTLCreateSystemDefaultDevice();
        g_CommandQueue = [g_Device newCommandQueue];

        ImGui_ImplMetal_Init(g_Device);
        ImGui_ImplOSX_Init(view);
    }

    NSLog(@"[OneStateMod] ImGui initialized successfully!");
}

void RenderImGui() {
    if (!g_MetalLayer || !g_Device) return;

    ImGuiIO& io = ImGui::GetIO();

    UpdateRainbow();

    ImGui_ImplMetal_NewFrame(g_MetalLayer.currentDrawable);
    ImGui_ImplOSX_NewFrame();
    ImGui::NewFrame();

    if (g_ShowLogin) {
        RenderLoginScreen();
    } else {
        RenderMainMenu();
    }

    ImGui::Render();

    id<MTLCommandBuffer> commandBuffer = [g_CommandQueue commandBuffer];
    MTLRenderPassDescriptor* renderPassDescriptor = [[MTLRenderPassDescriptor alloc] init];
    renderPassDescriptor.colorAttachments[0].texture = g_MetalLayer.currentDrawable.texture;
    renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionLoad;
    renderPassDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
    renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 0);

    id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
    ImGui_ImplMetal_RenderDrawData(ImGui::GetDrawData(), commandBuffer, renderEncoder);
    [renderEncoder endEncoding];
    [commandBuffer presentDrawable:g_MetalLayer.currentDrawable];
    [commandBuffer commit];
}

void ShutdownImGui() {
    ImGui_ImplMetal_Shutdown();
    ImGui_ImplOSX_Shutdown();
    ImGui::DestroyContext();
}
