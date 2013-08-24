//
//  CPPassoneConfig.h
//  Passone
//
//  Created by wangsw on 8/24/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#ifndef Passone_CPPassoneConfig_h
#define Passone_CPPassoneConfig_h

#define CONFIG_RELATED_TO_DEVICE(phone, pad) (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? phone : pad)

#define MEMO_CELL_HEIGHT 66.0
#define PASS_GRID_ROW_COUNT 3
#define PASS_GRID_COLUMN_COUNT 3
#define NOTIFICATION_MAX_COUNT 3
#define NOTIFICATION_STAY_TIME 2.0 // TODO: Determine how long a notification should stay on the screen.

#define BOX_SEPARATOR_SIZE CONFIG_RELATED_TO_DEVICE(8.0, 12.0)
#define BAR_HEIGHT CONFIG_RELATED_TO_DEVICE(36.0, 44.0)
#define MAIN_PASSWORD_POINT_SIZE CONFIG_RELATED_TO_DEVICE(50.0, 100.0)

#endif