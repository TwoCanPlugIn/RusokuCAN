//  SPDX-License-Identifier: BSD-2-Clause OR GPL-3.0-or-later
//
//  CAN Interface API, Version 3 (Testing)
//
//  Copyright (c) 2004-2021 Uwe Vogt, UV Software, Berlin (info@uv-software.com)
//  All rights reserved.
//
//  This file is part of CAN API V3.
//
//  CAN API V3 is dual-licensed under the BSD 2-Clause "Simplified" License and
//  under the GNU General Public License v3.0 (or any later version).
//  You can choose between one of them if you use this file.
//
//  BSD 2-Clause "Simplified" License:
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//  1. Redistributions of source code must retain the above copyright notice, this
//     list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright notice,
//     this list of conditions and the following disclaimer in the documentation
//     and/or other materials provided with the distribution.
//
//  CAN API V3 IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
//  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
//  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
//  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
//  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
//  OF CAN API V3, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  GNU General Public License v3.0 or later:
//  CAN API V3 is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  CAN API V3 is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with CAN API V3.  If not, see <http://www.gnu.org/licenses/>.
//
#import "Settings.h"
#import "can_api.h"
#import <XCTest/XCTest.h>

@interface test_can_init : XCTestCase

@end

@implementation test_can_init

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    (void)can_exit(CANKILL_ALL);
}

// @xctest TC02.1: Initialize interface again when interface already initialzed.
//
// @expected: CANERR_YETINIT
//
- (void)testWhenInterfaceInitialized {
    can_bitrate_t bitrate = { TEST_BTRINDEX };
    can_status_t status = { CANSTAT_RESET };
    int handle = INVALID_HANDLE;
    int rc = CANERR_FATAL;

    // @pre:
    // @- initialize DUT1 with configured settings
    handle = can_init(DUT1, TEST_CANMODE, NULL);
    XCTAssertLessThanOrEqual(0, handle);
    // @- get status of DUT1 and check to be in INIT state
    rc = can_status(handle, &status.byte);
    XCTAssertEqual(CANERR_NOERROR, rc);
    XCTAssertTrue(status.can_stopped);

    // @test:
    // @- try to initialize DUT1 a second time
    rc = can_init(DUT1, TEST_CANMODE, NULL);
    XCTAssertEqual(CANERR_YETINIT, rc);
    // @- get status of DUT1 and check to be in INIT state
    rc = can_status(handle, &status.byte);
    XCTAssertEqual(CANERR_NOERROR, rc);
    XCTAssertTrue(status.can_stopped);

    // @post:
    // @- start DUT1 with configured bit-rate settings
    rc = can_start(handle, &bitrate);
    XCTAssertEqual(CANERR_NOERROR, rc);
    // @- get status of DUT1 and check to be in RUNNING state
    rc = can_status(handle, &status.byte);
    XCTAssertEqual(CANERR_NOERROR, rc);
    XCTAssertFalse(status.can_stopped);
    // @- sunnyday traffic (optional):
#if (OPTION_SEND_TEST_FRAMES != 0)
    CTester tester;
    XCTAssertEqual(TEST_FRAMES, tester.SendSomeFrames(handle, DUT2, TEST_FRAMES));
    XCTAssertEqual(TEST_FRAMES, tester.ReceiveSomeFrames(handle, DUT2, TEST_FRAMES));
    // @- get status of DUT1 and check to be in RUNNING state
    rc = can_status(handle, &status.byte);
    XCTAssertEqual(CANERR_NOERROR, rc);
    XCTAssertFalse(status.can_stopped);
#endif
    // @- stop/reset DUT1
    rc = can_reset(handle);
    XCTAssertEqual(CANERR_NOERROR, rc);
    // @- get status of DUT1 and check to be in INIT state
    rc = can_status(handle, &status.byte);
    XCTAssertEqual(CANERR_NOERROR, rc);
    XCTAssertTrue(status.can_stopped);
    // @- shutdown DUT1
    rc = can_exit(handle);
    XCTAssertEqual(CANERR_NOERROR, rc);
}

