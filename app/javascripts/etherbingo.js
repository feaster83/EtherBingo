// Import the page's CSS. Webpack will know what to do with it.
import "../stylesheets/app.css";

// Import libraries we need.
import { default as Web3} from 'web3';
import { default as contract } from 'truffle-contract'

import etherbingo_artifacts from '../../build/contracts/EtherBingo.json'

var EtherBingo = contract(etherbingo_artifacts);

var accounts;
var account;
var etherBingo;

var CARDTYPE = {
    PLAYER: { value: 0},
    CONTRACT: { value: 1}
};

window.App = {


    start: () => {

        // Bootstrap the MetaCoin abstraction for Use.
        EtherBingo.setProvider(web3.currentProvider);

        // Get the initial account balance so it can be displayed.
        web3.eth.getAccounts((err, accs) => {
            if (err != null) {
                alert("There was an error fetching your accounts.");
                return;
            }

            if (accs.length == 0) {
                alert("Couldn't get any accounts! Make sure your Ethereum client is configured correctly.");
                return;
            }

            accounts = accs;
            account = accounts[0];
        });

        EtherBingo.deployed().then(function(newEtherBingo) {
            etherBingo = newEtherBingo; // set global instance reference to etherBingo

            App.setContractAddress();

            var transfers = etherBingo.eventNewCardGenerated({fromBlock: 0, toBlock: 'latest'});
            transfers.watch(function(error, result) {
                if (result.args.owner == account) {
                    App.getGame(result.args.cardId);
                }
            });

            App.getCardsOfAccount();
        });
    },

    errorHandler: (e) => console.log(e),

    getGame: (cardId) => {
        var games = document.getElementById('games');
        var gameTemplate = document.getElementById("gametemplate");
        var game = gameTemplate.cloneNode(true);

        game.id = "game" + cardId;
        games.insertBefore(game, games.firstChild);

        // Fix this uggly code
        game.getElementsByClassName("bingocardFooter").item(0).childNodes.item(1).innerHTML = "Card: " + cardId;
        game.getElementsByClassName("bingocardFooter").item(1).childNodes.item(1).innerHTML = "Contract card: " + cardId;


        var playerCard = document.getElementById("playerCardTemplate");
        App.getBingoNumbers(CARDTYPE.PLAYER.value, cardId, playerCard);
        playerCard.id = "playercard"+cardId; //Change name of newCard at the end because this makes it visible

        var contractCard = document.getElementById("contractCardTemplate");
        App.getBingoNumbers(CARDTYPE.CONTRACT.value, cardId, contractCard);
        contractCard.id = "contractcard"+cardId; //Change name of newCard at the end because this makes it visible

        setTimeout(function () {
            App.getDrawNumbersForGame(game, cardId);
        }, 1000);

    },

    getBingoNumbers: (cardType, cardId, newCard) => {
        var renderBingoCard = (value) => {
            var cardNumbers = value.valueOf();

            cardNumbers = cardNumbers.sort((a, b) => a - b);

            console.log("Retrieve bingo numbers for card " + cardId + ": " + cardNumbers);

            for (var index in cardNumbers) {
                if (index != 12) {
                    var rowNr = Math.floor(index / 5);
                    var row = newCard.getElementsByClassName("bingocardRow")[rowNr];
                    var cellNumber = index % 5;
                    var cardNumberValue = cardNumbers[index];
                    var targetCell = row.children[cellNumber];

                    targetCell.innerHTML = cardNumberValue
                }
            }

        };

        if (cardType == CARDTYPE.CONTRACT.value) {
            console.log("Request numbers for contract " + cardId);
            etherBingo.getContractCardNumbers.call(cardId, {from: account}).then(renderBingoCard).catch(App.errorHandler);
        } else if (cardType == CARDTYPE.PLAYER.value){
            console.log("Request numbers for player " + cardId);
            etherBingo.getPlayerCardNumbers.call(cardId, {from: account}).then(renderBingoCard).catch(App.errorHandler);
        }
    },

    getDrawNumbersForGame: (gameElement, cardId) => {
        etherBingo.getDrawNumbersForGame.call(cardId, {from: account}).then((value) => {
            var drawNumbersElement = gameElement.children.drawNumbersTemplate;
            drawNumbersElement.id = "drawNumbersBox"+cardId; //Change name of newCard at the end because this makes it visible

            var drawNumbers = value.valueOf();

            console.log("Retrieve draw numbers for card " + cardId + ": " + drawNumbers);

            var playerCard = document.getElementById("playercard"+cardId);
            var contractCard = document.getElementById("contractcard"+cardId);
            var drawNumbersDivElement = drawNumbersElement.children.item(1);
            drawNumbersDivElement.innerHTML = "";

            for (var index in drawNumbers) {
                var drawNumber = drawNumbers[index];
                
                for (var i = 0; i <= 24; i++) {
                    App.markDrawNumber(playerCard, i, drawNumber);
                    App.markDrawNumber(contractCard, i, drawNumber);
                }

                if (index > 0) {
                    drawNumbersDivElement.innerHTML += ", ";
                }
                drawNumbersDivElement.innerHTML += drawNumber;

                // sleep(100);
            }

        }).catch(App.errorHandler);
    },

    markDrawNumber: (card, index, drawNumber) => {
        var rowNr = Math.floor(index / 5);
        var row = card.getElementsByClassName("bingocardRow")[rowNr];
        var cellNumber = index % 5;
        var targetCell = row.children[cellNumber];

        if (targetCell.innerHTML == drawNumber) {
            targetCell.classList.add('drawNumber');
        }
    },

    getCardsOfAccount: () => {
        etherBingo.getCardsOfAddress.call({from: account}).then((value) => {
            var cardsOfAccount = value.valueOf();
            console.log("Cards of account retrieved: " + cardsOfAccount);
            for (var i in cardsOfAccount) {
                App.getGame(cardsOfAccount[i]);
            }
        }).catch(App.errorHandler);
    },

    buyNewCard: () => {
       etherBingo.buyCard({from: account, value: 30000000000}).catch(App.errorHandler);
    },

    setContractAddress() {
        var contractAddress = etherBingo.address;
        var contractLinkElement = document.getElementById("contractlink");
        contractLinkElement.setAttribute("href", "https://etherscan.io/address/" + contractAddress + "#code");
        contractLinkElement.innerHTML = contractAddress;
    }

};


function sleep(milliseconds) {
    var start = new Date().getTime();
    for (var i = 0; i < 1e7; i++) {
        if ((new Date().getTime() - start) > milliseconds){
            break;
        }
    }
}

function insertAfter(newNode, referenceNode) {
    referenceNode.parentNode.insertBefore(newNode, referenceNode.nextSibling);
}


window.addEventListener('load', () => {
  // Checking if Web3 has been injected by the browser (Mist/MetaMask)
  if (typeof web3 !== 'undefined') {
    console.warn("Using web3 detected from external source. If you find that your accounts don't appear or you have 0 MetaCoin, ensure you've configured that source properly. If using MetaMask, see the following link. Feel free to delete this warning. :) http://truffleframework.com/tutorials/truffle-and-metamask")
    // Use Mist/MetaMask's provider
    window.web3 = new Web3(web3.currentProvider);
  } else {
    console.warn("No web3 detected. Falling back to http://localhost:8545. You should remove this fallback when you deploy live, as it's inherently insecure. Consider switching to Metamask for development. More info here: http://truffleframework.com/tutorials/truffle-and-metamask");
    // fallback - use your fallback strategy (local node / hosted node + in-dapp id mgmt / fail)
    window.web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
  }

  App.start();
});
