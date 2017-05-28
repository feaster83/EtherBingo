pragma solidity ^0.4.11;

contract EtherBingo {
    struct Card {
        uint gameNumber;
        uint[] numbers;
    }
    Card[] cards;
    uint counter;

    function EtherBingo() {
        counter = 5;
    }

    function buyCard() public returns (uint[]) {
        uint gameNr = cards.length + 1 - (cards.length % 4);
        uint[] memory numbers;
        for (uint nrIndex = 0; nrIndex <= 25; nrIndex++) {
            numbers[nrIndex] = uint(42);
        }
        cards[cards.length] = Card(gameNr, numbers);
        return numbers;
    }

    function getRandomNumber() public returns (uint) {
//        semirandom = uint(block.blockhash(block.number - 1)) * gameStats.gameCounter * (cards.length + 1) % 100;

        return counter++;
    }

    function getGameCounter() public returns (uint) {
        return cards.length;
    }

}
