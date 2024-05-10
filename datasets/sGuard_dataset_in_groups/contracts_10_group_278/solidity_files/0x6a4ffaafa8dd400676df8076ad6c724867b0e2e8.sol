pragma solidity ^0.5.12;


contract SwapperLike {
    function fromDaiToBTU(address, uint256) external;
}



contract VatLike {
    function hope(address) external;
}



contract PotLike {
    function chi() external view returns (uint256);
    function rho() external view returns (uint256);
    function dsr() external view returns (uint256);
    function drip() external returns (uint256);
    function join(uint256) external;
    function exit(uint256) external;
}



contract JoinLike {
    function join(address, uint256) external;
    function exit(address, uint256) external;
}



contract ERC20Like {
    function transferFrom(address, address, uint256) external returns (bool);
    function transfer(address, uint256) external returns (bool);
    function approve(address, uint256) external returns (bool);
    function allowance(address, address) external view returns (uint256);
}





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










library RayMath {
    uint256 internal constant ONE_RAY = 10**27;

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        require(c >= a, "Bdai: overflow");

        return c;
    }

    function sub(uint256 a, uint256 b, string memory errMsg)
        internal
        pure
        returns (uint256)
    {
        require(b <= a, errMsg);

        return a - b;
    }

    function subOrZero(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b > a) {
            return uint256(0);
        } else {
            return a - b;
        }
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }

        c = a * b;
        require(c / a == b, "bDai: multiplication overflow");

        return c;
    }

    function rmul(uint256 a, uint256 b) internal pure returns (uint256) {
        return mul(a, b) / ONE_RAY;
    }

    
    function rdiv(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "bDai: division by 0");

        return mul(a, ONE_RAY) / b;
    }

    
    function rdivup(uint256 a, uint256 b) internal pure returns (uint256) {
        return add(mul(a, ONE_RAY), sub(b, 1, "bDai: division by 0")) / b;
    }
}



