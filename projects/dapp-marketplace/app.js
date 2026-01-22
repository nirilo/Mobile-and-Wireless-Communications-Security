const contractAddress = "";													//contract_address
const contractABI = [];														//ABI

let web3, contract, user;
function statuz(msg) { document.getElementById("statuz").innerText = msg }

// wallet wall.e
async function connectWallet() {
	if (!window.ethereum) return alert("install MetaMask!");

	web3 = new Web3(window.ethereum);
	await window.ethereum.request({ method: "eth_requestAccounts" });
	user = (await web3.eth.getAccounts())[0];
	account.innerText = `🟢🦊 ${user}`;
	contract = new web3.eth.Contract(contractABI, contractAddress);
}

async function listProduct() {
	const name = pName.value.trim();
	const eth = pPrice.value.trim();
	if (!name || !eth) return alert('Enter name and price (ETH)');
	const wei = web3.utils.toWei(eth, 'ether');

	statuz('Listing…');
	await contract.methods.listProduct(name, wei).send({ from: user });
	statuz('Item listed succesfully.');
loadListings();
}

// use #id to buy - init method
async function buyProduct() {
	const id = buyId.value.trim();
	if (!id) return alert("Enter an ID");

	const prod = await contract.methods.getProduct(id).call();
	if (prod.sold) return alert("Already sold or not found");

	statuz("Processing…");
	try {
		await contract.methods.buyProduct(id).send({ from: user, value: prod.price });
		statuz(`✓ bought item ${id}`);
		loadListings();
	} catch {
		console.error(e);
		statuz("✕ buy failed – see console");
	}
}

async function buyRow(id, priceWei) {
	statuz("Processing…");
	try {
		await contract.methods.buyProduct(id).send({ from: user, value: priceWei });
		statuz(`✓ bought item : ${id}`);
		loadListings();
	} catch (e) {
		console.error(e);
		statuz("✕ buy failed – see console");
	}
}

//	items' table
async function loadListings() {
	const tbody = document.getElementById("rows");
	tbody.innerHTML = "";
	const total = await contract.methods.totalProducts().call();

	for (let id = 1; id <= total; id++) {
		const p = await contract.methods.getProduct(id).call();
		if (p.sold) continue;

		const row = `
			<tr>
				<td>${id}</td>
				<td>${p.name}</td>
				<td>${web3.utils.fromWei(p.price, 'ether')} ETH</td>
				<td><button onclick="buyRow(${id}, '${p.price}')">Buy</button></td>	
			</tr>`;
		tbody.insertAdjacentHTML("beforeend", row);
	}
}
