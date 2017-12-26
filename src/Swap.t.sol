pragma solidity ^0.4.19;

import "ds-test/test.sol";

import "./Swap.sol";

contract SwapTest is DSTest {
    Swap swap;

    function setUp() public {
        // swap = new Swap("ethereum", address(0x90f9488adea4282ef2f56f5337c8343f774abd0f0), 1);
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }
}