// @xctest TC02.2: Initialize interface again when CAN controller already started.
//
// @expected: CANERR_YETINIT
//
- (void)testWhenInterfaceStarted {
    can_bitrate_t bitrate = { TEST_BTRINDEX };
    can_status_t status = { CANSTAT_RESET };
    int handle = INVALID_HANDLE;
    int rc = CANERR_FATAL;

    // @pre:
    // @- initialize DUT1 with configured settings
    handle = can_init(DUT1, TEST_CANMODE, NULL);
    XCTAssertLessThanOrEqual(0, handle);
    // @- get status of DUT1 and check to be in INIT state
    rc = can_status(handle, &status.byte);
    XCTAssertEqual(CANERR_NOERROR, rc);
    XCTAssertTrue(status.can_stopped);
    // @- start DUT1 with configured bit-rate settings
    rc = can_start(handle, &bitrate);
    XCTAssertEqual(CANERR_NOERROR, rc);
    // @- get status of DUT1 and check to be in RUNNING state
    rc = can_status(handle, &status.byte);
    XCTAssertEqual(CANERR_NOERROR, rc);
    XCTAssertFalse(status.can_stopped);

    // @test:
    // @- try to initialize DUT1 a second time
    rc = can_init(DUT1, TEST_CANMODE, NULL);
    XCTAssertEqual(CANERR_YETINIT, rc);
    // @- get status of DUT1 and check to be in RUNNING state
    rc = can_status(handle, &status.byte);
    XCTAssertEqual(CANERR_NOERROR, rc);
    XCTAssertFalse(status.can_stopped);

    // @post:
    // @- sunnyday traffic (optional):
#if (OPTION_SEND_TEST_FRAMES != 0)
    CTester tester;
    XCTAssertEqual(TEST_FRAMES, tester.SendSomeFrames(handle, DUT2, TEST_FRAMES));
    XCTAssertEqual(TEST_FRAMES, tester.ReceiveSomeFrames(handle, DUT2, TEST_FRAMES));
    // @- get status of DUT1 and check to be in RUNNING state
    rc = can_status(handle, &status.byte);
    XCTAssertEqual(CANERR_NOERROR, rc);
    XCTAssertFalse(status.can_stopped);
#endif
    // @- stop/reset DUT1
    rc = can_reset(handle);
    XCTAssertEqual(CANERR_NOERROR, rc);
    // @- get status of DUT1 and check to be in INIT state
    rc = can_status(handle, &status.byte);
    XCTAssertEqual(CANERR_NOERROR, rc);
    XCTAssertTrue(status.can_stopped);
    // @- shutdown DUT1
    rc = can_exit(handle);
    XCTAssertEqual(CANERR_NOERROR, rc);
}

// @xctest TC02.3: Initialize interface again when CAN controller already stopped.
//
// @expected: CANERR_YETINIT
//
- (void)testWhenInterfaceStopped {
    can_bitrate_t bitrate = { TEST_BTRINDEX };
    can_status_t status = { CANSTAT_RESET };
    int handle = INVALID_HANDLE;
    int rc = CANERR_FATAL;

    // @pre:
    // @- initialize DUT1 with configured settings
    handle = can_init(DUT1, TEST_CANMODE, NULL);
    XCTAssertLessThanOrEqual(0, handle);
    // @- get status of DUT1 and check to be in INIT state
    rc = can_status(handle, &status.byte);
    XCTAssertEqual(CANERR_NOERROR, rc);
    XCTAssertTrue(status.can_stopped);
    // @- start DUT1 with configured bit-rate settings
    rc = can_start(handle, &bitrate);
    XCTAssertEqual(CANERR_NOERROR, rc);
    // @- get status of DUT1 and check to be in RUNNING state
    rc = can_status(handle, &status.byte);
    XCTAssertEqual(CANERR_NOERROR, rc);
    XCTAssertFalse(status.can_stopped);
    // @- sunnyday traffic (optional):
#if (OPTION_SEND_TEST_FRAMES != 0)
    CTester tester;
    XCTAssertEqual(TEST_FRAMES, tester.SendSomeFrames(handle, DUT2, TEST_FRAMES));
    XCTAssertEqual(TEST_FRAMES, tester.ReceiveSomeFrames(handle, DUT2, TEST_FRAMES));
    // @- get status of DUT1 and check to be in RUNNING state
    rc = can_status(handle, &status.byte);
    XCTAssertEqual(CANERR_NOERROR, rc);
    XCTAssertFalse(status.can_stopped);
#endif
    // @- stop/reset DUT1
    rc = can_reset(handle);
    XCTAssertEqual(CANERR_NOERROR, rc);
    // @- get status of DUT1 and check to be in INIT state
    rc = can_status(handle, &status.byte);
    XCTAssertEqual(CANERR_NOERROR, rc);
    XCTAssertTrue(status.can_stopped);

    // @test:
    // @- try to initialize DUT1 a second time
    rc = can_init(DUT1, TEST_CANMODE, NULL);
    XCTAssertEqual(CANERR_YETINIT, rc);
    // @- get status of DUT1 and check to be in INIT state
    rc = can_status(handle, &status.byte);
    XCTAssertEqual(CANERR_NOERROR, rc);
    XCTAssertTrue(status.can_stopped);

    // @post: shutdown DUT1
    rc = can_exit(handle);
    XCTAssertEqual(CANERR_NOERROR, rc);
}

