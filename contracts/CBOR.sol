pragma solidity ^0.4.19;

import "@ensdomains/buffer/contracts/Buffer.sol";

library CBOR {
    using Buffer for Buffer.buffer;

    uint8 private constant MAJOR_TYPE_INT = 0;
    uint8 private constant MAJOR_TYPE_NEGATIVE_INT = 1;
    uint8 private constant MAJOR_TYPE_BYTES = 2;
    uint8 private constant MAJOR_TYPE_STRING = 3;
    uint8 private constant MAJOR_TYPE_ARRAY = 4;
    uint8 private constant MAJOR_TYPE_MAP = 5;
    uint8 private constant MAJOR_TYPE_TAG = 6;
    uint8 private constant MAJOR_TYPE_CONTENT_FREE = 7;

    uint8 private constant TAG_TYPE_BIGNUM = 2;
    uint8 private constant TAG_TYPE_NEGATIVE_BIGNUM = 3;

    function encodeType(Buffer.buffer memory buf, uint8 major, uint value) private pure {
        if(value <= 23) {
            buf.appendUint8(uint8((major << 5) | value));
        } else if(value <= 0xFF) {
            buf.appendUint8(uint8((major << 5) | 24));
            buf.appendInt(value, 1);
        } else if(value <= 0xFFFF) {
            buf.appendUint8(uint8((major << 5) | 25));
            buf.appendInt(value, 2);
        } else if(value <= 0xFFFFFFFF) {
            buf.appendUint8(uint8((major << 5) | 26));
            buf.appendInt(value, 4);
        } else if(value <= 0xFFFFFFFFFFFFFFFF) {
            buf.appendUint8(uint8((major << 5) | 27));
            buf.appendInt(value, 8);
        }
    }

    function encodeIndefiniteLengthType(Buffer.buffer memory buf, uint8 major) private pure {
        buf.appendUint8(uint8((major << 5) | 31));
    }

    function encodeUInt(Buffer.buffer memory buf, uint value) internal pure {
        encodeType(buf, MAJOR_TYPE_INT, value);
    }

    function encodeInt(Buffer.buffer memory buf, int value) internal pure {
        if(value < -10000000000000000) {
            encodeSignedBigNum(buf, value);
        } else if(value > 0xFFFFFFFFFFFFFFFF) {
            encodeBigNum(buf, value);
        } else if(value >= 0) {
            encodeType(buf, MAJOR_TYPE_INT, uint(value));
        } else {
            encodeType(buf, MAJOR_TYPE_NEGATIVE_INT, uint(-1 - value));
        }
    }

    function encodeBytes(Buffer.buffer memory buf, bytes value) internal pure {
        encodeType(buf, MAJOR_TYPE_BYTES, value.length);
        buf.append(value);
    }

    function encodeBigNum(Buffer.buffer memory buf, int value) internal pure {
      uint8 size = byteCount(uint(value));
      bytes memory significantBytes = new bytes(size);
      bytes memory encoded = abi.encodePacked(value);
      uint8 offset = 32 - size;
      for (uint8 i = 0; i < significantBytes.length; i++) {
          significantBytes[i]  = encoded[offset + i];
      }
      buf.appendUint8(uint8((MAJOR_TYPE_TAG << 5) | TAG_TYPE_BIGNUM));
      encodeBytes(buf, significantBytes);
    }

    function encodeSignedBigNum(Buffer.buffer memory buf, int input) internal pure {
      uint value = uint(-1 - input);
      uint8 size = byteCount(uint(value));
      bytes memory significantBytes = new bytes(size);
      bytes memory encoded = abi.encodePacked(value);
      uint8 offset = 32 - size;
      for (uint8 i = 0; i < significantBytes.length; i++) {
          significantBytes[i]  = encoded[offset + i];
      }
      buf.appendUint8(uint8((MAJOR_TYPE_TAG << 5) | TAG_TYPE_NEGATIVE_BIGNUM));
      encodeBytes(buf, significantBytes);
    }

    function byteCount(uint256 input) internal pure returns (uint8) {
        uint8 count = 0;
        uint256 value = input;
        if (value >> 128 > 0) {
            value = value >> 128;
            count = 16;
        }
        if (value >> 64 > 0) {
            value = value >> 64;
            count += 8;
        }
        if (value >> 32 > 0) {
            value = value >> 32;
            count += 4;
        }
        if (value >> 16 > 0) {
            value = value >> 16;
            count += 2;
        }
        if (value >> 8 > 0) {
            value = value >> 8;
            count += 1;
        }
        if (value > 0) {
            count += 1;
        }
        return count;
    }

    function encodeString(Buffer.buffer memory buf, string value) internal pure {
        encodeType(buf, MAJOR_TYPE_STRING, bytes(value).length);
        buf.append(bytes(value));
    }

    function startArray(Buffer.buffer memory buf) internal pure {
        encodeIndefiniteLengthType(buf, MAJOR_TYPE_ARRAY);
    }

    function startMap(Buffer.buffer memory buf) internal pure {
        encodeIndefiniteLengthType(buf, MAJOR_TYPE_MAP);
    }

    function endSequence(Buffer.buffer memory buf) internal pure {
        encodeIndefiniteLengthType(buf, MAJOR_TYPE_CONTENT_FREE);
    }
}
