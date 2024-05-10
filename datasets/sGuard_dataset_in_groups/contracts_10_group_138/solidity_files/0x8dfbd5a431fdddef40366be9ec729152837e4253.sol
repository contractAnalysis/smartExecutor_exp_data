pragma solidity 0.5.12;

interface IERC20Wrapper {
    function totalSupply() external view returns (uint256);
    function balanceOf(address _owner) external view returns (uint256);
    function allowance(address _owner, address _spender) external view returns (uint256);
    function transfer(address _to, uint256 _quantity) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _quantity) external returns (bool);
    function approve(address _spender, uint256 _quantity) external returns (bool);
    function symbol() external view returns (string memory);
}

library ERC20Wrapper {
    function balanceOf(address _token, address _owner) external view returns (uint256) {
        return IERC20Wrapper(_token).balanceOf(_owner);
    }

    function allowance(address _token, address owner, address spender)
        external
        view
        returns (uint256)
    {
        return IERC20Wrapper(_token).allowance(owner, spender);
    }

    function transfer(address _token, address _to, uint256 _quantity) external returns (bool) {
        if (isIssuedToken(_token)) {
            IERC20Wrapper(_token).transfer(_to, _quantity);

            require(checkSuccess(), "ERC20Wrapper.transfer: Bad return value");
            return true;
        } else {
            return IERC20Wrapper(_token).transfer(_to, _quantity);
        }
    }

    function transferFrom(address _token, address _from, address _to, uint256 _quantity)
        external
        returns (bool)
    {
        if (isIssuedToken(_token)) {
            IERC20Wrapper(_token).transferFrom(_from, _to, _quantity);
            
            require(checkSuccess(), "ERC20Wrapper.transferFrom: Bad return value");
            return true;
        } else {
            return IERC20Wrapper(_token).transferFrom(_from, _to, _quantity);
        }
    }

    function approve(address _token, address _spender, uint256 _quantity) external returns (bool) {
        if (isIssuedToken(_token)) {
            IERC20Wrapper(_token).approve(_spender, _quantity);
            
            require(checkSuccess(), "ERC20Wrapper.approve: Bad return value");
            return true;
        } else {
            return IERC20Wrapper(_token).approve(_spender, _quantity);
        }
    }

    function isIssuedToken(address _token) private returns (bool) {
        return (keccak256(abi.encodePacked((IERC20Wrapper(_token).symbol()))) ==
            keccak256(abi.encodePacked(("USDT"))));
    }

    

    
    function checkSuccess() private pure returns (bool) {
        
        uint256 returnValue = 0;

        assembly {
            
            switch returndatasize
                
                case 0x0 {
                    returnValue := 1
                }
                
                case 0x20 {
                    
                    returndatacopy(0x0, 0x0, 0x20)

                    
                    returnValue := mload(0x0)
                }
                
                default {

                }
        }

        
        return returnValue == 1;
    }
}