contract Bdai is IERC20 {
    using RayMath for uint256;

    bool public live;
    uint8 public constant decimals = 18;
    uint256 public totalSupply;

    string public constant name = "BTU Incentivized DAI";
    string public constant symbol = "bDAI";
    string public constant version = "1";

    mapping(address => uint256) private _balances;
    mapping(address => uint256) private _pies;
    mapping(address => uint256) private _nonces;

    mapping(address => mapping(address => uint256)) private _allowances;

    ERC20Like public dai;
    JoinLike public daiJoin;
    PotLike public pot;
    VatLike public vat;
    SwapperLike public swapper;

    address public owner;

    bytes32 public DOMAIN_SEPARATOR; 

    
    bytes32 public constant PERMIT_TYPEHASH = 0xea2aa0a1be11a07ed86d755c93467f4f82362b452371d1ba94d1715123511acb;

    
    bytes32 public constant CLAIM_TYPEHASH = 0xcbd06f2e482e52538ba0a2e3b1ec074c1ff826895448b9cf7b33c0abbbe904b3;

    
    bytes32 public constant EXIT_TYPEHASH = 0x703d2576480f8b8746c2232693aae93ab2bda9c8b68427bce6eff0c6238807ed;

    
    constructor(
        address dai_,
        address daiJoin_,
        address pot_,
        address vat_,
        address swapper_,
        uint256 chainId_
    ) public {
        owner = msg.sender;
        live = true;

        dai = ERC20Like(dai_);
        daiJoin = JoinLike(daiJoin_);
        pot = PotLike(pot_);
        vat = VatLike(vat_);
        swapper = SwapperLike(swapper_);

        vat.hope(daiJoin_);
        vat.hope(pot_);

        dai.approve(daiJoin_, uint256(-1));
        dai.approve(swapper_, uint256(-1));

        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256(bytes(name)),
                keccak256(bytes(version)),
                chainId_,
                address(this)
            )
        );
    }

    
    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    
    function transfer(address recipient, uint256 amount)
        external
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    
    function pieOf(address account) external view returns (uint256) {
        return _pies[account];
    }

    
    function chi() external view returns (uint256) {
        return pot.chi();
    }

    
    function rho() external view returns (uint256) {
        return pot.rho();
    }

    
    function dsr() external view returns (uint256) {
        return pot.dsr();
    }

    
    function allowance(address tokenOwner, address spender)
        external
        view
        returns (uint256)
    {
        return _allowances[tokenOwner][spender];
    }

    
    function approve(address spender, uint256 amount) external returns (bool) {
        require(spender != address(0), "Bdai: approve to 0x0");

        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);

        return true;
    }

    
    function transferFrom(address sender, address recipient, uint256 amount)
        external
        returns (bool)
    {
        _allow(sender, msg.sender, amount);
        _transfer(sender, recipient, amount);

        return true;
    }

    
    function join(uint256 amount) external {
        _join(msg.sender, amount);
    }

    
    function joinFor(address dest, uint256 amount) external {
        require(dest != address(0), "bDai: dest cannot be 0x0");
        _join(dest, amount);
    }

    
    function claim() external {
        _claim(msg.sender, msg.sender);
    }

    
    function claim(address dest) external {
        require(dest != address(0), "bDai: dest cannot be 0x0");
        _claim(msg.sender, dest);
    }

    
    function exit(uint256 amount) external {
        _exit(msg.sender, amount);
    }

    
    function transfer(address[] memory recipients, uint256[] memory amounts)
        public
        returns (bool)
    {
        _transfer(msg.sender, recipients, amounts);
        return true;
    }

    
    function transferFrom(
        address sender,
        address[] memory recipients,
        uint256[] memory amounts
    ) public returns (bool) {
        uint256 total;

        for (uint256 i; i < recipients.length; ++i) {
            total = total.add(amounts[i]);
        }

        _allow(sender, msg.sender, total);
        _transfer(sender, recipients, amounts);

        return true;
    }

    
    function nonces(address account) external view returns (uint256) {
        return _nonces[account];
    }

    
    function permit(
        address holder,
        address spender,
        uint256 nonce,
        uint256 expiry,
        bool allowed,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        require(holder != address(0), "bDai: approve from 0x0");
        require(spender != address(0), "bDai: approve to 0x0");
        require(expiry == 0 || now <= expiry, "bDai: permit-expired");
        require(nonce == _nonces[holder]++, "bDai: invalid-nonce");

        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(
                    abi.encode(
                        PERMIT_TYPEHASH,
                        holder,
                        spender,
                        nonce,
                        expiry,
                        allowed
                    )
                )
            )
        );

        require(holder == ecrecover(digest, v, r, s), "bDai: invalid-permit");
        uint256 amount = allowed ? uint256(-1) : 0;
        _allowances[holder][spender] = amount;
        emit Approval(holder, spender, amount);
    }

    
    function claimFor(
        address holder,
        uint256 nonce,
        uint256 expiry,
        address dest,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        require(dest != address(0), "bDai: dest cannot be 0x0");
        require(holder != address(0), "bDai: claim from 0x0");
        require(expiry == 0 || now <= expiry, "bDai: permit-expired");
        require(nonce == _nonces[holder]++, "bDai: invalid-nonce");

        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(
                    abi.encode(
                        CLAIM_TYPEHASH,
                        holder,
                        msg.sender,
                        nonce,
                        expiry,
                        dest
                    )
                )
            )
        );

        require(holder == ecrecover(digest, v, r, s), "bDai: invalid-permit");
        _claim(holder, dest);
    }

    
    function exitFor(
        address holder,
        uint256 nonce,
        uint256 expiry,
        uint256 amount,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        require(holder != address(0), "bDai: exit from 0x0");
        require(expiry == 0 || now <= expiry, "bDai: permit-expired");
        require(nonce == _nonces[holder]++, "bDai: invalid-nonce");

        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(
                    abi.encode(
                        EXIT_TYPEHASH,
                        holder,
                        msg.sender,
                        nonce,
                        expiry,
                        amount
                    )
                )
            )
        );

        require(holder == ecrecover(digest, v, r, s), "bDai: invalid-permit");
        _exit(holder, amount);
    }

    
    modifier onlyOwner() {
        require(msg.sender == owner, "bDai: op not allowed");
        _;
    }

    
    function setOwner(address owner_) external onlyOwner {
        require(owner_ != address(0), "bDai: owner cannot be 0x0");
        owner = owner_;
    }

    
    function freeze(bool freeze_) external onlyOwner {
        live = !freeze_;
    }

    
    function setSwapper(address swapper_) external onlyOwner {
        require(swapper_ != address(0), "bDai: cannot set to 0x0");
        address oldSwapper = address(swapper);
        swapper = SwapperLike(swapper_);

        dai.approve(oldSwapper, uint256(0));
        dai.approve(swapper_, uint256(-1));
    }

    
    function _chi() internal returns (uint256) {
        return now > pot.rho() ? pot.drip() : pot.chi();
    }

    
    function _allow(address sender, address caller, uint256 amount) internal {
        uint256 a = _allowances[sender][caller];
        require(a > 0, "bDAI: bad allowance");
        if (a != uint256(-1)) {
            _allowances[sender][caller] = a.sub(amount, "bDAI: bad allowance");
            emit Approval(sender, caller, _allowances[sender][caller]);
        }
    }

    
    function _transfer(address sender, address recipient, uint256 amount)
        internal
    {
        require(sender != address(0), "Bdai: transfer from 0x0");
        require(recipient != address(0), "Bdai: transfer to 0x0");

        uint256 c = _chi();
        uint256 senderBalance = _balances[sender];
        uint256 oldSenderPie = _pies[sender];
        uint256 tmp = senderBalance.rdivup(c); 
        uint256 pieToClaim = oldSenderPie.subOrZero(tmp);
        uint256 pieToBeTransfered = amount.rdivup(c);

        _balances[sender] = senderBalance.sub(
            amount,
            "bDai: not enougth funds"
        );
        _balances[recipient] = _balances[recipient].add(amount);

        tmp = pieToClaim.add(pieToBeTransfered);
        if (tmp > oldSenderPie) {
            _pies[sender] = 0;
            _pies[recipient] = _pies[recipient].add(oldSenderPie);
        } else {
            _pies[sender] = oldSenderPie - tmp;
            _pies[recipient] = _pies[recipient].add(pieToBeTransfered);
        }

        if (pieToClaim > 0) {
            uint256 claimedToken = pieToClaim.rmul(c);

            pot.exit(pieToClaim);
            daiJoin.exit(address(this), claimedToken);
            swapper.fromDaiToBTU(sender, claimedToken);
        }

        emit Transfer(sender, recipient, amount);
    }

    
    function _transfer(
        address sender,
        address[] memory recipients,
        uint256[] memory amounts
    ) internal {
        require(sender != address(0), "Bdai: transfer from 0x0");

        uint256 c = _chi();
        uint256 senderBalance = _balances[sender];
        uint256 oldSenderPie = _pies[sender];
        uint256 tmp = senderBalance.rdivup(c); 
        uint256 pieToClaim = oldSenderPie.subOrZero(tmp);
        uint256 pieToBeTransfered;

        uint256 total;
        uint256 totalPie = oldSenderPie;
        for (uint256 i; i < recipients.length; ++i) {
            require(recipients[i] != address(0), "Bdai: transfer to 0x0");
            total = total.add(amounts[i]);

            pieToBeTransfered = amounts[i].rdivup(c);
            _balances[recipients[i]] = _balances[recipients[i]].add(amounts[i]);

            tmp = pieToClaim.add(pieToBeTransfered);
            if (tmp > oldSenderPie) {
                totalPie = 0;
                _pies[recipients[i]] = _pies[recipients[i]].add(oldSenderPie);
            } else {
                totalPie = oldSenderPie - tmp;
                _pies[recipients[i]] = _pies[recipients[i]].add(
                    pieToBeTransfered
                );
            }

            emit Transfer(sender, recipients[i], amounts[i]);
        }

        _balances[sender] = senderBalance.sub(total, "bDai: not enougth funds");
        _pies[sender] = totalPie;

        if (pieToClaim > 0) {
            uint256 claimedToken = pieToClaim.rmul(c);

            pot.exit(pieToClaim);
            daiJoin.exit(address(this), claimedToken);
            swapper.fromDaiToBTU(sender, claimedToken);
        }
    }

    
    function _join(address dest, uint256 amount) internal {
        require(live, "bDai: system is frozen");

        uint256 c = _chi();
        uint256 pie = amount.rdiv(c);

        totalSupply = totalSupply.add(amount);
        _balances[dest] = _balances[dest].add(amount);
        _pies[dest] = _pies[dest].add(pie);

        dai.transferFrom(msg.sender, address(this), amount);
        daiJoin.join(address(this), amount);
        pot.join(pie);

        emit Transfer(address(0), dest, amount);
    }

    
    function _claim(address account, address dest) internal {
        uint256 c = _chi();
        uint256 newPie = _balances[account].rdivup(c);
        uint256 pieDiff = _pies[account].subOrZero(newPie);

        if (pieDiff > 0) {
            uint256 exitedTokens = pieDiff.rmul(c);
            _pies[account] = newPie;

            pot.exit(pieDiff);
            daiJoin.exit(address(this), exitedTokens);
            swapper.fromDaiToBTU(dest, exitedTokens);
        }
    }

    
    function _exit(address account, uint256 amount) internal {
        require(amount > 0, "bDai : zero amount");

        uint256 c = _chi();
        uint256 bal2 = _balances[account].sub(
            amount,
            "bDai: not enougth funds"
        );
        uint256 pie2 = bal2.rdiv(c);
        uint256 pieDiff = _pies[account].sub(pie2, "bDai: not enougth funds");
        uint256 totalDai = pieDiff.rmul(c);
        uint256 interestToken = totalDai.subOrZero(amount);

        _balances[account] = bal2;
        totalSupply = totalSupply.sub(amount, "bDai: totalSupply underflow");
        _pies[account] = pie2;

        pot.exit(pieDiff);
        daiJoin.exit(address(this), totalDai);
        dai.transfer(account, amount);

        if (interestToken > 0) {
            swapper.fromDaiToBTU(account, interestToken);
        }

        emit Transfer(account, address(0), amount);
    }
}