// @xctest TC02.4: Initialize interface again when shutdown before.
//
// @expected: CANERR_NOERROR
//
- (void)testWhenInterfaceShutdown {
    can_bitrate_t bitrate = { TEST_BTRINDEX };
    can_status_t status = { CANSTAT_RESET };
    int handle = INVALID_HANDLE;
    int rc = CANERR_FATAL;

    // @pre:
    // @- initialize DUT1 with configured settings
    handle = can_init(DUT1, TEST_CANMODE, NULL);
    XCTAssertLessThanOrEqual(0, handle);
    // @- get status of DUT1 and check to be in INIT state
    rc = can_status(handle, &status.byte);
    XCTAssertEqual(CANERR_NOERROR, rc);
    XCTAssertTrue(status.can_stopped);
    // @- start DUT1 with configured bit-rate settings
    rc = can_start(handle, &bitrate);
    XCTAssertEqual(CANERR_NOERROR, rc);
    // @- get status of DUT1 and check to be in RUNNING state
    rc = can_status(handle, &status.byte);
    XCTAssertEqual(CANERR_NOERROR, rc);
    XCTAssertFalse(status.can_stopped);
    // @- sunnyday traffic (optional):
#if (OPTION_SEND_TEST_FRAMES != 0)
    CTester tester;
    XCTAssertEqual(TEST_FRAMES, tester.SendSomeFrames(handle, DUT2, TEST_FRAMES));
    XCTAssertEqual(TEST_FRAMES, tester.ReceiveSomeFrames(handle, DUT2, TEST_FRAMES));
    // @- get status of DUT1 and check to be in RUNNING state
    rc = can_status(handle, &status.byte);
    XCTAssertEqual(CANERR_NOERROR, rc);
    XCTAssertFalse(status.can_stopped);
#endif
    // @- stop/reset DUT1
    rc = can_reset(handle);
    XCTAssertEqual(CANERR_NOERROR, rc);
    // @- get status of DUT1 and check to be in INIT state
    rc = can_status(handle, &status.byte);
    XCTAssertEqual(CANERR_NOERROR, rc);
    XCTAssertTrue(status.can_stopped);
    // @- shutdown DUT1
    rc = can_exit(handle);
    XCTAssertEqual(CANERR_NOERROR, rc);

    // @test:
    // @- initialize DUT1 a second time
    handle = can_init(DUT1, TEST_CANMODE, NULL);
    XCTAssertLessThanOrEqual(0, handle);
    // @- get status of DUT1 and check to be in INIT state
    rc = can_status(handle, &status.byte);
    XCTAssertEqual(CANERR_NOERROR, rc);
    XCTAssertTrue(status.can_stopped);

    // @post: shutdown DUT1
    rc = can_exit(handle);
    XCTAssertEqual(CANERR_NOERROR, rc);
}

// @xctest TC02.5: Initialize interface with valid channel number(s).
//
// @expected: CANERR_NOERROR
//
- (void)testWithValidChannelNo {
    SInt32 channel = INVALID_HANDLE;
    int handle = INVALID_HANDLE;
    int rc = CANERR_FATAL;

    // @test:
    // @- loop over the list of devices to get the channel no.
    rc = can_property(INVALID_HANDLE, CANPROP_SET_FIRST_CHANNEL, (void*)NULL, 0U);
    XCTAssertEqual(CANERR_NOERROR, rc);
    while (CANERR_NOERROR == rc) {
        rc = can_property(INVALID_HANDLE, CANPROP_GET_CHANNEL_TYPE, (void*)&channel, sizeof(SInt32));
        if (CANERR_NOERROR == rc) {
            // @-- try to initialize found channel with default settings
            handle = can_init(channel, TEST_CANMODE, NULL);
            if (0 <= handle) {
                // @-- on success: shutdown straightaway
                (void)can_exit(handle);
            } else if (CANERR_NOTINIT != handle) {
                // @-- otherwise: error NOTINIT or vendor-specific error
                XCTAssertGreaterThanOrEqual(CANERR_VENDOR, handle);
            }
        }
        rc = can_property(INVALID_HANDLE, CANPROP_SET_NEXT_CHANNEL, (void*)NULL, 0U);
    }
}

