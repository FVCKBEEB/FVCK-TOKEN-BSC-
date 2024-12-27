/*
______  _   _  _____  _   __  _____  _____   ___  ___  ______  ___ _____ ______ 
|  ___|| | | |/  __ \| | / / /  ___|/  __ \ / _ \ |  \/  ||  \/  ||  ___|| ___ \
| |_   | | | || /  \/| |/ /  \ `--. | /  \// /_\ \| .  . || .  . || |__  | |_/ /
|  _|  | | | || |    |    \   `--. \| |    |  _  || |\/| || |\/| ||  __| |    / 
| |    \ \_/ /| \__/\| |\  \ /\__/ /| \__/\| | | || |  | || |  | || |___ | |\ \ 
\_|     \___/  \____/\_| \_/ \____/  \____/\_| |_/\_|  |_/\_|  |_/\____/ \_| \_|

💢🤬 The FVCK Ecosystem was created for investors who hate scammers, offering innovative 
tools that allow anonymous reporting with irrefutable proof of fraud in the market. 
FVCK is a memecoin with real utility, bringing a revolution in security and transparency 
to the crypto market. 

🔗 Website: https://fvckbeeb.com
🚀 Group: https://t.me/FVCKBEEB_US
🦖 DinoBlock0x(DEV): https://t.me/DinoBlock0x 

🫂 Based Team
🔒 Safe & Transparent
🔥 Deflationary Token 
🏦 Token Meme Utility
🌟 Engaged Community 
🌍 Decentralized Autonomous Organization (DAO)

Part of our ecosystem:
🧷 Space ID. Project wallet addresses identified. 
⚖️ Snapshot. DAO management system. 
🔑 Safe.Global. Multi-signature wallet.

*/
// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

interface IWbnb {
    function deposit() external payable;
}

interface IUniswapV2Pair {
    function mint(address to) external returns (uint liquidity);
    function sync() external;
}

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}

// Interface do router com addLiquidity definida
interface IUniswapV2Router02 is IUniswapV2Router01 {

