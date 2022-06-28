
let items = JSON.parse(prompt("items.json"));

let body = document.getElementsByTagName("body")[0];

for (let itemKey in items) {

    let item = items[itemKey];

    let itemElement = document.createElement("div");
    itemElement.classList.add("Item");

    for (let propertyKey in item) {

        let propertyNameElement = document.createElement("p");
        propertyNameElement.classList.add("PropertyName");

        propertyNameElement.textContent = propertyKey;


        let editElement = document.createElement("input");
        editElement.classList.add("Edit");

        editElement.value = item[propertyKey];

        
        itemElement.appendChild(propertyNameElement);

        itemElement.appendChild(editElement);

    }

    body.appendChild(itemElement);

}
