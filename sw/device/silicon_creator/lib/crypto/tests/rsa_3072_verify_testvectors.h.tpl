// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// AUTOGENERATED. Do not edit this file by hand.
// See the crypto/tests README for details.

#ifndef OPENTITAN_SW_DEVICE_SILICON_CREATOR_LIB_CRYPTO_TESTS_RSA_3072_VERIFY_TESTVECTORS_H_
#define OPENTITAN_SW_DEVICE_SILICON_CREATOR_LIB_CRYPTO_TESTS_RSA_3072_VERIFY_TESTVECTORS_H_

#include "sw/device/silicon_creator/lib/crypto/rsa_3072/rsa_3072_verify.h"

#ifdef __cplusplus
extern "C" {
#endif  // __cplusplus

// A test vector for RSA-3072 verify (message hashed with SHA-256)
typedef struct rsa_3072_verify_test_vector_t {
  rsa_3072_public_key_t publicKey;  // The public key
  rsa_3072_int_t signature;         // The signature to verify
  char *msg;                        // The message
  size_t msgLen;                    // Length (in bytes) of the message
  bool valid;                       // Expected result (true if signature valid)
  char *comment;                    // Any notes about the test vector
} rsa_3072_verify_test_vector_t;

static const size_t RSA_3072_VERIFY_NUM_TESTS = ${len(tests)};

static const rsa_3072_verify_test_vector_t rsa_3072_verify_tests[${len(tests)}] = {
% for t in tests:
    {
        .publicKey =
            {
                .n = {.data =
                          {
  % for i in range(0, len(t["n_hexwords"]), 4):
                              ${', '.join(t["n_hexwords"][i:i + 4])},
  % endfor
                          }},
                .e = ${'{:#x}'.format(t["e"])},
            },
        .signature =
            {.data =
                 {
  % for i in range(0, len(t["sig_hexwords"]), 5):
                     ${', '.join(t["sig_hexwords"][i:i + 5])},
  % endfor
                 }},
        .msg = "${t["msg"]}",
        .msgLen = ${t["msg_len"]},
        .valid = ${"true" if t["valid"] else "false"},
        .comment = "${t["comment"]}",
    },
% endfor
};

#ifdef __cplusplus
}  // extern "C"
#endif  // __cplusplus

#endif  // OPENTITAN_SW_DEVICE_SILICON_CREATOR_LIB_CRYPTO_TESTS_RSA_3072_VERIFY_TESTVECTORS_H_
