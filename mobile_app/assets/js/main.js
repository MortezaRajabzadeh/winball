
function getCurrentUserIdFromUrl(tempUrl){
    const decodedUrl=decodeURIComponent(tempUrl);
    const finalDecoded=decodeURIComponent(decodedUrl);
    const splittedFinalDecoded=finalDecoded.split("user=");
    const userDetails=splittedFinalDecoded[splittedFinalDecoded.length-1];
    const userId=userDetails.split(",")[0];
    const currentUserIdString=userId.split(":")[1];
    return currentUserIdString;
}
function getInvitationCodeFromUrl(tempUrl){
        const decodedUrl=decodeURIComponent(tempUrl);
        const finalDecoded=decodeURIComponent(decodedUrl);
        const splittedUrl=finalDecoded.split("&");
        var invitationCodeString="";
        for(var i=0;i<splittedUrl.length;i++){
            const paramIndex=splittedUrl[i].indexOf('start_param');
            if(paramIndex!==-1){
                invitationCodeString=splittedUrl[i];
                break;
            }
        }
        if (invitationCodeString!==""){
            const invitationCodeArray=invitationCodeString.split("=");
            const invitationCode=invitationCodeArray[invitationCodeArray.length-1];
            return invitationCode;
        }
        return "";
}
async function initialize(){
    const currentUrl=window.location.href;
    const invitationCode=getInvitationCodeFromUrl(currentUrl);
    if(invitationCode!==""){
        console.log(invitationCode);
        const currentUser=getCurrentUserIdFromUrl(currentUrl);
          await fetch("https://back.winball.xyz/create-invitation",{
            method:"POST",
            body: JSON.stringify({
               "invited_id":currentUser,
               "invitation_code":invitationCode,
            }),
            // Adding headers to the request
            headers: {
                "Content-type": "application/json; charset=UTF-8",
                "Accept":"application/json; charset=UTF-8",
            }
        }) 
    }
}
window.onload=()=>{
    initialize();
};

