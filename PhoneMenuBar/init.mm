//
//  init.m
//  PhoneMenuBar
//
//  Created by Jinwoo Kim on 6/15/25.
//

#import <UIKit/UIKit.h>
#include <objc/runtime.h>
#include <objc/message.h>

namespace pmb_SBEmbeddedDisplayWindowSceneDelegate {

namespace completeStartupAfterAllEmbeddedScenesConnect {
void (*original)(id self, SEL _cmd);
void custom(id self, SEL _cmd) {
    original(self, _cmd);
    
    id _sbWindowSceneContext = reinterpret_cast<id (*)(id, SEL)>(objc_msgSend)(self, sel_registerName("_sbWindowSceneContext"));
    id switcherController = reinterpret_cast<id (*)(id, SEL)>(objc_msgSend)(_sbWindowSceneContext, sel_registerName("switcherController"));
    id menuBarManager = reinterpret_cast<id (*)(id, SEL)>(objc_msgSend)(_sbWindowSceneContext, sel_registerName("menuBarManager"));
    
    reinterpret_cast<void (*)(id, SEL, id)>(objc_msgSend)(menuBarManager, sel_registerName("setMenuBarSceneProvider:"), switcherController);
}
void swizzle() {
    Method method = class_getInstanceMethod(objc_lookUpClass("SBEmbeddedDisplayWindowSceneDelegate"), sel_registerName("completeStartupAfterAllEmbeddedScenesConnect"));
    assert(method != NULL);
    original = reinterpret_cast<decltype(original)>(method_getImplementation(method));
    method_setImplementation(method, reinterpret_cast<IMP>(custom));
}
}

}


namespace pmb_SBFullScreenFluidSwitcherRootSwitcherModifier {

namespace wantsMenuBar {
BOOL custom(id self, SEL _cmd) {
    return YES;
}
void addMethod() {
    assert(class_addMethod(objc_lookUpClass("SBFullScreenFluidSwitcherRootSwitcherModifier"), sel_registerName("wantsMenuBar"), reinterpret_cast<IMP>(custom), NULL));
}
}

}


namespace pmb_SBMenuBarViewController {

namespace _loadAllMainMenusWithCompletion_ {
void (*original)(__kindof UIViewController *self, SEL _cmd, void (^completion)(BOOL success));
void custom(__kindof UIViewController *self, SEL _cmd, void (^completion)(BOOL success)) {
    original(self, _cmd, ^(BOOL success) {
        completion(success);
        
        UIWindowScene *windowScene = self.parentViewController.view.window.windowScene;
        assert(windowScene != nil);
        
        [self willMoveToParentViewController:nil];
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
        
        __kindof UIWindow *window = [[objc_lookUpClass("SBFTouchPassThroughWindow") alloc] initWithWindowScene:windowScene];
        
        __kindof UIViewController *viewController = [objc_lookUpClass("SBFTouchPassThroughViewController") new];
        [viewController addChildViewController:self];
        [viewController.view addSubview:self.view];
        self.view.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            [viewController.view.safeAreaLayoutGuide.topAnchor constraintEqualToAnchor:self.view.topAnchor],
            [viewController.view.safeAreaLayoutGuide.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
            [viewController.view.safeAreaLayoutGuide.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        ]];
        [self didMoveToParentViewController:viewController];
        
        window.windowLevel = UIWindowLevelAlert;
        window.rootViewController = viewController;
        [viewController release];
        
        [window makeKeyAndVisible];
        
        __kindof UIView *menuBarView = reinterpret_cast<id (*)(id, SEL)>(objc_msgSend)(self, sel_registerName("menuBarView"));
        __kindof UIView *menuHeaderContainerView = reinterpret_cast<id (*)(id, SEL)>(objc_msgSend)(self, sel_registerName("menuHeaderContainerView"));
        
        [menuBarView.constraints enumerateObjectsUsingBlock:^(__kindof NSLayoutConstraint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.firstAttribute == NSLayoutAttributeHeight) {
                obj.constant = 30;
            }
        }];
        [menuHeaderContainerView.constraints enumerateObjectsUsingBlock:^(__kindof NSLayoutConstraint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.firstAttribute == NSLayoutAttributeHeight) {
                obj.constant = 30;
            }
        }];
        [menuHeaderContainerView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj.constraints enumerateObjectsUsingBlock:^(__kindof NSLayoutConstraint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.firstAttribute == NSLayoutAttributeHeight) {
                    obj.constant = 30;
                }
            }];
        }];
        
        // TODO: [window release]
    });
}
void swizzle() {
    Method method = class_getInstanceMethod(objc_lookUpClass("SBMenuBarViewController"), sel_registerName("_loadAllMainMenusWithCompletion:"));
    assert(method != NULL);
    original = reinterpret_cast<decltype(original)>(method_getImplementation(method));
    method_setImplementation(method, reinterpret_cast<IMP>(custom));
}
}

}

__attribute__((constructor)) static void init() {
#if DEBUG
    if (static_cast<NSNumber *>(NSProcessInfo.processInfo.environment[@"PMB_WAIT_FOR_DEBUGGER"]).boolValue) {
        kill(getpid(), SIGSTOP);
    }
#endif
    
    pmb_SBEmbeddedDisplayWindowSceneDelegate::completeStartupAfterAllEmbeddedScenesConnect::swizzle();
    pmb_SBFullScreenFluidSwitcherRootSwitcherModifier::wantsMenuBar::addMethod();
    pmb_SBMenuBarViewController::_loadAllMainMenusWithCompletion_::swizzle();
}
