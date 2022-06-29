
function basicUISet(item, itemElement, propertyKey) {

    let propertyNameElement = document.createElement("p");
    propertyNameElement.classList.add("PropertyName");

    propertyNameElement.textContent = propertyKey + ":";


    let editElement = document.createElement("input");
    editElement.classList.add("Edit");

    editElement.value = item[propertyKey];

    
    itemElement.appendChild(propertyNameElement);

    itemElement.appendChild(editElement);

}

function listUISet(item, itemElement, propertyKey) {

    let propertyNameElement = document.createElement("p");
    propertyNameElement.classList.add("PropertyName");

    propertyNameElement.textContent = propertyKey + ":";


    let propertyList = item[propertyKey];

    let propertyListElement = document.createElement("div");

    propertyListElement.classList.add("PropertyList");

    for (let propertyInKey in propertyList) {

        let propertyInNameElement = document.createElement("p");
        propertyInNameElement.classList.add("PropertyName");
    
        propertyInNameElement.textContent = propertyInKey + ":";


        let editInElement = document.createElement("input");
        editInElement.classList.add("Edit");
    
        editInElement.value = item[propertyKey][propertyInKey];


        propertyListElement.appendChild(propertyInNameElement);

        propertyListElement.appendChild(editInElement);

    }

    itemElement.appendChild(propertyNameElement);

    itemElement.appendChild(propertyListElement);

}

functionsUI = {

    "basic" : basicUISet,

    "texture" : function (item, itemElement, propertyKey) {

        basicUISet(item, itemElement, propertyKey);

        itemElement.appendChild(document.createElement("br"));

        let imageElement = document.createElement("img");

        imageElement.classList.add("ItemTexture");

        imageElement.src = "data/images/items/" + item["texture"] + ".png";

        itemElement.appendChild(imageElement);

    },

    "stats" : listUISet,
    "explosion" : listUISet,
    "projectile" : listUISet,
    "holdData" : listUISet

}

function resetItemUI(data) {
    
    let items = JSON.parse(data);

    let itemsElement = document.getElementById("Items");

    itemsElement.innerHTML = "";

    for (let itemKey in items) {

        let item = items[itemKey];

        let itemElement = document.createElement("div");
        itemElement.classList.add("Item");

        for (let propertyKey in item) {

            if (propertyKey in functionsUI) {
                
                functionsUI[propertyKey](item, itemElement, propertyKey);

            } else {

                functionsUI["basic"](item, itemElement, propertyKey);

            }

        }

        itemsElement.appendChild(itemElement);

    }

}

function setItems(event) {

    event.preventDefault();

    const file = event.dataTransfer.items[0].getAsFile();

    read = new FileReader();

    read.readAsBinaryString(file);

    read.onloadend = function() {

        resetItemUI(read.result);

    }

}

function dragOverHandler(event) {

    event.preventDefault();

}

