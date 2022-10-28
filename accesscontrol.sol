// SPDX-License-Identifier: UNLICENSED
// defines what solidity version you're using
pragma solidity ^0.8.0;

// role based access control
contract AccessControl {
    // indexed to quickly log through the logs
    event GrantRole(bytes32 indexed role, address indexed account);
    event RevokeRole(bytes32 indexed role, address indexed account);
    /** 
    *   @dev access control
    *   role => account => bool
    *
    *   why defined role as bytes32 and not as a string?
    *   hash the name of the role bc even if the name of the role is a long string,
    *   it still hashes 32 bytes and we'll save some gas
    **/
    mapping(bytes32 => mapping(address => bool)) public roles;

    // defines 'admin' and 'user' roles, constants named in capital
    // to complete the hash temporary public and once you have the hash back to private
    // 0xdf8b4c520ffe197c5343c6f5aec59570151ef9a492f2c624fd45ddde6135ec42
    bytes32 private constant ADMIN = keccak256(abi.encodePacked("ADMIN"));

    modifier onlyRole(bytes32 _role) {
        require(roles[_role][msg.sender], "not authorized");
        _;
    }

    // makes sure that the admin role is granted to the msg.sender (deployer?)
    // so deployer will be able to call the function grantRole to give roles to other accounts
    constructor() {
        _grantRole(ADMIN, msg.sender);
    }

    // fuction to grant the role to the deployer of the contract
    // internal so it can be called when inherit
    function _grantRole(bytes32 _role, address _account) internal {
        // updates role mapping, grants role to an account
        roles[_role][_account] = true;
        emit GrantRole(_role, _account);
    }

    // external because only admins should be able to call this function
    // onlyRole(ADMIN) function modifier makes sure it can only be called by the admin role
    function grantRole(bytes32 _role, address _account) external onlyRole(ADMIN) {
        _grantRole(_role, _account);
    }

    // allows admins to revoke roles
    function revokeRole(bytes32 _role, address _account) external onlyRole(ADMIN) {
        roles[_role][_account] = false;
        emit RevokeRole(_role, _account);
    }
}