// @xctest TC02.6: Initialize interface with invalid channel number(s).
//
// @expected: CANERR_NOTINIT or CANERR_VENDOR
//
- (void)testWithInvalidChannelNo {
    int rc = CANERR_FATAL;

    // @test:
    // @- try to initialize with invalid channel no. -1
    rc = can_init((SInt32)(-1), TEST_CANMODE, NULL);
    XCTAssertNotEqual(CANERR_NOERROR, rc);
    XCTAssert((CANERR_NOTINIT == rc) || (CANERR_VENDOR >= rc));
    // @- try to initialize with invalid channel no. INT8_MIN
    rc = can_init((SInt32)INT8_MIN, TEST_CANMODE, NULL);
    XCTAssertNotEqual(CANERR_NOERROR, rc);
    XCTAssert((CANERR_NOTINIT == rc) || (CANERR_VENDOR >= rc));
    // @- try to initialize with invalid channel no. INT16_MIN
    rc = can_init((SInt32)INT16_MIN, TEST_CANMODE, NULL);
    XCTAssertNotEqual(CANERR_NOERROR, rc);
    XCTAssert((CANERR_NOTINIT == rc) || (CANERR_VENDOR >= rc));
    // @- try to initialize with invalid channel no. INT32_MIN
    rc = can_init((SInt32)INT32_MIN, TEST_CANMODE, NULL);
    XCTAssertNotEqual(CANERR_NOERROR, rc);
    XCTAssert((CANERR_NOTINIT == rc) || (CANERR_VENDOR >= rc));

    // @note: channel numbers are defined by the CAN device vendor.
    //        Therefore, no assumptions can be made for positive values!
}

// @xctest TC02.7: Check if interface can be initialized with its full operation mode capability.
//
// @expected: CANERR_NOERROR
//
- (void)testOperationModeCapability {
    can_bitrate_t bitrate = { TEST_BTRINDEX };
    can_status_t status = { CANSTAT_RESET };
    can_mode_t capa = { CANMODE_DEFAULT };
    can_mode_t mode = { CANMODE_DEFAULT };
    int handle = INVALID_HANDLE;
    int rc = CANERR_FATAL;

    // @pre:
    // @- initialize DUT1 with configured settings
    handle = can_init(DUT1, TEST_CANMODE, NULL);
    XCTAssertLessThanOrEqual(0, handle);
    // @- get operation capability from DUT1
    rc = can_property(handle, CANPROP_GET_OP_CAPABILITY, (void*)&capa.byte, sizeof(UInt8));
    XCTAssertEqual(CANERR_NOERROR, rc);
    // @- shutdown DUT1
    rc = can_exit(handle);
    XCTAssertEqual(CANERR_NOERROR, rc);

    // @test:
    mode.byte = capa.byte;
    // @- initialize DUT1 with all bits from operation capacity
    handle = can_init(DUT1, mode.byte, NULL);
    XCTAssertLessThanOrEqual(0, handle);
    // @- get status of DUT1 and check to be in INIT state
    rc = can_status(handle, &status.byte);
    XCTAssertEqual(CANERR_NOERROR, rc);
    XCTAssertTrue(status.can_stopped);

    // @post:
    // @- start DUT1 with configured bit-rate settings
    rc = can_start(handle, &bitrate);
    XCTAssertEqual(CANERR_NOERROR, rc);
    // @- get status of DUT1 and check to be in RUNNING state
    rc = can_status(handle, &status.byte);
    XCTAssertEqual(CANERR_NOERROR, rc);
    XCTAssertFalse(status.can_stopped);
    // @note: listen-only mode (when supported) prevents the sending of frames!
    // @- stop/reset DUT1
    rc = can_reset(handle);
    XCTAssertEqual(CANERR_NOERROR, rc);
    // @- get status of DUT1 and check to be in INIT state
    rc = can_status(handle, &status.byte);
    XCTAssertEqual(CANERR_NOERROR, rc);
    XCTAssertTrue(status.can_stopped);
    // @- shutdown DUT1
    rc = can_exit(handle);
    XCTAssertEqual(CANERR_NOERROR, rc);
}

