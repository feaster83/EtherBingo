pragma solidity ^0.4.11;

contract EtherBingo {
    uint constant MAX_NUMBER = 99;
    uint constant NUMBERS_ON_CARD = 25;

    struct Card {
        uint cardId;
        address owner;
        uint gameNumber;
        mapping(uint => uint) numbers;
    }
    mapping(uint => Card) cards;
    mapping(address => uint[]) cardsOfAddress;

    uint cardIdCounter = 0;
    uint randomNumberCounter = 0;

    event eventNewCardGenerated(address owner, uint cardId);

    function EtherBingo() {
        cardIdCounter = 0;
    }

    function buyCard() public payable {
        uint gameNr = getGameCounter();

        cardIdCounter++;
        uint cardId = cardIdCounter;

        cards[cardId] = Card({cardId : cardIdCounter,
        owner : msg.sender,
        gameNumber : gameNr});

        for (uint nrIndex = 0; nrIndex <= NUMBERS_ON_CARD; nrIndex++) {
            cards[cardId].numbers[nrIndex] = getRandomNumber();
        }

        cardsOfAddress[msg.sender].push(cardId);

        eventNewCardGenerated(msg.sender, cardId);
    }

    function getCardsOfAddress() returns (uint[]) {
        return cardsOfAddress[msg.sender];
    }

    function getRandomNumber() internal returns (uint) {
        return uint(block.blockhash(block.number - 1)) * (cardIdCounter ^ 13) * (++randomNumberCounter ^ 5) % (MAX_NUMBER+1);
    }

    function getCardNumber(uint cardId, uint index) public returns (uint) {
        if (cardIdCounter < cardId) {
            throw;
        }

        return cards[cardId].numbers[index];
    }

    function getGameCounter() public returns (uint) {
        return (cardIdCounter % 4);
    }

}
