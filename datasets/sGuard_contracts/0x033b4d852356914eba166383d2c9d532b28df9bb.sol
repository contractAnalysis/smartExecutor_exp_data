pragma solidity ^0.5.8;


interface IERC20 {
    
    function totalSupply() external view returns (uint256);

    
    function balanceOf(address account) external view returns (uint256);

    
    function transfer(address recipient, uint256 amount) external returns (bool);

    
    function allowance(address owner, address spender) external view returns (uint256);

    
    function approve(address spender, uint256 amount) external returns (bool);

    
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    
    event Transfer(address indexed from, address indexed to, uint256 value);

    
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


library SafeMath {
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        
        
        
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        
        require(b > 0, errorMessage);
        uint256 c = a / b;
        

        return c;
    }

    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


contract ERC20Seller {

    using SafeMath for uint256;

    

    address payable seller; 
    IERC20 public token;    
    uint public divisor;    

    
    struct Order {
        uint price;  
        uint amount; 
    }

    Order[] public orders; 

    

    uint public MAX_ORDERS = 100;   
    uint NO_ORDER_FOUND = uint(-1); 
    uint MAX_VALUE = uint(-1);      

    

    
    event TokenPurchase(address _contributor, uint _amount);

    

    
    constructor(IERC20 _token, uint _divisor) public {
        seller  = msg.sender;
        token   = _token;
        divisor = _divisor;
    }

    

    
    function addOrder(uint _price, uint _amount) external {
        require(msg.sender == seller, "Only the seller can perform this action.");
        require(orders.length < MAX_ORDERS, "The maximum number of orders should not have already been reached.");
        require(token.transferFrom(msg.sender, address(this), _amount));
        orders.push(Order({price: _price, amount: _amount}));
    }

    
    function increaseAmount(uint _orderID, uint _amount) external {
        require(msg.sender == seller, "Only the seller can perform this action.");
        require(token.transferFrom(msg.sender, address(this), _amount));
        orders[_orderID].amount = orders[_orderID].amount.add(_amount);
    }

    
    function decreaseAmount(uint _orderID, uint _amount) external {
        require(msg.sender == seller, "Only the seller can perform this action.");
        uint amountToDecrease = orders[_orderID].amount < _amount ? orders[_orderID].amount : _amount;
        require(token.transfer(seller, amountToDecrease));
        orders[_orderID].amount = orders[_orderID].amount.sub(amountToDecrease);
    }

    
    function removeOrder(uint _orderID) external {
        require(msg.sender == seller, "Only the seller can perform this action.");
        require(token.transfer(seller, orders[_orderID].amount));
        orders[_orderID] = orders[orders.length - 1];
        --orders.length;
    }

    
    function () external payable {
        buy(MAX_VALUE);
    }

    

    
    function buy(uint _maxPrice) public payable {
        uint remainingETH  = msg.value;
        uint cheapestOrder = findCheapestOrder();
        uint tokensBought;

        while(remainingETH!=0 && cheapestOrder!=NO_ORDER_FOUND && orders[cheapestOrder].price<=_maxPrice) { 
            uint fullOrderValue = orders[cheapestOrder].price.mul(orders[cheapestOrder].amount).div(divisor);
            if (fullOrderValue <= remainingETH) { 
                tokensBought = tokensBought.add(orders[cheapestOrder].amount);
                remainingETH = remainingETH.sub(fullOrderValue);
                orders[cheapestOrder].amount = 0;
                cheapestOrder = findCheapestOrder();
            } else { 
                uint amountBought = remainingETH.mul(divisor).div(orders[cheapestOrder].price);
                tokensBought = tokensBought.add(amountBought);
                orders[cheapestOrder].amount = orders[cheapestOrder].amount.sub(amountBought);
                remainingETH = 0;
            }

        }

        require(token.transfer(msg.sender, tokensBought));
        emit TokenPurchase(msg.sender, tokensBought);
        if (remainingETH != 0)
            msg.sender.transfer(remainingETH); 
        seller.transfer(address(this).balance); 
    }


    

    
    function findCheapestOrder() public view returns (uint _orderID) {
        uint bestPrice = MAX_VALUE;
        _orderID = NO_ORDER_FOUND;

        for (uint i = 0; i < orders.length; ++i) {
            if (orders[i].price<bestPrice && orders[i].amount!=0) {
                bestPrice = orders[i].price;
                _orderID = i;
            }
        }
    }

    
    function getOpenOrders() external view returns (uint[] memory orderIDs) {
      uint orderCount = 0;
      for (uint i = 0; i < orders.length; i++) {
        if (orders[i].amount > 0)
          orderCount++;
      }

      orderIDs = new uint[](orderCount);
      uint counter = 0;
      for (uint j = 0; j < orders.length; j++) {
        if (orders[j].amount > 0) {
          orderIDs[counter] = j;
          counter++;
        }
      }
    }
}