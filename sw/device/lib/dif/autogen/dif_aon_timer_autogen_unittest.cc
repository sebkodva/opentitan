// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// This file is auto-generated.

#include "sw/device/lib/dif/autogen/dif_aon_timer_autogen.h"

#include "gtest/gtest.h"
#include "sw/device/lib/base/mmio.h"
#include "sw/device/lib/base/testing/mock_mmio.h"

#include "aon_timer_regs.h"  // Generated.

namespace dif_aon_timer_autogen_unittest {
namespace {
using ::mock_mmio::MmioTest;
using ::mock_mmio::MockDevice;
using ::testing::Eq;
using ::testing::Test;

class AonTimerTest : public Test, public MmioTest {
 protected:
  dif_aon_timer_t aon_timer_ = {.base_addr = dev().region()};
};

class InitTest : public AonTimerTest {};

TEST_F(InitTest, NullArgs) {
  EXPECT_EQ(dif_aon_timer_init({.base_addr = dev().region()}, nullptr),
            kDifBadArg);
}

TEST_F(InitTest, Success) {
  EXPECT_EQ(dif_aon_timer_init({.base_addr = dev().region()}, &aon_timer_),
            kDifOk);
}

class AlertForceTest : public AonTimerTest {};

TEST_F(AlertForceTest, NullArgs) {
  EXPECT_EQ(dif_aon_timer_alert_force(nullptr, kDifAonTimerAlertFatalFault),
            kDifBadArg);
}

TEST_F(AlertForceTest, BadAlert) {
  EXPECT_EQ(dif_aon_timer_alert_force(nullptr,
                                      static_cast<dif_aon_timer_alert_t>(32)),
            kDifBadArg);
}

TEST_F(AlertForceTest, Success) {
  // Force first alert.
  EXPECT_WRITE32(AON_TIMER_ALERT_TEST_REG_OFFSET,
                 {{AON_TIMER_ALERT_TEST_FATAL_FAULT_BIT, true}});
  EXPECT_EQ(dif_aon_timer_alert_force(&aon_timer_, kDifAonTimerAlertFatalFault),
            kDifOk);
}

class IrqGetStateTest : public AonTimerTest {};

TEST_F(IrqGetStateTest, NullArgs) {
  dif_aon_timer_irq_state_snapshot_t irq_snapshot = 0;

  EXPECT_EQ(dif_aon_timer_irq_get_state(nullptr, &irq_snapshot), kDifBadArg);

  EXPECT_EQ(dif_aon_timer_irq_get_state(&aon_timer_, nullptr), kDifBadArg);

  EXPECT_EQ(dif_aon_timer_irq_get_state(nullptr, nullptr), kDifBadArg);
}

TEST_F(IrqGetStateTest, SuccessAllRaised) {
  dif_aon_timer_irq_state_snapshot_t irq_snapshot = 0;

  EXPECT_READ32(AON_TIMER_INTR_STATE_REG_OFFSET,
                std::numeric_limits<uint32_t>::max());
  EXPECT_EQ(dif_aon_timer_irq_get_state(&aon_timer_, &irq_snapshot), kDifOk);
  EXPECT_EQ(irq_snapshot, std::numeric_limits<uint32_t>::max());
}

TEST_F(IrqGetStateTest, SuccessNoneRaised) {
  dif_aon_timer_irq_state_snapshot_t irq_snapshot = 0;

  EXPECT_READ32(AON_TIMER_INTR_STATE_REG_OFFSET, 0);
  EXPECT_EQ(dif_aon_timer_irq_get_state(&aon_timer_, &irq_snapshot), kDifOk);
  EXPECT_EQ(irq_snapshot, 0);
}

class IrqIsPendingTest : public AonTimerTest {};

TEST_F(IrqIsPendingTest, NullArgs) {
  bool is_pending;

  EXPECT_EQ(dif_aon_timer_irq_is_pending(
                nullptr, kDifAonTimerIrqWkupTimerExpired, &is_pending),
            kDifBadArg);

  EXPECT_EQ(dif_aon_timer_irq_is_pending(
                &aon_timer_, kDifAonTimerIrqWkupTimerExpired, nullptr),
            kDifBadArg);

  EXPECT_EQ(dif_aon_timer_irq_is_pending(
                nullptr, kDifAonTimerIrqWkupTimerExpired, nullptr),
            kDifBadArg);
}

TEST_F(IrqIsPendingTest, BadIrq) {
  bool is_pending;
  // All interrupt CSRs are 32 bit so interrupt 32 will be invalid.
  EXPECT_EQ(dif_aon_timer_irq_is_pending(
                &aon_timer_, static_cast<dif_aon_timer_irq_t>(32), &is_pending),
            kDifBadArg);
}

TEST_F(IrqIsPendingTest, Success) {
  bool irq_state;

  // Get the first IRQ state.
  irq_state = false;
  EXPECT_READ32(AON_TIMER_INTR_STATE_REG_OFFSET,
                {{AON_TIMER_INTR_STATE_WKUP_TIMER_EXPIRED_BIT, true}});
  EXPECT_EQ(dif_aon_timer_irq_is_pending(
                &aon_timer_, kDifAonTimerIrqWkupTimerExpired, &irq_state),
            kDifOk);
  EXPECT_TRUE(irq_state);

  // Get the last IRQ state.
  irq_state = true;
  EXPECT_READ32(AON_TIMER_INTR_STATE_REG_OFFSET,
                {{AON_TIMER_INTR_STATE_WDOG_TIMER_BARK_BIT, false}});
  EXPECT_EQ(dif_aon_timer_irq_is_pending(
                &aon_timer_, kDifAonTimerIrqWdogTimerBark, &irq_state),
            kDifOk);
  EXPECT_FALSE(irq_state);
}

class AcknowledgeAllTest : public AonTimerTest {};

TEST_F(AcknowledgeAllTest, NullArgs) {
  EXPECT_EQ(dif_aon_timer_irq_acknowledge_all(nullptr), kDifBadArg);
}

TEST_F(AcknowledgeAllTest, Success) {
  EXPECT_WRITE32(AON_TIMER_INTR_STATE_REG_OFFSET,
                 std::numeric_limits<uint32_t>::max());

  EXPECT_EQ(dif_aon_timer_irq_acknowledge_all(&aon_timer_), kDifOk);
}

class IrqAcknowledgeTest : public AonTimerTest {};

TEST_F(IrqAcknowledgeTest, NullArgs) {
  EXPECT_EQ(
      dif_aon_timer_irq_acknowledge(nullptr, kDifAonTimerIrqWkupTimerExpired),
      kDifBadArg);
}

TEST_F(IrqAcknowledgeTest, BadIrq) {
  EXPECT_EQ(dif_aon_timer_irq_acknowledge(nullptr,
                                          static_cast<dif_aon_timer_irq_t>(32)),
            kDifBadArg);
}

TEST_F(IrqAcknowledgeTest, Success) {
  // Clear the first IRQ state.
  EXPECT_WRITE32(AON_TIMER_INTR_STATE_REG_OFFSET,
                 {{AON_TIMER_INTR_STATE_WKUP_TIMER_EXPIRED_BIT, true}});
  EXPECT_EQ(dif_aon_timer_irq_acknowledge(&aon_timer_,
                                          kDifAonTimerIrqWkupTimerExpired),
            kDifOk);

  // Clear the last IRQ state.
  EXPECT_WRITE32(AON_TIMER_INTR_STATE_REG_OFFSET,
                 {{AON_TIMER_INTR_STATE_WDOG_TIMER_BARK_BIT, true}});
  EXPECT_EQ(
      dif_aon_timer_irq_acknowledge(&aon_timer_, kDifAonTimerIrqWdogTimerBark),
      kDifOk);
}

class IrqForceTest : public AonTimerTest {};

TEST_F(IrqForceTest, NullArgs) {
  EXPECT_EQ(dif_aon_timer_irq_force(nullptr, kDifAonTimerIrqWkupTimerExpired),
            kDifBadArg);
}

TEST_F(IrqForceTest, BadIrq) {
  EXPECT_EQ(
      dif_aon_timer_irq_force(nullptr, static_cast<dif_aon_timer_irq_t>(32)),
      kDifBadArg);
}

TEST_F(IrqForceTest, Success) {
  // Force first IRQ.
  EXPECT_WRITE32(AON_TIMER_INTR_TEST_REG_OFFSET,
                 {{AON_TIMER_INTR_TEST_WKUP_TIMER_EXPIRED_BIT, true}});
  EXPECT_EQ(
      dif_aon_timer_irq_force(&aon_timer_, kDifAonTimerIrqWkupTimerExpired),
      kDifOk);

  // Force last IRQ.
  EXPECT_WRITE32(AON_TIMER_INTR_TEST_REG_OFFSET,
                 {{AON_TIMER_INTR_TEST_WDOG_TIMER_BARK_BIT, true}});
  EXPECT_EQ(dif_aon_timer_irq_force(&aon_timer_, kDifAonTimerIrqWdogTimerBark),
            kDifOk);
}

}  // namespace
}  // namespace dif_aon_timer_autogen_unittest
