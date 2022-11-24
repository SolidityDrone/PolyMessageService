## Author
SolidityDrone 

# PolyMessageServiceV1
! Even tho this code functions, it shouldn't be used on production as i'll update this later !<br><br>
PolyMessageServiceV1 is ERC721 contract created to live on Polygon Network and so portable on other EVMs. Its functioning message system that leverages ERC721 to send message either in data from RPC calls, either through visualization of the nft itself (i.e. OpenSea or similar)<br>
The goal is to create a tool to reach out to people on the marketplace by having an nft to act as a mail.<br>
When a message is sent an NFT is minted and its tokenURI function will return a JSON with Base64 encoded svg data.<br>

![image](https://user-images.githubusercontent.com/104315978/203834827-ac9835d1-0a86-4469-9dae-7ab3d511867e.png)

This is a how it looks at testnet.opensea.io 
Notice that every site may have different approaches for svg rendering*

A Message may contain up to 652 characters and can be sent either individually or in batch. <br>
Gas cost increase with the length of the addresses' array*


## Features
 
 - NFT as Message.
 - NFT can be retrieved and displayed as an SVG.
 - Can be sent in batches.
 - Data can be encrypted before being sent.
 - Can get you in touch with people that are not reachable in other ways.
 - Data is stored on Polygon 

## Next features planned
 
 - V2

