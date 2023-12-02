// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract USDTTOKEN is ERC20 {
    constructor() ERC20("USDT Dummy", "USDT") {}

    function mint() external {
        _mint(msg.sender, 100000 ** decimals());
    }

    function decimals() public view virtual override returns (uint8) {
        return 1;
    }
}