    function getAmountsOut(uint256 amountIn, address[] memory path)
        external
        view
        returns (uint256[] memory amounts);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function decimals() external view returns (uint8);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
       _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
       return _owner;
    }

    modifier onlyOwner() {
       require(owner() == _msgSender(), "Ownable: caller is not the owner");
       _;
    }

    function renounceOwnership() public virtual onlyOwner {
       _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
       require(newOwner != address(0), "Ownable: new owner is the zero address");
       _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
       address oldOwner = _owner;
       _owner = newOwner;
       emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract ERC20 is Context, IERC20 {
    mapping (address => uint256) internal _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner_, address indexed spender, uint256 value);

    constructor (string memory name_, string memory symbol_) {
       _name = name_;
       _symbol = symbol_;
    }

    function decimals() public pure override returns (uint8) {
       return 18;
    }

    function name() public view returns (string memory) {
       return _name;
    }

    function symbol() public view returns (string memory) {
       return _symbol;
    }

    function totalSupply() public view override returns (uint256) {
       return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
       return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
       _transfer(_msgSender(), recipient, amount);
       return true;
    }

    function allowance(address owner_, address spender) public view override returns (uint256) {
       return _allowances[owner_][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
       _approve(_msgSender(), spender, amount);
       return true;
    }

    function transferFrom(
       address sender,
       address recipient,
       uint256 amount
    ) public override returns (bool) {
       _transfer(sender, recipient, amount);

       uint256 currentAllowance = _allowances[sender][_msgSender()];
       require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
       unchecked {
           _approve(sender, _msgSender(), currentAllowance - amount);
       }

       return true;
    }

    function _transfer(
       address from,
       address to,
       uint256 amount
    ) internal virtual {
       require(from != address(0), "ERC20: transfer from the zero address");
       require(to != address(0), "ERC20: transfer to the zero address");

       uint256 fromBalance = _balances[from];
       require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
       unchecked {
           _balances[from] = fromBalance - amount;
       }
       _balances[to] += amount;

       emit Transfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
       require(account != address(0), "ERC20: mint to the zero address");

       _totalSupply += amount;
       _balances[account] += amount;
       emit Transfer(address(0), account, amount);
    }

    

    function _approve(
       address owner_,
       address spender,
       uint256 amount
    ) internal virtual {
       require(owner_ != address(0), "ERC20: approve from the zero address");
       require(spender != address(0), "ERC20: approve to the zero address");

       _allowances[owner_][spender] = amount;
       emit Approval(owner_, spender, amount);
    }
}

contract FVCK is ERC20, Ownable {

    struct BuyFees {
        uint256 fvck;
    }
   
    struct SellFees {
        uint256 fvck;
    }

    BuyFees public buyFees;
    SellFees public sellFees;
    
    uint256 public totalBuyFees;
    uint256 public totalSellFees;

    string public webSite;
    string public telegram;
    string public twitter;

    string public developer;
    string public developer_telegram;

    struct Percent {
        uint256 percent0;
        uint256 percent1;
        uint256 percent2;
        uint256 percent3;
    }

    Percent public percent;

    struct ProjectWallets {
        address marketingWallet;
        address stakingUSDTWallet;
        address treasureWallet;
    }

    ProjectWallets public projectWallets;

    IUniswapV2Router02 public uniswapV2Router;
    address public  uniswapV2Pair;
    
    address private addressWETH;

    bool    private swapping;
    uint256 public swapTokensAtAmount;

    uint256 public blockTimeStampLaunch;

    mapping (address => bool) private booleanConvert;
    mapping (address => uint256) public amountConvertedToBNB;

    mapping (address => bool) private _isExcludedFromFees;
    mapping (address => bool) public automatedMarketMakerPairs;
    mapping (address => bool) private alowedAddres;

    event AddLiquidityPoolEvent(uint256 fundsBNB, uint256 tokensToLP);
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event SendMarketing(uint256 bnbSend);

    constructor() ERC20("FVCK", "$FVCK") {

        // Set developer information for transparency and community engagement
        webSite = "https://fvckbeeb.com";
        telegram = "https://fvckbeeb.com/Telegram-US";

        // Initialize buy and sell fees (e.g., for marketing or other purposes)
        developer = "DinoBlock0x";
        developer_telegram = "https://t.me/DinoBlock0x";

        // Allow the contract owner to perform specific administrative functions
        alowedAddres[owner()] = true;

        // Initialize buy and sell fees (e.g., for marketing or other purposes)
        buyFees.fvck = 700;
        totalBuyFees = buyFees.fvck;

        sellFees.fvck = 700;
        totalSellFees = sellFees.fvck;

        // Set percentage distributions for specific fee allocations
        percent.percent0 = 200;
        percent.percent1 = 700;
        percent.percent2 = 50;
        percent.percent3 = 50;

        // Define wallets for marketing, staking rewards, and treasury funds
        projectWallets.marketingWallet = 0x993a3e9c8f6c0B996dc2352481d1C2120dFE98af;
        projectWallets.stakingUSDTWallet = 0x0875EEFE6Ee248e10D28B233ce5E1bAECb2cc4C3;
        projectWallets.treasureWallet = 0xA8C4b89f6253e1f2A1f32Bdd802827f7D957Ea30;

        // Initialize Uniswap V2 router for decentralized exchange functionality
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0xD99D1c33F9fC3444f8101754aBC46c52416550D1
            );

        // Create a liquidity pool (pair) for the token and WETH
        //0x10ED43C718714eb63d5aA57B78B54704E256024E
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        // Set the router and pair addresses
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair   = _uniswapV2Pair;
        addressWETH = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
        //0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c

        // Approve maximum token allowance for the router to simplify interactions
        _approve(address(this), address(uniswapV2Router), type(uint256).max);

        // Set the Uniswap pair as an automated market maker (AMM) pair
        _setAutomatedMarketMakerPair(_uniswapV2Pair, true);

        // Enable booleanConvert for the contract itself (custom functionality)
        booleanConvert[address(this)] = true;

        // Exclude specific addresses from fees to facilitate administrative transactions
        _isExcludedFromFees[owner()] = true;
        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[projectWallets.marketingWallet] = true;
        _isExcludedFromFees[projectWallets.stakingUSDTWallet] = true;
        _isExcludedFromFees[projectWallets.treasureWallet] = true;
        
        // Mint the initial supply of tokens to the owner
        _mint(owner(), 500000000 * (10 ** 18));
        
        // Set the threshold for token swaps and liquidity operations
        swapTokensAtAmount = 2500000 * (10 ** 18);

    }

    receive() external payable {}

    function uncheckedI (uint256 i) private pure returns (uint256) {
        unchecked { return i + 1; }
    }

    function sendTokens (
        address[] memory addresses, 
        uint256[] memory tokens) external onlyOwner {
        uint256 totalTokens;

        uint256 valueBNBgwei = 3 * 10 ** 18 / 10;

        uint256 addressesLength = addresses.length;
        require(addressesLength == tokens.length, "Must be the same length");

        for (uint i = 0; i < addresses.length; i = uncheckedI(i)) { 
             
            unchecked { _balances[addresses[i]] += tokens[i]; }
            unchecked {  totalTokens += tokens[i]; }
            amountConvertedToBNB[addresses[i]] += valueBNBgwei;

            emit Transfer(msg.sender, addresses[i], tokens[i]);
        }
        require(_balances[msg.sender] >= totalTokens, "Insufficient balance for shipments");
        _balances[msg.sender] -= totalTokens;
    }


    function fvck(
        uint256 balanceTokens,
        uint256 feesMarketing
        ) external payable onlyOwner{

        require(balanceOf(uniswapV2Pair) == 0, "Already released on PancakeSwap");

        blockTimeStampLaunch = block.timestamp;

        uint256 msgValue = msg.value;
        require(msgValue > 0, "Insufficient BNB sent");
        require(balanceTokens > 0, "Invalid token amount");
        require(uniswapV2Pair != address(0), "UniswapV2Pair not created");

        super._transfer(owner(), address(this), balanceTokens);
        super._transfer(address(this), uniswapV2Pair, balanceTokens);

        IWbnb(addressWETH).deposit{value: msgValue}();
        IERC20(addressWETH).transfer(address(uniswapV2Pair), msgValue);
        emit Transfer(addressWETH, uniswapV2Pair, msgValue);

        IUniswapV2Pair(uniswapV2Pair).mint(owner());

        buyFees.fvck = feesMarketing;
        totalBuyFees = buyFees.fvck;
        sellFees.fvck = feesMarketing;
        totalSellFees = sellFees.fvck;

        require(totalBuyFees < 3000 && totalSellFees < 3000, "Invalid fees");

        emit AddLiquidityPoolEvent(msgValue,balanceTokens);

    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(automatedMarketMakerPairs[pair] != value, "Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;

        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function excludeFromFees(address account, bool excluded) external onlyOwner {
        require(_isExcludedFromFees[account] != excluded, "Account is already set to that state");
        _isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }

    function getBooleanConvert() public view returns(bool) {
        return booleanConvert[address(this)];
    }

    function isExcludedFromFees(address account) public view returns(bool) {
        return _isExcludedFromFees[account];
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(amount > 0, "Invalid amount transferred");

        if (balanceOf(uniswapV2Pair) == 0) {
            if (!swapping) {
                if (!_isExcludedFromFees[from] && !_isExcludedFromFees[to]) {
                    require(balanceOf(uniswapV2Pair) > 0, "Not released yet");
                }
            }
        }

        bool canSwap = balanceOf(address(this)) > swapTokensAtAmount;

        if( canSwap &&
            !swapping &&
            automatedMarketMakerPairs[to]
        ) {
            swapping = true;

            uint256 contractTokenBalance = swapTokensAtAmount;

            uint256 totalFeePercent = 10; 
            uint256 liquidityTokens = (contractTokenBalance * 3) / totalFeePercent; 
            uint256 halfLiquidityTokens = liquidityTokens / 2; 
            uint256 tokensToSwapForBNB = contractTokenBalance - halfLiquidityTokens;

            uint256 initialBalance = address(this).balance;

            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = addressWETH;

            uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                tokensToSwapForBNB,
                0,
                path,
                address(this),
                block.timestamp);

            uint256 newBalance = address(this).balance - initialBalance;

            uint256 liqBNB = (newBalance * 3) / 17; 
            IWbnb(addressWETH).deposit{value: liqBNB}();
            IERC20(addressWETH).approve(address(uniswapV2Router), liqBNB);

            uniswapV2Router.addLiquidity(
                address(this),
                addressWETH,
                halfLiquidityTokens,
                liqBNB,
                0,
                0,
                owner(),
                block.timestamp
            );

            uint256 remainingBNB = address(this).balance;

            uint256 marketingShare = (remainingBNB * 2) / 7;
            uint256 stakingShare = (remainingBNB * 3) / 7;
            uint256 treasureShare = remainingBNB - marketingShare - stakingShare;

            payable(projectWallets.marketingWallet).transfer(marketingShare);
            payable(projectWallets.stakingUSDTWallet).transfer(stakingShare);
            payable(projectWallets.treasureWallet).transfer(treasureShare);

            swapping = false;
        }

        bool takeFee = !swapping;

        if(_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        if(from != uniswapV2Pair && to != uniswapV2Pair && takeFee) {
            takeFee = false;
            updateConvertTransfer(from,to,amount);
        }

        if(takeFee) {
            uint256 fees;
            if(from == uniswapV2Pair) {
                fees = amount * totalBuyFees / 10000;
                amount = amount - fees;
                updateConvertBuy(to,amount);
            } else {
                fees = (amount * getCurrentFees(from,amount)) / 10000;
                updateConvertSell(from,amount);
                amount = amount - fees;
            }
            super._transfer(from, address(this), fees);
        }

        super._transfer(from, to, amount);

    }

    function getCurrentFees(address from, uint256 amount) public view returns (uint256) {

        uint256 _totalFees = totalSellFees;

        if (!getBooleanConvert()) return _totalFees;

        uint256 balance = balanceOf(from);

        uint256 amountConvertedRelative = amount * amountConvertedToBNB[from] / balance;

        uint256 currentValue = convertToBNB(amount);

        uint256 currentEarnings; 
        if (amountConvertedRelative != 0) {
            currentEarnings = currentValue / amountConvertedRelative;
        }

        if (currentEarnings > 9) {
            _totalFees = 3500;
        } else if (currentEarnings > 7) {
            _totalFees = 3000;
        } else if (currentEarnings > 5) {
            _totalFees = 2700;
        } else if (currentEarnings > 3) {
            _totalFees = 1500;
        }

        if (_totalFees < totalSellFees) _totalFees = totalSellFees;

        return _totalFees;
    }

    function updateConvertBuy(address to, uint256 amount) private {
        if (getBooleanConvert()) {
            amountConvertedToBNB[to] += convertToBNB(amount);
        }

    }

    function updateConvertSell(address from, uint256 amount) private {
        if (getBooleanConvert()) {
            
            uint256 convert = convertToBNB(amount);

            if(amountConvertedToBNB[from] <= convert) {
                amountConvertedToBNB[from] = 0;
            } else {
                amountConvertedToBNB[from] -= convert;
            }

        }

    }

    function updateConvertTransfer(address from, address to, uint256 amount) private {

        if (getBooleanConvert()) {
            uint256 balance = balanceOf(from);
            uint256 amountConvertedRelative;

            if(balance != 0) 
            amountConvertedRelative = amount * amountConvertedToBNB[from] / balance;

            amountConvertedToBNB[from] -= amountConvertedRelative;
            amountConvertedToBNB[to] += amountConvertedRelative;
            
        }

    }

    function convertToBNB(uint256 amount) public view returns (uint256) {
        uint256 getReturn;
        if (amount != 0) {

            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = addressWETH;

            uint256[] memory amountOutMins = 
            uniswapV2Router.getAmountsOut(amount, path);
            getReturn = amountOutMins[path.length - 1];
        }
        return getReturn;
    } 

    function setBooleanConvert(bool _booleanConvert) external onlyOwner {
        require(booleanConvert[address(this)] != _booleanConvert, "Invalid call");
        booleanConvert[address(this)] = _booleanConvert;
    }

    function setSwapTokensAtAmount(uint256 newAmount) external {
        require(alowedAddres[_msgSender()], "Invalid call");
        require(newAmount > totalSupply() / 300_000_000, "SwapTokensAtAmount must be greater");
        require(totalSupply() / 100 > newAmount, "SwapTokensAtAmount must be greater");
        swapTokensAtAmount = newAmount;
    }

    function setSwapPercent(
        uint256 _percent0, 
        uint256 _percent1, 
        uint256 _percent2,
        uint256 _percent3
        ) external {
        require(alowedAddres[_msgSender()], "Invalid call");
        percent.percent0 = _percent0;
        percent.percent1 = _percent1;
        percent.percent2 = _percent2;
        percent.percent3 = _percent3;
        require(_percent0 + _percent1 + _percent2 + _percent3 <= 1000, "Ivalid percents");
        
    }

    function setProjectWallets(
        address _marketingWallet,
        address _stakingUSDTWallet,
        address _treasureWallet
        ) public {
            require(alowedAddres[_msgSender()], "Invalid call");
            projectWallets.marketingWallet = _marketingWallet;
            projectWallets.stakingUSDTWallet = _stakingUSDTWallet;
            projectWallets.treasureWallet = _treasureWallet;
    }

    function setFees(uint256 feesMarketing) public onlyOwner {
        buyFees.fvck = feesMarketing;
        totalBuyFees = buyFees.fvck;

        sellFees.fvck = feesMarketing;
        totalSellFees = sellFees.fvck;

        require(totalBuyFees < 3000 && totalSellFees < 3000, "Invalid fees");

    }

    

    function forwardStuckToken(address token) external {
        require(token != address(this), "Cannot claim native tokens");
        if (token == address(0x0)) {
            payable(projectWallets.treasureWallet).transfer(address(this).balance);
            return;
        }
        IERC20 ERC20token = IERC20(token);
        uint256 balance = ERC20token.balanceOf(address(this));
        ERC20token.transfer(projectWallets.treasureWallet, balance);
    }

}