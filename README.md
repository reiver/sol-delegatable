# sol-delegatable

`Delegatable` is a contract-module which provides a basic access-control mechanism where there are one or more accounts (an owner plus zero or more delegates) that can be granted exclusive access to specific functions, for the Solidity programming language.

This contract-module in used through inheritance.

## Examples

Here is an example usage of `Delegatable`:

```solidity
import "@reiver/delegatable/delegatable.sol";

contract MyContract is Delegatable {

	// ...

	function myFunction() public onlyOwnerOrDelegate {
		// ...
	}

	// ...
}
```

## Installation

To install using `forge` do the following:

```
forge install https://github.com/reiver/sol-delegatable
```

And then append the following to your `remappings.txt` file:

```
@reiver/delegatable/=lib/sol-delegatable/lib/
```

## Import

To import use `import` code like the follownig:
```
import "@reiver/delegatable/delegatable.sol";
```

## Author

Package **delegatable** was written by [Charles Iliya Krempeaux](http://reiver.link)
