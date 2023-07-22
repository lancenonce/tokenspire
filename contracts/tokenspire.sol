// SPDX-License-Identifier: BSD-3-Clause-Clear

pragma solidity >=0.8.13 <0.9.0;

import "fhevm/lib/TFHE.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract Tokenspire is ERC20, ERC20Burnable, Ownable {
    mapping(address => euint32) internal _encryptedBalances;

    constructor() ERC20("Tokenspire", "TSP") {
        _mint(msg.sender, 1000000000 * 10 ** decimals());
    }

    function balanceOfEncrypted(address sender, bytes32 publicKey) public view returns (bytes memory) {
        return TFHE.reencrypt(_encryptedBalances[sender], publicKey);
    }

    euint32 private counter;

    function add(bytes calldata encryptedValue) public {
        euint32 value = TFHE.asEuint32(encryptedValue);
        counter = TFHE.add(counter, value);
    }

    function getCounter(bytes32 publicKey) public view returns (bytes memory) {
        return TFHE.reencrypt(counter, publicKey);
    }
}
