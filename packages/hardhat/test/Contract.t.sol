// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "src/millionDollarHomepageNFT.sol";

contract ContractTest is Test {
    string newURI = "https://www.baseURI.com";

    millionDollarHomepageNFT _mdnft;
    function setUp() public {
        _mdnft = new millionDollarHomepageNFT("lfg", "lfg");
    }
    function testExample() public {
        //tests: mint, lease takeover, register expired token  
        _mdnft.mint(address(this), 1);
        _mdnft.mint(address(this), 2);
        _mdnft.transferFrom(address(this), 0x940ACd9375b46EC2FA7C0E8aAd9D7241fb01e205, 2);   
        address transferTestUser = _mdnft.userOf(2);
        emit log_address (transferTestUser);
        _mdnft.setBaseURI(newURI, 1);
        uint jump = 366 days;
        vm.warp(jump);
        _mdnft.registerExpiredToken(address(this), 1);
        vm.warp(jump);
    }

    function testFail() public {
        _mdnft.setBaseURI(newURI, 1);
    }

}
