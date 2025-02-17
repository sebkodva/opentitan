---
title: "System Reset Control (Chrome OS) Technical Specification"
---

# Overview

This document specifies the functionality of the System Reset Control (`sysrst_ctrl`) block which implements Chrome-OS-Platform-specific system and reset functionality.
This IP block implements keyboard and button combination-triggered action and the Embedded Controller (EC) reset stretching and OpenTitan reset request logic.
This module conforms to the [Comportable guideline for peripheral functionality.]({{< relref "doc/rm/comportability_specification" >}}).
See that document for integration overview within the broader top level system.

## Features

The IP block implements the following features:

- Always-on: uses the always-on power and clock domain
- EC reset pulse duration control and stretching
- Keyboard and button combination (combo) triggered action
- AC_present can trigger interrupt 
- Configuration registers can be set and locked until the next chip reset
- Pin output override

## Description

The `sysrst_ctrl` logic is very simple.
It looks up the configuration registers to decide how long the EC reset pulse duration and how long the keyboard debounce timer should be. 
Also what actions to take (e.g. Interrupt, EC reset, OpenTitan reset request, disconnect the battery from the power tree).

## Compatibility

The configuration programming interface is not based on any existing interface.

# Theory of Operations

![`sysrst_ctrl` Block Diagram](sysrst_ctrl_blockdiagram.svg)

The block diagram above shows a conceptual view of the `sysrst_ctrl` block, which consists of 3 main modules:
The first is the configuration and status registers, the second is the keyboard combo debounce and detection logic, and the third is the pinout override logic.

The `sysrst_ctrl` has four input pins (`pwrb_in`, `key[0,1,2]_in`) with corresponding output pins (`pwrb_out`, `key[0,1,2]_out`).
During normal operation the `sysrst_ctrl` will pass the pin information directly from the input pins to the output pins with optional inversion.
Combinations of the inputs being active for a specified time can be detected and used to trigger actions. 
The override logic allows the output to be overridden (i.e. not follow the corresponding input) based either on trigger or software settings. 
This allows the security chip to take over the inputs for its own use without disturbing the main user.

The `sysrst_ctrl` also controls two active-low open-drain I/Os named `flash_wp_out_l` and `ec_rst_in_l` / `ec_rst_out_l`.
The `ec_rst_in_l` / `ec_rst_out_l` signals are connected to the same bidirectional pin of the OpenTitan chip, and are used to either reset the embedded controller (EC), or to detect self-reset of the EC and stretch the reset pulse (hence the bidirectional nature of this pin).
This output is always asserted when `sysrst_ctrl` is reset (allowing its use as a power-on reset) and remains asserted until released by software.
The flash write-protect output `flash_wp_out_l` is typically connected to the BIOS flash chip in the system.
This output is always asserted when the `sysrst_ctrl` block is reset and remains asserted until released by software.

## Hardware Interfaces

{{< incGenFromIpDesc "../data/sysrst_ctrl.hjson" "hwcfg" >}}

### Signals

The table below lists the `sysrst_ctrl` intermodule signals.

Signal                                 | Direction | Type    | Description
---------------------------------------|-----------|---------|---------------
`aon_ot_wkup_req_o`                    | `output`  | `logic` |  OpenTitan wake request signal to `pwrmgr` (running on AON clock).
`aon_ot_rst_req_o`                     | `output`  | `logic` |  OpenTitan reset request to `rstmgr` (running on AON clock).
`intr_sysrst_ctrl_o`                   | `output`  | `logic` |  Interrupt request to PLIC (running on bus clock).


## Combo detection

Software can program the `sysrst_ctrl` block to detect certain button combos and for how long they have to be asserted until they trigger a programmable action.
Let's use the "Power button + Esc + Refresh" combo as an example:

1. Software can define the three key values `pwrb_in==0`, `key0_in==0` and `key1_in==0` as trigger combination in the {{< regref COM_SEL_CTL_0 >}} register.
2. The combo duration for which the above combo should be pressed (e.g. 10 seconds) can be configured via the {{< regref COM_DET_CTL_0 >}} register.
3. Actions such as asserting `ec_rst_out_l` and raising an interrupt can be configured via the {{< regref COM_OUT_CTL_0 >}} register.
4. The pulse width of the `ec_rst_out_l` pulse can be set in the {{< regref EC_RST_CTL >}} register.
5. The software can optionally lock the `sysrst_ctrl` configuration via {{< regref REGWEN >}}

Once the above configuration is active, `sysrst_ctrl` will start the timer when a combo high (logic 1) to low (logic 0) transition is detected.
Once the timing condition is met (10 seconds), `sysrst_ctrl` will assert `ec_rst_out_l`, the interrupt request and set the interrupt status register {{< regref COMBO_INTR_STATUS >}} to indicate the interrupt cause.
The software interrupt handler should then read {{< regref COMBO_INTR_STATUS >}} register and clear the interrupt.

## Auto-block key outputs

Software can program the `sysrst_ctrl` block to override the output value of specific passthrough signals, depending on whether certain input signals are asserted or not.
Let's use the "Power button + Esc + Refresh" combo as an example.
When `pwrb_in` is asserted, `key1_out` (row) should be overridden so that `sysrst_ctrl` can detect if `key0_in` (column) is Refresh.

