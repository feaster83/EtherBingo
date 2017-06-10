pragma solidity ^0.4.11;

contract EtherBingo {
    uint constant MIN_NUMBER_ON_CARD = 1;
    uint constant MAX_NUMBER_ON_CARD = 99;
    uint constant NUMBERS_ON_CARD = 25;

    address contractOwner;

    struct Card {
        uint cardId;
        uint8[25] numbers;
    }

    mapping(uint => Card) playerCards;
    mapping(uint => Card) contractCards;
    mapping(address => uint[]) cardsOfAddress;
    mapping(uint => uint8[40]) drawNumbersForGame;

    uint cardIdCounter = 0;
    uint randomNumberCounter = 0;
    uint256 priceBingoCard = 1;

    event eventNewCardGenerated(address owner, uint cardId);

    function EtherBingo() {
        contractOwner = msg.sender;
    }

    function setBingoCardPrice(uint256 newPrice) {
        if (msg.sender != contractOwner)
            throw;

        priceBingoCard = newPrice;
    }

    function buyCard() public payable {
        handlePayment();

        uint cardId = ++cardIdCounter;

        // Generate card for player
        playerCards[cardId] = generateCard();
        cardsOfAddress[msg.sender].push(cardId);

        // Generate card for contract (opponent)
        contractCards[cardId] = generateCard();

        generateDrawNumbersForGame(cardId);

        eventNewCardGenerated(msg.sender, cardId);
    }


    function generateCard() internal returns (Card card) {
        card.cardId = cardIdCounter;

        bool[99] memory pool;
        for (uint nrIndex = 0; nrIndex < NUMBERS_ON_CARD; nrIndex++) {
            card.numbers[nrIndex] = uint8(getRandomNumber(MIN_NUMBER_ON_CARD, MAX_NUMBER_ON_CARD, pool));
        }

        return card;
    }

    function generateDrawNumbersForGame(uint cardId) internal {
        bool[99] memory pool;
        for (uint i = 0; i < 40; i++) {
            drawNumbersForGame[cardId][i] = uint8(getRandomNumber(MIN_NUMBER_ON_CARD, MAX_NUMBER_ON_CARD, pool));
        }
    }

    function handlePayment() internal {
        if (msg.value < priceBingoCard)
            throw;

        if (msg.value > priceBingoCard) {
            msg.sender.transfer(msg.value - priceBingoCard);
        }
    }

    function getCardsOfAddress() returns (uint[]) {
        return cardsOfAddress[msg.sender];
    }

    function getRandomNumber(uint min, uint max, bool[99] pool) internal returns (uint) {
        bool uniqueNumberFound = false;
        uint randomNumber;
        while (!uniqueNumberFound) {
            randomNumber = uint(sha3(randomNumberCounter++))%(min+max)-min;
            if(pool[randomNumber] == false) {
                pool[randomNumber] = true;
                uniqueNumberFound = true;
            }
        }
        return randomNumber;
    }

    function getPlayerCardNumbers(uint cardId) public returns (uint8[25]) {
        if (cardIdCounter < cardId) {
            throw;
        }
        return playerCards[cardId].numbers;
    }

    function getContractCardNumbers(uint cardId) public returns (uint8[25]) {
        if (cardIdCounter < cardId) {
            throw;
        }
        return contractCards[cardId].numbers;
    }

    function getDrawNumbersForGame(uint cardId) public returns (uint8[40]) {
        if (cardIdCounter < cardId) {
            throw;
        }
        return drawNumbersForGame[cardId];
    }

}
