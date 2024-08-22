// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../utils/ECDSA.sol";
import "./CrazyEggplant.sol";

contract SignatureNFT is CrazyEggplant{
    address immutable private signer;
    mapping (address => bool) private mintedAddress;

    constructor(address _signer) {
        signer = _signer;
    }

    function getMessageHash(address account, uint256 tokenId) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(account, tokenId));
    }

    function whitelistMint(address account, uint256 tokenId, bytes memory _signature) external {
        bytes32 msgHash = getMessageHash(account, tokenId);
        bytes32 ethMsgHash = ECDSA.toEthSignedMessageHash(msgHash);
        require (ECDSA.recoverSigner(ethMsgHash, _signature) == signer, "invalid signature!");

        require (!mintedAddress[account], "account already minted!");
        mintedAddress[account] = true;
        this.mint(account, tokenId);
    }


}