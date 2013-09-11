//
//  CPLocorConfig.h
//  Locor
//
//  Created by wangsw on 8/24/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#ifndef CPLOCORCONFIG_h
#define CPLOCORCONFIG_h

#define CONFIG_RELATED_TO_DEVICE(phone, pad) (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? phone : pad)

#define COPY_PASSWORD_TAP_NUMBER                       2
#define EDITING_TAP_NUMBER                             1
#define ICON_PICKER_ANIMATION_FRAME_PER_SECOND         50
#define ICON_PICKER_ANIMATION_SPEED_MULTIPLIER         5.0
#define ICON_PICKER_ITEM_COUNT                         12
#define ICON_PICKER_ITEM_POSITION_EXPONENT             1.0
#define MEMO_CELL_HEIGHT                               66.0
#define MEMO_CELL_REMOVING_LABEL_DISTANCE_TO_CELL_EDGE 5.0
#define NOTIFICATION_STAY_TIME                         2.0
#define PASS_CELL_REMOVING_LABEL_DISTANCE_TO_CELL_EDGE 5.0
#define PASS_GRID_COLUMN_COUNT                         3
#define PASS_GRID_ROW_COUNT                            3
#define WATER_MARK_ALPHA                               0.7

#define BAR_HEIGHT                           CONFIG_RELATED_TO_DEVICE(36.0, 44.0)
#define BOX_SEPARATOR_SIZE                   CONFIG_RELATED_TO_DEVICE(8.0,  12.0)
#define ICON_PICKER_ITEM_ALPHA_EXPONENT      CONFIG_RELATED_TO_DEVICE(1.3, 2.0)
#define ICON_PICKER_ITEM_MAX_SIZE            CONFIG_RELATED_TO_DEVICE(50.0, 100.0)
#define ICON_PICKER_ITEM_POSITION_MULTIPLIER CONFIG_RELATED_TO_DEVICE(1.2, 1.3)
#define ICON_PICKER_ITEM_SIZE_EXPONENT       CONFIG_RELATED_TO_DEVICE(1.4, 1.1)
#define MAIN_PASSWORD_LINE_WIDTH             CONFIG_RELATED_TO_DEVICE(10.0, 20.0)
#define MAIN_PASSWORD_POINT_SIZE             CONFIG_RELATED_TO_DEVICE(50.0, 100.0)
#define NOTIFICATION_FONT_SIZE               CONFIG_RELATED_TO_DEVICE(15.0, 30.0)
#define PASS_EDIT_VIEW_BORDER_WIDTH          CONFIG_RELATED_TO_DEVICE(8.0,  12.0)
#define PASS_EDIT_VIEW_CELL_SIZE             CONFIG_RELATED_TO_DEVICE(75.0, 150.0)
#define PASS_GRID_HORIZONTAL_INDENT          CONFIG_RELATED_TO_DEVICE(23.0, 0.0)

#endif
