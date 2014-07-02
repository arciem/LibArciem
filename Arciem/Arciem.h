//
//  Arciem.h
//  Arciem
//
//  Created by Robert McNally on 2/12/13.
//  Copyright (c) 2013 Arciem LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

// C
//#include "murmur_hash_3.h"

// essentials
#include "config.h"
#include "random.h"
#include "time_utils.h"
#include "xtime.h"
#include "math_utils.h"
#include "geometry.h"

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
#import "CFixedDate.h"
#import "XMLUtils.h"

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
#import "CUseCounter.h"
#import "CSerializer.h"

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
#import "CTextureAtlas.h"
#import "CColorHSB.h"

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
#import "CTextFieldTableViewCell1.h"
#import "CTextFieldTableViewCell2.h"
#import "CButton.h"
#import "CSwitchTableViewCell.h"
#import "DispatchUtils.h"

// CTable
#import "CTableManager.h"
#import "CTableView.h"
#import "CTableViewCell.h"
#import "CTextFieldItemTableViewCell.h"
#import "CSwitchItemTableViewCell.h"

// Dev
#import "CDebugOverlayView.h"
#import "CDebugMenuView.h"
#import "CWorkerDebugView.h"
#import "CWorkerManagerDebugView.h"

    // CSetup
#import "CSetup.h"
