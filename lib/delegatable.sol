// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract Delegatable is Ownable {

	////////////////////////////////////////////////////////////////////////////////////////////////////
	// CONSTANTS                                                                                      //
	////////////////////////////////////////////////////////////////////////////////////////////////////

	address private constant ZEROADDR = 0x0000000000000000000000000000000000000000;
	uint private constant ZEROINDEX = 0;
 
	////////////////////////////////////////////////////////////////////////////////////////////////////
	// STORAGE                                                                                        //
	////////////////////////////////////////////////////////////////////////////////////////////////////

	// ‘_delegates’ is a list of delegate-accounts.
	//
	// NOTE that the first element in the — ‘_delegates[0]’ — is special.
	// It will always have the value ‘0’.
	// And it will always be ignored.
	address[] private _delegates;

	// ‘_delegateIndex’ is an index — it makes it so we can find a delegate-account in ‘_delegates’ faster.
	// It does this by — rather than having to scan through ‘_delegates’ for an address, we can quickly
	// look it up using ‘_delegateIndex’.
	//
	// NOTE that the key to ‘_delegateIndex’ is:
	//
	//	keccak256(abi.encodePacked(accountAddress))
	mapping(bytes32 => uint) private _delegateIndex;

	////////////////////////////////////////////////////////////////////////////////////////////////////
	// CONSTRUCTOR, FALLBACKS                                                                         //
	////////////////////////////////////////////////////////////////////////////////////////////////////

	constructor() Ownable(_msgSender()) {
		// index zero of _delegates is ignored.
		_delegates.push(ZEROADDR);
	}

	////////////////////////////////////////////////////////////////////////////////////////////////////
	// ERRORS                                                                                         //
	////////////////////////////////////////////////////////////////////////////////////////////////////

	error DelegatableUnauthorizedAccount(address account);

	////////////////////////////////////////////////////////////////////////////////////////////////////
	// EVENTS                                                                                         //
	////////////////////////////////////////////////////////////////////////////////////////////////////

	event DelegateAccountAuthorized(address account);
	event DelegateAccountDeauthorized(address account);

	////////////////////////////////////////////////////////////////////////////////////////////////////
	// MODIFIERS                                                                                      //
	////////////////////////////////////////////////////////////////////////////////////////////////////

	modifier onlyOwnerOrDelegate() {
		_checkOwnerOrDelegate();
		_;
	}

	////////////////////////////////////////////////////////////////////////////////////////////////////
	// PUBLIC FUNCTIONS                                                                               //
	////////////////////////////////////////////////////////////////////////////////////////////////////

	function authorizeDelegateAccount(address account) public onlyOwner {
		require(ZEROADDR != account, "address cannot be zero");

		if (isDelegateAccount(account)) {
			return;
		}

		_delegates.push(account);
		uint index = _delegates.length - 1;

		assert(0 != index);

		bytes32 digest = keccak256(abi.encodePacked(account));
		_delegateIndex[digest] = index;

		emit DelegateAccountAuthorized(account);
	}

	function deauthorizeDelegateAccount(address account) public onlyOwner {
		require(ZEROADDR != account, "address cannot be zero");

		if (!isDelegateAccount(account)) {
			return;
		}

		bytes32 digest = keccak256(abi.encodePacked(account));

		uint index = _delegateIndex[digest];

		assert(index <  _delegates.length);
		assert(0 != index);

		_delegateIndex[digest] = ZEROINDEX;

		uint lastindex = _delegates.length - 1;
		address lastaddress = _delegates[lastindex];

		_delegates.pop();

		assert(1 <= _delegates.length);

		if (index == lastindex) {
			return;
		}

		_delegates[index] = lastaddress;

		bytes32 lastdigest = keccak256(abi.encodePacked(lastaddress));
		_delegateIndex[lastdigest] = index;

		emit DelegateAccountDeauthorized(account);
	}

	////////////////////////////////////////////////////////////////////////////////////////////////////
	// EXTERNAL VIEWS                                                                                 //
	////////////////////////////////////////////////////////////////////////////////////////////////////

	function delegateAccount(uint index) public view returns (address) {
		uint indexinc = 1 + index;

		require(indexinc < _delegates.length, "index out of range");

		return _delegates[indexinc];
	}

	function isDelegateAccount(address account) public view returns (bool) {
		if (ZEROADDR == account) {
			return false;
		}

		bytes32 digest = keccak256(abi.encodePacked(account));

		uint index = _delegateIndex[digest];

		assert(index < _delegates.length);

		return account == _delegates[index];
	}

	function numberOfDelegateAccounts() public view returns (uint256) {
		return _delegates.length - 1;
	}

	////////////////////////////////////////////////////////////////////////////////////////////////////
	// INTERNAL FUNCTIONS                                                                             //
	////////////////////////////////////////////////////////////////////////////////////////////////////

	function _checkOwnerOrDelegate() internal view virtual {
		address sender = _msgSender();

		assert(ZEROADDR != sender);

		if (owner() != sender && !isDelegateAccount(sender)) {
			revert DelegatableUnauthorizedAccount(sender);
		}
	}
}
