// SPDX-License-Identifier: MIT
pragma solidity >= 0.4.19 < 0.9.0;

import "@ensdomains/buffer/contracts/Buffer.sol";
import "../contracts/CBOREncoder.sol";

contract TestCBOR {
    using CBOREncoder for CBOREncoder.CBOR;

    function getTestData() public pure returns(bytes memory) {
        CBOREncoder.CBOR memory buf = CBOREncoder.create(64);

        // Maps
        buf.startMap();

        // Short strings
        buf.writeKVString("key1", "value1");

        // Longer strings
        buf.writeKVString("long", "This string is longer than 24 characters.");

        // Bytes
        buf.writeKVBytes("bytes", bytes("Test"));

        // Bools, null, undefined
        buf.writeKVBool("true", true);
        buf.writeKVBool("false", false);
        buf.writeKVNull("null");
        buf.writeKVUndefined("undefined");

        // Arrays
        buf.writeKVArray("array");
        buf.writeUInt64(0);
        buf.writeUInt64(1);
        buf.writeUInt64(23);
        buf.writeUInt64(24);

        // 2, 4, and 8 byte numbers.
        buf.writeUInt64(0x100);
        buf.writeUInt64(0x10000);
        buf.writeUInt64(0x100000000);

        // Negative numbers
        buf.writeInt64(-42);

        buf.endSequence();
        buf.endSequence();

        return buf.data();
    }

    function getTestDataBigInt() public pure returns(bytes memory) {
        CBOREncoder.CBOR memory buf = CBOREncoder.create(128);

        buf.startArray();
        buf.writeInt256(type(int256).min);
        buf.writeInt256(type(int256).min+1);
        buf.writeInt256(type(int256).max-1);
        buf.writeInt256(type(int256).max);
        buf.writeInt64(type(int64).min);
        buf.writeInt64(type(int64).min+1);
        buf.writeInt64(type(int64).max-1);
        buf.writeInt64(type(int64).max);
        buf.endSequence();

        return buf.data();
    }

    function getTestDataBigUint() public pure returns(bytes memory) {
        CBOREncoder.CBOR memory buf = CBOREncoder.create(128);

        buf.startArray();
        buf.writeUInt256(type(uint256).min);
        buf.writeUInt256(type(uint256).min+1);
        buf.writeUInt256(type(uint256).max-1);
        buf.writeUInt256(type(uint256).max);
        buf.endSequence();

        return buf.data();
    }
}
