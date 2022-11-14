// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import '../modules/uniswap/v2/V2SwapRouter.sol';
import '../modules/uniswap/v3/V3SwapRouter.sol';
import '../modules/Payments.sol';
import '../base/RouterCallbacks.sol';
import '../libraries/Commands.sol';
import '../libraries/Recipient.sol';
import {ERC721} from 'solmate/tokens/ERC721.sol';
import {ERC1155} from 'solmate/tokens/ERC1155.sol';
import {ICryptoPunksMarket} from '../interfaces/external/ICryptoPunksMarket.sol';
import 'permit2/src/interfaces/IAllowanceTransfer.sol';

contract Dispatcher is V2SwapRouter, V3SwapRouter, RouterCallbacks {
    using Recipient for address;

    error InvalidCommandType(uint256 commandType);
    error InvalidOwnerERC721();
    error InvalidOwnerERC1155();

    constructor(
        address permit2,
        address v2Factory,
        address v3Factory,
        bytes32 pairInitCodeHash,
        bytes32 poolInitCodeHash
    ) V2SwapRouter(v2Factory, pairInitCodeHash, permit2) V3SwapRouter(v3Factory, poolInitCodeHash) {}

    /// @notice executes the given command with the given inputs
    /// @param command The command to execute
    /// @param inputs The inputs to execute the command with
    /// @return success true on success, false on failure
    /// @return output The outputs, if any from the command
    function dispatch(uint256 command, bytes memory inputs) internal returns (bool success, bytes memory output) {
        success = true;
        if (command == Commands.PERMIT2_PERMIT) {
            (IAllowanceTransfer.PermitSingle memory permitSingle, bytes memory data) =
                abi.decode(inputs, (IAllowanceTransfer.PermitSingle, bytes));
            IAllowanceTransfer(PERMIT2).permit(msg.sender, permitSingle, data);
        } else if (command == Commands.PERMIT2_PERMIT_BATCH) {
            (IAllowanceTransfer.PermitBatch memory permitBatch, bytes memory data) =
                abi.decode(inputs, (IAllowanceTransfer.PermitBatch, bytes));
            IAllowanceTransfer(PERMIT2).permit(msg.sender, permitBatch, data);
        } else if (command == Commands.PERMIT2_TRANSFER_FROM) {
            (address token, address recipient, uint160 amount) = abi.decode(inputs, (address, address, uint160));
            permit2TransferFrom(token, msg.sender, recipient, amount);
        } else if (command == Commands.TRANSFER) {
            (address token, address recipient, uint256 value) = abi.decode(inputs, (address, address, uint256));
            Payments.pay(token, recipient.map(), value);
        } else if (command == Commands.V2_SWAP_EXACT_IN) {
            (uint256 amountIn, uint256 amountOutMin, address[] memory path, address recipient, bool payerIsUser) =
                abi.decode(inputs, (uint256, uint256, address[], address, bool));
            address payer = payerIsUser ? msg.sender : address(this);
            v2SwapExactInput(amountIn, amountOutMin, path, recipient.map(), payer);
        } else if (command == Commands.V2_SWAP_EXACT_OUT) {
            (uint256 amountOut, uint256 amountInMax, address[] memory path, address recipient, bool payerIsUser) =
                abi.decode(inputs, (uint256, uint256, address[], address, bool));
            address payer = payerIsUser ? msg.sender : address(this);
            v2SwapExactOutput(amountOut, amountInMax, path, recipient.map(), payer);
        } else if (command == Commands.V3_SWAP_EXACT_IN) {
            (address recipient, uint256 amountIn, uint256 amountOutMin, bytes memory path, bool payerIsUser) =
                abi.decode(inputs, (address, uint256, uint256, bytes, bool));
            address payer = payerIsUser ? msg.sender : address(this);
            v3SwapExactInput(recipient.map(), amountIn, amountOutMin, path, payer);
        } else if (command == Commands.V3_SWAP_EXACT_OUT) {
            (address recipient, uint256 amountOut, uint256 amountInMax, bytes memory path, bool payerIsUser) =
                abi.decode(inputs, (address, uint256, uint256, bytes, bool));
            address payer = payerIsUser ? msg.sender : address(this);
            v3SwapExactOutput(recipient.map(), amountOut, amountInMax, path, payer);
        } else if (command == Commands.SEAPORT) {
            (uint256 value, bytes memory data) = abi.decode(inputs, (uint256, bytes));
            (success, output) = Constants.SEAPORT.call{value: value}(data);
        } else if (command == Commands.NFTX) {
            (uint256 value, bytes memory data) = abi.decode(inputs, (uint256, bytes));
            (success, output) = Constants.NFTX_ZAP.call{value: value}(data);
        } else if (command == Commands.LOOKS_RARE_721) {
            (success, output) = callAndTransfer721(inputs, Constants.LOOKS_RARE);
        } else if (command == Commands.X2Y2_721) {
            (success, output) = callAndTransfer721(inputs, Constants.X2Y2);
        } else if (command == Commands.LOOKS_RARE_1155) {
            (success, output) = callAndTransfer1155(inputs, Constants.LOOKS_RARE);
        } else if (command == Commands.X2Y2_1155) {
            (success, output) = callAndTransfer1155(inputs, Constants.X2Y2);
        } else if (command == Commands.FOUNDATION) {
            (success, output) = callAndTransfer721(inputs, Constants.FOUNDATION);
        } else if (command == Commands.SUDOSWAP) {
            (uint256 value, bytes memory data) = abi.decode(inputs, (uint256, bytes));
            (success, output) = Constants.SUDOSWAP.call{value: value}(data);
        } else if (command == Commands.NFT20) {
            (uint256 value, bytes memory data) = abi.decode(inputs, (uint256, bytes));
            (success, output) = Constants.NFT20_ZAP.call{value: value}(data);
        } else if (command == Commands.CRYPTOPUNKS) {
            (uint256 punkId, address recipient, uint256 value) = abi.decode(inputs, (uint256, address, uint256));
            (success, output) = Constants.CRYPTOPUNKS.call{value: value}(
                abi.encodeWithSelector(ICryptoPunksMarket.buyPunk.selector, punkId)
            );
            if (success) ICryptoPunksMarket(Constants.CRYPTOPUNKS).transferPunk(recipient.map(), punkId);
            else output = 'CryptoPunk Trade Failed';
        } else if (command == Commands.SWEEP) {
            (address token, address recipient, uint256 amountMin) = abi.decode(inputs, (address, address, uint256));
            Payments.sweep(token, recipient.map(), amountMin);
        } else if (command == Commands.SWEEP_ERC721) {
            (address token, address recipient, uint256 id) = abi.decode(inputs, (address, address, uint256));
            Payments.sweepERC721(token, recipient.map(), id);
        } else if (command == Commands.SWEEP_ERC1155) {
            (address token, address recipient, uint256 id, uint256 amount) =
                abi.decode(inputs, (address, address, uint256, uint256));
            Payments.sweepERC1155(token, recipient.map(), id, amount);
        } else if (command == Commands.WRAP_ETH) {
            (address recipient, uint256 amountMin) = abi.decode(inputs, (address, uint256));
            Payments.wrapETH(recipient.map(), amountMin);
        } else if (command == Commands.UNWRAP_WETH) {
            (address recipient, uint256 amountMin) = abi.decode(inputs, (address, uint256));
            Payments.unwrapWETH9(recipient.map(), amountMin);
        } else if (command == Commands.PAY_PORTION) {
            (address token, address recipient, uint256 bips) = abi.decode(inputs, (address, address, uint256));
            Payments.payPortion(token, recipient.map(), bips);
        } else if (command == Commands.OWNERSHIP_CHECK_721) {
            (address owner, address token, uint256 id) = abi.decode(inputs, (address, address, uint256));
            success = (ERC721(token).ownerOf(id) == owner);
            if (!success) output = abi.encodeWithSignature('InvalidOwnerERC721()');
        } else if (command == Commands.OWNERSHIP_CHECK_1155) {
            (address owner, address token, uint256 id, uint256 minBalance) =
                abi.decode(inputs, (address, address, uint256, uint256));
            success = (ERC1155(token).balanceOf(owner, id) >= minBalance);
            if (!success) output = abi.encodeWithSignature('InvalidOwnerERC1155()');
        } else {
            revert InvalidCommandType(command);
        }
    }

    function callAndTransfer721(bytes memory inputs, address protocol)
        internal
        returns (bool success, bytes memory output)
    {
        (uint256 value, bytes memory data, address recipient, address token, uint256 id) =
            abi.decode(inputs, (uint256, bytes, address, address, uint256));
        (success, output) = protocol.call{value: value}(data);
        if (success) ERC721(token).safeTransferFrom(address(this), recipient.map(), id);
    }

    function callAndTransfer1155(bytes memory inputs, address protocol)
        internal
        returns (bool success, bytes memory output)
    {
        (uint256 value, bytes memory data, address recipient, address token, uint256 id, uint256 amount) =
            abi.decode(inputs, (uint256, bytes, address, address, uint256, uint256));
        (success, output) = protocol.call{value: value}(data);
        if (success) ERC1155(token).safeTransferFrom(address(this), recipient.map(), id, amount, new bytes(0));
    }
}