// @xctest TC02.8: Check if interface can be initialized with operation mode bit MON set (listen-only mode).
//
// @expected: CANERR_NOERROR or CANERR_ILLPARA if listen-only mode is not supported
//
- (void)testMonitorModeEnableDisable {
    can_mode_t capa = { CANMODE_DEFAULT };
    can_mode_t mode = { CANMODE_DEFAULT };
    int handle = INVALID_HANDLE;
    int rc = CANERR_FATAL;

    // @pre:
    // @- initialize DUT1 with configured settings
    handle = can_init(DUT1, TEST_CANMODE, NULL);
    XCTAssertLessThanOrEqual(0, handle);
    // @- get operation capability from DUT1
    rc = can_property(handle, CANPROP_GET_OP_CAPABILITY, (void*)&capa.byte, sizeof(UInt8));
    XCTAssertEqual(CANERR_NOERROR, rc);
    // @- shutdown DUT1
    rc = can_exit(handle);
    XCTAssertEqual(CANERR_NOERROR, rc);

    // @test:
    mode.mon = 1;
    // @- initialize DUT1 with operation mode bit MON set
    rc = can_init(DUT1, mode.byte, NULL);
    if (capa.mon) {
        handle = rc;
        XCTAssertLessThanOrEqual(0, handle);
        // @- get operation mode from DUT1
        rc = can_property(handle, CANPROP_GET_OP_MODE, (void*)&mode.byte, sizeof(UInt8));
        XCTAssertEqual(CANERR_NOERROR, rc);
        XCTAssertEqual(CANMODE_MON, mode.byte);

        // TODO: try to send a frame & receive some frames
        // @- shutdown DUT1
        rc = can_exit(handle);
        XCTAssertEqual(CANERR_NOERROR, rc);
    } else {
        XCTAssertEqual(CANERR_ILLPARA, rc);
    }
}

// @xctest TC02.9: Check if interface can be initialized with operation mode bit ERR set (error frame reception).
//
// @expected: CANERR_NOERROR or CANERR_ILLPARA if error frame reception is not supported
//
- (void)testErrorFramesEnableDisable {
    can_mode_t capa = { CANMODE_DEFAULT };
    can_mode_t mode = { CANMODE_DEFAULT };
    int handle = INVALID_HANDLE;
    int rc = CANERR_FATAL;

    // @pre:
    // @- initialize DUT1 with configured settings
    handle = can_init(DUT1, TEST_CANMODE, NULL);
    XCTAssertLessThanOrEqual(0, handle);
    // @- get operation capability from DUT1
    rc = can_property(handle, CANPROP_GET_OP_CAPABILITY, (void*)&capa.byte, sizeof(UInt8));
    XCTAssertEqual(CANERR_NOERROR, rc);
    // @- shutdown DUT1
    rc = can_exit(handle);
    XCTAssertEqual(CANERR_NOERROR, rc);

    // @test:
    mode.err = 1;
    // @- initialize DUT1 with operation mode bit ERR set
    rc = can_init(DUT1, mode.byte, NULL);
    if (capa.err) {
        handle = rc;
        XCTAssertLessThanOrEqual(0, handle);
        // @- get operation mode from DUT1
        rc = can_property(handle, CANPROP_GET_OP_MODE, (void*)&mode.byte, sizeof(UInt8));
        XCTAssertEqual(CANERR_NOERROR, rc);
        XCTAssertEqual(CANMODE_ERR, mode.byte);

        // TODO: receive some error frames
        // @- shutdown DUT1
        rc = can_exit(handle);
        XCTAssertEqual(CANERR_NOERROR, rc);
    } else {
        XCTAssertEqual(CANERR_ILLPARA, rc);
    }
}

