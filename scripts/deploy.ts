import { ethers } from 'hardhat';
import { run } from 'hardhat';

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log('Mendeploy kontrak dengan akun:', deployer.address);

  const KostNFT = await ethers.getContractFactory('KostNFT');
  const NFTMarketplace = await ethers.getContractFactory('NFTMarketplace');

  // Deploy KostNFT
  const kostNFT = await KostNFT.deploy();
  await kostNFT.deployed();
  console.log('KostNFT berhasil didaftarkan ke alamat:', kostNFT.address);

  // Deploy NFTMarketplace, berikan alamat KostNFT dan alamat USDT ke constructor
  const nftMarketplace = await NFTMarketplace.deploy(kostNFT.address, '<ALAMAT_KONTRAK_USDT>');
  await nftMarketplace.deployed();
  console.log('NFTMarketplace berhasil didaftarkan ke alamat:', nftMarketplace.address);

  // Set alamat marketplace di kontrak KostNFT
  await kostNFT.setMarketplaceAddress(nftMarketplace.address);

  // Mint NFTs (Anda dapat menyesuaikan bagian ini sesuai kebutuhan Anda)
  for (let i = 0; i < 5; i++) {
    await nftMarketplace.mintNFT(deployer.address);
  }

  // Distribusi pendapatan (Anda dapat menyesuaikan bagian ini sesuai kebutuhan Anda)
  await nftMarketplace.distributeIncome(1000);

  // Melakukan tindakan lain yang dibutuhkan...

  // Jika Anda perlu memverifikasi kontrak, Anda dapat menggunakan plugin Hardhat Etherscan
  await run('verify:verify', {
    address: kostNFT.address,
    constructorArguments: [],
  });

  await run('verify:verify', {
    address: nftMarketplace.address,
    constructorArguments: [kostNFT.address, '<ALAMAT_KONTRAK_USDT>'],
  });
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
