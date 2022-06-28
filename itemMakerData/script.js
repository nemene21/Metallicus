
let items = JSON.parse(prompt("items.json"));

let body = document.getElementsByTagName("body")[0];

function basicUISet(item, itemElement, propertyKey) {

    let propertyNameElement = document.createElement("p");
    propertyNameElement.classList.add("PropertyName");

    propertyNameElement.textContent = propertyKey;


    let editElement = document.createElement("input");
    editElement.classList.add("Edit");

    editElement.value = item[propertyKey];

    
    itemElement.appendChild(propertyNameElement);

    itemElement.appendChild(editElement);

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

    }

}

for (let itemKey in items) {

    let item = items[itemKey];

    let itemElement = document.createElement("div");
    itemElement.classList.add("Item");

    for (let propertyKey in item) {

        if (propertyKey in functionsUI) {
            
            functionsUI[propertyKey](item, itemElement, propertyKey)

        } else {

            functionsUI["basic"](item, itemElement, propertyKey)

        }

    }

    body.appendChild(itemElement);

}
