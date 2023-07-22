// SPDX-License-Identifier: BSD-3-Clause-Clear

pragma solidity >=0.8.13 <0.9.0;

import "fhevm/lib/TFHE.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract Tokenspire is ERC20, ERC20Burnable, Ownable {
    mapping(address => euint32) internal _encryptedBalances;
    uint256 public startBlock;
    euint32 internal burnRate;
    uint32 public constant MAX_HEIGHT = 10;
    uint32 public constant BASE_HEIGHT = 5;

    constructor() ERC20("Tokenspire", "TSP") {
        _mint(msg.sender, 1000000000 * 10 ** decimals());
        startBlock = block.number;
    }

    function balanceOfEncrypted(address sender, bytes32 publicKey) public view returns (bytes memory) {
        return TFHE.reencrypt(_encryptedBalances[sender], publicKey);
    }

    function updateBurnRate() internal {
        uint256 period = block.number - startBlock;
        uint256 phase = period % 100;
        uint32 rawBurnRate;

        if (phase < 25) {
            rawBurnRate = BASE_HEIGHT + uint32((5 * phase) / 25);
            burnRate = TFHE.asEuint32(rawBurnRate);
        } else if (phase < 50) {
            rawBurnRate = MAX_HEIGHT - uint32((5 * (phase - 25)) / 25);
            burnRate = TFHE.asEuint32(rawBurnRate);
        } else if (phase < 75) {
            rawBurnRate = BASE_HEIGHT - uint32((5 * (phase - 50)) / 25);
            burnRate = TFHE.asEuint32(rawBurnRate);
        } else {
            rawBurnRate = uint32((5 * (phase - 75)) / 25);
            burnRate = TFHE.asEuint32(rawBurnRate);
        }
    }

    function transferEncrypted(address to, bytes calldata encryptedAmount) public {
        _transferEncrypted(to, TFHE.asEuint32(encryptedAmount));
    }

    function _transferEncrypted(address to, euint32 amount) internal {
        updateBurnRate();
    }

    function _transferImple(address from, address to, euint32 amount) internal {}
}
