pragma solidity ^0.4.11;

contract EtherBingo {
    uint constant MIN_NUMBER_ON_CARD = 1;
    uint constant MAX_NUMBER_ON_CARD = 99;
    uint constant NUMBERS_ON_CARD = 25;

    struct Card {
    uint cardId;
    address owner;
    uint gameNumber;
    uint8[25] numbers;
    }
    mapping(uint => Card) cards;
    mapping(address => uint[]) cardsOfAddress;

    uint cardIdCounter = 0;
    uint randomNumberCounter = 0;

    event eventNewCardGenerated(address owner, uint cardId);

    function EtherBingo() {
    }

    function buyCard() public payable {
        uint gameNr = getGameCounter();
        uint cardId = ++cardIdCounter;

        cards[cardId].cardId = cardIdCounter;
        cards[cardId].owner = msg.sender;
        cards[cardId].gameNumber = gameNr;

        for (uint nrIndex = 0; nrIndex < NUMBERS_ON_CARD; nrIndex++) {
            cards[cardId].numbers[nrIndex] = uint8(getRandomNumber(MIN_NUMBER_ON_CARD, MAX_NUMBER_ON_CARD));
        }

        cardsOfAddress[msg.sender].push(cardId);

        eventNewCardGenerated(msg.sender, cardId);
    }

    function getCardsOfAddress() returns (uint[]) {
        return cardsOfAddress[msg.sender];
    }

    function getRandomNumber(uint min, uint max) internal returns (uint) {
        randomNumberCounter++;
        return uint(sha3(randomNumberCounter))%(min+max)-min;
    }

    function getCardNumbers(uint cardId) public returns (uint8[25]) {
        if (cardIdCounter < cardId) {
            throw;
        }

        return cards[cardId].numbers;
    }

    function getGameCounter() public returns (uint) {
        return (cardIdCounter % 4);
    }

}
