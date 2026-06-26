#include <substrate.h>
#include <Foundation/Foundation.h>
#include <UIKit/UIKit.h>
#include <dlfcn.h>
#include <sys/types.h>
#include <objc/runtime.h>

// Forward declarations
void InitializeImGui();
void RenderImGui();
void ShutdownImGui();

// Constructor - called when dylib is loaded
__attribute__((constructor))
static void OneStateModConstructor() {
    NSLog(@"[OneStateMod] dylib loaded successfully!");
    NSLog(@"[OneStateMod] Waiting for game to initialize...");

    // Hook into UIWindow to initialize ImGui when game starts
    %init;
}

// Hook UIWindow to inject ImGui
%hook UIWindow

- (void)makeKeyAndVisible {
    %orig;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"[OneStateMod] Initializing ImGui...");
        InitializeImGui();
    });
}

%end

// Hook CAMetalLayer for rendering
%hook CAMetalLayer

- (void)presentDrawable:(id)drawable {
    RenderImGui();
    %orig;
}

%end

// Fallback hook for OpenGL games (if Metal not available)
%hook EAGLContext

+ (BOOL)setCurrentContext:(EAGLContext*)context {
    BOOL result = %orig(context);

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"[OneStateMod] OpenGL context detected, initializing...");
        // Initialize for OpenGL if needed
    });

    return result;
}

%end

%ctor {
    NSLog(@"[OneStateMod] Constructor executed");
    NSLog(@"[OneStateMod] Bundle: %@", [[NSBundle mainBundle] bundleIdentifier]);
}
