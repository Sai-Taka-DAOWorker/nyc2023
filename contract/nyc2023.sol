// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts@4.8.0/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts@4.8.0/access/Ownable.sol";
import "@openzeppelin/contracts@4.8.0/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts@4.8.0/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract WagmiErc1155 is ERC1155, Ownable, ERC1155Burnable, ERC1155Supply {
		
	string public constant name = "Wagumi 2023 New Year's Card";
    string public constant symbol = "W23NYC";
    address[] mintErrorAddrs;

    mapping(address => bool) private _isMint;

    string private prefix;
    string private suffix;

		error mintedAdderess(address[] to);
    
    constructor(string memory prefix_, string memory suffix_) ERC1155("") {
	    prefix = prefix_;
	    suffix = suffix_;
    }

    function setPrefix(string memory newPrefix) external onlyOwner {
	    prefix = newPrefix;
    }

    function setSuffix(string memory newSuffix) external onlyOwner {
	    suffix = newSuffix;
    }

    function uri(uint256 tokenId) public view virtual override returns(string memory) {
	    return string(abi.encodePacked(prefix, Strings.toString(tokenId), suffix));
    }

    function mint(address[] memory accounts, uint256 id, bytes memory data)
        public
        onlyOwner
    {
        uint256 amount = 1;
        address[] memory tempAddr = new address[](0);
        mintErrorAddrs = tempAddr;
        for (uint256 i = 0; i < accounts.length; ++i) {
            address to = accounts[i];
            if(_isMint[to] == false) {
                _isMint[to] = true;
                _mint(to, id, amount, data);
            } else {
                mintErrorAddrs.push(to);
            }
        }
        if(mintErrorAddrs.length > 0) {
            revert mintedAdderess(mintErrorAddrs);
        }
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {
        revert("Nobody can list the SBT on the marketplace");
    }

    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        override(ERC1155, ERC1155Supply)
    {
        require(from == address(0) || to == address(0), "cannot send to any one");
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }
}