1. The software enables the auto block feature and sets an appropriate debounce timer value in the {{< regref AUTO_BLOCK_DEBOUNCE_CTL >}} register.
2. The software then defines the key outputs to auto override and their override values in the {{< regref AUTO_BLOCK_OUT_CTL >}} register.

Once the above configuration is active, `sysrst_ctrl` will detect a high (logic 1) to low (logic 0) transition on `pwrb_in` and check whether the key `pwrb_in` stays low for the programmed duration.
If this condition is met, `sysrst_ctrl` will drive `key1_out` to the value programmed in {{< regref AUTO_BLOCK_OUT_CTL >}}.

## Keyboard and input triggered interrupt

Software can program the `sysrst_ctrl` block to detect edge transitions on the `pwrb_in`, `key0_in`, `key1_in`, `key2_in`, `ac_present_in` and `ec_rst_in_l` signals and trigger an interrupt:

1. Software first defines the input signal and the edge transition to detect (H->L or L->H) via the {{< regref KEY_INTR_CTL >}} register.
2. The software then programs an appropriate debounce timer value to the {{< regref KEY_INTR_DEBOUNCE_CTL >}} register.

For example, when the power button is pressed, `pwrb_in` goes from logic 1 to logic 0 which would amount to an H->L transition.
Likewise, when the power button is released, `pwrb_in` goes from logic 0 to logic 1 which would amount to an L->H transition.
When `sysrst_ctrl` detects a transition (H->L or L->H) as specified in {{< regref KEY_INTR_CTL >}} and it meets the debounce requirement in {{< regref KEY_INTR_DEBOUNCE_CTL >}}, `sysrst_ctrl` sets the {{< regref KEY_INTR_STATUS >}} register to indicate the interrupt cause and send out a consolidated interrupt to the PLIC.
The software interrupt handler should then read {{< regref KEY_INTR_STATUS >}} register and clear the interrupt.

## Pin input value accessibility

`sysrst_ctrl` allows the software to read the raw input pin values via the {{< regref PIN_IN_VALUE >}} register like GPIOs.
To this end, the hardware samples the raw input values of `pwrb_in`, `key[0,1,2]_in`, `ac_present_in`, `ec_rst_in_l` before they are being inverted, and synchronizes them onto the bus clock domain.

## Pin output and keyboard inversion control

Software can optionally override all output signals, and change the signal polarity of some of the input and output signals.
The output signal override feature always has higher priority than any of the combo pattern detection mechanisms described above.

The selection of output signals to override, and the override values are programmable and lockable via the {{< regref PIN_ALLOWED_CTL >}} register.
For example, {{< regref PIN_ALLOWED_CTL.EC_RST_L_0 >}} to 1 and {{< regref PIN_ALLOWED_CTL.EC_RST_L_1 >}} to 0 means that software allows `ec_rst_out_l` to be overridden with logic 0, but not with logic 1.
If the SW locks the configuration with {{< regref REGWEN >}}, {{< regref PIN_ALLOWED_CTL >}} cannot be modified until the next OpenTitan reset.

When the system is up and running, the software can modify {{< regref PIN_OUT_CTL >}} and {{< regref PIN_OUT_VALUE >}} to enable or disable the feature.
For example, to release `ec_rst_out_l` after OpenTitan completes the reset, software can set {{< regref PIN_OUT_CTL >}} to 0 to stop the hardware from driving `ec_rst_out_l` to 0.

The input / output signal inversions can be programmed via the {{< regref KEY_INVERT_CTL >}} register.
Input signals will be inverted before the combo detection logic, while output signals will be inverted after the output signal override logic.

## EC and Power-on-reset

OpenTitan and EC will be reset together during power-on.
When OpenTitan is in reset, `ec_rst_out_l` will be asserted (active low).
The power-on-reset value of {{< regref PIN_ALLOWED_CTL.EC_RST_L_1 >}} and {{< regref PIN_OUT_CTL.EC_RST_L >}} will guarantee that `ec_rst_out_l` remains asserted after OpenTitan reset is released.
The software can release `ec_rst_out_l` explicitly by setting {{< regref PIN_OUT_CTL.EC_RST_L >}} to 0 during boot in order to complete the OpenTitan and EC power-on-reset sequence.

Note that since the `sysrst_ctrl` does not have control over the pad open-drain settings, software should properly initialize the pad attributes of the corresponding pad in the [pinmux configuration]({{< relref "hw/ip/pinmux/doc/" >}}) before releasing `ec_rst_out_l`.

## Flash Write Protect Output

Upon reset, the `flash_wp_out_l` signal will be asserted active low.
The software can release `flash_wp_out_l` explicitly by setting {{< regref PIN_OUT_CTL.FLASH_WP_L >}} to 0 when needed.
The `flash_wp_out_l` signal does not have a corresponding input signal such as the `pwrb_in` or `key[0,1,2]_in`.
Hence, the value of `flash_wp_out_l` defaults to logic 0 when it is not explicitly driven via the override function.

Note that since the `sysrst_ctrl` does not have control over the pad open-drain settings, software should properly initialize the pad attributes of the corresponding pad in the [pinmux configuration]({{< relref "hw/ip/pinmux/doc/" >}}) before releasing `flash_wp_out_l`.

## Registers

{{< incGenFromIpDesc "../data/sysrst_ctrl.hjson" "registers" >}}


