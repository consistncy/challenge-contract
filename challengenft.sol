// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "./accesscontrol.sol";

contract ChallengeNFT is ERC721, IERC2981, AccessControl {
    bool public paused;

    uint256 public saleTimestamp;
    uint256 public totalSupply;

    uint256 public maxSupply = 1000;
    uint256 private mintLength = [86400, 172800];
    uint256 public mintPrice = [0.01 ether, 0.03 ether];

    bool public privateMintActive;
    bool public publicMintActive;

    mapping(address => uint256) public mintedWallets;

    constructor() payable ERC721('ChallengeNFT', 'CHALLENGE') {}

    // ADMIN FUNCTIONS //

    function setPaused(bool _paused) public {
        require(msg.sender == onlyRole(ADMIN), "You are not the owner");
        paused = _paused;
    }

    function toggleIsMintEnabled() external onlyRole(ADMIN) {
        isMintEnabled = !isMintEnabled;
    }

    function setMaxSupply(uint256 maxSupply_) external onlyRole(ADMIN){
        maxSupply = maxSupply_;
    }

    // PUBLIC FUNCTIONS //

    function privateMint() public payable {
        // limits mints per wallet
        require(mintedWallets[msg.sender] < 2, "exceeds max per wallet");
        internalMint();
    }

    function publicMint() external payable {
        // limits mints per wallet
        require(mintedWallets[msg.sender] < 5, "exceeds max per wallet");
        internalMint();
    }

    function internalMint() internal {
        require(isMintEnabled, "minting not enabled");
        require(msg.value == mintPrice, "wrong value");
        require(maxSupply > totalSupply, "sold out");

        mintedWallets[msg.sender]++;
        totalSupply++;
        uint256 tokenId = totalSupply;
        _safeMint(msg.sender, tokenId);
    }

    // METADATA & MISC FUNCTIONS // 

        function _baseURI() internal view override returns (string memory) {
        // 1 day == 86400 seconds
        uint256 r = block.timestamp % (86400 * 3);
        
        if (r < 86400) {
            return "https://api.dayone.com/";
        } else if (r > 86400 && r <= 172800) {
            return "https://api.daytwo.com/";
        } else {
            return "https://api.daythree.com/";
        }
    }

    // sets royalty
    function setDefaultRoyalty(address receiver, uint96 feeNumerator) external onlyRole(ADMIN) {
        _setDefaultRoyalty(receiver, feeNumerator);
    }

    // deletes royalty
    function deleteDefaultRoyalty() external onlyRole(ADMIN) {
        _deleteDefaultRoyalty();
    }

    function royaltyInfo(
        uint256 _tokenId, 
        address receiver, 
        uint96 feeNumerator
        ) external view onlyRole(ADMIN) {
            _setTokenRoyalty(tokenId, receiver, feeNumerator);
    }

    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}
