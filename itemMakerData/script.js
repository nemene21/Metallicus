
let boolConvert = {

    "true" : true, "false" : false

}

function basicUISet(itemKey, item, itemElement, propertyKey) {

    let propertyNameElement = document.createElement("p");
    propertyNameElement.classList.add("PropertyName");

    propertyNameElement.textContent = propertyKey + ":";


    let editElement = document.createElement("input");
    editElement.classList.add("Edit");

    editElement.value = item[propertyKey];

    editElement.index = propertyKey

    
    itemElement.appendChild(propertyNameElement);

    itemElement.appendChild(editElement);

}

function listUISet(itemKey, item, itemElement, propertyKey) {

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

        editInElement.index = propertyKey + "," + propertyInKey


        propertyListElement.appendChild(propertyInNameElement);

        propertyListElement.appendChild(editInElement);

    }

    itemElement.appendChild(propertyNameElement);

    itemElement.appendChild(propertyListElement);

}

functionsUI = {

    "basic" : basicUISet,

    "texture" : function (itemKey, item, itemElement, propertyKey) {

        basicUISet(itemKey, item, itemElement, propertyKey);

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

        itemElement.name = itemKey;

        for (let propertyKey in item) {

            if (propertyKey in functionsUI) {
                
                functionsUI[propertyKey](itemKey, item, itemElement, propertyKey);

            } else {

                functionsUI["basic"](itemKey, item, itemElement, propertyKey);

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

function download(filename, text) {

    var element = document.createElement('a');

    element.setAttribute('href', 'data:text/plain;charset=utf-8,' + encodeURIComponent(text));
    element.setAttribute('download', filename);
  
    element.style.display = 'none';
    document.body.appendChild(element);
  
    element.click();
  
    document.body.removeChild(element);
}

listProperties = {

    "types" : true

}

function downloadItemsFile() {

    let items = {};

    let itemElements = document.getElementsByClassName("Item");

    for (let elementId = 0; elementId < itemElements.length; elementId++) {

        let itemElement = itemElements[elementId];

        let itemKey = itemElement.name;

        items[itemKey] = {};

        let properties = itemElement.getElementsByClassName("Edit");

        for (let propertyId = 0; propertyId < properties.length; propertyId++) {

            let property = properties[propertyId];

            let location = property.index.split(",");

            let value = property.value;

            if (location[0] in listProperties) {

                value = value.split(",");

            }

            if (!isNaN(value)) {

                value = Number(value);

            }

            if (value == "true" || value == "false") {

                value = boolConvert[value];

            }

            if (location.length == 1) {

                items[itemKey][location[0]] = value;

            } else {

                if (location[0] in items[itemKey]) {

                    items[itemKey][location[0]][location[1]] = value;
            
                } else {

                    items[itemKey][location[0]] = {};
                    items[itemKey][location[0]][location[1]] = value;

                }

            }
            
        }

    }

    let jsonData = JSON.stringify(items, null, 4)

    let splitJson = jsonData.split("\n");

    let newTabContent = ""

    for (let id = 0; id < splitJson.length; id++) {

        newTabContent += "<pre>" + splitJson[id] + "</pre>";

    }

    let tab = window.open('about:blank', '_blank');

    tab.document.write(newTabContent);
    tab.document.close();

    // download("newItemData.json", jsonData);

}

fetch("data/items.json")
  .then(response => response.json())
  .then(data => resetItemUI(data));

