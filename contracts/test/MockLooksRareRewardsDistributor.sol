// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import {ERC20} from 'solmate/tokens/ERC20.sol';

contract MockLooksRareRewardsDistributor {
    address public immutable routerRewardsDistributor;
    ERC20 immutable looksRareToken;

    constructor(address _routerRewardsDistributor, address _looksRareToken) {
        routerRewardsDistributor = _routerRewardsDistributor;
        looksRareToken = ERC20(_looksRareToken);
    }

    fallback() external {
        looksRareToken.transfer(routerRewardsDistributor, looksRareToken.balanceOf(address(this)));
    }
}
