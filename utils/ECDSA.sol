// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library ECDSA {

    function toEthSignedMessageHash(bytes32 hash) public pure returns(bytes32){
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
        // return keccak256(abi.encodePacked(bytes1(0x19), bytes1(0x45), "thereum Signed Message:\n32",hash));
    }

    function recoverSigner(bytes32 _msgHash, bytes memory _signature) public pure returns(address) {
        require(_signature.length == 65, "invalid signature length");

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            /*
            前32 bytes存储签名的长度
            add(sig, 32) = sig的指针 + 32
            等效为略过signature的前32 bytes
            mload(p) 载入从内存地址p起始的接下来32 bytes数据
            */
            // 读取长度数据后的32 bytes
            r := mload(add(_signature, 0x20))
            // 读取之后的32 bytes
            s := mload(add(_signature, 0x40))
            // 读取最后一个byte
            v := byte(0, mload(add(_signature, 0x60)))
        }
        return ecrecover(_msgHash, v, r, s);
    }

    function verify(bytes32 _ethMsgHash, bytes memory _signature, address _signer) public pure returns(bool) {
        return recoverSigner(_ethMsgHash, _signature) == _signer;
    }
    
}