// @xctest TC02.10: Check if interface can be initialized with operation mode bit NRTR set (suppress remote frames).
//
// @expected: CANERR_NOERROR or CANERR_ILLPARA if suppressing of remote frames is not supported
//
- (void)testRemoteFramesDisableEnable {
    can_mode_t capa = { CANMODE_DEFAULT };
    can_mode_t mode = { CANMODE_DEFAULT };
    int handle = INVALID_HANDLE;
    int rc = CANERR_FATAL;

    // @pre:
    // @- initialize DUT1 with configured settings
    handle = can_init(DUT1, TEST_CANMODE, NULL);
    XCTAssertLessThanOrEqual(0, handle);
    // @- get operation capability from DUT1
    rc = can_property(handle, CANPROP_GET_OP_CAPABILITY, (void*)&capa.byte, sizeof(UInt8));
    XCTAssertEqual(CANERR_NOERROR, rc);
    // @- shutdown DUT1
    rc = can_exit(handle);
    XCTAssertEqual(CANERR_NOERROR, rc);

    // @test:
    mode.nrtr = 1;
    // @- initialize DUT1 with operation mode bit NRTR set
    rc = can_init(DUT1, mode.byte, NULL);
    if (capa.nrtr) {
        handle = rc;
        XCTAssertLessThanOrEqual(0, handle);
        // @- get operation mode from DUT1
        rc = can_property(handle, CANPROP_GET_OP_MODE, (void*)&mode.byte, sizeof(UInt8));
        XCTAssertEqual(CANERR_NOERROR, rc);
        XCTAssertEqual(CANMODE_NRTR, mode.byte);

        // TODO: try to request & receive some remote frames
        // @- shutdown DUT1
        rc = can_exit(handle);
        XCTAssertEqual(CANERR_NOERROR, rc);
    } else {
        XCTAssertEqual(CANERR_ILLPARA, rc);
    }
}

// @xctest TC02.11: Check if interface can be initialized with operation mode bit NXTD set (suppress extended frames).
//
// @expected: CANERR_NOERROR or CANERR_ILLPARA if suppressing of extended frames is not supported
//
- (void)testExtendedFramesDisableEnable {
    can_mode_t capa = { CANMODE_DEFAULT };
    can_mode_t mode = { CANMODE_DEFAULT };
    int handle = INVALID_HANDLE;
    int rc = CANERR_FATAL;

    // @pre:
    // @- initialize DUT1 with configured settings
    handle = can_init(DUT1, TEST_CANMODE, NULL);
    XCTAssertLessThanOrEqual(0, handle);
    // @- get operation capability from DUT1
    rc = can_property(handle, CANPROP_GET_OP_CAPABILITY, (void*)&capa.byte, sizeof(UInt8));
    XCTAssertEqual(CANERR_NOERROR, rc);
    // @- shutdown DUT1
    rc = can_exit(handle);
    XCTAssertEqual(CANERR_NOERROR, rc);

    // @test:
    mode.nxtd = 1;
    // @- initialize DUT1 with operation mode bit NXTD set
    rc = can_init(DUT1, mode.byte, NULL);
    if (capa.nxtd) {
        handle = rc;
        XCTAssertLessThanOrEqual(0, handle);
        // @- get operation mode from DUT1
        rc = can_property(handle, CANPROP_GET_OP_MODE, (void*)&mode.byte, sizeof(UInt8));
        XCTAssertEqual(CANERR_NOERROR, rc);
        XCTAssertEqual(CANMODE_NXTD, mode.byte);

        // TODO: try to send & receive some extended frames
        // @- shutdown DUT1
        rc = can_exit(handle);
        XCTAssertEqual(CANERR_NOERROR, rc);
    } else {
        XCTAssertEqual(CANERR_ILLPARA, rc);
    }
}

// @xctest TC02.12: Check if interface can be initialized with operation mode bit FDOE set (CAN FD operation enabled).
//
// @expected: CANERR_NOERROR or CANERR_ILLPARA if CAN FD operation mode is not supported
//
//- (void)testCanFdOperationEnableDisable {
//        TODO: insert coin here
//}

// @xctest TC02.13: Check if interface can be initialized with operation mode bit FDOE and BRSE set (CAN FD operation with bit-rate switching enabled).
//
// @expected: CANERR_NOERROR or CANERR_ILLPARA if CAN FD operation mode or bit-rate switching is not supported
//
//- (void)testBitrateSwitchingEnableDisable {
//        TODO: insert coin here
//}

@end
