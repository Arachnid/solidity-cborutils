const TestCBOR = artifacts.require('./TestCBOR.sol');
const cbor = require('cbor');

contract('CBOR', function(accounts) {
  it('returns valid CBOR-encoded data', async function() {
    var test = await TestCBOR.new();
    var result = new Buffer.from((await test.getTestData()).slice(2), 'hex');
    var decoded = await cbor.decodeFirst(result);
    assert.deepEqual(decoded, {
      'key1': 'value1',
      'long': 'This string is longer than 24 characters.',
      'bytes': Buffer.from('Test'),
      'true': true,
      'false': false,
      'null': null,
      'undefined': undefined,
      'array': [0, 1, 23, 24, 0x100, 0x10000, 0x100000000, -42]
    });
  });

  it('returns > 8 byte int as bytes', async function() {
    var test = await TestCBOR.new();
    var result = cbor.decodeFirstSync(new Buffer.from((await test.getTestDataBigInt()).slice(2), 'hex'));
    expect(result.map((x) => x.toFixed())).to.deep.equal([
      '-57896044618658097711785492504343953926634992332820282019728792003956564819968',
      '-57896044618658097711785492504343953926634992332820282019728792003956564819967',
      '57896044618658097711785492504343953926634992332820282019728792003956564819966',
      '57896044618658097711785492504343953926634992332820282019728792003956564819967',
      '-9223372036854775808',
      '-9223372036854775807',
      '9223372036854775806',
      '9223372036854775807'
    ]);
  });

  it('returns > 8 byte uint as bytes', async function() {
    var test = await TestCBOR.new();
    var result = cbor.decodeFirstSync(new Buffer.from((await test.getTestDataBigUint()).slice(2), 'hex'));
    expect(result.map((x) => x.toFixed())).to.deep.equal([
      '0',
      '1',
      '115792089237316195423570985008687907853269984665640564039457584007913129639934',
      '115792089237316195423570985008687907853269984665640564039457584007913129639935'
    ]);
  });
});
