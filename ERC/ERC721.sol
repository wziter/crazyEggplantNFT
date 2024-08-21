// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./IERC165.sol";
import "./IERC721.sol";
import "./IERC721Metadata.sol";
import "./IERC721Enumerable.sol";
import "./IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract ERC721 is IERC165, IERC721, IERC721Receiver, IERC721Metadata{
    using Strings for uint256;

    mapping (address owner => uint256 tokenAmount) private _balances;
    mapping (uint256 tokenId => address owner) private _owners;
    mapping (uint256 tokenId => address approval) private _tokenApprovals;
    mapping (address owner => mapping(address approval => bool)) private _operatorApprovals;

    string private _name;
    string private _symbol;

    error AddressNotOwnerOrApproval(address _addr);
    event LogonERC721Received(address opeartor, address from, uint256 tokenId, bytes data);
    event LogMint(address owner, uint256 tokenId);
    event LogBurn(address owner, uint256 tokenId);
    
    constructor(string memory cname, string memory csymbol) {
        _name = cname;
        _symbol = csymbol;
    }

    // implement IERC165
    function supportsInterface(bytes4 interfaceID) external pure override 
    returns (bool) {
        return 
            interfaceID == type(IERC165).interfaceId || 
            interfaceID == type(IERC721).interfaceId ||
            interfaceID == type(IERC721Metadata).interfaceId ||
            interfaceID == type(IERC721Enumerable).interfaceId;
    }

    // implement IERC721Receiver
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes calldata _data) external returns(bytes4) {
        require(_operator != address(0), "operator is zero address!");
        require(_from != address(0), "from is zero address!");
        emit LogonERC721Received(_operator, _from, _tokenId, _data);
        return this.onERC721Received.selector;
    }

    // implment IERC721
    function balanceOf(address _owner) external view override returns (uint256) {
        require(_owner != address(0), "zero owner address!");
        return _balances[_owner];
    }

    function ownerOf(uint256 _tokenId) external view override returns (address) {
        require(_owners[_tokenId] != address(0), "zero tokenOwner address!");
        return _owners[_tokenId];
    }

    function getApproved(uint256 _tokenId) external view override returns (address) {
        require(_tokenApprovals[_tokenId] != address(0), "token approvals zero address!");
        return _tokenApprovals[_tokenId];
    }

    function isApprovedForAll(address _owner, address _operator) external view override returns (bool) {
        return _operatorApprovals[_owner][_operator];
    }

    function approve(address _approved, uint256 _tokenId) external payable {
        require(_approved != address(0));
        address owner = this.ownerOf(_tokenId);
        if (!(msg.sender == owner || this.isApprovedForAll(owner, msg.sender))) {
            revert AddressNotOwnerOrApproval(msg.sender);
        }

        _tokenApprovals[_tokenId] = _approved;
        emit Approval(owner, _approved, _tokenId);
    }

    function setApprovalForAll(address _operator, bool _approved) external {
        require(_operator != address(0), "operator is zero address");
        _operatorApprovals[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) external override payable {
        address owner = this.ownerOf(_tokenId);
        if (!(
            owner == msg.sender || 
            this.isApprovedForAll(owner, msg.sender) ||
            this.getApproved(_tokenId) == msg.sender)) {
                revert AddressNotOwnerOrApproval(msg.sender);
        }
        require(_from == owner, "from address not owner!");
        require(_to != address(0), "to address is zero!");

        delete _tokenApprovals[_tokenId];
        _balances[_from] -= 1;
        _balances[_to] += 1;
        _owners[_tokenId] = _to;
        emit Transfer(_from, _to, _tokenId);
    }

    function safeTransferFrom(
        address _from, 
        address _to, 
        uint256 _tokenId, 
        bytes calldata data) 
        external override  payable 
    {
        address owner = this.ownerOf(_tokenId);
        if (_to.code.length > 0) {
            require(this.onERC721Received(msg.sender, owner, _tokenId, data) == 
            IERC721Receiver.onERC721Received.selector, "onERC721Received not implement!");
        }

        this.transferFrom(_from, _to, _tokenId);
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external override payable {
        this.safeTransferFrom(_from, _to, _tokenId, "");
    }

    // implement IERC721Metadata
    function name() external view override returns (string memory) {
        return _name;
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function tokenURI(uint256 _tokenId) external view override returns (string memory) {
        require (_owners[_tokenId] != address(0), "Token Not Exist!");
        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, _tokenId.toString())) : "";
    }
    function _baseURI() internal pure virtual returns (string memory){
        return "";
    }

    function _mint(address to, uint256 tokenId) internal{
        require(to != address(0), "mint address can not be zero!");
        require(_owners[tokenId] == address(0), "token already minted");

        _balances[to] += 1;
        _owners[tokenId] = to;
        emit LogMint(to, tokenId);
    }

    function _burn(uint256 tokenId) internal {
        address owner = this.ownerOf(tokenId);
        require(owner != msg.sender, "msgSender not owner, can not burn!");
        require(_balances[owner] > 0, "balance not big than zero!");

        delete _tokenApprovals[tokenId];
        _balances[owner] -= 1;
        delete _owners[tokenId];
        emit LogBurn(owner, tokenId);
    }

}