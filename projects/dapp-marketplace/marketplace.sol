// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract SummerMarketplace {
    struct Product {
        uint256 id;
        string  name;
        uint256 price;
        address payable seller;
        bool    sold;
    }
    mapping(uint256 => Product) public products;
    uint256 public nextId = 1;

    function listProduct(string calldata name, uint256 price) external {
        require(price > 0, "Price must be > 0");
        products[nextId] = Product({
            id:    nextId,
            name:  name,
            price: price,
            seller: payable(msg.sender),
            sold:  false
        });
        nextId++;
    }
	
    function buyProduct(uint256 id) external payable {
        Product storage p = products[id];
		
        require(!p.sold, "Already sold");
        require(msg.value == p.price, "Incorrect price");

        p.sold = true;
		
        p.seller.transfer(msg.value);
    }

    function getProduct(uint256 id) external view returns (string memory name, uint256 price, 
	address seller, bool sold) {
        Product storage p = products[id];
        return (p.name, p.price, p.seller, p.sold);
    }
    function totalProducts() external view returns (uint256) {
        return nextId - 1;
    }

}
