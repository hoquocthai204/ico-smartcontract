//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SPMToken is ERC20 {
    address public owner;

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    constructor(uint256 _initialSupply) ERC20("Sparkminds", "SPM") {
        _mint(msg.sender, _initialSupply * (uint256(10)**decimals()));
        owner = msg.sender;
    }
}
