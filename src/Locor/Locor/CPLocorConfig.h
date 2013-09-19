//
//  CPLocorConfig.h
//  Locor
//
//  Created by wangsw on 8/24/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPHelperMacros.h"

#ifndef _CPLOCORCONFIG_h_
#define _CPLOCORCONFIG_h_

#define C(obj) obj                                   // CONSTANT
#define D(phone, pad) DEVICE_RELATED_OBJ(phone, pad) // DEVICE RELATED


#define BAR_HEIGHT                                     D(36.0, 44.0)

#define BOX_SEPARATOR_SIZE                             D(8.0, 12.0)

#define COPY_PASSWORD_TAP_NUMBER                       C(2)
#define EDITING_TAP_NUMBER                             C(1)

#define HELP_BUTTON_VIEW_HEIGHT                        D(60.0, 60.0)
#define HELP_PAGE_CONTROL_HEIGHT                       D(44.0, 44.0)
#define HELP_PAGE_DELAY_TIME                           C(3.0)
#define HELP_START_BUTTON_HEIGHT                       D(44.0, 44.0)
#define HELP_START_BUTTON_WIDTH                        D(200.0, 200.0)
#define HELP_TEXT_HEIGHT                               D(60.0, 60.0)
#define HELP_TITLE_HEIGHT                              D(50.0, 50.0)

#define ICON_PICKER_ANIMATION_FRAME_PER_SECOND         C(50)
#define ICON_PICKER_ANIMATION_SPEED_MULTIPLIER         C(5.0)
#define ICON_PICKER_ITEM_ALPHA_EXPONENT                D(1.3, 2.0)
#define ICON_PICKER_ITEM_COUNT                         C(12)
#define ICON_PICKER_ITEM_MAX_SIZE                      D(50.0, 100.0)
#define ICON_PICKER_ITEM_POSITION_EXPONENT             C(1.0)
#define ICON_PICKER_ITEM_POSITION_MULTIPLIER           D(1.2, 1.3)
#define ICON_PICKER_ITEM_SIZE_EXPONENT                 D(1.4, 1.1)

#define MAIN_PASSWORD_LINE_WIDTH                       D(8.0, 16.0)
#define MAIN_PASSWORD_POINT_ANIMATION_MULTIPLIER       C(1.2)
#define MAIN_PASSWORD_POINT_SIZE                       D(50.0, 100.0)

#define MEMO_CELL_HEIGHT                               C(66.0)
#define MEMO_CELL_REMOVING_LABEL_DISTANCE_TO_CELL_EDGE C(5.0)

#define NOTIFICATION_STAY_TIME                         C(2.0)
#define NOTIFICATION_FONT_SIZE                         D(15.0, 30.0)

#define PASS_CELL_REMOVING_LABEL_DISTANCE_TO_CELL_EDGE C(5.0)

#define PASS_EDIT_VIEW_CELL_SIZE                       D(75.0, 150.0)

#define PASS_GRID_COLUMN_COUNT                         C(3)
#define PASS_GRID_HORIZONTAL_INDENT                    D(23.0, 0.0)
#define PASS_GRID_ROW_COUNT                            C(3)

#define SETTINGS_BUTTON_ANIMATION_BOUNCE_MULTIPLIER    C(2.0)
#define SETTINGS_BUTTON_ANIMATION_TIME_STEP            C(0.1)
#define SETTINGS_BUTTON_COUNT                          C(3)

#define WATER_MARK_ALPHA                               C(0.7)


#endif
