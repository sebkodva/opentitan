// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// THIS FILE HAS BEEN GENERATED, DO NOT EDIT MANUALLY. COMMAND:
// util/make_new_dif.py --mode=regen --only=autogen

#include "sw/device/lib/dif/autogen/dif_spi_device_autogen.h"
#include <stdint.h>

#include "spi_device_regs.h"  // Generated.

OT_WARN_UNUSED_RESULT
dif_result_t dif_spi_device_init(mmio_region_t base_addr,
                                 dif_spi_device_t *spi_device) {
  if (spi_device == NULL) {
    return kDifBadArg;
  }

  spi_device->base_addr = base_addr;

  return kDifOk;
}

dif_result_t dif_spi_device_alert_force(const dif_spi_device_t *spi_device,
                                        dif_spi_device_alert_t alert) {
  if (spi_device == NULL) {
    return kDifBadArg;
  }

  bitfield_bit32_index_t alert_idx;
  switch (alert) {
    case kDifSpiDeviceAlertFatalFault:
      alert_idx = SPI_DEVICE_ALERT_TEST_FATAL_FAULT_BIT;
      break;
    default:
      return kDifBadArg;
  }

  uint32_t alert_test_reg = bitfield_bit32_write(0, alert_idx, true);
  mmio_region_write32(spi_device->base_addr, SPI_DEVICE_ALERT_TEST_REG_OFFSET,
                      alert_test_reg);

  return kDifOk;
}

/**
 * Get the corresponding interrupt register bit offset of the IRQ. If the IP's
 * HJSON does NOT have a field "no_auto_intr_regs = true", then the
 * "<ip>_INTR_COMMON_<irq>_BIT" macro can be used. Otherwise, special cases
 * will exist, as templated below.
 */
static bool spi_device_get_irq_bit_index(dif_spi_device_irq_t irq,
                                         bitfield_bit32_index_t *index_out) {
  switch (irq) {
    case kDifSpiDeviceIrqRxFull:
      *index_out = SPI_DEVICE_INTR_COMMON_RX_FULL_BIT;
      break;
    case kDifSpiDeviceIrqRxWatermark:
      *index_out = SPI_DEVICE_INTR_COMMON_RX_WATERMARK_BIT;
      break;
    case kDifSpiDeviceIrqTxWatermark:
      *index_out = SPI_DEVICE_INTR_COMMON_TX_WATERMARK_BIT;
      break;
    case kDifSpiDeviceIrqRxError:
      *index_out = SPI_DEVICE_INTR_COMMON_RX_ERROR_BIT;
      break;
    case kDifSpiDeviceIrqRxOverflow:
      *index_out = SPI_DEVICE_INTR_COMMON_RX_OVERFLOW_BIT;
      break;
    case kDifSpiDeviceIrqTxUnderflow:
      *index_out = SPI_DEVICE_INTR_COMMON_TX_UNDERFLOW_BIT;
      break;
    case kDifSpiDeviceIrqCmdfifoNotEmpty:
      *index_out = SPI_DEVICE_INTR_COMMON_CMDFIFO_NOT_EMPTY_BIT;
      break;
    case kDifSpiDeviceIrqPayloadNotEmpty:
      *index_out = SPI_DEVICE_INTR_COMMON_PAYLOAD_NOT_EMPTY_BIT;
      break;
    case kDifSpiDeviceIrqReadbufWatermark:
      *index_out = SPI_DEVICE_INTR_COMMON_READBUF_WATERMARK_BIT;
      break;
    case kDifSpiDeviceIrqReadbufFlip:
      *index_out = SPI_DEVICE_INTR_COMMON_READBUF_FLIP_BIT;
      break;
    case kDifSpiDeviceIrqTpmHeaderNotEmpty:
      *index_out = SPI_DEVICE_INTR_COMMON_TPM_HEADER_NOT_EMPTY_BIT;
      break;
    default:
      return false;
  }

  return true;
}

OT_WARN_UNUSED_RESULT
dif_result_t dif_spi_device_irq_get_state(
    const dif_spi_device_t *spi_device,
    dif_spi_device_irq_state_snapshot_t *snapshot) {
  if (spi_device == NULL || snapshot == NULL) {
    return kDifBadArg;
  }

  *snapshot = mmio_region_read32(spi_device->base_addr,
                                 SPI_DEVICE_INTR_STATE_REG_OFFSET);

  return kDifOk;
}

OT_WARN_UNUSED_RESULT
dif_result_t dif_spi_device_irq_is_pending(const dif_spi_device_t *spi_device,
                                           dif_spi_device_irq_t irq,
                                           bool *is_pending) {
  if (spi_device == NULL || is_pending == NULL) {
    return kDifBadArg;
  }

  bitfield_bit32_index_t index;
  if (!spi_device_get_irq_bit_index(irq, &index)) {
    return kDifBadArg;
  }

  uint32_t intr_state_reg = mmio_region_read32(
      spi_device->base_addr, SPI_DEVICE_INTR_STATE_REG_OFFSET);

  *is_pending = bitfield_bit32_read(intr_state_reg, index);

  return kDifOk;
}

