// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../ERC/ERC721.sol";

contract CrazyEggplant is ERC721{
    uint256 internal MAXNUMBERS = 10000;

    constructor() ERC721("CrazyEggplant", "CEP") {}

    function _baseURI() internal pure override  returns (string memory){
        return "ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/";
    }

    // todo: use multisignature to control this operate
    function mint(address to, uint256 tokenId) external {
        require(tokenId >= 0 && tokenId < MAXNUMBERS, "tokenId out of range!");
        _mint(to, tokenId);
    }

    // todo: use multisignature to control this operate
    function burn(uint256 tokenId) external {
        _burn(tokenId);
    }
}