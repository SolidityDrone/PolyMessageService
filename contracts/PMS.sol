//SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol';
import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Base64.sol';
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Strings.sol";
    
contract PmsV1 is ERC721{

    event messageReceived(address indexed from, address indexed to, string indexed content);

    using Strings for uint256;
    using Strings for address;
    uint256 lineLength = 48;
    uint256 pmsCounter;
    constructor()
        ERC721("PolyMsgService", "PMS")
    {
        
    }

    mapping(address => mapping(uint256 => uint256)) internal  messageNumberOf;
    mapping(address => uint256) internal perAddressCounter;
    mapping(uint256 => message) internal messageById;    

    struct message {
        address from;
        address to;
        string content;
      
    }

    /*
    * @Dev  returns 'messageNumberOf[addr][index]'.
    */
    function getMessageNumberOf(address addr, uint256 index) external view virtual returns (uint256){
        return messageNumberOf[addr][index];
    }
    /*
    * @Dev  returns 'messageById[tokenId]'.
    */
    function getMessageById(uint256 tokenId) external view virtual returns (message memory){
        return messageById[tokenId];
    }
    /*
    * @Dev  returns 'perAddressCounter[addr]'.
    */
    function getPerAddressCounter(address addr) external view virtual returns (uint256){
        return perAddressCounter[addr];
    }

    /*
    * @Dev  returns 'pmsCounter'.
    */
    function totalSupply() external view virtual returns (uint256) {
        return pmsCounter;
    }
    /*
    *@Dev  returns an array of the history of messages sent from 'sender' to 'recipient'.
    *      
    */
    function getChatProgressive(address sender, address recipient) external view virtual returns (uint256[] memory){
        uint256[] memory ids = new uint256[](perAddressCounter[sender]);
        for (uint256 i = 1; i < perAddressCounter[sender]+1; i++){
           if (messageById[messageNumberOf[sender][i]].to == recipient){
               ids[i-1] = messageNumberOf[sender][i];
           }
        }
        return ids;
    }
    /*
    * @Dev Send message will call a single istance of '_sendMessage' or revert
    * 
    */
    function SendMessage(address to, string memory content) external payable virtual  {
        require(bytes(content).length < 672, "This message is too big. Max 672 characters");
        require(to != msg.sender, "Can't send message to self");
        require(_sendMessage(msg.sender, to, content), "Token creation reverted");
    }
    /*
    * @Dev  Takes (from, to, content) as parameters and increments perAddressCounter and pmsCounter state variables. 
            Set a struct of type storage message and update its parameters according to the function arguments.
            Then it updates the address related counter to be equal to pms global counter, to match its id.
            Finally calls _safeMintFunction, emits messageReceived and returns success.
    * 
    */
    function _sendMessage(address from, address to, string memory content) internal virtual returns(bool success){
     
        unchecked {
            perAddressCounter[from] +=1;
            pmsCounter +=1; 
        } 
   
        message storage pms = messageById[pmsCounter];
        pms.from = from;
        pms.to = to;
        pms.content = content;
        
        messageNumberOf[from][perAddressCounter[from]] = pmsCounter;

        _safeMint(to, pmsCounter);
        emit messageReceived(from, to, content);
        return true;
    }
       /*
    * @Dev  For each element in a list of address this function will call _sendMessage to any in the list.
    *       This function will revert when any address in the list dosen't implement ERC721 or whether the
    *       _sendMessage function reverts.
    */
    function BatchSendMessage(address[] memory addrs, string memory content) external virtual returns (bool) {
        require(bytes(content).length < 672, "This message is too big. Max 672 characters");
        require(addrs.length < 100, "Max 100 user per batch");
        for (uint i = 0; i < addrs.length; i++){
            require(_sendMessage(msg.sender, addrs[i], content), "One or more messages has failed to arrive, all recipients have to be ERC721 Receiver");
        }
        return true;
    }
    /*
    * @Dev   This function overrides ERC721's tokenURI(uint256) function. Saves a string in memory trough 'svgContent' internal function
    *        Creates a JSON format string which contains parameters name and image. Image is encoded using 'Base64.sol' library.
    *        Therefore the JSON string gets encoded again using 'Base64'. 
    *        
    *        Returns data:application/json;base64, + dataUri
    *       
    *      
    */
    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {   
        bytes memory svgPacked = bytes(abi.encodePacked(svgContent(tokenId)));
        bytes memory dataURI = abi.encodePacked(
            '{',
                '"name": "Message #', tokenId.toString(), '",',
                '"image": "data:image/svg+xml;base64,', Base64.encode(svgPacked),'",',
                '"description": "Visit pms.io"',
            '}'
        );
        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(dataURI)
            )
        );
    }

     /*
    * @Dev   Takes and uint256 to get the bytes of the string returned by 'messageById' mapping.
    *        It then executes computation to arrange lines on the svg and populate them with an array of strings, using substring function.
    *        All these strings are used in the first and second variable, dynamically embeded into an svg-like string
    *        Returns a string with svg-like content.
    *#Notice 
    *        To avoid going too deep in the stack the string is unpacked in four strings and assembled as return of this function.
    *        
    *        
    *       
    *      
    */
    function svgContent(uint256 tokenId) internal view virtual returns (string memory){
        bytes memory content = bytes(messageById[tokenId].content);
        string[] memory lines = new string[](14);
        uint256 nLines = content.length / lineLength; 
        
            for (uint256 i = 0; i < nLines +1; i++){
                lines[i] = substring(messageById[tokenId].content, i*lineLength, content.length);
            }
            for (uint256 i = 0; i < lines.length; i++){
                if (bytes(lines[i]).length > 0 && bytes(lines[i]).length > lineLength ){
                    lines[i] = substring(lines[i], 0, lineLength);
                } 
            }
  
    string memory first = string(abi.encodePacked
        (
            '<svg id="eNSIk2eFiqa1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 360 360" shape-rendering="geometricPrecision" text-rendering="geometricPrecision" style="background-color:rgba(3,0,25,0.84)"><rect width="36" height="36" rx="2" ry="2" transform="matrix(9.77128 0 0 9.77128 4.11701 4.11701)" fill="#ec6352" stroke-width="0"/><rect width="36" height="36.8828" rx="2" ry="2" transform="matrix(9.30323 0 0 7.02557 13.017 90.3781)" fill="#f8c9ac" stroke-width="0"/><rect width="334.916" height="69.9679" rx="18" ry="18" transform="translate(12.5419 12.3785)" fill="#f8c9ac" stroke-width="0"/><text dx="0" dy="0" font-family="&quot;eNSIk2eFiqa1:::Bubblegum Sans&quot;" font-size="11" font-weight="400" transform="translate(75.9322 40.0131)" fill="#a34908" stroke-width="0"><tspan y="0" font-family="&quot;eNSIk2eFiqa1:::Bubblegum Sans&quot;" font-size="11" font-weight="400" font-style="normal" fill="#a34908" stroke-width="0">',
            '<![CDATA[From: ', messageById[tokenId].from.toHexString() ,']]></tspan><tspan x="0" y="11" font-family="&quot;eNSIk2eFiqa1:::Bubblegum Sans&quot;" font-size="11" font-weight="400" font-style="normal" fill="#a34908" stroke-width="0">',
            '<![CDATA[To: ', messageById[tokenId].to.toHexString() ,' ]]></tspan><tspan x="0" y="22" font-family="&quot;eNSIk2eFiqa1:::Bubblegum Sans&quot;" font-size="11" font-weight="400" font-style="normal" fill="#a34908" stroke-width="0">',
            '<![CDATA[Date: ', block.timestamp.toString() ,']]></tspan></text><text dx="0" dy="0" font-family="&quot;eNSIk2eFiqa1:::Bubblegum Sans&quot;" font-size="12" font-weight="300" transform="translate(37.842774 128.247933)" fill="#8c4f05" stroke-width="0"><tspan y="0" font-weight="300" stroke-width="0">',
            '<![CDATA[Body]]></tspan><tspan x="0" y="12" font-weight="300" stroke-width="0">'
        ));
         string memory second = string(abi.encodePacked
        (
            '<![CDATA[',lines[0],']]></tspan><tspan x="0" y="24" font-weight="300" stroke-width="0">',
            '<![CDATA[',lines[1],']]></tspan><tspan x="0" y="36" font-weight="300" stroke-width="0">',
            '<![CDATA[',lines[2],']]></tspan><tspan x="0" y="48" font-weight="300" stroke-width="0">',
            '<![CDATA[',lines[3],']]></tspan><tspan x="0" y="60" font-weight="300" stroke-width="0">',
            '<![CDATA[',lines[4],']]></tspan><tspan x="0" y="72" font-weight="300" stroke-width="0">',
            '<![CDATA[',lines[5],']]></tspan><tspan x="0" y="84" font-weight="300" stroke-width="0">'
        ));
    string memory third = string(abi.encodePacked
        (
            '<![CDATA[',lines[6],']]></tspan><tspan x="0" y="96" font-weight="300" stroke-width="0">',
            '<![CDATA[',lines[7],']]></tspan><tspan x="0" y="108" font-weight="300" stroke-width="0">',
            '<![CDATA[',lines[8],']]></tspan><tspan x="0" y="120" font-weight="300" stroke-width="0">',
            '<![CDATA[',lines[9],']]></tspan><tspan x="0" y="134" font-weight="300" stroke-width="0">',
            '<![CDATA[',lines[10],']]></tspan><tspan x="0" y="146" font-weight="300" stroke-width="0">'
        ));


    string memory fourth = string(abi.encodePacked
        (
            '<![CDATA[',lines[11],']]></tspan><tspan x="0" y="36" font-weight="300" stroke-width="0">',
            '<![CDATA[',lines[12],']]></tspan><tspan x="0" y="36" font-weight="300" stroke-width="0">',
            '<![CDATA[',lines[13],']]></tspan><tspan x="0" y="36" font-weight="300" stroke-width="0">',
            '<![CDATA[]]></tspan></text><text dx="0" dy="0" font-family="&quot;eNSIk2eFiqa1:::Bubblegum Sans&quot;" font-size="10" font-weight="300" transform="translate(37.8428 331.23)" fill="#8c4f05" stroke-width="0"><tspan y="0" font-family="&quot;eNSIk2eFiqa1:::Bubblegum Sans&quot;" font-size="10" font-weight="300" font-style="normal" fill="#8c4f05" stroke-width="0">',
            '<![CDATA[MsgValue: 1000000000000000000]]></tspan></text><rect width="103.531" height="23.2946" rx="11" ry="11" transform="matrix(1.1 0 0 1.22222 228.477 314.477)" fill="#fd8d09" stroke="rgba(56,66,6,0.2)"/><ellipse rx="23.8498" ry="11.5679" transform="matrix(1.04092 0.638498-.711428 1.15982 46.0725 45.551)" fill="#ec6352" stroke-width="0"/><path d="M33.125756,55.115556q.056764,0,.283818-8.173963c-6.002139.016858-12.20124-3.874486-12.162816-7.946909-.408026-6.421434,9.115066-8.563942,17.328307-6.244c2.728235,1.264082,4.806046,7.199339,5.392545,10.988939q.090219.582943,4.086981-10.53483c1.867004-.276791,5.541327-.413346,6.754872,0v9.309236c7.138529-.015754,16.014976,3.843786,16.088779,9.309235.446506,6.813299-12.345185,8.790346-22.04896,7.606327c1.708615-3.078077,1.600901-12.74653.567636-18.788762-3.179898,7.222542-4.351389,10.538707-3.973454,10.330981.111234-.061138-1.759673.964982-2.667891-.170291q-.908218-1.135273-4.200508-11.806835l-.732291,16.802034c-2.103566.183456-2.75859.498453-4.717018-.681162Z" transform="translate(0 0.000001)" fill="#f8c9ac" stroke="rgba(63,87,135,0)" stroke-width="0.72"/><text dx="0" dy="0" font-family="&quot;e6joPQeL0xc1:::Bubblegum Sans&quot;" font-size="14" font-weight="400" transform="translate(241.91 332.353)" fill="#753803" stroke-width="0"><tspan y="0" font-family="&quot;e6joPQeL0xc1:::Bubblegum Sans&quot;" font-size="14" font-weight="400" font-style="normal" fill="#753803" stroke-width="0"><![CDATA[Reply at pms.io!]]></tspan></text><path d="M33.409574,36.052812v7.686812c-3.747791-.101437-7.498124-2.476011-7.50794-4.744939.035917-2.20886,3.571034-3.834515,7.224122-3.1304l.283818.188527Z" fill="#ec6352" stroke="rgba(63,87,135,0)" stroke-width="0.72"/><path d="M54.809463,46.941594l.92752,8.855125c7.928887.007165,9.741836-2.334193,9.3-3.973454-.789302-3.157658-5.853487-5.358118-9.76-4.881671h-.46752" fill="#ec6352" stroke="rgba(63,87,135,0)" stroke-width="0.72"/>',
            '<style><![CDATA[@font-face {font-family:',
            "'eNSIk2eFiqa1:::Bubblegum Sans';font-style: normal;font-weight: 400;src: url(https://fonts.gstatic.com/l/font?kit=AYCSpXb_Z9EORv1M5QTjEzMEtdaH1rbNY4xYACn3Ef4cjgCt5uwQ9dGoZ750dcKMkOgaUm7dv0ycuC2LGg7C9sBNdQfeHKgu&skey=907fcf96211c8e7e&v=v16) format('truetype');}]]></style></svg>"
        ));
             
  
        return string(abi.encodePacked(first,second,third,fourth));
    }
    /*
    * @Dev  Takes a String and given the parametes returns a string with the characters between the interval
    *       Returns the desired string  
    */
    function substring(string memory str, uint startIndex, uint endIndex) internal pure virtual  returns (string memory ) {
        bytes memory strBytes = bytes(str);
        bytes memory result = new bytes(endIndex-startIndex);
            for(uint i = startIndex; i < endIndex; i++) {
                result[i-startIndex] = strBytes[i];
            }
        return string(result);
    }

    
    
}
  