OT_WARN_UNUSED_RESULT
dif_result_t dif_spi_device_irq_acknowledge_all(
    const dif_spi_device_t *spi_device) {
  if (spi_device == NULL) {
    return kDifBadArg;
  }

  // Writing to the register clears the corresponding bits (Write-one clear).
  mmio_region_write32(spi_device->base_addr, SPI_DEVICE_INTR_STATE_REG_OFFSET,
                      UINT32_MAX);

  return kDifOk;
}

OT_WARN_UNUSED_RESULT
dif_result_t dif_spi_device_irq_acknowledge(const dif_spi_device_t *spi_device,
                                            dif_spi_device_irq_t irq) {
  if (spi_device == NULL) {
    return kDifBadArg;
  }

  bitfield_bit32_index_t index;
  if (!spi_device_get_irq_bit_index(irq, &index)) {
    return kDifBadArg;
  }

  // Writing to the register clears the corresponding bits (Write-one clear).
  uint32_t intr_state_reg = bitfield_bit32_write(0, index, true);
  mmio_region_write32(spi_device->base_addr, SPI_DEVICE_INTR_STATE_REG_OFFSET,
                      intr_state_reg);

  return kDifOk;
}

OT_WARN_UNUSED_RESULT
dif_result_t dif_spi_device_irq_force(const dif_spi_device_t *spi_device,
                                      dif_spi_device_irq_t irq) {
  if (spi_device == NULL) {
    return kDifBadArg;
  }

  bitfield_bit32_index_t index;
  if (!spi_device_get_irq_bit_index(irq, &index)) {
    return kDifBadArg;
  }

  uint32_t intr_test_reg = bitfield_bit32_write(0, index, true);
  mmio_region_write32(spi_device->base_addr, SPI_DEVICE_INTR_TEST_REG_OFFSET,
                      intr_test_reg);

  return kDifOk;
}

OT_WARN_UNUSED_RESULT
dif_result_t dif_spi_device_irq_get_enabled(const dif_spi_device_t *spi_device,
                                            dif_spi_device_irq_t irq,
                                            dif_toggle_t *state) {
  if (spi_device == NULL || state == NULL) {
    return kDifBadArg;
  }

  bitfield_bit32_index_t index;
  if (!spi_device_get_irq_bit_index(irq, &index)) {
    return kDifBadArg;
  }

  uint32_t intr_enable_reg = mmio_region_read32(
      spi_device->base_addr, SPI_DEVICE_INTR_ENABLE_REG_OFFSET);

  bool is_enabled = bitfield_bit32_read(intr_enable_reg, index);
  *state = is_enabled ? kDifToggleEnabled : kDifToggleDisabled;

  return kDifOk;
}

OT_WARN_UNUSED_RESULT
dif_result_t dif_spi_device_irq_set_enabled(const dif_spi_device_t *spi_device,
                                            dif_spi_device_irq_t irq,
                                            dif_toggle_t state) {
  if (spi_device == NULL) {
    return kDifBadArg;
  }

  bitfield_bit32_index_t index;
  if (!spi_device_get_irq_bit_index(irq, &index)) {
    return kDifBadArg;
  }

  uint32_t intr_enable_reg = mmio_region_read32(
      spi_device->base_addr, SPI_DEVICE_INTR_ENABLE_REG_OFFSET);

  bool enable_bit = (state == kDifToggleEnabled) ? true : false;
  intr_enable_reg = bitfield_bit32_write(intr_enable_reg, index, enable_bit);
  mmio_region_write32(spi_device->base_addr, SPI_DEVICE_INTR_ENABLE_REG_OFFSET,
                      intr_enable_reg);

  return kDifOk;
}

OT_WARN_UNUSED_RESULT
dif_result_t dif_spi_device_irq_disable_all(
    const dif_spi_device_t *spi_device,
    dif_spi_device_irq_enable_snapshot_t *snapshot) {
  if (spi_device == NULL) {
    return kDifBadArg;
  }

  // Pass the current interrupt state to the caller, if requested.
  if (snapshot != NULL) {
    *snapshot = mmio_region_read32(spi_device->base_addr,
                                   SPI_DEVICE_INTR_ENABLE_REG_OFFSET);
  }

  // Disable all interrupts.
  mmio_region_write32(spi_device->base_addr, SPI_DEVICE_INTR_ENABLE_REG_OFFSET,
                      0u);

  return kDifOk;
}

OT_WARN_UNUSED_RESULT
dif_result_t dif_spi_device_irq_restore_all(
    const dif_spi_device_t *spi_device,
    const dif_spi_device_irq_enable_snapshot_t *snapshot) {
  if (spi_device == NULL || snapshot == NULL) {
    return kDifBadArg;
  }

  mmio_region_write32(spi_device->base_addr, SPI_DEVICE_INTR_ENABLE_REG_OFFSET,
                      *snapshot);

  return kDifOk;
}
