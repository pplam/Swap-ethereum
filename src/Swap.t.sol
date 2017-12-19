pragma solidity ^0.4.19;

import "ds-test/test.sol";

import "./Swap.sol";

contract SwapTest is DSTest {
    Swap swap;

    function setUp() public {
        swap = new Swap();
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }
}
