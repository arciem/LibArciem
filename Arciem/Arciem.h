//
//  Arciem.h
//  Arciem
//
//  Created by Robert McNally on 2/12/13.
//  Copyright (c) 2013 Arciem LLC. All rights reserved.
//

// CPP
#include "gl_utils.hpp"
#include "murmur_hash_3.hpp"
#include "stringstreams.hpp"

// essentials
#include "config.hpp"
#include "random.hpp"
#include "time_utils.hpp"
#include "xtime.hpp"

// geometry
#include "align.hpp"
#include "arc2.hpp"
#include "area.hpp"
#include "areai.hpp"
#include "bezier2_list.hpp"
#include "bezier2.hpp"
#include "delta2.hpp"
#include "delta2i.hpp"
#include "delta3.hpp"
#include "geometry.hpp"
#include "line2.hpp"
#include "orientation.hpp"
#include "point2_list.hpp"
#include "point2.hpp"
#include "point2i.hpp"
#include "point3.hpp"
#include "volume.hpp"
#include "wedge2.hpp"

#ifdef __OBJC__

#import <UIKit/UIKit.h>

@interface Arciem : NSObject

+ (NSBundle*)frameworkBundle;

@end

// ObjC
#import "ArciemGeom.h"
#import "CMatrix.h"
#import "CMutableArray.h"
#import "CQuantity.h"
#import "CSlowCall.h"
#import "NSIndexPathUtils.h"
#import "ISO8601DateFormatter.h"
#import "CWorker.h"
#import "CWorkerManager.h"
#import "URLRequestUtils.h"

// Essentials
#import "CLog.h"
#import "CObserver.h"
#import "CSwitch.h"
#import "DateTimeUtils.h"
#import "ErrorUtils.h"
#import "Geom.h"
#import "I18nUtils.h"
#import "InvocationUtils.h"
#import "JSONUtils.h"
#import "ObjectUtils.h"
#import "PropertyUtils.h"
#import "StringUtils.h"
#import "ThreadUtils.h"

// CItem/CForm
#import "CForm.h"

// CTable
#import "CTableItem.h"

// iOS
#import "CBeveledBackgroundView.h"
#import "CNetworkActivity.h"
#import "CStatusBar.h"
#import "CNetworkController.h"
#import "CRestWorker.h"
#import "CReachability.h"
#import "CTabBar.h"
#import "UILabelUtils.h"
#import "WhiteLabel.h"
#import "CSystemSound.h"
#import "CMiniPickerView.h"
#import "CSidebarContainerViewController.h"
#import "CKeychainUtils.h"
#import "CNotifier.h"
#import "CNotifierItem.h"
#import "CNotifierBar.h"
#import "CNotifierItemView.h"
#import "CNotifierViewController.h"
#import "CDisclosureIndicator.h"
#import "CBadgeView.h"

// MapKit
#import "CDebugAnnotation.h"
#import "CDebugAnnotationView.h"
#import "CUserTrackingBarButtonItem.h"
#import "MapKitUtils.h"

// Essentials
#import "CShieldView.h"
#import "CActivityShieldView.h"
#import "CAlertManager.h"
#import "CActionSheetManager.h"
#import "CGradientView.h"
#import "CGUtils.h"
#import "CImageView.h"
#import "CNavigationBar.h"
#import "CNavigationController.h"
#import "CTapToDismissKeyboardManager.h"
#import "CView.h"
#import "CViewController.h"
#import "CWindow.h"
#import "AppUtils.h"
#import "DeviceUtils.h"
#import "NibUtils.h"
#import "TextUtils.h"
#import "UIColorUtils.h"
#import "UIImageUtils.h"
#import "UIViewUtils.h"
#import "UIViewControllerUtils.h"
#import "CTextFieldTableViewCell.h"
#import "CButton.h"

// CTableManager
#import "CTableManager.h"

// Dev
#import "CDebugOverlayView.h"
#import "CDebugMenuView.h"
#import "CWorkerDebugView.h"
#import "CWorkerManagerDebugView.h"

    // CSetup
#import "CSetup.h"

#endif // __OBJC__